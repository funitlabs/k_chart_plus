import 'package:flutter/material.dart';

import '../entity/candle_entity.dart';
import '../k_chart_widget.dart' show MainState;
import 'base_chart_renderer.dart';

enum VerticalTextAlignment { left, right }

//For TrendLine
double? trendLineMax;
double? trendLineScale;
double? trendLineContentRec;

class MainRenderer extends BaseChartRenderer<CandleEntity> {
  late double mCandleWidth;
  late double mCandleLineWidth;
  MainState state;
  bool isLine;

  //绘制的内容区域
  late Rect _contentRect;
  double _contentPadding = 5.0;
  List<int> maDayList;
  List<int> emaDayList;
  List<int> avlDayList;
  final ChartStyle chartStyle;
  final ChartColors chartColors;
  final double mLineStrokeWidth = 1.0;
  double scaleX;
  late Paint mLinePaint;
  final VerticalTextAlignment verticalTextAlignment;

  MainRenderer(
      Rect mainRect,
      double maxValue,
      double minValue,
      double topPadding,
      this.state,
      this.isLine,
      int fixedLength,
      this.chartStyle,
      this.chartColors,
      this.scaleX,
      this.verticalTextAlignment,
      [this.maDayList = const [5, 10, 20],
      this.emaDayList = const [5, 10, 20],
      this.avlDayList = const [5, 10, 20]])
      : super(
            chartRect: mainRect,
            maxValue: maxValue,
            minValue: minValue,
            topPadding: topPadding,
            fixedLength: fixedLength,
            gridColor: chartColors.gridColor) {
    mCandleWidth = this.chartStyle.candleWidth;
    mCandleLineWidth = this.chartStyle.candleLineWidth;
    mLinePaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = mLineStrokeWidth
      ..color = this.chartColors.kLineColor;
    _contentRect = Rect.fromLTRB(
        chartRect.left,
        chartRect.top + _contentPadding,
        chartRect.right,
        chartRect.bottom - _contentPadding);
    if (maxValue == minValue) {
      maxValue *= 1.5;
      minValue /= 2;
    }
    scaleY = _contentRect.height / (maxValue - minValue);
  }

