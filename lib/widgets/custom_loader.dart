import 'package:flutter/material.dart';

class CustomLoader extends StatefulWidget {
  const CustomLoader({super.key});

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.1), // fondo semitransparente
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 60,
              width: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            /*             ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                Icons.attach_money,
                size: 30,
                color: Theme.of(context).colorScheme.primary,
              ),
            ), */
          ],
        ),
      ),
    );
  }
}
