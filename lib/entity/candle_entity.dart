// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import,camel_case_types
mixin CandleEntity {
  late double open;
  late double high;
  late double low;
  late double close;
  late double vol;

  List<double>? maValueList;
  List<double>? emaValueList; // EMA 값을 저장할 리스트로 변경
  List<double>? avlValueList; // 평균체결가격 리스트

//  上轨线
  double? up;

//  中轨线
  double? mb;

//  下轨线
  double? dn;

  double? BOLLMA;

  double? ema5;
  double? ema10;
  double? ema20;
  double? sar;

  // Average Volume Line
  double? avl5;
  double? avl10;
  double? avl20;
}
