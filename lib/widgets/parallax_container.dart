import 'package:flutter/material.dart';

/// Parallax container widget that creates a parallax scrolling effect
/// 
/// This widget tracks scroll offset and applies a parallax transformation
/// to create a depth effect where the child moves slower than the scroll.
/// 
/// Example:
/// ```dart
/// SingleChildScrollView(
///   child: Column(
///     children: [
///       ParallaxContainer(
///         child: HeaderImage(),
///         parallaxFactor: 0.5,
///       ),
///       // Rest of content
///     ],
///   ),
/// )
/// ```
class ParallaxContainer extends StatefulWidget {
  /// The widget to apply parallax effect to
  final Widget child;

  /// Factor for parallax effect (0.0 = no parallax, 1.0 = full scroll)
  /// Recommended: 0.3 - 0.7
  final double parallaxFactor;

  /// Maximum offset in pixels
  final double maxOffset;

  /// Enable debug visualization
  final bool debug;

  const ParallaxContainer({
    required this.child,
    this.parallaxFactor = 0.5,
    this.maxOffset = 50.0,
    this.debug = false,
    super.key,
  });

  @override
  State<ParallaxContainer> createState() => _ParallaxContainerState();
}

class _ParallaxContainerState extends State<ParallaxContainer> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate parallax offset
    double parallaxOffset = _scrollOffset * widget.parallaxFactor;

    // Clamp offset to max value
    if (parallaxOffset.abs() > widget.maxOffset) {
      parallaxOffset = parallaxOffset > 0
          ? widget.maxOffset
          : -widget.maxOffset;
    }

    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: widget.debug
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: widget.child,
            )
          : widget.child,
    );
  }
}

/// Parallax list view that automatically handles scroll tracking
/// 
/// Wraps SingleChildScrollView with parallax support
class ParallaxListView extends StatefulWidget {
  /// List of widgets to display
  final List<Widget> children;

  /// Parallax factor for header
  final double parallaxFactor;

  /// Maximum offset for parallax
  final double maxOffset;

  /// Background color
  final Color backgroundColor;

  /// Padding
  final EdgeInsetsGeometry padding;

  const ParallaxListView({
    required this.children,
    this.parallaxFactor = 0.5,
    this.maxOffset = 50.0,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(0),
    super.key,
  });

  @override
  State<ParallaxListView> createState() => _ParallaxListViewState();
}

class _ParallaxListViewState extends State<ParallaxListView> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Container(
        color: widget.backgroundColor,
        padding: widget.padding,
        child: Column(
          children: List.generate(
            widget.children.length,
            (index) {
              // Apply parallax only to first child (header)
              if (index == 0) {
                double parallaxOffset =
                    _scrollOffset * widget.parallaxFactor;

                if (parallaxOffset.abs() > widget.maxOffset) {
                  parallaxOffset = parallaxOffset > 0
                      ? widget.maxOffset
                      : -widget.maxOffset;
                }

                return Transform.translate(
                  offset: Offset(0, parallaxOffset),
                  child: widget.children[index],
                );
              }

              return widget.children[index];
            },
          ),
        ),
      ),
    );
  }
}

/// Parallax image widget for hero images
/// 
/// Optimized for displaying images with parallax effect
class ParallaxImage extends StatefulWidget {
  /// Image provider
  final ImageProvider image;

  /// Height of the image
  final double height;

  /// Width of the image
  final double width;

  /// Fit for the image
  final BoxFit fit;

  /// Parallax factor
  final double parallaxFactor;

  /// Maximum offset
  final double maxOffset;

  /// Overlay color
  final Color? overlayColor;

  /// Overlay opacity
  final double overlayOpacity;

  const ParallaxImage({
    required this.image,
    this.height = 300,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
    this.parallaxFactor = 0.5,
    this.maxOffset = 50.0,
    this.overlayColor,
    this.overlayOpacity = 0.3,
    super.key,
  });

  @override
  State<ParallaxImage> createState() => _ParallaxImageState();
}

class _ParallaxImageState extends State<ParallaxImage> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    double parallaxOffset = _scrollOffset * widget.parallaxFactor;

    if (parallaxOffset.abs() > widget.maxOffset) {
      parallaxOffset = parallaxOffset > 0
          ? widget.maxOffset
          : -widget.maxOffset;
    }

    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: widget.image,
            fit: widget.fit,
          ),
        ),
        child: widget.overlayColor != null
            ? Container(
                color: widget.overlayColor!
                    .withValues(alpha: widget.overlayOpacity),
              )
            : null,
      ),
    );
  }
}

/// Parallax card widget for card-based layouts
/// 
/// Provides parallax effect for cards in a scrollable list
class ParallaxCard extends StatefulWidget {
  /// Card content
  final Widget child;

  /// Card height
  final double height;

  /// Card width
  final double width;

  /// Parallax factor
  final double parallaxFactor;

  /// Maximum offset
  final double maxOffset;

  /// Card elevation
  final double elevation;

  /// Card shape
  final ShapeBorder shape;

  /// Card color
  final Color color;

  const ParallaxCard({
    required this.child,
    this.height = 200,
    this.width = double.infinity,
    this.parallaxFactor = 0.3,
    this.maxOffset = 30.0,
    this.elevation = 4.0,
    this.shape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    this.color = Colors.white,
    super.key,
  });

  @override
  State<ParallaxCard> createState() => _ParallaxCardState();
}

class _ParallaxCardState extends State<ParallaxCard> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    double parallaxOffset = _scrollOffset * widget.parallaxFactor;

    if (parallaxOffset.abs() > widget.maxOffset) {
      parallaxOffset = parallaxOffset > 0
          ? widget.maxOffset
          : -widget.maxOffset;
    }

    return Transform.translate(
      offset: Offset(0, parallaxOffset),
      child: Card(
        elevation: widget.elevation,
        shape: widget.shape,
        color: widget.color,
        child: SizedBox(
          height: widget.height,
          width: widget.width,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Parallax background widget for full-screen parallax effects
/// 
/// Creates a parallax background that moves slower than foreground content
class ParallaxBackground extends StatefulWidget {
  /// Background widget
  final Widget background;

  /// Foreground widget
  final Widget foreground;

  /// Parallax factor for background
  final double parallaxFactor;

  /// Maximum offset
  final double maxOffset;

  const ParallaxBackground({
    required this.background,
    required this.foreground,
    this.parallaxFactor = 0.5,
    this.maxOffset = 100.0,
    super.key,
  });

  @override
  State<ParallaxBackground> createState() => _ParallaxBackgroundState();
}

class _ParallaxBackgroundState extends State<ParallaxBackground> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    double parallaxOffset = _scrollOffset * widget.parallaxFactor;

    if (parallaxOffset.abs() > widget.maxOffset) {
      parallaxOffset = parallaxOffset > 0
          ? widget.maxOffset
          : -widget.maxOffset;
    }

    return Stack(
      children: [
        // Background with parallax
        Transform.translate(
          offset: Offset(0, parallaxOffset),
          child: widget.background,
        ),
        // Foreground with scroll
        SingleChildScrollView(
          controller: _scrollController,
          child: widget.foreground,
        ),
      ],
    );
  }
}
