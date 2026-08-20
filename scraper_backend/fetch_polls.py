"""
Backend data job for the PLC Election Tracker app.

Runs on a schedule (see .github/workflows/update-data.yml), fetches the
latest published PCPSR poll release, and writes data/fetched_data.json in
the same shape the Flutter app expects (see assets/data/seed_data.json in
the app project for the canonical schema).

WHY THIS RUNS HERE AND NOT ON THE PHONE:
- Android background execution is heavily restricted (Doze, battery
  optimization) — a phone-side scraper would run unreliably at best.
- One scheduled job serving all app users is far more polite to PCPSR's
  servers than every installed app hitting them independently.
- HTML scraping breaks when a site's markup changes. It's much easier to
  monitor and fix one script than to ship an app update to every user.

IMPORTANT CAVEAT:
PCPSR publishes poll results as prose press releases, not structured
data (no public API). The regex-based extraction below is a best-effort
starting point — it WILL misparse some releases (e.g. if a percentage
for a different question gets matched instead of the legislative vote
question). Treat its output as a draft: the recommended workflow is for
a human to glance at data/fetched_data.json in the pull request this
workflow can optionally open, before it goes live in the app.
"""

import json
import re
import sys
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urljoin

import requests
from bs4 import BeautifulSoup

PCPSR_INDEX_URL = "https://pcpsr.org/en/index.php?page=1&CategoryId=6"
CEC_2026_URL = "https://www.elections.ps/tabid/1313/language/en-US/Default.aspx"
OUTPUT_PATH = Path(__file__).parent.parent / "data" / "fetched_data.json"
SEED_PATH = Path(__file__).parent.parent / "assets" / "data" / "seed_data.json"

HEADERS = {"User-Agent": "Mozilla/5.0 (compatible; ElectionTrackerBot/1.0; +https://example.com/about)"}


def fetch_latest_release_url() -> str | None:
    """Find the most recent press-release link on the PCPSR polls index page."""
    resp = requests.get(PCPSR_INDEX_URL, headers=HEADERS, timeout=20)
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, "html.parser")
    # PCPSR release links are typically /en/node/<id> — adjust this selector
    # if their site structure changes.
    link = soup.select_one("a[href*='/en/node/']")
    if not link:
        return None
    href = link.get("href", "")
    return urljoin("https://pcpsr.org", href)


def first_number(pattern: str, text: str) -> float | None:
    match = re.search(pattern, text, flags=re.IGNORECASE)
    if not match:
        return None
    return float(match.group(1))


def extract_vote_shares(release_text: str) -> dict:
    """
    Best-effort regex extraction of Fatah/Hamas legislative vote share
    from a PCPSR press release's prose. Returns an empty dict if it can't
    find a confident match — callers should fall back to the last known
    good value rather than publish a bad parse.
    """
    result = {}
    text = re.sub(r"\s+", " ", release_text)

    national = re.search(
        r"Among those who would participate,\s*Fatah would receive\s*(\d{1,2}(?:\.\d+)?)%.*?"
        r"Hamas.*?with\s*(\d{1,2}(?:\.\d+)?)%.*?"
        r"third parties combined with\s*(\d{1,2}(?:\.\d+)?)%.*?"
        r"(\d{1,2}(?:\.\d+)?)%\s*have not yet decided",
        text,
        flags=re.IGNORECASE,
    )
    if national:
        result["fatah_pct"] = float(national.group(1))
        result["hamas_pct"] = float(national.group(2))
        result["third_parties_pct"] = float(national.group(3))
        result["undecided_pct"] = float(national.group(4))

    gaza = re.search(
        r"In Gaza,\s*Hamas would receive\s*(\d{1,2}(?:\.\d+)?)%.*?"
        r"Fatah\s*(\d{1,2}(?:\.\d+)?)%.*?"
        r"third parties\s*(\d{1,2}(?:\.\d+)?)%.*?"
        r"(\d{1,2}(?:\.\d+)?)%\s*remain undecided",
        text,
        flags=re.IGNORECASE,
    )
    if gaza:
        result["gaza_subsample"] = {
            "hamas_pct": float(gaza.group(1)),
            "fatah_pct": float(gaza.group(2)),
            "third_parties_pct": float(gaza.group(3)),
            "undecided_pct": float(gaza.group(4)),
        }

    west_bank = re.search(
        r"In the West Bank,\s*(\d{1,2}(?:\.\d+)?)%.*?Fatah,\s*"
        r"(\d{1,2}(?:\.\d+)?)%.*?Hamas,\s*"
        r"(\d{1,2}(?:\.\d+)?)%.*?third parties.*?"
        r"(\d{1,2}(?:\.\d+)?)%\s*remain undecided",
        text,
        flags=re.IGNORECASE,
    )
    if west_bank:
        result["west_bank_subsample"] = {
            "fatah_pct": float(west_bank.group(1)),
            "hamas_pct": float(west_bank.group(2)),
            "third_parties_pct": float(west_bank.group(3)),
            "undecided_pct": float(west_bank.group(4)),
        }

    turnout = first_number(r"turnout would be\s*(\d{1,2}(?:\.\d+)?)%", text)
    if turnout is not None:
        result["likely_turnout_pct"] = turnout

    return result


