// 課務相關模型 (課表、成績)

import 'common_models.dart';

/// 高醫節次對照表 (對齊 reference/kmucoursequery_wac.py PERIOD_MAP)
/// 1~9 為日間，A~D 為夜間
class KmuPeriod {
  const KmuPeriod(this.code, this.timeRange);
  final String code;
  final String timeRange;

  static const List<KmuPeriod> all = [
    KmuPeriod('1', '08:10-09:00'),
    KmuPeriod('2', '09:10-10:00'),
    KmuPeriod('3', '10:10-11:00'),
    KmuPeriod('4', '11:10-12:00'),
    KmuPeriod('5', '13:10-14:00'),
    KmuPeriod('6', '14:10-15:00'),
    KmuPeriod('7', '15:10-16:00'),
    KmuPeriod('8', '16:10-17:00'),
    KmuPeriod('9', '17:10-18:00'),
    KmuPeriod('A', '18:10-19:00'),
    KmuPeriod('B', '19:10-20:00'),
    KmuPeriod('C', '20:10-21:00'),
    KmuPeriod('D', '21:10-22:00'),
  ];

  /// 節次代碼 → 該節起始時間 HH:mm
  static String? startTimeOf(String code) {
    for (final p in all) {
      if (p.code == code) return p.timeRange.split('-').first;
    }
    return null;
  }

  /// 節次代碼 → 該節結束時間 HH:mm
  static String? endTimeOf(String code) {
    for (final p in all) {
      if (p.code == code) return p.timeRange.split('-').last;
    }
    return null;
  }

  /// 起始節次 + 結束節次 → 連續節次代碼清單 (對齊 Python get_period_range)
  static List<String> expandRange(String? bcl, String? ecl) {
    if (bcl == null || bcl.isEmpty || ecl == null || ecl.isEmpty) return const [];
    final keys = all.map((p) => p.code).toList();
    final upperBcl = bcl.toUpperCase();
    final upperEcl = ecl.toUpperCase();
    final i1 = keys.indexOf(upperBcl);
    final i2 = keys.indexOf(upperEcl);
    if (i1 < 0 || i2 < 0) return [bcl];
    if (i1 > i2) return [bcl];
    return keys.sublist(i1, i2 + 1);
  }
}

