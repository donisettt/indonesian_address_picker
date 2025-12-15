import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('🚀 Converting CSV to JSON...\n');

  const baseUrl =
      'https://raw.githubusercontent.com/emsifa/api-wilayah-indonesia/master/data';

  // Download provinces.csv
  await downloadAndConvert(
    '$baseUrl/provinces.csv',
    'lib/src/data/provinces.json',
    ['id', 'name'],
  );

  // Download regencies.csv
  await downloadAndConvert(
    '$baseUrl/regencies.csv',
    'lib/src/data/cities.json',
    ['id', 'province_id', 'name'],
  );

  // Download districts.csv
  await downloadAndConvert(
    '$baseUrl/districts.csv',
    'lib/src/data/districts.json',
    ['id', 'regency_id', 'name'],
  );

  // Download villages.csv
  await downloadAndConvert(
    '$baseUrl/villages.csv',
    'lib/src/data/villages.json',
    ['id', 'district_id', 'name'],
  );

  print('\n🎉 All conversions completed!');
}

Future<void> downloadAndConvert(
  String url,
  String outputPath,
  List<String> headers,
) async {
  try {
    print('⬇️  Downloading ${url.split('/').last}...');
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse CSV
      final lines = response.body.split('\n');
      final List<Map<String, dynamic>> jsonData = [];

      // Skip header row (index 0)
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final values = line.split(',');
        if (values.length == headers.length) {
          final Map<String, dynamic> item = {};
          for (var j = 0; j < headers.length; j++) {
            item[headers[j]] = values[j].replaceAll('"', '').trim();
          }
          jsonData.add(item);
        }
      }

      // Save to JSON
      final outputDir = Directory('lib/src/data');
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      final file = File(outputPath);
      await file.writeAsString(
        JsonEncoder.withIndent('  ').convert(jsonData),
      );

      final sizeKB = (await file.length()) / 1024;
      print('   ✓ Converted ${outputPath.split('/').last} (${sizeKB.toStringAsFixed(2)} KB)');
    } else {
      print('   ✗ Failed: HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('   ✗ Error: $e');
  }
}