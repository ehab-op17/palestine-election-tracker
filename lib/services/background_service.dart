import 'package:workmanager/workmanager.dart';
import 'data_service.dart';

const String kRefreshTaskName = 'refreshElectionData';

/// Entry point Android calls when the OS wakes the background isolate.
/// Must be a top-level or static function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == kRefreshTaskName) {
      try {
        await DataService().loadDataset(forceRefresh: true);
      } catch (_) {
        // Best-effort — Android may kill this at any time. The app will
        // simply fetch again next time it's opened.
      }
    }
    return Future.value(true);
  });
}

class BackgroundService {
  /// Registers a periodic refresh. Android's minimum interval for
  /// periodic WorkManager tasks is 15 minutes; realistically the OS will
  /// batch this much less often under Doze/battery optimization, so treat
  /// this as "refresh when the OS feels like it," not a guarantee.
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      kRefreshTaskName,
      kRefreshTaskName,
      frequency: const Duration(hours: 6),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }
}
