// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import,camel_case_types
mixin VolumeEntity {
  late double open;
  late double close;
  late double vol;

  // 동적 MA 값을 저장할 Map
  Map<int, double> _maVolumeMap = {};

  // MA 값을 동적으로 가져오는 메서드
  double? getMAVolume(int day) {
    // 먼저 기존 고정 MA 값 확인
    return _maVolumeMap[day];
  }

  // 동적 MA 값을 설정하는 메서드
  void setMAVolume(int day, double value) {
    _maVolumeMap[day] = value;
  }

  // 동적 MA 값이 있는지 확인하는 메서드
  bool hasMAVolume(int day) {
    return _maVolumeMap.containsKey(day);
  }
}
