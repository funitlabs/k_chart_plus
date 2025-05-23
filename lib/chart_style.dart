import 'package:flutter/material.dart' show Color;

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
  Color bgColor;

  Color kLineColor;

  ///
  Color lineFillColor;

  ///
  Color lineFillInsideColor;

  /// color: ma5, ma10, ma30, up, down, vol, macd, diff, dea, k, d, j, rsi
  Color ma5Color;
  Color ma10Color;
  Color ma20Color;
  Color ma30Color;
  Color ma60Color;
  Color ma120Color;
  Color ma250Color;
  Color avlColor;
  Color upColor;
  Color dnColor;
  Color volColor;

  Color macdColor;
  Color difColor;
  Color deaColor;

  Color kColor;
  Color dColor;
  Color jColor;
  Color rsiColor;

  /// default text color: apply for text at grid
  Color defaultTextColor;

  /// color of the current price
  Color nowPriceUpColor;
  Color nowPriceDnColor;
  Color nowPriceTextColor;

  /// trend color
  Color trendLineColor;

  /// depth color
  Color depthBuyColor; //upColor
  Color depthBuyPathColor;
  Color depthSellColor; //dnColor
  Color depthSellPathColor;

  ///value border color after selection
  Color selectBorderColor;

  ///background color when value selected
  Color selectFillColor;

  ///color of grid
  Color gridColor;

  ///color of annotation content
  Color infoWindowNormalColor;
  Color infoWindowTitleColor;
  Color infoWindowUpColor;
  Color infoWindowDnColor;

  /// color of the horizontal cross line
  Color hCrossColor;

  /// color of the vertical cross line
  Color vCrossColor;

  /// text color
  Color crossTextColor;

  ///The color of the maximum and minimum values in the current display
  Color maxColor;
  Color minColor;

  /// get MA color via index
  Color getMAColor(int index) {
    switch (index % 3) {
      case 1:
        return ma10Color;
      case 2:
        return ma30Color;
      default:
        return ma5Color;
    }
  }

  /// constructor chart color
  ChartColors({
    this.bgColor = const Color(0xffffffff),
    this.kLineColor = const Color(0xff4C86CD),

    ///
    this.lineFillColor = const Color(0x554C86CD),

    ///
    this.lineFillInsideColor = const Color(0x00000000),

    ///
    this.ma5Color = const Color(0xffE5B767),
    this.ma10Color = const Color(0xff1FD1AC),
    this.ma20Color = const Color(0xFFE6A23C),
    this.ma30Color = const Color(0xFFE6A23C),
    this.ma60Color = const Color(0xFFE6A23C),
    this.ma120Color = const Color(0xFFE6A23C),
    this.ma250Color = const Color(0xFFE6A23C),
    this.avlColor = const Color(0xFF2196F3),
    this.upColor = const Color(0xFF14AD8F),
    this.dnColor = const Color(0xFFD5405D),
    this.volColor = const Color(0xff2f8fd5),
    this.macdColor = const Color(0xff2f8fd5),
    this.difColor = const Color(0xffE5B767),
    this.deaColor = const Color(0xff1FD1AC),
    this.kColor = const Color(0xffE5B767),
    this.dColor = const Color(0xff1FD1AC),
    this.jColor = const Color(0xffB48CE3),
    this.rsiColor = const Color(0xffE5B767),
    this.defaultTextColor = const Color(0xFF909196),
    this.nowPriceUpColor = const Color(0xFF14AD8F),
    this.nowPriceDnColor = const Color(0xFFD5405D),
    this.nowPriceTextColor = const Color(0xffffffff),

    /// trend color
    this.trendLineColor = const Color(0xFFF89215),

    ///depth color
    this.depthBuyColor = const Color(0xFF14AD8F),
    this.depthBuyPathColor = const Color(0x3314AD8F),
    this.depthSellColor = const Color(0xFFD5405D),
    this.depthSellPathColor = const Color(0x33D5405D),

    ///value border color after selection
    this.selectBorderColor = const Color(0xFF222223),

    ///background color when value selected
    this.selectFillColor = const Color(0xffffffff),

    ///color of grid
    this.gridColor = const Color(0xFFD1D3DB),

    ///color of annotation content
    this.infoWindowNormalColor = const Color(0xFF222223),
    this.infoWindowTitleColor = const Color(0xFF4D4D4E), //0xFF707070
    this.infoWindowUpColor = const Color(0xFF14AD8F),
    this.infoWindowDnColor = const Color(0xFFD5405D),
    this.hCrossColor = const Color(0xFF222223),
    this.vCrossColor = const Color(0x28424652),
    this.crossTextColor = const Color(0xFF222223),

    ///The color of the maximum and minimum values in the current display
    this.maxColor = const Color(0xFF222223),
    this.minColor = const Color(0xFF222223),
  });
}

class ChartStyle {
  double topPadding = 30.0;

  double bottomPadding = 20.0;

  double childPadding = 12.0;

  ///point-to-point distance
  double pointWidth = 11.0;

  ///candle width
  double candleWidth = 8.5;
  double candleLineWidth = 1.0;

  ///vol column width
  double volWidth = 8.5;

  ///macd column width
  double macdWidth = 1.2;

  ///vertical-horizontal cross line width
  double vCrossWidth = 8.5;
  double hCrossWidth = 0.5;

  ///(line length - space line - thickness) of the current price
  double nowPriceLineLength = 4.5;
  double nowPriceLineSpan = 3.5;
  double nowPriceLineWidth = 1;

  int gridRows = 4;
  int gridColumns = 4;

  ///customize the time below
  List<String>? dateTimeFormat;

  double lineWidth = 1.0;

  /// SAR parameters
  double sarStart = 0.02;
  double sarMaximum = 0.2;

  /// BOLL parameters
  int bollPeriod = 20;
  double bollBandwidth = 2.0;

  /// VOL decimal places
  int volDecimalPlaces = 0;

  ChartStyle({
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
