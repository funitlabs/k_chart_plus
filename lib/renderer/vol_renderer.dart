import 'package:flutter/material.dart';
import 'package:k_chart_plus/k_chart_plus.dart';

class VolRenderer extends BaseChartRenderer<VolumeEntity> {
  late double mVolWidth;
  final ChartStyle chartStyle;
  final ChartColors chartColors;
  final List<int> volumeMaDayList;

  VolRenderer(
      Rect mainRect,
      double maxValue,
      double minValue,
      double topPadding,
      int fixedLength,
      this.chartStyle,
      this.chartColors,
      this.volumeMaDayList)
      : super(
          chartRect: mainRect,
          maxValue: maxValue,
          minValue: minValue,
          topPadding: topPadding,
          fixedLength: fixedLength,
          gridColor: chartColors.gridColor,
        ) {
    mVolWidth = this.chartStyle.volWidth;
  }

  double _getVolumeMAValue(VolumeEntity point, int day) {
    if (point == null) return 0;
    return point.getMAVolume(day) ?? 0;
  }

  @override
  void drawChart(VolumeEntity lastPoint, VolumeEntity curPoint, double lastX,
      double curX, Size size, Canvas canvas) {
    if (curPoint == null) return;

    double r = mVolWidth / 2;
    double top = getVolY(curPoint.vol);
    double bottom = chartRect.bottom;
    if (curPoint.vol != 0) {
      canvas.drawRect(
          Rect.fromLTRB(curX - r, top, curX + r, bottom),
          chartPaint
            ..color = curPoint.close > curPoint.open
                ? this.chartColors.upColor
                : this.chartColors.dnColor);
    }

    // volumeMaDayList에 있는 기간에 대해서만 MA 라인을 그립니다
    for (int i = 0; i < volumeMaDayList.length; i++) {
      final day = volumeMaDayList[i];
      final maValue = _getVolumeMAValue(curPoint, day);
      final lastMaValue = _getVolumeMAValue(lastPoint, day);
      if (lastMaValue != 0 && maValue != 0) {
        drawLine(lastMaValue, maValue, canvas, lastX, curX,
            this.chartColors.getMAColor(i));
      }
    }
  }

  double getVolY(double value) =>
      (maxValue - value) * (chartRect.height / maxValue) + chartRect.top;

  @override
  void drawText(Canvas canvas, VolumeEntity data, double x) {
    if (data == null || data.vol == 0) return;

    TextSpan span = TextSpan(
      children: [
        TextSpan(
          text:
              "VOL:${data.vol >= 1000 ? NumberUtil.format(data.vol) : data.vol.toStringAsFixed(chartStyle.volDecimalPlaces)} ",
          style: getTextStyle(this.chartColors.volColor),
        ),
        ...volumeMaDayList
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key;
              final day = entry.value;
              final maValue = _getVolumeMAValue(data, day);
              if (maValue == 0) return null;

              // indicatorColors의 인덱스를 순환하여 사용 (0~3)
              return TextSpan(
                text:
                    "MA($day):${maValue >= 1000 ? NumberUtil.format(maValue) : maValue.toStringAsFixed(chartStyle.volDecimalPlaces)} ",
                style: getTextStyle(this.chartColors.getMAColor(index)),
              );
            })
            .whereType<TextSpan>()
            .toList(),
      ],
    );
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, chartRect.top - topPadding));
  }

  @override
  void drawVerticalText(canvas, textStyle, int gridRows) {
    TextSpan span = TextSpan(
        text:
            "${maxValue >= 1000 ? NumberUtil.format(maxValue) : maxValue.toStringAsFixed(chartStyle.volDecimalPlaces)}",
        style: textStyle);
    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(
        canvas, Offset(chartRect.width - tp.width, chartRect.top - topPadding));
  }

  @override
  void drawGrid(Canvas canvas, int gridRows, int gridColumns) {
    canvas.drawLine(Offset(0, chartRect.bottom),
        Offset(chartRect.width, chartRect.bottom), gridPaint);
    double columnSpace = chartRect.width / gridColumns;
    for (int i = 0; i <= columnSpace; i++) {
      //vol垂直线
      canvas.drawLine(Offset(columnSpace * i, chartRect.top - topPadding),
          Offset(columnSpace * i, chartRect.bottom), gridPaint);
    }
  }
}