/// 課程基本資訊
class Course {
  const Course({
    required this.id,
    required this.name,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    required this.startWeek,
    required this.endWeek,
    required this.credit,
    this.teacher,
    this.classroom,
    this.building,
    this.weeks,
    this.type,
    this.color,
    this.department,
    this.semester,
    // Python API 詳細欄位
    this.cm,
    this.cono,
    this.deptnam,
    this.edeptnam,
    this.englishco,
    this.esm,
    this.ecsk,
    this.furcm,
    this.grade,
    this.mteafno,
    this.noryn,
    this.pid,
    this.secnam,
    this.secqty,
    this.sm,
    this.teafenam,
    this.teafnam,
    this.textbook,
    this.xdeptno,
    this.seqno,
    // 高醫 wac CSV 節次欄位 (從 qurq0006.php 取得)
    this.periodCode,
    this.periods = const [],
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Python API 欄位對應
    final year = json['year']?.toString() ?? '0';
    final sem = json['sem']?.toString() ?? '0';
    final seqno = json['seqno']?.toString().trim() ?? '';
    final id = '$year-$sem-$seqno';

    final chineseco = json['chineseco'] as String? ?? '';
    final englishco = json['englishco'] as String? ?? '';
    final name = chineseco.isNotEmpty ? chineseco : englishco;

    // wk 是 "1,3,5" 格式的星期幾 (Python API: 字串)
    // Python API: 0=Sunday, 1=Monday, ..., 6=Saturday
    // Flutter weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
    final wkStr = json['wk']?.toString().trim() ?? '';
    int weekday = 1;
    if (wkStr.isNotEmpty && wkStr != '0' && wkStr != 'null') {
      // 取第一個星期
      final firstWk = wkStr.split(',').first.trim();
      final pyWk = int.tryParse(firstWk) ?? 1;
      // Python 0=Sunday → Flutter 7; Python 1-6 → Flutter 1-6
      weekday = pyWk == 0 ? 7 : pyWk;
    }

    // wac CSV 節次欄位 (從 qurq0006.php join 進來)
    // periodCode = 第一節代碼 (1~9 / A~D)
    // periods = 展開後的連續節次清單
    final periodCodeRaw = json['periodCode']?.toString().trim();
    final periodsRaw = json['periods'];
    final List<String> periods = periodsRaw is List
        ? periodsRaw.map((e) => e.toString()).toList()
        : (periodCodeRaw != null && periodCodeRaw.isNotEmpty)
            ? [periodCodeRaw]
            : <String>[];

    // 從第一節推導上課時間 (若無 wac 資料則 fallback 預設值)
    String startTime;
    String endTime;
    if (periods.isNotEmpty) {
      startTime = KmuPeriod.startTimeOf(periods.first) ?? '08:00';
      final lastPeriod = periods.last;
      endTime = KmuPeriod.endTimeOf(lastPeriod) ?? '08:50';
    } else {
      startTime = '08:00';
      endTime = '08:50';
    }

    // credit 可能是字串或數字 (Python API: "0", "2", "3" 或 0/2/3)
    final creditRaw = json['credit'];
    double credit = 0.0;
    if (creditRaw is num) {
      credit = creditRaw.toDouble();
    } else if (creditRaw is String) {
      credit = double.tryParse(creditRaw) ?? 0.0;
    }

    // sm: 必修/選修/通識 -> type
    final sm = json['sm']?.toString() ?? '';
    final type = sm.contains('必修')
        ? 'required'
        : sm.contains('選修')
            ? 'elective'
            : sm.contains('通識')
                ? 'general'
                : 'other';

    // 學期
    final semester = '$year-$sem';

    return Course(
      id: id,
      name: name,
      weekday: weekday,
      startTime: startTime,
      endTime: endTime,
      startWeek: 1,
      endWeek: 18,
      credit: credit,
      teacher: json['teacherName']?.toString(),
      classroom: json['roomNo']?.toString(),
      building: null,
      weeks: wkStr,
      type: type,
      color: null,
      department: json['csk']?.toString(),
      semester: semester,
      // Python API 詳細欄位
      cm: json['cm']?.toString(),
      cono: json['cono']?.toString(),
      deptnam: json['deptnam']?.toString(),
      edeptnam: json['edeptnam']?.toString(),
      englishco: englishco.isNotEmpty ? englishco : null,
      esm: json['esm']?.toString(),
      ecsk: json['ecsk']?.toString(),
      furcm: json['furcm']?.toString(),
      grade: json['grade']?.toString(),
      mteafno: json['mteafno']?.toString(),
      noryn: json['noryn']?.toString(),
      pid: json['pid']?.toString(),
      secnam: json['secnam']?.toString(),
      secqty: json['secqty']?.toString(),
      sm: sm.isNotEmpty ? sm : null,
      teafenam: json['teafenam']?.toString(),
      teafnam: json['teafnam']?.toString(),
      textbook: json['textbook']?.toString(),
      xdeptno: json['xdeptno']?.toString(),
      seqno: seqno.isNotEmpty ? seqno : null,
      periodCode: periodCodeRaw != null && periodCodeRaw.isNotEmpty ? periodCodeRaw : null,
      periods: periods,
    );
  }

  final String id;
  final String name;
  final int weekday;
  final String startTime;
  final String endTime;
  final int startWeek;
  final int endWeek;
  final double credit;
  final String? teacher;
  final String? classroom;
  final String? building;
  final String? weeks;
  final String? type;
  final String? color;
  final String? department;
  final String? semester;
  // Python API 詳細欄位
  final String? cm;
  final String? cono;
  final String? deptnam;
  final String? edeptnam;
  final String? englishco;
  final String? esm;
  final String? ecsk;
  final String? furcm;
  final String? grade;
  final String? mteafno;
  final String? noryn;
  final String? pid;
  final String? secnam;
  final String? secqty;
  final String? sm;
  final String? teafenam;
  final String? teafnam;
  final String? textbook;
  final String? xdeptno;
  final String? seqno;
  // 高醫 wac CSV 節次欄位 (從 qurq0006.php 取得)
  final String? periodCode;
  final List<String> periods;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weekday': weekday,
      'startTime': startTime,
      'endTime': endTime,
      'startWeek': startWeek,
      'endWeek': endWeek,
      'credit': credit,
      'teacher': teacher,
      'classroom': classroom,
      'building': building,
      'weeks': weeks,
      'type': type,
      'color': color,
      'department': department,
      'semester': semester,
      'cm': cm,
      'cono': cono,
      'deptnam': deptnam,
      'edeptnam': edeptnam,
      'englishco': englishco,
      'esm': esm,
      'ecsk': ecsk,
      'furcm': furcm,
      'grade': grade,
      'mteafno': mteafno,
      'noryn': noryn,
      'pid': pid,
      'secnam': secnam,
      'secqty': secqty,
      'sm': sm,
      'teafenam': teafenam,
      'teafnam': teafnam,
      'textbook': textbook,
      'xdeptno': xdeptno,
      'seqno': seqno,
      'periodCode': periodCode,
      'periods': periods,
      // 新增：保存 year/sem 供 WAC 目錄下載使用
      'year': id.split('-').isNotEmpty ? id.split('-')[0] : '',
      'sem': id.split('-').length > 1 ? id.split('-')[1] : '',
    };
  }

  Course copyWith({
    String? id,
    String? name,
    int? weekday,
    String? startTime,
    String? endTime,
    int? startWeek,
    int? endWeek,
    double? credit,
    String? teacher,
    String? classroom,
    String? building,
    String? weeks,
    String? type,
    String? color,
    String? department,
    String? semester,
    String? cm,
    String? cono,
    String? deptnam,
    String? edeptnam,
    String? englishco,
    String? esm,
    String? ecsk,
    String? furcm,
    String? grade,
    String? mteafno,
    String? noryn,
    String? pid,
    String? secnam,
    String? secqty,
    String? sm,
    String? teafenam,
    String? teafnam,
    String? textbook,
    String? xdeptno,
    String? seqno,
    String? periodCode,
    List<String>? periods,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      weekday: weekday ?? this.weekday,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      credit: credit ?? this.credit,
      teacher: teacher ?? this.teacher,
      classroom: classroom ?? this.classroom,
      building: building ?? this.building,
      weeks: weeks ?? this.weeks,
      type: type ?? this.type,
      color: color ?? this.color,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      cm: cm ?? this.cm,
      cono: cono ?? this.cono,
      deptnam: deptnam ?? this.deptnam,
      edeptnam: edeptnam ?? this.edeptnam,
      englishco: englishco ?? this.englishco,
      esm: esm ?? this.esm,
      ecsk: ecsk ?? this.ecsk,
      furcm: furcm ?? this.furcm,
      grade: grade ?? this.grade,
      mteafno: mteafno ?? this.mteafno,
      noryn: noryn ?? this.noryn,
      pid: pid ?? this.pid,
      secnam: secnam ?? this.secnam,
      secqty: secqty ?? this.secqty,
      sm: sm ?? this.sm,
      teafenam: teafenam ?? this.teafenam,
      teafnam: teafnam ?? this.teafnam,
      textbook: textbook ?? this.textbook,
      xdeptno: xdeptno ?? this.xdeptno,
      seqno: seqno ?? this.seqno,
      periodCode: periodCode ?? this.periodCode,
      periods: periods ?? this.periods,
    );
  }
}

