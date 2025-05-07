import 'dart:async';
import 'package:flutter/material.dart';
import 'package:k_chart_plus/chart_translations.dart';
import 'package:k_chart_plus/components/popup_info_view.dart';
import 'package:k_chart_plus/k_chart_plus.dart';
import 'renderer/base_dimension.dart';

enum MainState { MA, BOLL, EMA, SAR, AVL, NONE }

// enum SecondaryState { MACD, KDJ, RSI, WR, CCI, NONE }
enum SecondaryState { MACD, KDJ, RSI, WR, CCI } //no support NONE

class TimeFormat {
  static const List<String> YEAR_MONTH_DAY = [yyyy, '-', mm, '-', dd];
  static const List<String> YEAR_MONTH_DAY_WITH_HOUR = [
    yyyy,
    '-',
    mm,
    '-',
    dd,
    ' ',
    HH,
    ':',
    nn
  ];
}

class KChartWidget extends StatefulWidget {
  final List<KLineEntity>? datas;
  final MainState mainState;
  final bool volHidden;
  final Set<SecondaryState> secondaryStateLi;
  // final Function()? onSecondaryTap;
  final bool isLine;
  final bool
      isTapShowInfoDialog; //Whether to enable click to display detailed data
  final bool hideGrid;
  final bool showNowPrice;
  final bool showInfoDialog;
  final bool materialInfoDialog; // Material Style Information Popup
  final ChartTranslations chartTranslations;
  final List<String> timeFormat;
  final double mBaseHeight;

  // It will be called when the screen scrolls to the end.
  // If true, it will be scrolled to the end of the right side of the screen.
  // If it is false, it will be scrolled to the end of the left side of the screen.
  final Function(bool)? onLoadMore;