def enrich_from_cec(dataset: dict) -> None:
    """Add current CEC election-timeline metadata when the page is reachable."""
    resp = requests.get(CEC_2026_URL, headers=HEADERS, timeout=20)
    resp.raise_for_status()
    text = BeautifulSoup(resp.text, "html.parser").get_text(" ", strip=True)
    voters = re.search(r"([\d,]+)\s+Registered voters until", text)
    if voters:
        dataset.setdefault("election_administration", {})["registered_voters"] = int(voters.group(1).replace(",", ""))
    dataset.setdefault("election_administration", {})["source_url"] = CEC_2026_URL
    dataset.setdefault("election_administration", {})["organizing_body"] = "Central Elections Commission - Palestine"


def fetch_news_signals(sources: list[dict]) -> list[dict]:
    """Fetch only parseable RSS headlines; never infer vote shares from news."""
    signals = []
    for feed in sources:
        try:
            resp = requests.get(feed["feed_url"], headers=HEADERS, timeout=20)
            resp.raise_for_status()
            root = ET.fromstring(resp.content)
            for item in root.findall(".//item")[:5]:
                title = (item.findtext("title") or "").strip()
                link = (item.findtext("link") or "").strip()
                published = (item.findtext("pubDate") or "").strip()
                if not title or not link:
                    continue
                signals.append(
                    {
                        "source": feed["name"],
                        "source_type": feed.get("type", "news"),
                        "title": title,
                        "url": link,
                        "published_at": published,
                        "category": feed.get("news_category", "general"),
                        "impact_score": 0,
                        "summary": "Headline captured from a public feed. Human review is required before it affects model risk.",
                    }
                )
        except (requests.RequestException, ET.ParseError) as e:
            print(f"News feed failed for {feed['name']}, keeping prior signals: {e}", file=sys.stderr)
    return signals


def build_dataset() -> dict:
    # Start from the seed file so unchanged fields (2006 result, local
    # elections, coalition reporting) carry forward — this script's job
    # is primarily to refresh latest_national_poll and generated_at.
    with open(SEED_PATH, "r", encoding="utf-8") as f:
        dataset = json.load(f)

    try:
        release_url = fetch_latest_release_url()
        if release_url:
            resp = requests.get(release_url, headers=HEADERS, timeout=20)
            resp.raise_for_status()
            soup = BeautifulSoup(resp.text, "html.parser")
            text = soup.get_text(" ", strip=True)
            shares = extract_vote_shares(text)

            if "fatah_pct" in shares and "hamas_pct" in shares:
                dataset["latest_national_poll"]["fatah_pct"] = shares["fatah_pct"]
                dataset["latest_national_poll"]["hamas_pct"] = shares["hamas_pct"]
                dataset["latest_national_poll"]["third_parties_pct"] = shares.get("third_parties_pct", 0)
                dataset["latest_national_poll"]["undecided_pct"] = shares.get(
                    "undecided_pct",
                    round(100 - shares["fatah_pct"] - shares["hamas_pct"] - shares.get("third_parties_pct", 0), 1),
                )
                dataset["latest_national_poll"]["other_undecided_pct"] = round(
                    dataset["latest_national_poll"]["third_parties_pct"]
                    + dataset["latest_national_poll"]["undecided_pct"],
                    1,
                )
                dataset["latest_national_poll"]["likely_turnout_pct"] = shares.get(
                    "likely_turnout_pct", dataset["latest_national_poll"].get("likely_turnout_pct", 0)
                )
                for key in ("gaza_subsample", "west_bank_subsample"):
                    if key in shares:
                        shares[key]["other_undecided_pct"] = round(
                            shares[key]["third_parties_pct"] + shares[key]["undecided_pct"], 1
                        )
                        dataset["latest_national_poll"][key] = shares[key]
                dataset["latest_national_poll"]["source_url"] = release_url
                print(f"Updated poll numbers from {release_url}: {shares}")
            else:
                print(f"Could not confidently parse vote shares from {release_url}; keeping previous values.", file=sys.stderr)
    except requests.RequestException as e:
        print(f"Fetch failed, keeping previous values: {e}", file=sys.stderr)

    try:
        enrich_from_cec(dataset)
    except requests.RequestException as e:
        print(f"CEC fetch failed, keeping previous election administration values: {e}", file=sys.stderr)

    news_sources = [
        source
        for source in dataset.get("public_sources", [])
        if source.get("feed_url")
    ]
    fetched_signals = fetch_news_signals(news_sources)
    if fetched_signals:
        dataset["news_signals"] = fetched_signals

    dataset["data_quality"] = {
        "model_status": "public-data-nowcast",
        "primary_poll_source": "PCPSR",
        "refresh_policy": "scheduled backend refresh plus app launch/resume/manual foreground refresh",
        "precision_note": (
            "Predictions are constrained by sparse public polling, undecided voters, access to Gaza and East Jerusalem, "
            "and whether coalition lists are finalized."
        ),
    }
    dataset["meta"]["generated_at"] = datetime.now(timezone.utc).isoformat()
    return dataset


def main():
    dataset = build_dataset()
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(dataset, f, indent=2, ensure_ascii=False)
    print(f"Wrote {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
