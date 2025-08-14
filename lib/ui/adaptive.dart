import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Breakpoints {
  final double width;
  const Breakpoints(this.width);
  bool get compact => width < 600;
  bool get medium  => width >= 600 && width < 1024;
  bool get expanded => width >= 1024;

  static Breakpoints of(BuildContext context) =>
      Breakpoints(MediaQuery.sizeOf(context).width);
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class CenteredContent extends StatelessWidget {
  const CenteredContent({super.key, required this.child, this.maxWidth = 920});
  final Widget child;
  final double maxWidth;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}