  final int fixedLength;
  final List<int> maDayList;
  final List<int> emaDayList;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool)? isOnDrag;
  final ChartColors chartColors;
  final ChartStyle chartStyle;
  final VerticalTextAlignment verticalTextAlignment;
  final bool isTrendLine;
  final double xFrontPadding;
  final int volDecimalPlaces;

  KChartWidget(
    this.datas,
    this.chartStyle,
    this.chartColors, {
    required this.isTrendLine,
    this.xFrontPadding = 100,
    this.mainState = MainState.MA,
    this.secondaryStateLi = const <SecondaryState>{},
    // this.onSecondaryTap,
    this.volHidden = false,
    this.isLine = false,
    this.isTapShowInfoDialog = false,
    this.hideGrid = false,
    this.showNowPrice = true,
    this.showInfoDialog = true,
    this.materialInfoDialog = true,
    this.chartTranslations = const ChartTranslations(),
    this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
    this.onLoadMore,
    this.fixedLength = 2,
    this.maDayList = const [5, 10, 20],
    this.emaDayList = const [5, 10, 20],
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
    this.verticalTextAlignment = VerticalTextAlignment.left,
    this.mBaseHeight = 360,
    this.volDecimalPlaces = 0,
  });

  @override
  _KChartWidgetState createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  final StreamController<InfoWindowEntity?> mInfoWindowStream =
      StreamController<InfoWindowEntity?>();
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;
  double mHeight = 0, mWidth = 0;
  AnimationController? _controller;
  Animation<double>? aniX;

  //For TrendLine
  List<TrendLine> lines = [];
  double? changeinXposition;
  double? changeinYposition;
  double mSelectY = 0.0;
  bool waitingForOtherPairofCords = false;
  bool enableCordRecord = false;

  double getMinScrollX() {
    return mScaleX;
  }

  double _lastScale = 1.0;
  bool isScale = false, isDrag = false, isLongPress = false, isOnTap = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    mInfoWindowStream.sink.close();
    mInfoWindowStream.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas != null && widget.datas!.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }
    final BaseDimension baseDimension = BaseDimension(
      mBaseHeight: widget.mBaseHeight,
      volHidden: widget.volHidden,
      secondaryStateLi: widget.secondaryStateLi,
    );

    // Create a new ChartStyle with volDecimalPlaces
    final chartStyle = ChartStyle(
      topPadding: widget.chartStyle.topPadding,
      bottomPadding: widget.chartStyle.bottomPadding,
      childPadding: widget.chartStyle.childPadding,
      pointWidth: widget.chartStyle.pointWidth,
      candleWidth: widget.chartStyle.candleWidth,
      candleLineWidth: widget.chartStyle.candleLineWidth,
      volWidth: widget.chartStyle.volWidth,
      macdWidth: widget.chartStyle.macdWidth,
      vCrossWidth: widget.chartStyle.vCrossWidth,
      hCrossWidth: widget.chartStyle.hCrossWidth,
      nowPriceLineLength: widget.chartStyle.nowPriceLineLength,
      nowPriceLineSpan: widget.chartStyle.nowPriceLineSpan,
      nowPriceLineWidth: widget.chartStyle.nowPriceLineWidth,
      gridRows: widget.chartStyle.gridRows,
      gridColumns: widget.chartStyle.gridColumns,
      dateTimeFormat: widget.chartStyle.dateTimeFormat,
      lineWidth: widget.chartStyle.lineWidth,
      sarStart: widget.chartStyle.sarStart,
      sarMaximum: widget.chartStyle.sarMaximum,
      bollPeriod: widget.chartStyle.bollPeriod,
      bollBandwidth: widget.chartStyle.bollBandwidth,
      volDecimalPlaces: widget.volDecimalPlaces,
    );

    final _painter = ChartPainter(
      chartStyle,
      widget.chartColors,
      baseDimension: baseDimension,
      lines: lines,
      sink: mInfoWindowStream.sink,
      xFrontPadding: widget.xFrontPadding,
      isTrendLine: widget.isTrendLine,
      selectY: mSelectY,
      datas: widget.datas,
      scaleX: mScaleX,
      scrollX: mScrollX,
      selectX: mSelectX,
      isLongPass: isLongPress,
      isOnTap: isOnTap,
      isTapShowInfoDialog: widget.isTapShowInfoDialog,
      mainState: widget.mainState,
      volHidden: widget.volHidden,
      secondaryStateLi: widget.secondaryStateLi,
      isLine: widget.isLine,
      hideGrid: widget.hideGrid,
      showNowPrice: widget.showNowPrice,
      fixedLength: widget.fixedLength,
      maDayList: widget.maDayList,
      emaDayList: widget.emaDayList,
      verticalTextAlignment: widget.verticalTextAlignment,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        mHeight = constraints.maxHeight;
        mWidth = constraints.maxWidth;
        return GestureDetector(
          onTapUp: (details) {
            // if (!widget.isTrendLine && widget.onSecondaryTap != null && _painter.isInSecondaryRect(details.localPosition)) {
            //   widget.onSecondaryTap!();
            // }

            if (!widget.isTrendLine &&
                _painter.isInMainRect(details.localPosition)) {
              isOnTap = true;
              if (mSelectX != details.localPosition.dx &&
                  widget.isTapShowInfoDialog) {
                mSelectX = details.localPosition.dx;
                notifyChanged();
              }
            }
            if (widget.isTrendLine && !isLongPress && enableCordRecord) {
              enableCordRecord = false;
              Offset p1 = Offset(getTrendLineX(), mSelectY);
              if (!waitingForOtherPairofCords) {
                lines.add(TrendLine(
                    p1, Offset(-1, -1), trendLineMax!, trendLineScale!));
              }

              if (waitingForOtherPairofCords) {
                var a = lines.last;
                lines.removeLast();
                lines.add(TrendLine(a.p1, p1, trendLineMax!, trendLineScale!));
                waitingForOtherPairofCords = false;
              } else {
                waitingForOtherPairofCords = true;
              }
              notifyChanged();
            }
          },
          onHorizontalDragDown: (details) {
            isOnTap = false;
            _stopAnimation();
            _onDragChanged(true);
          },
          onHorizontalDragUpdate: (details) {
            if (isScale || isLongPress) return;
            mScrollX = ((details.primaryDelta ?? 0) / mScaleX + mScrollX)
                .clamp(0.0, ChartPainter.maxScrollX)
                .toDouble();
            notifyChanged();
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            var velocity = details.velocity.pixelsPerSecond.dx;
            _onFling(velocity);
          },
          onHorizontalDragCancel: () => _onDragChanged(false),
          onScaleStart: (_) {
            isScale = true;
          },
          onScaleUpdate: (details) {
            if (isDrag || isLongPress) return;
            mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
            notifyChanged();
          },
          onScaleEnd: (_) {
            isScale = false;
            _lastScale = mScaleX;
          },
          onLongPressStart: (details) {
            isOnTap = false;
            isLongPress = true;
            if ((mSelectX != details.localPosition.dx ||
                    mSelectY != details.globalPosition.dy) &&
                !widget.isTrendLine) {
              mSelectX = details.localPosition.dx;
              notifyChanged();
            }
            //For TrendLine
            if (widget.isTrendLine && changeinXposition == null) {
              mSelectX = changeinXposition = details.localPosition.dx;
              mSelectY = changeinYposition = details.globalPosition.dy;
              notifyChanged();
            }
            //For TrendLine
            if (widget.isTrendLine && changeinXposition != null) {
              changeinXposition = details.localPosition.dx;
              changeinYposition = details.globalPosition.dy;
              notifyChanged();
            }
          },
          onLongPressMoveUpdate: (details) {
            if ((mSelectX != details.localPosition.dx ||
                    mSelectY != details.globalPosition.dy) &&
                !widget.isTrendLine) {
              mSelectX = details.localPosition.dx;
              mSelectY = details.localPosition.dy;
              notifyChanged();
            }
            if (widget.isTrendLine) {
              mSelectX =
                  mSelectX + (details.localPosition.dx - changeinXposition!);
              changeinXposition = details.localPosition.dx;
              mSelectY =
                  mSelectY + (details.globalPosition.dy - changeinYposition!);
              changeinYposition = details.globalPosition.dy;
              notifyChanged();
            }
          },
          onLongPressEnd: (details) {
            isLongPress = false;
            enableCordRecord = true;
            mInfoWindowStream.sink.add(null);
            notifyChanged();
          },
          child: Stack(
            children: <Widget>[
              CustomPaint(
                size: Size(double.infinity, baseDimension.mDisplayHeight),
                painter: _painter,
              ),
              if (widget.showInfoDialog) _buildInfoDialog()
            ],
          ),
        );
      },
    );
  }

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller!.isAnimating) {
      _controller!.stop();
      _onDragChanged(false);
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  void _onDragChanged(bool isOnDrag) {
    isDrag = isOnDrag;
    if (widget.isOnDrag != null) {
      widget.isOnDrag!(isDrag);
    }
  }

  void _onFling(double x) {
    _controller = AnimationController(
        duration: Duration(milliseconds: widget.flingTime), vsync: this);
    aniX = null;
    aniX = Tween<double>(begin: mScrollX, end: x * widget.flingRatio + mScrollX)
        .animate(CurvedAnimation(
            parent: _controller!.view, curve: widget.flingCurve));
    aniX!.addListener(() {
      mScrollX = aniX!.value;
      if (mScrollX <= 0) {
        mScrollX = 0;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(true);
        }
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore!(false);
        }
        _stopAnimation();
      }
      notifyChanged();
    });
    aniX!.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    _controller!.forward();
  }

  void notifyChanged() => setState(() {});

  late List<String> infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity?>(
      stream: mInfoWindowStream.stream,
      builder: (context, snapshot) {
        if ((!isLongPress && !isOnTap) ||
            widget.isLine == true ||
            !snapshot.hasData ||
            snapshot.data?.kLineEntity == null) return SizedBox();
        KLineEntity entity = snapshot.data!.kLineEntity;
        final dialogWidth = mWidth / 3;
        if (snapshot.data!.isLeft) {
          return Positioned(
            top: 25,
            left: 10.0,
            child: PopupInfoView(
              entity: entity,
              width: dialogWidth,
              chartColors: widget.chartColors,
              chartTranslations: widget.chartTranslations,
              materialInfoDialog: widget.materialInfoDialog,
              timeFormat: widget.timeFormat,
              fixedLength: widget.fixedLength,
            ),
          );
        }
        return Positioned(
          top: 25,
          right: 10.0,
          child: PopupInfoView(
            entity: entity,
            width: dialogWidth,
            chartColors: widget.chartColors,
            chartTranslations: widget.chartTranslations,
            materialInfoDialog: widget.materialInfoDialog,
            timeFormat: widget.timeFormat,
            fixedLength: widget.fixedLength,
          ),
        );
      },
    );
  }
}
