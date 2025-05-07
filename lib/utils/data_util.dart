import 'dart:math';

import '../entity/index.dart';

class DataUtil {
  static calculate(List<KLineEntity> dataList,
      [List<int> maDayList = const [5, 10, 20],
      List<int> emaDayList = const [5, 10, 20],
      List<int> avlDayList = const [5, 10, 20],
      int n = 20,
      k = 2,
      double sarStart = 0.02,
      double sarMaximum = 0.2,
      int bollPeriod = 20,
      double bollBandwidth = 2.0]) {
    calcMA(dataList, maDayList);
    calcBOLL(dataList, bollPeriod, bollBandwidth);
    calcVolumeMA(dataList, avlDayList);
    calcKDJ(dataList);
    calcMACD(dataList);
    calcRSI(dataList);
    calcWR(dataList);
    calcCCI(dataList);
    calculateEMA(dataList, emaDayList);
    calculateSAR(dataList, start: sarStart, maximum: sarMaximum);
    calculateAVL(dataList);
  }

  static calcMA(List<KLineEntity> dataList, List<int> maDayList) {
    List<double> ma = List<double>.filled(maDayList.length, 0);

    if (dataList.isNotEmpty) {
      for (int i = 0; i < dataList.length; i++) {
        KLineEntity entity = dataList[i];
        final closePrice = entity.close;
        entity.maValueList = List<double>.filled(maDayList.length, 0);

        for (int j = 0; j < maDayList.length; j++) {
          ma[j] += closePrice;
          if (i == maDayList[j] - 1) {
            entity.maValueList?[j] = ma[j] / maDayList[j];
          } else if (i >= maDayList[j]) {
            ma[j] -= dataList[i - maDayList[j]].close;
            entity.maValueList?[j] = ma[j] / maDayList[j];
          } else {
            entity.maValueList?[j] = 0;
          }
        }
      }
    }
  }

