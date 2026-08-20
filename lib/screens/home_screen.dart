import 'dart:async';

import 'package:flutter/material.dart';

import '../models/election_data.dart';
import '../localization.dart';
import '../services/data_service.dart';
import '../theme.dart';
import 'baseline_screen.dart';
import 'news_screen.dart';
import 'overview_screen.dart';
import 'parties_screen.dart';
import 'polls_screen.dart';
import 'report_screen.dart';
import 'scenario_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleLanguage;
  const HomeScreen({super.key, required this.onToggleLanguage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final _dataService = DataService();
  int _tab = 0;
  DataFetchResult? _result;
  bool _refreshing = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
    _refreshTimer = Timer.periodic(
        const Duration(minutes: 15), (_) => _load(forceRefresh: true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load(forceRefresh: true);
    }
  }

  Future<void> _load({bool forceRefresh = false}) async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    final result = await _dataService.loadDataset(forceRefresh: forceRefresh);
    if (!mounted) return;
    setState(() {
      _result = result;
      _refreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = _result!.dataset;
    final strings = AppStrings.of(context);
    final compact = MediaQuery.sizeOf(context).width < 600;
    final daysOut =
        data.electionDate.difference(DateTime.now()).inDays.clamp(0, 100000);

    final tabs = [
      OverviewScreen(
          data: data,
          sourceLabel: _result!.sourceLabel,
          onNavigate: (index) => setState(() => _tab = index)),
      PollsScreen(data: data),
      PartiesScreen(data: data),
      BaselineScreen(data: data),
      ScenarioScreen(data: data),
      NewsScreen(data: data),
      ReportScreen(data: data),
    ];
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0, elevation: 0),
      body: RefreshIndicator(
        onRefresh: () => _load(forceRefresh: true),
        child: Column(
          children: [
            _Header(
                daysOut: daysOut,
                data: data,
                sourceLabel: _result!.sourceLabel,
                refreshing: _refreshing,
                onToggleLanguage: widget.onToggleLanguage),
            Expanded(child: tabs[_tab]),
          ],
        ),
      ),
      bottomNavigationBar: compact
          ? NavigationBar(
              selectedIndex: _tab == 0
                  ? 0
                  : _tab == 1
                      ? 1
                      : _tab == 2
                          ? 2
                          : 3,
              onDestinationSelected: (i) {
                if (i == 3) {
                  _showMore(context, strings);
                } else {
                  setState(() => _tab = i);
                }
              },
              destinations: [
                NavigationDestination(icon: const Icon(Icons.dashboard), label: strings.brief),
                NavigationDestination(icon: const Icon(Icons.bar_chart), label: strings.polling),
                NavigationDestination(icon: const Icon(Icons.groups), label: strings.parties),
                NavigationDestination(icon: const Icon(Icons.more_horiz), label: strings.t('More', 'المزيد')),
              ],
            )
          : NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.dashboard), label: strings.brief),
          NavigationDestination(icon: const Icon(Icons.bar_chart), label: strings.polling),
          NavigationDestination(icon: const Icon(Icons.groups), label: strings.parties),
          NavigationDestination(icon: const Icon(Icons.history), label: strings.baseline),
          NavigationDestination(icon: const Icon(Icons.tune), label: strings.scenarios),
          NavigationDestination(icon: const Icon(Icons.newspaper), label: strings.news),
          NavigationDestination(icon: const Icon(Icons.print), label: strings.reports),
        ],
      ),
    );
  }

  void _showMore(BuildContext context, AppStrings strings) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.history), title: Text(strings.baseline), onTap: () => _selectMore(context, 3)),
            ListTile(leading: const Icon(Icons.tune), title: Text(strings.scenarios), onTap: () => _selectMore(context, 4)),
            ListTile(leading: const Icon(Icons.newspaper), title: Text(strings.news), onTap: () => _selectMore(context, 5)),
            ListTile(leading: const Icon(Icons.print), title: Text(strings.reports), onTap: () => _selectMore(context, 6)),
          ],
        ),
      ),
    );
  }

  void _selectMore(BuildContext context, int tab) {
    Navigator.pop(context);
    setState(() => _tab = tab);
  }
}

class _Header extends StatelessWidget {
  final int daysOut;
  final ElectionDataset data;
  final String sourceLabel;
  final bool refreshing;
  final VoidCallback onToggleLanguage;

  const _Header({
    required this.daysOut,
    required this.data,
    required this.sourceLabel,
    required this.refreshing,
    required this.onToggleLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final compact = MediaQuery.sizeOf(context).width < 600;
    return Container(
      color: AppColors.ink,
      padding: EdgeInsets.fromLTRB(compact ? 14 : 20, compact ? 10 : 24, compact ? 14 : 20, compact ? 10 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                strings.appTitle,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 10, letterSpacing: 1.2),
              ),
              IconButton(
                onPressed: onToggleLanguage,
                tooltip: strings.switchLanguage,
                icon: Text(strings.arabic,
                    style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ),
              if (refreshing)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white54),
                )
              else
                Icon(
                  Icons.circle,
                  size: 8,
                  color: sourceLabel.startsWith('Live')
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                ),
            ],
          ),
          SizedBox(height: compact ? 3 : 10),
          Text(
            strings.scheduled,
            style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 15 : 20,
                fontWeight: FontWeight.w600,
                height: 1.25),
          ),
          SizedBox(height: compact ? 4 : 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$daysOut',
                style: TextStyle(
                    color: const Color(0xFFE8DCC0),
                    fontSize: compact ? 25 : 32,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(strings.daysUntil,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis)),
            ],
          ),
          if (!compact) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.alert.withValues(alpha: 0.18),
              border: const Border(
                  left: BorderSide(color: AppColors.alert, width: 3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.unresolved,
                  style: const TextStyle(
                    color: Color(0xFFE8A896),
                        fontSize: 10,
                        letterSpacing: 1.2)),
                const SizedBox(height: 4),
                ...data.unresolvedConditions.map(
                  (condition) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('- $condition',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12, height: 1.3)),
                  ),
                ),
              ],
            ),
          ),
          ],
          const SizedBox(height: 6),
          Text(sourceLabel,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}