  @override
  void drawText(Canvas canvas, CandleEntity data, double x) {
    if (isLine == true) return;
    TextSpan? span;
    if (state == MainState.MA) {
      span = TextSpan(
        children: _createMATextSpan(data),
      );
    } else if (state == MainState.BOLL) {
      span = TextSpan(
        children: [
          TextSpan(
              text:
                  "BOLL(${chartStyle.bollPeriod}, ${chartStyle.bollBandwidth.toStringAsFixed(1)}) ",
              style: getTextStyle(chartColors.indicatorColors?[0] ??
                  chartColors.defaultTextColor)),
          if (data.up != 0)
            TextSpan(
                text: "UP:${format(data.up)} ",
                style: getTextStyle(
                    chartColors.indicatorColors?[1] ?? chartColors.ma10Color)),
          if (data.mb != 0)
            TextSpan(
                text: "MB:${format(data.mb)} ",
                style: getTextStyle(
                    chartColors.indicatorColors?[2] ?? chartColors.ma5Color)),
          if (data.dn != 0)
            TextSpan(
                text: "DN:${format(data.dn)}",
                style: getTextStyle(
                    chartColors.indicatorColors?[3] ?? chartColors.ma30Color)),
        ],
      );
    } else if (state == MainState.EMA) {
      span = TextSpan(
        children: _createEMATextSpan(data),
      );
    } else if (state == MainState.SAR) {
      span = TextSpan(
        children: [
          if (data.sar != 0)
            TextSpan(
                text:
                    "SAR(${chartStyle.sarStart.toStringAsFixed(2)}, ${chartStyle.sarMaximum.toStringAsFixed(2)}): ${format(data.sar)}    ",
                style: getTextStyle(
                    chartColors.indicatorColors?[0] ?? chartColors.ma5Color)),
        ],
      );
    } else if (state == MainState.AVL) {
      span = TextSpan(
        children: _createAVLTextSpan(data),
      );
    }
    if (span == null) return;
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  List<InlineSpan> _createMATextSpan(CandleEntity data) {
    List<InlineSpan> result = [];
    for (int i = 0; i < (data.maValueList?.length ?? 0); i++) {
      if (data.maValueList?[i] != 0) {
        var item = TextSpan(
            text: "MA(${maDayList[i]}):${format(data.maValueList![i])} ",
            style: getTextStyle(this.chartColors.getMAColor(i)));
        result.add(item);
      }
    }
    return result;
  }

  List<InlineSpan> _createEMATextSpan(CandleEntity data) {
    List<InlineSpan> result = [];
    for (int i = 0; i < (data.emaValueList?.length ?? 0); i++) {
      if (data.emaValueList?[i] != 0) {
        result.add(TextSpan(
            text: "EMA(${emaDayList[i]}):${format(data.emaValueList![i])} ",
            style: getTextStyle(this.chartColors.getMAColor(i))));
      }
    }
    return result;
  }

  List<InlineSpan> _createAVLTextSpan(CandleEntity data) {
    return [
      TextSpan(
        text: "AVL:${format(data.avl ?? 0)}  ",
        style: getTextStyle(this.chartColors.avlColor),
      )
    ];
  }

  @override
  void drawChart(CandleEntity lastPoint, CandleEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    if (isLine) {
      drawPolyline(lastPoint.close, curPoint.close, canvas, lastX, curX);
    } else {
      drawCandle(curPoint, canvas, curX);
      if (state == MainState.MA) {
        drawMaLine(lastPoint, curPoint, canvas, lastX, curX);
      } else if (state == MainState.BOLL) {
        drawBollLine(lastPoint, curPoint, canvas, lastX, curX);
      } else if (state == MainState.EMA) {
        drawEMALine(lastPoint, curPoint, canvas, lastX, curX);
      } else if (state == MainState.SAR) {
        drawSARPoint(curPoint, canvas, curX);
      } else if (state == MainState.AVL) {
        drawAVLLine(lastPoint, curPoint, canvas, lastX, curX);
      }
    }
  }

  Shader? mLineFillShader;
  Path? mLinePath, mLineFillPath;
  Paint mLineFillPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  //画折线图
  drawPolyline(double lastPrice, double curPrice, Canvas canvas, double lastX,
      double curX) {
//    drawLine(lastPrice + 100, curPrice + 100, canvas, lastX, curX, ChartColors.kLineColor);
    mLinePath ??= Path();

//    if (lastX == curX) {
//      mLinePath.moveTo(lastX, getY(lastPrice));
//    } else {
////      mLinePath.lineTo(curX, getY(curPrice));
//      mLinePath.cubicTo(
//          (lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
//    }
    if (lastX == curX) lastX = 0; //起点位置填充
    mLinePath!.moveTo(lastX, getY(lastPrice));
    mLinePath!.cubicTo((lastX + curX) / 2, getY(lastPrice), (lastX + curX) / 2,
        getY(curPrice), curX, getY(curPrice));

    //画阴影
    mLineFillShader ??= LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      tileMode: TileMode.clamp,
      colors: [
        this.chartColors.lineFillColor,
        this.chartColors.lineFillInsideColor
      ],
    ).createShader(Rect.fromLTRB(
        chartRect.left, chartRect.top, chartRect.right, chartRect.bottom));
    mLineFillPaint..shader = mLineFillShader;

    mLineFillPath ??= Path();

    mLineFillPath!.moveTo(lastX, chartRect.height + chartRect.top);
    mLineFillPath!.lineTo(lastX, getY(lastPrice));
    mLineFillPath!.cubicTo((lastX + curX) / 2, getY(lastPrice),
        (lastX + curX) / 2, getY(curPrice), curX, getY(curPrice));
    mLineFillPath!.lineTo(curX, chartRect.height + chartRect.top);
    mLineFillPath!.close();

    canvas.drawPath(mLineFillPath!, mLineFillPaint);
    mLineFillPath!.reset();

    canvas.drawPath(mLinePath!,
        mLinePaint..strokeWidth = (mLineStrokeWidth / scaleX).clamp(0.1, 1.0));
    mLinePath!.reset();
  }

