import 'package:flutter/material.dart';

/// ChartColors
///
/// Note:
/// If you need to apply multi theme, you need to change at least the colors related to the text, border and background color
/// Ex:
/// Background: bgColor, selectFillColor
/// Border
/// Text
///
class ChartColors {
  /// the background color of base chart
  final Color bgColor;

  final Color kLineColor;

  ///
  final Color lineFillColor;

  ///
  final Color lineFillInsideColor;

  /// color: ma5, ma10, ma30, up, down, vol, macd, diff, dea, k, d, j, rsi
  final Color ma5Color;
  final Color ma10Color;
  final Color ma30Color;
  final Color ma60Color;
  final Color ma90Color;
  final Color ma120Color;
  final Color ma250Color;
  final Color ma360Color;
  final Color ma720Color;
  final Color ma1080Color;
  final Color ma1440Color;
  final Color avlColor;
  final Color upColor;
  final Color dnColor;
  final Color volColor;

  final Color macdColor;
  final Color difColor;
  final Color deaColor;

  final Color kColor;
  final Color dColor;
  final Color jColor;
  final Color rsiColor;

  /// default text color: apply for text at grid
  final Color defaultTextColor;

  /// color of the current price
  final Color nowPriceUpColor;
  final Color nowPriceDnColor;
  final Color nowPriceTextColor;

  /// trend color
  final Color trendLineColor;

  /// depth color
  final Color depthBuyColor; //upColor
  final Color depthBuyPathColor;
  final Color depthSellColor; //dnColor
  final Color depthSellPathColor;

  ///value border color after selection
  final Color selectBorderColor;

  ///background color when value selected
  final Color selectFillColor;

  ///color of grid
  final Color gridColor;

  ///color of annotation content
  final Color infoWindowNormalColor;
  final Color infoWindowTitleColor;
  final Color infoWindowUpColor;
  final Color infoWindowDnColor;

  /// color of the horizontal cross line
  final Color hCrossColor;

  /// color of the vertical cross line
  final Color vCrossColor;

  /// text color
  final Color crossTextColor;

  ///The color of the maximum and minimum values in the current display
  final Color maxColor;
  final Color minColor;

  List<Color>? indicatorColors = [
    Colors.orange,
    Colors.pink,
    Colors.deepPurple,
    Colors.greenAccent,
    Colors.brown,
    Colors.teal,
    Colors.indigo,
    Colors.lightGreen,
    Colors.deepOrange,
    Colors.deepPurple,
  ];

  /// get MA color via index
  Color getMAColor(int index) {
    if (indicatorColors != null && indicatorColors!.isNotEmpty) {
      return indicatorColors![index];
    } else {
      switch (index) {
        case 0:
          return ma5Color;
        case 1:
          return ma10Color;
        case 2:
          return ma30Color;
        case 3:
          return ma60Color;
        case 4:
          return ma90Color;
        case 5:
          return ma120Color;
        case 6:
          return ma250Color;
        case 7:
          return ma360Color;
        case 8:
          return ma720Color;
        case 9:
          return ma1080Color;
        default:
          return ma1440Color;
      }
    }
  }

