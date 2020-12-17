import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phantom3d/bloc/keyboard_listener/keyboard_listener_cubit.dart';

class ViewportInteractionListener extends StatefulWidget {
  const ViewportInteractionListener({
    Key key,
    this.child,
    this.onPrimaryMouseButtonDown,
    this.onPrimaryMouseButtonUp,
    this.onPrimaryMouseButtonDrag,
    this.onPrimaryMouseButtonDragComplete,
    this.onSecondaryMouseButtonDown,
    this.onSecondaryMouseButtonUp,
    this.onSecondaryMouseButtonDrag,
    this.onSecondaryMouseButtonDragComplete,
    this.onScrollerButtonDown,
    this.onScrollerButtonUp,
    this.onScrollerButtonDrag,
    this.onScrollerButtonDragComplete,
    this.onScrollerScroll,
    this.onScrollerScrollComplete,
    this.focusNode,
  }) : super(key: key);

  final Widget child;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onPrimaryMouseButtonDown;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onPrimaryMouseButtonUp;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onPrimaryMouseButtonDrag;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onPrimaryMouseButtonDragComplete;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onSecondaryMouseButtonDown;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onSecondaryMouseButtonUp;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onSecondaryMouseButtonDrag;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onSecondaryMouseButtonDragComplete;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onScrollerButtonDown;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onScrollerButtonUp;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onScrollerButtonDrag;
  final Function(int xPos, int yPos, RawKeyDownEvent keyDownEvent)
      onScrollerButtonDragComplete;
  final Function(int xOffset, int yOffset, RawKeyDownEvent keyDownEvent)
      onScrollerScroll;
  final Function(int xOffset, int yOffset, RawKeyDownEvent keyDownEvent)
      onScrollerScrollComplete;
  final FocusNode focusNode;

  // rotate viewport freely
  // rotate viewport about the axis out of the screen
  // pan view port
  // zoom view port
  // select objects
  // deselect objects

  @override
  _ViewportInteractionListenerState createState() =>
      _ViewportInteractionListenerState();
}

enum _ButtonEvents {
  buttonDown,
  buttonUp,
  buttonDrag,
  buttonReset,
  buttonScroll
}

