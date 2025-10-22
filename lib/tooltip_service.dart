import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TooltipService extends ChangeNotifier {
  static const String _tooltipSeenPrefix = 'tooltip_seen_';
  late SharedPreferences _prefs;

  TooltipService() {
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  bool hasSeenTooltip(String tooltipId) {
    return _prefs.getBool('$_tooltipSeenPrefix$tooltipId') ?? false;
  }

  Future<void> markTooltipAsSeen(String tooltipId) async {
    await _prefs.setBool('$_tooltipSeenPrefix$tooltipId', true);
    notifyListeners();
  }

  // For testing purposes, to reset all tooltips
  Future<void> resetAllTooltips() async {
    final keys = _prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith(_tooltipSeenPrefix)) {
        await _prefs.remove(key);
      }
    }
    notifyListeners();
  }
}

// A custom tooltip widget that integrates with TooltipService
class CustomTooltip extends StatefulWidget {
  final String tooltipId;
  final String message;
  final Widget child;
  final Duration? showDuration;
  final Duration? hideDuration;
  final TooltipTriggerMode? triggerMode;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool? preferBelow;
  final double? verticalOffset;
  final double? height;
  final double? excludeFromSemantics;
  final double? waitDuration;
  final bool? enableFeedback;
  final bool? showWhenDisabled;
  final double? closeButtonOffset;
  final String? closeButtonTooltip;
  final VoidCallback? onClose;

  const CustomTooltip({
    super.key,
    required this.tooltipId,
    required this.message,
    required this.child,
    this.showDuration,
    this.hideDuration,
    this.triggerMode,
    this.decoration,
    this.textStyle,
    this.padding,
    this.margin,
    this.preferBelow,
    this.verticalOffset,
    this.height,
    this.excludeFromSemantics,
    this.waitDuration,
    this.enableFeedback,
    this.showWhenDisabled,
    this.closeButtonOffset,
    this.closeButtonTooltip,
    this.onClose,
  });

  @override
  State<CustomTooltip> createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<CustomTooltip> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTooltip();
    });
  }

  @override
  void didUpdateWidget(covariant CustomTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tooltipId != widget.tooltipId) {
      _checkAndShowTooltip();
    }
  }

  void _checkAndShowTooltip() {
    final tooltipService = Provider.of<TooltipService>(context, listen: false);
    if (!tooltipService.hasSeenTooltip(widget.tooltipId)) {
      _showOverlay();
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _dismissTooltip,
            child: Material(
              color: Colors.black54, // Semi-transparent overlay
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message: widget.message,
                      preferBelow: widget.preferBelow ?? true,
                      verticalOffset: widget.verticalOffset ?? 30,
                      decoration: widget.decoration ??
                          BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                      textStyle: widget.textStyle ??
                          const TextStyle(color: Colors.white, fontSize: 14),
                      padding: widget.padding ?? const EdgeInsets.all(12),
                      child: widget.child, // The widget the tooltip is for
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _dismissTooltip,
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _dismissTooltip() {
    final tooltipService = Provider.of<TooltipService>(context, listen: false);
    tooltipService.markTooltipAsSeen(widget.tooltipId);
    _overlayEntry?.remove();
    _overlayEntry = null;
    widget.onClose?.call();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child; // The actual widget, tooltip is shown as an overlay
  }
}
