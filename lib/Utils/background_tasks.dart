import 'package:workmanager/workmanager.dart';
import 'package:photos/service/imageservice.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Check and index new media
    //await ImageService.indexNewMedia();
    return Future.value(true);
  });
}

class BackgroundTasks {
  static void initialize() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );

    // Schedule the background task
    Workmanager().registerPeriodicTask(
      "1",
      "checkNewMedia",
      frequency: Duration(hours: 1), // Adjust frequency as needed
    );
  }
}