  void drawMaLine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX) {
    if (lastPoint.maValueList == null || curPoint.maValueList == null) return;
    for (int i = 0; i < curPoint.maValueList!.length && i < 10; i++) {
      if (lastPoint.maValueList![i] == 0) continue;
      drawLine(lastPoint.maValueList![i], curPoint.maValueList![i], canvas,
          lastX, curX, chartColors.getMAColor(i));
    }
  }

  void drawBollLine(CandleEntity lastPoint, CandleEntity curPoint,
      Canvas canvas, double lastX, double curX) {
    if (lastPoint.up != 0) {
      drawLine(lastPoint.up, curPoint.up, canvas, lastX, curX,
          chartColors.indicatorColors?[1] ?? chartColors.ma10Color);
    }
    if (lastPoint.mb != 0) {
      drawLine(lastPoint.mb, curPoint.mb, canvas, lastX, curX,
          chartColors.indicatorColors?[2] ?? chartColors.ma5Color);
    }
    if (lastPoint.dn != 0) {
      drawLine(lastPoint.dn, curPoint.dn, canvas, lastX, curX,
          chartColors.indicatorColors?[3] ?? chartColors.ma30Color);
    }
  }

  void drawEMALine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX) {
    if (lastPoint.emaValueList == null || curPoint.emaValueList == null) return;
    for (int i = 0; i < curPoint.emaValueList!.length && i < 10; i++) {
      if (lastPoint.emaValueList![i] == 0 || curPoint.emaValueList![i] == 0)
        continue;
      drawLine(lastPoint.emaValueList![i], curPoint.emaValueList![i], canvas,
          lastX, curX, chartColors.getMAColor(i));
    }
  }

  void drawSARPoint(CandleEntity curPoint, Canvas canvas, double curX) {
    if (curPoint.sar != 0) {
      double y = getY(curPoint.sar!);
      canvas.drawCircle(
          Offset(curX, y),
          2.0,
          Paint()
            ..color = chartColors.indicatorColors?[0] ?? chartColors.ma5Color);
    }
  }

  void drawAVLLine(CandleEntity lastPoint, CandleEntity curPoint, Canvas canvas,
      double lastX, double curX) {
    if (lastPoint.avl == null || curPoint.avl == null) return;

    double lastY = getY(lastPoint.avl!);
    double curY = getY(curPoint.avl!);

    canvas.drawLine(
        Offset(lastX, lastY),
        Offset(curX, curY),
        Paint()
          ..color = chartColors.indicatorColors?[0] ?? chartColors.avlColor
          ..strokeWidth = this.chartStyle.lineWidth
          ..isAntiAlias = true);
  }

  void drawCandle(CandleEntity curPoint, Canvas canvas, double curX) {
    var high = getY(curPoint.high);
    var low = getY(curPoint.low);
    var open = getY(curPoint.open);
    var close = getY(curPoint.close);
    double r = mCandleWidth / 2;
    double lineR = mCandleLineWidth / 2;
    if (open >= close) {
      // 实体高度>= CandleLineWidth
      if (open - close < mCandleLineWidth) {
        open = close + mCandleLineWidth;
      }
      chartPaint.color = this.chartColors.upColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, close, curX + r, open), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    } else if (close > open) {
      // 实体高度>= CandleLineWidth
      if (close - open < mCandleLineWidth) {
        open = close - mCandleLineWidth;
      }
      chartPaint.color = this.chartColors.dnColor;
      canvas.drawRect(
          Rect.fromLTRB(curX - r, open, curX + r, close), chartPaint);
      canvas.drawRect(
          Rect.fromLTRB(curX - lineR, high, curX + lineR, low), chartPaint);
    }
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    double rowSpace = chartRect.height / gridRows;
    for (var i = 0; i <= gridRows; ++i) {
      double value = (gridRows - i) * rowSpace / scaleY + minValue;
      TextSpan span = TextSpan(text: "${format(value)}", style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();

      double offsetX;
      switch (verticalTextAlignment) {
        case VerticalTextAlignment.left:
          offsetX = 0;
          break;
        case VerticalTextAlignment.right:
          offsetX = chartRect.width - tp.width;
          break;
      }

      if (i == 0) {
        tp.paint(canvas, Offset(offsetX, topPadding));
      } else {
        tp.paint(
            canvas, Offset(offsetX, rowSpace * i - tp.height + topPadding));
      }
    }
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
//    final int gridRows = 4, gridColumns = 4;
    double rowSpace = chartRect.height / gridRows;
    for (int i = 0; i <= gridRows; i++) {
      canvas.drawLine(Offset(0, rowSpace * i + topPadding),
          Offset(chartRect.width, rowSpace * i + topPadding), gridPaint);
    }
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      canvas.drawLine(Offset(columnSpace * i, topPadding / 3),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }

  @override
  double getY(double y) {
    //For TrendLine
    updateTrendLineData();
    return (maxValue - y) * scaleY + _contentRect.top;
  }

  void updateTrendLineData() {
    trendLineMax = maxValue;
    trendLineScale = scaleY;
    trendLineContentRec = _contentRect.top;
  }
}
