import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:habitur/constants.dart';

enum StatusType {
  loading,
  success,
  error,
}

class StatusCard extends StatefulWidget {
  final String message;
  final StatusType status;
  final VoidCallback? onDismiss;

  const StatusCard({
    Key? key,
    required this.message,
    required this.status,
    this.onDismiss,
  }) : super(key: key);

  @override
  _StatusCardState createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  StatusType? _previousStatus;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
    _handleStatusChange();
  }

  @override
  void didUpdateWidget(StatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _handleStatusChange();
    }
  }

  void _handleStatusChange() {
    // If transitioning from loading to success/error
    if (_previousStatus == StatusType.loading &&
        widget.status != StatusType.loading) {
      _autoDismiss();
    }
    // If new status is success/error
    else if (widget.status != StatusType.loading) {
      _autoDismiss();
    }
    _previousStatus = widget.status;
  }

  void _autoDismiss() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (widget.onDismiss != null) {
            widget.onDismiss!();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor() {
    switch (widget.status) {
      case StatusType.loading:
        return kDarkGray;
      case StatusType.success:
        return kLightGreenAccent;
      case StatusType.error:
        return kLightRedAccent;
    }
  }

  IconData _getIcon() {
    switch (widget.status) {
      case StatusType.loading:
        return Icons.hourglass_empty;
      case StatusType.success:
        return Icons.check_circle_outline;
      case StatusType.error:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 80,
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _getColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getColor().withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (widget.status == StatusType.loading)
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(_getColor()),
                            ),
                          )
                        else
                          Icon(
                            _getIcon(),
                            color: _getColor(),
                            size: 20,
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              color: _getColor() == kDarkGray
                                  ? Colors.white
                                  : _getColor(),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
