import 'package:flutter/physics.dart';

class GlubSpringConfig {
  static const double stiffness = 300.0;
  static const double damping = 20.0;
  static const double mass = 1.0;
  static const SpringDescription spring = SpringDescription(
    mass: mass,
    stiffness: stiffness,
    damping: damping,
  );
  static const Duration microInteraction = Duration(milliseconds: 150);
  static const Duration panelTransition = Duration(milliseconds: 250);
  static const Duration screenNavigation = Duration(milliseconds: 350);
  
  // ✅ ОПТИМИЗАЦИЯ: Константы для производительности
  static const int maxConcurrentImageLoads = 5;
  static const int imageCacheMemoryMB = 200;
  static const int filesPerBatch = 100;
  static const double scrollBufferMultiplier = 1.5;
}