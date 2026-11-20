import 'package:flutter/material.dart';

/// Önce tarih, sonra saat seçtirir (24 saat). Tarihte vazgeçilirse `null`;
/// saatte vazgeçilirse gün [current]'ın saatiyle dönüyor.
Future<DateTime?> pickDateTime(BuildContext context, DateTime current) async {
  final now = DateTime.now();

  final date = await showDatePicker(
    context: context,
    initialDate: current,
    firstDate: DateTime(now.year - 1),
    lastDate: DateTime(now.year + 2),
  );
  if (date == null || !context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(current),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );

  return DateTime(
    date.year,
    date.month,
    date.day,
    time?.hour ?? current.hour,
    time?.minute ?? current.minute,
  );
}

const List<String> _months = [
  'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', //
  'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
];

/// "14 Eyl · 21:00"
String shortDateTimeLabel(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${value.day} ${_months[value.month - 1]} · '
      '${two(value.hour)}:${two(value.minute)}';
}
