import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:hive/hive.dart';

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning';
  }
  if (hour < 17) {
    return 'Good Afternoon';
  }
  return 'Good Evening';
}

//hive box for recently recently played
void updateRandomArray(List<MediaItem> list) {
  // Open the Hive box where the array will be stored
  var box = Hive.box('recently_played');

  // Generate a new random array by shuffling the elements of the input list
  var randomArray = list.toList()..shuffle();

  // Save the random array in the Hive box
  box.put('array', randomArray);

  // Set up a timer to update the array daily at midnight
  var midnight = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
  var duration = midnight.difference(DateTime.now());
  Timer(duration, () => updateRandomArray(list));
}
