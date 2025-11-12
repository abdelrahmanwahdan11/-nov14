import 'package:flutter/material.dart';

class Parallax3DCard extends StatefulWidget {
  const Parallax3DCard({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  State<Parallax3DCard> createState() => _Parallax3DCardState();
}

class _Parallax3DCardState extends State<Parallax3DCard> {
  double _x = 0;
  double _y = 0;

  void _onPointerMove(PointerEvent event, Size size) {
    final center = size.center(Offset.zero);
    final offset = event.localPosition - center;
    setState(() {
      _x = (offset.dy / size.height) * 0.4;
      _y = -(offset.dx / size.width) * 0.4;
    });
  }

  void _reset() {
    setState(() {
      _x = 0;
      _y = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerHover: (e) => _onPointerMove(e, context.size ?? const Size(1, 1)),
      onPointerMove: (e) => _onPointerMove(e, context.size ?? const Size(1, 1)),
      onPointerUp: (_) => _reset(),
      onPointerCancel: (_) => _reset(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_x)
          ..rotateY(_y),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(.25),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
              color: Theme.of(context).colorScheme.surface,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    widget.image,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(.1), Colors.black.withOpacity(.65)],
                      ),
                    ),
                  ),
                ),
                if (widget.badge != null)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20, right: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(widget.badge!, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: widget.onTap,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                        child: Text(MaterialLocalizations.of(context).okButtonLabel),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
