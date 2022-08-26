/*
 *  This file is part of BlackHole (https://github.com/Sangwan5688/BlackHole).
 */

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class CustomPhysics extends ScrollPhysics {
  const CustomPhysics({super.parent});

  @override
  CustomPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 150,
        stiffness: 100,
        damping: 1,
      );
}