/// Course 擴展方法
extension CourseExtension on Course {
  /// 解析開始時間
  DateTime? get parsedStartTime {
    try {
      final parts = startTime.split(':');
      return DateTime.now().copyWith(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) { return null; }
  }

  /// 解析結束時間
  DateTime? get parsedEndTime {
    try {
      final parts = endTime.split(':');
      return DateTime.now().copyWith(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) { return null; }
  }

  /// 週數列表
  List<int> get weekList {
    if (weeks == null || weeks!.isEmpty) {
      return List.generate(endWeek - startWeek + 1, (i) => startWeek + i);
    }
    // 解析 "1-18" 或 "1,3,5" 格式
    final result = <int>[];
    for (final part in weeks!.split(',')) {
      if (part.contains('-')) {
        final range = part.split('-');
        final start = int.tryParse(range[0]) ?? startWeek;
        final end = int.tryParse(range[1]) ?? endWeek;
        result.addAll(List.generate(end - start + 1, (i) => start + i));
      } else {
        final w = int.tryParse(part);
        if (w != null) result.add(w);
      }
    }
    return result;
  }

  /// 持續時間 (分鐘)
  int get durationMinutes {
    final start = parsedStartTime;
    final end = parsedEndTime;
    if (start == null || end == null) return 0;
    return end.difference(start).inMinutes;
  }
}

/// 課表回應
class MyScheduleResponse {
  const MyScheduleResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MyScheduleResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    ScheduleData? scheduleData;

    if (data is Map<String, dynamic>) {
      // 標準格式：data 已經是 ScheduleData 結構
      scheduleData = ScheduleData.fromJson(data);
    } else if (data is List) {
      // Python API: data 是 List<課堂>
      final courses = data
          .whereType<Map<String, dynamic>>()
          .map(Course.fromJson)
          .toList();
      String? semester;
      if (courses.isNotEmpty) {
        final first = courses.first;
        final parts = first.id.split('-');
        semester = '${parts[0]}-${parts[1]}'; // year-sem
      }
      scheduleData = ScheduleData(
        courses: courses,
        semester: semester,
      );
    }

    return MyScheduleResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: scheduleData,
    );
  }