class _ViewportInteractionListenerState
    extends State<ViewportInteractionListener> {
  bool _pointerInViewport;

  RawKeyDownEvent _keyDownEvent;
  _ButtonEvents _previousButtonEvent = _ButtonEvents.buttonReset;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (onEnter) {
        _pointerInViewport = true;
      },
      onExit: (onExit) {
        _pointerInViewport = false;
        _previousButtonEvent = _ButtonEvents.buttonReset;
      },
      onHover: (onHover) {
        //dont use this
      },
      child: BlocBuilder<KeyboardListenerCubit, RawKeyEvent>(
        builder: (context, rawKeyEvent) {
          if (rawKeyEvent is RawKeyDownEvent) {
            _keyDownEvent = rawKeyEvent;
          } else if (rawKeyEvent is RawKeyUpEvent) {
            _keyDownEvent = null;
          }
          return Listener(
            child: widget.child ?? Container(),
            onPointerDown: (onPointerDownEvent) {
              if (_pointerInViewport) {
                if (!widget.focusNode.hasFocus) {
                  FocusScope.of(context).requestFocus(widget.focusNode);
                }

                if (onPointerDownEvent.buttons == kPrimaryMouseButton) {
                  _primaryMouseButtonDownEvent(
                      onPointerDownEvent.localPosition.dx.toInt(),
                      onPointerDownEvent.localPosition.dy.toInt(),
                      _keyDownEvent);
                } else if (onPointerDownEvent.buttons ==
                    kSecondaryMouseButton) {
                  _secondaryMouseButtonDownEvent(
                      onPointerDownEvent.localPosition.dx.toInt(),
                      onPointerDownEvent.localPosition.dy.toInt(),
                      _keyDownEvent);
                } else {
                  _scrollerButtonDownEvent(
                      onPointerDownEvent.localPosition.dx.toInt(),
                      onPointerDownEvent.localPosition.dy.toInt(),
                      _keyDownEvent);
                }
              }
            },
            onPointerUp: (onPointerUpEvent) {
              if (_pointerInViewport) {
                if (_previousButtonEvent == _ButtonEvents.buttonDown) {
                  // all callback related to button click
                  if (onPointerUpEvent.buttons == kPrimaryMouseButton) {
                    _primaryMouseButtonUpEvent(
                        onPointerUpEvent.localPosition.dx.toInt(),
                        onPointerUpEvent.localPosition.dy.toInt(),
                        _keyDownEvent);
                  } else if (onPointerUpEvent.buttons ==
                      kSecondaryMouseButton) {
                    _secondaryMouseButtonUpEvent(
                        onPointerUpEvent.localPosition.dx.toInt(),
                        onPointerUpEvent.localPosition.dy.toInt(),
                        _keyDownEvent);
                  } else {
                    _scrollerButtonUpEvent(
                        onPointerUpEvent.localPosition.dx.toInt(),
                        onPointerUpEvent.localPosition.dy.toInt(),
                        _keyDownEvent);
                  }
                } else if (_previousButtonEvent == _ButtonEvents.buttonDrag) {
                  // all callback related to finishing drag
                  if (onPointerUpEvent.buttons == kPrimaryMouseButton) {
                    _primaryMouseButtonDragCompleteEvent(
                        onPointerUpEvent.localPosition.dx.toInt(),
                        onPointerUpEvent.localPosition.dy.toInt(),
                        _keyDownEvent);
                  } else if (onPointerUpEvent.buttons ==
                      kSecondaryMouseButton) {
                    _secondaryMouseButtonDragCompleteEvent(
                        onPointerUpEvent.localPosition.dx.toInt(),
                        onPointerUpEvent.localPosition.dy.toInt(),
                        _keyDownEvent);
                  } else {
                    _scrollerButtonDragCompleteEvent(
                        onPointerUpEvent.localPosition.dx.toInt(),
                        onPointerUpEvent.localPosition.dy.toInt(),
                        _keyDownEvent);
                  }
                }
              }
            },
            onPointerMove: (onPointerMoveEvent) {
              if (_pointerInViewport) {
                if (_previousButtonEvent == _ButtonEvents.buttonDown ||
                    _previousButtonEvent == _ButtonEvents.buttonDrag) {
                  // all callback related to drags
                  if (onPointerMoveEvent.buttons == kPrimaryMouseButton) {
                    _primaryMouseButtonDragEvent(
                        onPointerMoveEvent.localPosition.dx.toInt(),
                        onPointerMoveEvent.localPosition.dy.toInt(),
                        _keyDownEvent);
                  } else if (onPointerMoveEvent.buttons ==
                      kSecondaryMouseButton) {
                    _secondaryMouseButtonDragEvent(
                        onPointerMoveEvent.localPosition.dx.toInt(),
                        onPointerMoveEvent.localPosition.dy.toInt(),
                        _keyDownEvent);
                  } else {
                    _scrollerButtonDragEvent(
                        onPointerMoveEvent.localPosition.dx.toInt(),
                        onPointerMoveEvent.localPosition.dy.toInt(),
                        _keyDownEvent);
                  }
                }
              }
            },
            onPointerHover: (onPointerHover) {
              //not needed
            },
            onPointerSignal: (onPointerSignalEvent) {
              if (onPointerSignalEvent is PointerScrollEvent) {
                _scrollerButtonScrollEvent(
                    onPointerSignalEvent.scrollDelta.dx.toInt(),
                    onPointerSignalEvent.scrollDelta.dy.toInt(),
                    _keyDownEvent);
              }
            },
          );
        },
      ),
    );
  }

  void _primaryMouseButtonDownEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonDown;

    if (widget.onPrimaryMouseButtonDown != null) {
      widget.onPrimaryMouseButtonDown(xPos, yPos, keyDownEvent);
    }
  }

  void _primaryMouseButtonUpEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonUp;

    if (widget.onPrimaryMouseButtonUp != null) {
      widget.onPrimaryMouseButtonUp(xPos, yPos, keyDownEvent);
    }
  }

  void _primaryMouseButtonDragEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonDrag;

    if (widget.onPrimaryMouseButtonDrag != null) {
      widget.onPrimaryMouseButtonDrag(xPos, yPos, keyDownEvent);
    }
  }

  void _primaryMouseButtonDragCompleteEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonDrag;

    if (widget.onPrimaryMouseButtonDragComplete != null) {
      widget.onPrimaryMouseButtonDragComplete(xPos, yPos, keyDownEvent);
    }
  }

  void _secondaryMouseButtonDownEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonDown;

    if (widget.onSecondaryMouseButtonDown != null) {
      widget.onSecondaryMouseButtonDown(xPos, yPos, keyDownEvent);
    }
  }

  void _secondaryMouseButtonUpEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonUp;

    if (widget.onSecondaryMouseButtonUp != null) {
      widget.onSecondaryMouseButtonUp(xPos, yPos, keyDownEvent);
    }
  }

  void _secondaryMouseButtonDragEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonDrag;

    if (widget.onSecondaryMouseButtonDrag != null) {
      widget.onSecondaryMouseButtonDrag(xPos, yPos, keyDownEvent);
    }
  }

  void _secondaryMouseButtonDragCompleteEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonReset;

    if (widget.onSecondaryMouseButtonDragComplete != null) {
      widget.onSecondaryMouseButtonDragComplete(xPos, yPos, keyDownEvent);
    }
  }

  void _scrollerButtonDownEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonDown;

    if (widget.onScrollerButtonDown != null) {
      widget.onScrollerButtonDown(xPos, yPos, keyDownEvent);
    }
  }

  void _scrollerButtonUpEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonUp;

    if (widget.onScrollerButtonUp != null) {
      widget.onScrollerButtonUp(xPos, yPos, keyDownEvent);
    }
  }

  void _scrollerButtonDragEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonDrag;

    if (widget.onScrollerButtonDrag != null) {
      widget.onScrollerButtonDrag(xPos, yPos, keyDownEvent);
    }
  }

  void _scrollerButtonDragCompleteEvent(
      int xPos, int yPos, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonReset;

    if (widget.onScrollerButtonDragComplete != null) {
      widget.onScrollerButtonDragComplete(xPos, yPos, keyDownEvent);
    }
  }

  void _scrollerButtonScrollEvent(
      int xOffset, int yOffset, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonScroll;

    if (widget.onScrollerScroll != null) {
      widget.onScrollerScroll(xOffset, yOffset, keyDownEvent);
    }
  }

  void _scrollerButtonScrollCompleteEvent(
      int xOffset, int yOffset, RawKeyDownEvent keyDownEvent) {
    _previousButtonEvent = _ButtonEvents.buttonReset;

    if (widget.onScrollerScrollComplete != null) {
      widget.onScrollerScrollComplete(xOffset, yOffset, keyDownEvent);
    }
  }
}