  static void calcBOLL(
      List<KLineEntity> dataList, int period, double bandwidth) {
    _calcBOLLMA(period, dataList);
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      if (i >= period) {
        double md = 0;
        for (int j = i - period + 1; j <= i; j++) {
          double c = dataList[j].close;
          double m = entity.BOLLMA!;
          double value = c - m;
          md += value * value;
        }
        md = md / (period - 1);
        md = sqrt(md);
        entity.mb = entity.BOLLMA!;
        entity.up = entity.mb! + bandwidth * md;
        entity.dn = entity.mb! - bandwidth * md;
      }
    }
  }

  static void _calcBOLLMA(int day, List<KLineEntity> dataList) {
    double ma = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      ma += entity.close;
      if (i == day - 1) {
        entity.BOLLMA = ma / day;
      } else if (i >= day) {
        ma -= dataList[i - day].close;
        entity.BOLLMA = ma / day;
      } else {
        entity.BOLLMA = null;
      }
    }
  }

  static void calcMACD(List<KLineEntity> dataList) {
    double ema12 = 0;
    double ema26 = 0;
    double dif = 0;
    double dea = 0;
    double macd = 0;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final closePrice = entity.close;
      if (i == 0) {
        ema12 = closePrice;
        ema26 = closePrice;
      } else {
        // EMA（12） = 前一日EMA（12） X 11/13 + 今日收盘价 X 2/13
        ema12 = ema12 * 11 / 13 + closePrice * 2 / 13;
        // EMA（26） = 前一日EMA（26） X 25/27 + 今日收盘价 X 2/27
        ema26 = ema26 * 25 / 27 + closePrice * 2 / 27;
      }
      // DIF = EMA（12） - EMA（26） 。
      // 今日DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
      // 用（DIF-DEA）*2即为MACD柱状图。
      dif = ema12 - ema26;
      dea = dea * 8 / 10 + dif * 2 / 10;
      macd = (dif - dea) * 2;
      entity.dif = dif;
      entity.dea = dea;
      entity.macd = macd;
    }
  }

  static void calcVolumeMA(
      List<KLineEntity> dataList, List<int> volumeMaDayList) {
    if (dataList.isEmpty) return;

    // 각 데이터 포인트에 대해 MA 값을 계산
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];

      // 이전 데이터 포인트 연결
      if (i > 0) {
        entity.previous = dataList[i - 1];
      }

      // MA 값 계산
      entity.volumeMaDayList = volumeMaDayList;
      entity.calculateVolumeMA(volumeMaDayList);
    }
  }

  static void calcRSI(List<KLineEntity> dataList) {
    double? rsi;
    double rsiABSEma = 0;
    double rsiMaxEma = 0;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      final double closePrice = entity.close;
      if (i == 0) {
        rsi = 0;
        rsiABSEma = 0;
        rsiMaxEma = 0;
      } else {
        double rMax = max(0, closePrice - dataList[i - 1].close.toDouble());
        double rAbs = (closePrice - dataList[i - 1].close.toDouble()).abs();

        rsiMaxEma = (rMax + (14 - 1) * rsiMaxEma) / 14;
        rsiABSEma = (rAbs + (14 - 1) * rsiABSEma) / 14;
        rsi = (rsiMaxEma / rsiABSEma) * 100;
      }
      if (i < 13) rsi = null;
      if (rsi != null && rsi.isNaN) rsi = null;
      entity.rsi = rsi;
    }
  }

  static void calcKDJ(List<KLineEntity> dataList) {
    var preK = 50.0;
    var preD = 50.0;
    final tmp = dataList.first;
    tmp.k = preK;
    tmp.d = preD;
    tmp.j = 50.0;
    for (int i = 1; i < dataList.length; i++) {
      final entity = dataList[i];
      final n = max(0, i - 8);
      var low = entity.low;
      var high = entity.high;
      for (int j = n; j < i; j++) {
        final t = dataList[j];
        if (t.low < low) {
          low = t.low;
        }
        if (t.high > high) {
          high = t.high;
        }
      }
      final cur = entity.close;
      var rsv = (cur - low) * 100.0 / (high - low);
      rsv = rsv.isNaN ? 0 : rsv;
      final k = (2 * preK + rsv) / 3.0;
      final d = (2 * preD + k) / 3.0;
      final j = 3 * k - 2 * d;
      preK = k;
      preD = d;
      entity.k = k;
      entity.d = d;
      entity.j = j;
    }
  }

  static void calcWR(List<KLineEntity> dataList) {
    double r;
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      int startIndex = i - 14;
      if (startIndex < 0) {
        startIndex = 0;
      }
      double max14 = double.minPositive;
      double min14 = double.maxFinite;
      for (int index = startIndex; index <= i; index++) {
        max14 = max(max14, dataList[index].high);
        min14 = min(min14, dataList[index].low);
      }
      if (i < 13) {
        entity.r = -10;
      } else {
        r = -100 * (max14 - dataList[i].close) / (max14 - min14);
        if (r.isNaN) {
          entity.r = null;
        } else {
          entity.r = r;
        }
      }
    }
  }

  static void calcCCI(List<KLineEntity> dataList) {
    final size = dataList.length;
    final count = 14;
    for (int i = 0; i < size; i++) {
      final kline = dataList[i];
      final tp = (kline.high + kline.low + kline.close) / 3;
      final start = max(0, i - count + 1);
      var amount = 0.0;
      var len = 0;
      for (int n = start; n <= i; n++) {
        amount += (dataList[n].high + dataList[n].low + dataList[n].close) / 3;
        len++;
      }
      final ma = amount / len;
      amount = 0.0;
      for (int n = start; n <= i; n++) {
        amount +=
            (ma - (dataList[n].high + dataList[n].low + dataList[n].close) / 3)
                .abs();
      }
      final md = amount / len;
      kline.cci = ((tp - ma) / 0.015 / md);
      if (kline.cci!.isNaN) {
        kline.cci = 0.0;
      }
    }
  }

  static void calculateEMA(List<KLineEntity> dataList,
      [List<int> emaDayList = const [5, 10, 20]]) {
    List<double> ema = List<double>.filled(emaDayList.length, 0.0);
    List<double> k = emaDayList.map((day) => 2.0 / (day + 1)).toList();

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      entity.emaValueList = List<double>.filled(emaDayList.length, 0.0);

      if (i == 0) {
        for (int j = 0; j < emaDayList.length; j++) {
          ema[j] = entity.close;
          entity.emaValueList?[j] = ema[j];
        }
      } else {
        for (int j = 0; j < emaDayList.length; j++) {
          ema[j] = ema[j] * (1 - k[j]) + entity.close * k[j];
          entity.emaValueList?[j] = ema[j];
        }
      }
    }
  }

  static void calculateSAR(List<KLineEntity> dataList,
      {double start = 0.02, double maximum = 0.2}) {
    double acceleration = start;
    double maxAcceleration = maximum;
    double sar = 0.0;
    bool isLong = true;
    double ep = 0.0;
    double af = acceleration;

    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      if (i == 0) {
        sar = entity.low;
        ep = entity.high;
      } else {
        if (isLong) {
          if (entity.low < sar) {
            isLong = false;
            sar = ep;
            ep = entity.low;
            af = acceleration;
          } else {
            if (entity.high > ep) {
              ep = entity.high;
              af = min(af + acceleration, maxAcceleration);
            }
            sar = sar + af * (ep - sar);
          }
        } else {
          if (entity.high > sar) {
            isLong = true;
            sar = ep;
            ep = entity.high;
            af = acceleration;
          } else {
            if (entity.low < ep) {
              ep = entity.low;
              af = min(af + acceleration, maxAcceleration);
            }
            sar = sar + af * (ep - sar);
          }
        }
      }
      entity.sar = sar;
    }
  }

  static void calculateAVL(List<KLineEntity> dataList) {
    for (int i = 0; i < dataList.length; i++) {
      KLineEntity entity = dataList[i];
      // 각 캔들의 중간값 계산 ((고가 + 저가) / 2)
      entity.avl = (entity.high + entity.low) / 2;
    }
  }
}
