

import 'package:flutter/material.dart';
import 'package:gem/Helpers/route_handler.dart';

void handleSharedText(
  String sharedText,
  GlobalKey<NavigatorState> navigatorKey,
) {
  final route = HandleRoute.handleRoute(sharedText);
  if (route != null) navigatorKey.currentState?.push(route);
}
