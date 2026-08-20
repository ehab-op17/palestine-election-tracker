# PLC Election Tracker — Flutter app

Tracks the Nov 28, 2026 Palestinian Legislative Council election: poll
trends, the 2006/April-2026-local-elections baseline, and an interactive
scenario model (not a black-box prediction) for the open political
questions — Gaza voting, Jerusalem voting, and the reported Hamas +
Dahlan + left coalition.

## Why this isn't "the app scrapes data on your phone"

Android restricts background execution too heavily for reliable
on-device scraping, and having every installed copy of the app hit
PCPSR's website independently is both unreliable and rude. So:

```
[GitHub Actions cron, every 30m]          [Flutter app]
   scraper_backend/fetch_polls.py    →    fetches data/fetched_data.json
   commits data/fetched_data.json         on open, pull-to-refresh, and
   to this repo                           best-effort WorkManager sync
                                           → recomputes scenarios locally
```

The app always shows *something*: live data if reachable, otherwise the
last successfully cached fetch, otherwise the bundled seed data
(`assets/data/seed_data.json`). It never blocks on network.

## Setup

### 1. Backend (do this first)

```bash
cd scraper_backend
pip install requests beautifulsoup4
python fetch_polls.py   # writes ../data/fetched_data.json
```

Push this whole project to a public GitHub repo. The included
`.github/workflows/update-data.yml` will then run the scraper every 6
hours automatically and commit the refreshed JSON.

**Before trusting it in production**: the scraper uses regex over
PCPSR's press-release prose (they don't publish a structured API), so
review `data/fetched_data.json` after the first few runs. It's
deliberately conservative — if it can't confidently parse a release, it
keeps the previous numbers rather than guessing.

### 2. Point the app at your live data

`DATA_URL` is the public HTTPS address of the generated `fetched_data.json`.
The app downloads this file on launch/refresh, caches the last successful
version, and falls back to bundled seed data if the URL is unavailable.

For a GitHub repository, run the app or build it like this:

```bash
flutter run --dart-define=DATA_URL=https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/data/fetched_data.json
flutter build apk --release --dart-define=DATA_URL=https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/data/fetched_data.json
```

This project is already configured with the repository URL above as its
default. The `--dart-define` flag is only needed when testing a different
data host or branch. The repository must be public for the mobile app to
download the raw JSON without authentication.

### 3. Run the app

```bash
flutter pub get
flutter run
```

## Extending data sources

The scraper fetches PCPSR polling, CEC metadata, and RSS feeds configured in
the dataset's `public_sources` records. News is stored as attributed `news_signals` only;
it never changes vote shares automatically. A signal can affect the
scenario's bounded uncertainty after review, while poll percentages
remain source-provided. Add or remove feeds by updating `public_sources`
and review the generated JSON before publishing it.

All party, coalition, candidate, and source facts belong in the dataset.
The Flutter UI must treat them as provisional unless the record says
`official`, and must tolerate new, merged, renamed, or withdrawn lists.

### Reviewing news evidence

Fresh RSS headlines are classified automatically with transparent rules.
Low-confidence or unclassified headlines use `review_status: "unreviewed"`
and `impact_score: 0`; they appear in the app but cannot affect predictions.
Only headlines matching the source's `news_keywords` list are ingested;
general public news is ignored. The keyword list is deliberately focused
on elections, voting, parties, lists, coalitions, and the Legislative Council.
After a human verifies a headline, annotate its record in
`data/fetched_data.json` with fields such as:

```json
{
  "review_status": "reviewed",
  "confidence_pct": 80,
  "affected_entities": ["list or party name"],
  "coalition_action": "join|leave|uncertain|none",
  "risk_effects": {
    "coalition_probability": 5,
    "election_delay": 2,
    "gaza_feasibility": 0,
    "jerusalem_feasibility": 0,
    "turnout_uncertainty": 3
  },
  "entity_updates": ["Describe the verified status change"]
}
```

Only `reviewed` or high-confidence `auto_reviewed` signals with at least 60%
confidence affect the scenario risk panel. They adjust uncertainty and risk,
not poll percentages. The scraper preserves automatic and reviewed
annotations across future headline refreshes.

Automatic classification is a transparent rule-based analysis aid, not an
official fact verifier. It should be treated as a probabilistic signal and
never as proof that a party joined or left a coalition.

## What this app deliberately does NOT do

- Output a single precise vote-count prediction. Palestinian polling is
  too sparse and this election has too many unresolved structural
  questions for that to be honest.
- Auto-trust scraped numbers. Every fetch either succeeds cleanly or
  falls back — it never publishes a partial/garbled parse as if it were
  a real poll result.