  /// constructor chart color
  ChartColors({
    this.bgColor = const Color(0xFF1E222D),
    this.kLineColor = const Color(0xFF4C86CD),

    ///
    this.lineFillColor = const Color(0x1A4C86CD),

    ///
    this.lineFillInsideColor = const Color(0x0A4C86CD),

    ///
    this.ma5Color = const Color(0xFFC9B885),
    this.ma10Color = const Color(0xFF6CB0A6),
    this.ma30Color = const Color(0xFF9979C6),
    this.ma60Color = const Color(0xFFC6B5E5),
    this.ma90Color = const Color(0xFFE6A23C),
    this.ma120Color = const Color(0xFF67C23A),
    this.ma250Color = const Color(0xFFF56C6C),
    this.ma360Color = const Color(0xFF909399),
    this.ma720Color = const Color(0xFFE6A23C),
    this.ma1080Color = const Color(0xFF67C23A),
    this.ma1440Color = const Color(0xFFF56C6C),
    this.avlColor = const Color(0xFFC9B885),
    this.upColor = const Color(0xFF14AD8F),
    this.dnColor = const Color(0xFFD5405D),
    this.volColor = const Color(0xFF4729AE),
    this.macdColor = const Color(0xFF4729AE),
    this.difColor = const Color(0xFFC9B885),
    this.deaColor = const Color(0xFF6CB0A6),
    this.kColor = const Color(0xFFC9B885),
    this.dColor = const Color(0xFF6CB0A6),
    this.jColor = const Color(0xFF9979C6),
    this.rsiColor = const Color(0xFFC9B885),
    this.defaultTextColor = const Color(0xFF60738E),
    this.nowPriceUpColor = const Color(0xFF14AD8F),
    this.nowPriceDnColor = const Color(0xFFD5405D),
    this.nowPriceTextColor = const Color(0xFF60738E),

    /// trend color
    this.trendLineColor = const Color(0xFF60738E),

    ///depth color
    this.depthBuyColor = const Color(0xFF14AD8F),
    this.depthBuyPathColor = const Color(0x3314AD8F),
    this.depthSellColor = const Color(0xFFD5405D),
    this.depthSellPathColor = const Color(0x33D5405D),

    ///value border color after selection
    this.selectBorderColor = const Color(0xFF4C86CD),

    ///background color when value selected
    this.selectFillColor = const Color(0x0A4C86CD),

    ///color of grid
    this.gridColor = const Color(0xFF1E222D),

    ///color of annotation content
    this.infoWindowNormalColor = const Color(0xFF60738E),
    this.infoWindowTitleColor = const Color(0xFF60738E),
    this.infoWindowUpColor = const Color(0xFF14AD8F),
    this.infoWindowDnColor = const Color(0xFFD5405D),
    this.hCrossColor = const Color(0xFF60738E),
    this.vCrossColor = const Color(0xFF60738E),
    this.crossTextColor = const Color(0xFF60738E),

    ///The color of the maximum and minimum values in the current display
    this.maxColor = const Color(0xFF60738E),
    this.minColor = const Color(0xFF60738E),
    this.indicatorColors,
  });
}

class ChartStyle {
  final double topPadding;
  final double bottomPadding;
  final double childPadding;
  final double pointWidth;
  final double candleWidth;
  final double candleLineWidth;
  final double volWidth;
  final double macdWidth;
  final double vCrossWidth;
  final double hCrossWidth;
  final double nowPriceLineLength;
  final double nowPriceLineSpan;
  final double nowPriceLineWidth;
  final int gridRows;
  final int gridColumns;
  final List<String>? dateTimeFormat;
  final double lineWidth;
  final double sarStart;
  final double sarMaximum;
  final int bollPeriod;
  final double bollBandwidth;
  final int volDecimalPlaces;

  const ChartStyle({
    this.topPadding = 30.0,
    this.bottomPadding = 20.0,
    this.childPadding = 12.0,
    this.pointWidth = 11.0,
    this.candleWidth = 8.5,
    this.candleLineWidth = 1.0,
    this.volWidth = 8.5,
    this.macdWidth = 1.2,
    this.vCrossWidth = 8.5,
    this.hCrossWidth = 0.5,
    this.nowPriceLineLength = 4.5,
    this.nowPriceLineSpan = 3.5,
    this.nowPriceLineWidth = 1,
    this.gridRows = 4,
    this.gridColumns = 4,
    this.dateTimeFormat,
    this.lineWidth = 1.0,
    this.sarStart = 0.02,
    this.sarMaximum = 0.2,
    this.bollPeriod = 20,
    this.bollBandwidth = 2.0,
    this.volDecimalPlaces = 0,
  });
}