  final bool success;
  final String message;
  final ScheduleData? data;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

/// 課表資料
/// Python API 回傳 items 是 List<課堂>，但前端期望有 courses/semester 欄位
class ScheduleData {
  const ScheduleData({
    this.courses = const [],
    this.semester,
    this.totalCredits,
  });

  factory ScheduleData.fromJson(Map<String, dynamic> json) {
    // Python API: items 是 List<課堂>，需要轉成 Course
    final List<Course> courses = [];
    String? semester;

    // 處理兩種格式：
    // 1. data 是 List (Python items 直接對應)
    // 2. data 是 Map 包含 courses 欄位
    final dynamic items = json is List ? json : (json['courses'] as List?);

    if (items != null && items is List) {
      for (final item in items) {
        if (item is Map) {  // 接受 Map<dynamic, dynamic>
          courses.add(Course.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    // 從第一門課程取得學期 (year-sem 格式，不是 year-sem-seqno)
    if (courses.isNotEmpty) {
      final first = courses.first;
      semester = first.id.split('-').take(2).join('-');
    } else if (json['semester'] is String) {
      semester = json['semester'] as String?;
    }

    return ScheduleData(
      courses: courses,
      semester: semester,
      totalCredits: (json['totalCredits'] as num?)?.toDouble(),
    );
  }

  final List<Course> courses;
  final String? semester;
  final double? totalCredits;

  Map<String, dynamic> toJson() {
    return {
      'courses': courses.map((e) => e.toJson()).toList(),
      'semester': semester,
      'totalCredits': totalCredits,
    };
  }

  ScheduleData copyWith({
    List<Course>? courses,
    String? semester,
    double? totalCredits,
  }) {
    return ScheduleData(
      courses: courses ?? this.courses,
      semester: semester ?? this.semester,
      totalCredits: totalCredits ?? this.totalCredits,
    );
  }
}

/// 成績單科目
/// Python API 欄位: courseCode, credit, score, grade, rank, totalStudents, average,
/// midterm, finalExam, homework, attendance, other, teacher, semester, type, department
class ScoreSubject {
  const ScoreSubject({
    required this.id,
    required this.name,
    required this.credit,
    this.courseCode,
    this.score,
    this.grade,
    this.rank,
    this.totalStudents,
    this.average,
    this.midterm,
    this.finalExam,
    this.homework,
    this.attendance,
    this.other,
    this.teacher,
    this.semester,
    this.type,
    this.department,
  });

  factory ScoreSubject.fromJson(Map<String, dynamic> json) {
    return ScoreSubject(
      id: json['id']?.toString() ?? json['courseCode']?.toString() ?? '',
      name: json['name']?.toString() ?? json['chineseco']?.toString() ?? '',
      credit: _parseDouble(json['credit']) ?? 0.0,
      courseCode: json['courseCode']?.toString(),
      score: _parseDouble(json['score']),
      grade: json['grade']?.toString(),
      rank: _parseInt(json['rank']),
      totalStudents: _parseInt(json['totalStudents']),
      average: _parseDouble(json['average']),
      midterm: _parseDouble(json['midterm']),
      finalExam: _parseDouble(json['finalExam']),
      homework: _parseDouble(json['homework']),
      attendance: _parseDouble(json['attendance']),
      other: _parseDouble(json['other']),
      teacher: json['teacher']?.toString() ?? json['teacherName']?.toString(),
      semester: json['semester']?.toString(),
      type: json['type']?.toString(),
      department: json['department']?.toString() ?? json['deptnam']?.toString(),
    );
  }

  final String id;
  final String name;
  final double credit;
  final String? courseCode;
  final double? score;
  final String? grade;
  final int? rank;
  final int? totalStudents;
  final double? average;
  final double? midterm;
  final double? finalExam;
  final double? homework;
  final double? attendance;
  final double? other;
  final String? teacher;
  final String? semester;
  final String? type;
  final String? department;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'credit': credit,
      'courseCode': courseCode,
      'score': score,
      'grade': grade,
      'rank': rank,
      'totalStudents': totalStudents,
      'average': average,
      'midterm': midterm,
      'finalExam': finalExam,
      'homework': homework,
      'attendance': attendance,
      'other': other,
      'teacher': teacher,
      'semester': semester,
      'type': type,
      'department': department,
    };
  }

  static double? _parseDouble(v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int? _parseInt(v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }
}

/// ScoreSubject 擴展方法
extension ScoreSubjectExtension on ScoreSubject {
  /// 是否及格 (60分以上)
  bool get isPassed => score != null && score! >= 60;

  /// 等級分數 (用於 GPA 計算)
  double get gradePoint {
    if (score == null) return 0;
    final s = score!;
    if (s >= 90) return 4.3;
    if (s >= 85) return 4.0;
    if (s >= 80) return 3.7;
    if (s >= 77) return 3.3;
    if (s >= 73) return 3.0;
    if (s >= 70) return 2.7;
    if (s >= 67) return 2.3;
    if (s >= 63) return 2.0;
    if (s >= 60) return 1.7;
    return 0;
  }
}

/// 成績回應
class MyScoresResponse {
  const MyScoresResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MyScoresResponse.fromJson(Map<String, dynamic> json) {
    return MyScoresResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null ? ScoresData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  final bool success;
  final String message;
  final ScoresData? data;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

/// 成績資料
/// 使用自定義 fromJson 避免 freezed 產生器問題
class ScoresData {
  const ScoresData({
    this.subjects = const [],
    this.semesters = const [],
    this.currentSemester,
    this.gpa,
    this.totalCredits,
    this.earnedCredits,
    this.rank,
    this.totalStudents,
    this.gpaTrend = const [],
  });

  factory ScoresData.fromJson(Map<String, dynamic> json) {
    final subjects = <ScoreSubject>[];
    if (json['subjects'] is List) {
      for (final item in json['subjects']) {
        if (item is Map<String, dynamic>) {
          subjects.add(ScoreSubject.fromJson(item));
        }
      }
    }
    final semesters = <SemesterInfo>[];
    if (json['semesters'] is List) {
      for (final item in json['semesters']) {
        if (item is Map<String, dynamic>) {
          semesters.add(SemesterInfo.fromJson(item));
        }
      }
    }
    return ScoresData(
      subjects: subjects,
      semesters: semesters,
      currentSemester: json['currentSemester']?.toString(),
      gpa: (json['gpa'] as num?)?.toDouble(),
      totalCredits: (json['totalCredits'] as num?)?.toDouble(),
      earnedCredits: (json['earnedCredits'] as num?)?.toDouble(),
      rank: (json['rank'] as num?)?.toInt(),
      totalStudents: (json['totalStudents'] as num?)?.toInt(),
      gpaTrend: [],
    );
  }

  final List<ScoreSubject> subjects;
  final List<SemesterInfo> semesters;
  final String? currentSemester;
  final double? gpa;
  final double? totalCredits;
  final double? earnedCredits;
  final int? rank;
  final int? totalStudents;
  final List<GPATrendPoint> gpaTrend;

  Map<String, dynamic> toJson() {
    return {
      'subjects': subjects.map((e) => e.toJson()).toList(),
      'semesters': semesters.map((e) => {'id': e.id, 'name': e.name, 'isCurrent': e.isCurrent}).toList(),
      'currentSemester': currentSemester,
      'gpa': gpa,
      'totalCredits': totalCredits,
      'earnedCredits': earnedCredits,
      'rank': rank,
      'totalStudents': totalStudents,
      'gpaTrend': gpaTrend.map((e) => e.toJson()).toList(),
    };
  }
}

/// ScoresData 擴展方法
extension ScoresDataExtension on ScoresData {
  /// 本學期 GPA
  double get semesterGpa {
    final semSubjects = subjects.where((s) => s.semester == currentSemester).toList();
    if (semSubjects.isEmpty) return 0;
    double totalPoints = 0;
    double totalCredits = 0;
    for (final s in semSubjects) {
      if (s.score != null) {
        totalPoints += s.gradePoint * s.credit;
        totalCredits += s.credit;
      }
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }

  /// 累積 GPA
  double get cumulativeGpa {
    final passedSubjects = subjects.where((s) => s.score != null).toList();
    if (passedSubjects.isEmpty) return 0;
    double totalPoints = 0;
    double totalCredits = 0;
    for (final s in passedSubjects) {
      totalPoints += s.gradePoint * s.credit;
      totalCredits += s.credit;
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0;
  }
}

/// 課程大綱項目
class CourseOutline {
  const CourseOutline({
    this.pid,
    this.year,
    this.sem,
    this.seqno,
    this.refurl,
    this.officehour,
    this.syllabn,
    this.eSyllabn,
    this.purpos,
    this.ePurpos,
    this.method,
    this.eMethod,
    this.asses,
    this.eAsses,
    this.seqnir,
    this.eSeqnir,
  });

  factory CourseOutline.fromJson(Map<String, dynamic> json) {
    return CourseOutline(
      pid: json['pid']?.toString(),
      year: json['year']?.toString(),
      sem: json['sem']?.toString(),
      seqno: json['seqno']?.toString(),
      refurl: json['refurl']?.toString(),
      officehour: json['officehour']?.toString(),
      syllabn: json['syllabn']?.toString(),
      eSyllabn: json['eSyllabn']?.toString(),
      purpos: json['purpos']?.toString(),
      ePurpos: json['ePurpos']?.toString(),
      method: json['method']?.toString(),
      eMethod: json['eMethod']?.toString(),
      asses: json['asses']?.toString(),
      eAsses: json['eAsses']?.toString(),
      seqnir: json['seqnir']?.toString(),
      eSeqnir: json['eSeqnir']?.toString(),
    );
  }

  final String? pid;
  final String? year;
  final String? sem;
  final String? seqno;
  final String? refurl;
  final String? officehour;
  final String? syllabn;
  final String? eSyllabn;
  final String? purpos;
  final String? ePurpos;
  final String? method;
  final String? eMethod;
  final String? asses;
  final String? eAsses;
  final String? seqnir;
  final String? eSeqnir;

  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'year': year,
      'sem': sem,
      'seqno': seqno,
      'refurl': refurl,
      'officehour': officehour,
      'syllabn': syllabn,
      'eSyllabn': eSyllabn,
      'purpos': purpos,
      'ePurpos': ePurpos,
      'method': method,
      'eMethod': eMethod,
      'asses': asses,
      'eAsses': eAsses,
      'seqnir': seqnir,
      'eSeqnir': eSeqnir,
    };
  }
}

/// 課程大綱 (包含中英雙語版本)
class CourseDetail {
  const CourseDetail({
    this.outlines = const [],
    this.textbook,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final outlines = <CourseOutline>[];
    if (json['outline'] is List) {
      for (final item in json['outline']) {
        if (item is Map<String, dynamic>) {
          outlines.add(CourseOutline.fromJson(item));
        }
      }
    }
    return CourseDetail(
      outlines: outlines,
      textbook: json['textbook']?.toString(),
    );
  }

  final List<CourseOutline> outlines;
  final String? textbook;

  Map<String, dynamic> toJson() {
    return {
      'outlines': outlines.map((e) => e.toJson()).toList(),
      'textbook': textbook,
    };
  }
}

/// 成績趨勢資料點 (用於圖表)
class GPATrendPoint {
  const GPATrendPoint({
    required this.semester,
    required this.gpa,
    required this.credits,
    required this.subjectCount,
  });

  factory GPATrendPoint.fromJson(Map<String, dynamic> json) {
    return GPATrendPoint(
      semester: json['semester']?.toString() ?? '',
      gpa: (json['gpa'] as num?)?.toDouble() ?? 0.0,
      credits: (json['credits'] as num?)?.toDouble() ?? 0.0,
      subjectCount: (json['subjectCount'] as num?)?.toInt() ?? 0,
    );
  }

  final String semester;
  final double gpa;
  final double credits;
  final int subjectCount;

  Map<String, dynamic> toJson() {
    return {
      'semester': semester,
      'gpa': gpa,
      'credits': credits,
      'subjectCount': subjectCount,
    };
  }
}

/// 課務狀態 (Riverpod 管理)
class CourseState {
  const CourseState({
    this.courses = const [],
    this.scheduleData,
    this.scoresData,
    this.selectedSemester,
    this.isLoadingSchedule = false,
    this.isLoadingScores = false,
    this.error,
  });

  factory CourseState.initial() => const CourseState();

  final List<Course> courses;
  final ScheduleData? scheduleData;
  final ScoresData? scoresData;
  final String? selectedSemester;
  final bool isLoadingSchedule;
  final bool isLoadingScores;
  final String? error;

  CourseState copyWith({
    List<Course>? courses,
    ScheduleData? scheduleData,
    ScoresData? scoresData,
    String? selectedSemester,
    bool? isLoadingSchedule,
    bool? isLoadingScores,
    String? error,
  }) {
    return CourseState(
      courses: courses ?? this.courses,
      scheduleData: scheduleData ?? this.scheduleData,
      scoresData: scoresData ?? this.scoresData,
      selectedSemester: selectedSemester ?? this.selectedSemester,
      isLoadingSchedule: isLoadingSchedule ?? this.isLoadingSchedule,
      isLoadingScores: isLoadingScores ?? this.isLoadingScores,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': courses.map((e) => e.toJson()).toList(),
      'scheduleData': scheduleData?.toJson(),
      'scoresData': scoresData?.toJson(),
      'selectedSemester': selectedSemester,
      'isLoadingSchedule': isLoadingSchedule,
      'isLoadingScores': isLoadingScores,
      'error': error,
    };
  }
}