import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A full-width image viewer that pages through multiple images with
/// tappable pagination dots and left/right slide arrows.
///
/// When there is only a single image it behaves exactly like a plain image
/// (no dots, no arrows). Pinch-to-zoom is preserved per image; horizontal
/// paging is driven by the arrows/dots rather than swipe so it never fights
/// the zoom's pan gesture.
class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final double aspectRatio;
  final bool enableZoom;

  /// When true the user can swipe horizontally to change pages. Swipe disables
  /// the zoom's pan so the horizontal drag reaches the PageView (pinch-to-zoom
  /// still works).
  final bool enableSwipe;

  /// When true, left/right slide arrows are shown for multi-image posts.
  final bool showArrows;

  /// Called when the user swipes past the last image (a forward overscroll).
  /// Used by the feed to hand the gesture off to the parent tab so that
  /// swiping beyond the final image moves to the next tab.
  final VoidCallback? onOverscrollNext;

  const ImageCarousel({
    super.key,
    required this.images,
    this.aspectRatio = 4 / 5,
    this.enableZoom = true,
    this.enableSwipe = false,
    this.showArrows = true,
    this.onOverscrollNext,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late final PageController _controller;
  int _current = 0;
  // Accumulated forward drag past the last image during the current gesture,
  // and whether we've already handed off to the parent tab this gesture.
  double _overscrollAccum = 0;
  bool _handedOff = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Hands off to [onOverscrollNext] (e.g. switch to the next tab) mid-drag, as
  // soon as the user pulls clearly past the last image — so the tab starts
  // sliding in while the finger is still moving, instead of bouncing back
  // first and animating afterwards. Only a forward (past the end) drag counts.
  bool _onScroll(ScrollNotification n) {
    if (widget.onOverscrollNext == null) return false;
    if (n.metrics.axis != Axis.horizontal) return false;
    if (n is ScrollStartNotification) {
      _overscrollAccum = 0;
      _handedOff = false;
    } else if (n is OverscrollNotification &&
        n.overscroll > 0 &&
        n.dragDetails != null) {
      _overscrollAccum += n.overscroll;
      if (!_handedOff && _overscrollAccum > 48) {
        _handedOff = true;
        widget.onOverscrollNext!();
      }
    } else if (n is ScrollEndNotification) {
      _overscrollAccum = 0;
      _handedOff = false;
    }
    return false;
  }

  void _goTo(int page) {
    final target = page.clamp(0, _images.length - 1);
    _controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Guard against an empty list so the widget always renders one page.
  List<String> get _images => widget.images.isEmpty ? const [''] : widget.images;

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        width: double.infinity,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, size: 50, color: Colors.grey),
      );
    }
    final image = CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(color: Colors.grey.shade200),
      errorWidget: (_, __, ___) =>
          const Center(child: Icon(Icons.broken_image)),
    );
    if (!widget.enableZoom) return image;
    final tc = TransformationController();
    return InteractiveViewer(
      transformationController: tc,
      // Disable pan when swipe is enabled so the horizontal drag goes to the
      // PageView; pinch-to-zoom still works.
      panEnabled: !widget.enableSwipe,
      scaleEnabled: true,
      minScale: 1.0,
      maxScale: 4.0,
      clipBehavior: Clip.none,
      onInteractionEnd: (_) => tc.value = Matrix4.identity(),
      child: image,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _images;
    final hasMultiple = images.length > 1;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: [
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: PageView.builder(
                controller: _controller,
                physics: widget.enableSwipe
                    ? const BouncingScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => _buildImage(images[i]),
              ),
            ),
          ),
          if (widget.showArrows && hasMultiple && _current > 0)
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ArrowButton(
                  icon: Icons.chevron_left,
                  onTap: () => _goTo(_current - 1),
                ),
              ),
            ),
          if (widget.showArrows && hasMultiple && _current < images.length - 1)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _ArrowButton(
                  icon: Icons.chevron_right,
                  onTap: () => _goTo(_current + 1),
                ),
              ),
            ),
          if (hasMultiple)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: _DotsIndicator(count: images.length, current: _current),
            ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0x66000000),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x40000000),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (i) {
            final active = i == current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 8 : 6,
              height: active ? 8 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? Colors.white : Colors.white54,
              ),
            );
          }),
        ),
      ),
    );
  }
}
