import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/province.dart';
import '../models/city.dart';
import '../models/district.dart';
import '../models/village.dart';

/// Service untuk load dan manage data wilayah Indonesia
class AddressService {
  // Cache data supaya gak load berkali-kali
  static List<Province>? _provinces;
  static List<City>? _cities;
  static List<District>? _districts;
  static List<Village>? _villages;

  /// Initialize semua data (load dari JSON)
  static Future<void> initialize() async {
    if (_provinces != null) return; // Sudah di-load sebelumnya

    try {
      // Load provinces
      final provincesJson = await rootBundle.loadString(
        'packages/indonesian_address_picker/lib/src/data/provinces.json',
      );
      final List<dynamic> provincesData = json.decode(provincesJson);
      _provinces = provincesData.map((e) => Province.fromJson(e)).toList();

      // Load cities
      final citiesJson = await rootBundle.loadString(
        'packages/indonesian_address_picker/lib/src/data/cities.json',
      );
      final List<dynamic> citiesData = json.decode(citiesJson);
      _cities = citiesData.map((e) => City.fromJson(e)).toList();

      // Load districts
      final districtsJson = await rootBundle.loadString(
        'packages/indonesian_address_picker/lib/src/data/districts.json',
      );
      final List<dynamic> districtsData = json.decode(districtsJson);
      _districts = districtsData.map((e) => District.fromJson(e)).toList();

      // Load villages
      final villagesJson = await rootBundle.loadString(
        'packages/indonesian_address_picker/lib/src/data/villages.json',
      );
      final List<dynamic> villagesData = json.decode(villagesJson);
      _villages = villagesData.map((e) => Village.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load address data: $e');
    }
  }

  // ==================== PROVINCES ====================

  /// Get all provinces
  static Future<List<Province>> getProvinces() async {
    await initialize();
    return List.unmodifiable(_provinces ?? []);
  }

  /// Search provinces by name
  static Future<List<Province>> searchProvinces(String query) async {
    await initialize();
    if (query.isEmpty) return getProvinces();

    final lowerQuery = query.toLowerCase();
    return _provinces
            ?.where((p) => p.name.toLowerCase().contains(lowerQuery))
            .toList() ??
        [];
  }

  /// Get province by ID
  static Future<Province?> getProvinceById(String id) async {
    await initialize();
    try {
      return _provinces?.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== CITIES ====================

  /// Get cities by province ID
  static Future<List<City>> getCitiesByProvince(String provinceId) async {
    await initialize();
    return _cities?.where((c) => c.provinceId == provinceId).toList() ?? [];
  }

  /// Search cities by name (optionally filter by province)
  static Future<List<City>> searchCities(String query,
      {String? provinceId}) async {
    await initialize();
    if (query.isEmpty && provinceId == null) return [];

    var results = _cities ?? [];

    // Filter by province if provided
    if (provinceId != null) {
      results = results.where((c) => c.provinceId == provinceId).toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results
          .where((c) => c.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    return results;
  }

  /// Get city by ID
  static Future<City?> getCityById(String id) async {
    await initialize();
    try {
      return _cities?.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== DISTRICTS ====================

  /// Get districts by city ID
  static Future<List<District>> getDistrictsByCity(String cityId) async {
    await initialize();
    return _districts?.where((d) => d.cityId == cityId).toList() ?? [];
  }

  /// Search districts by name (optionally filter by city)
  static Future<List<District>> searchDistricts(String query,
      {String? cityId}) async {
    await initialize();
    if (query.isEmpty && cityId == null) return [];

    var results = _districts ?? [];

    if (cityId != null) {
      results = results.where((d) => d.cityId == cityId).toList();
    }

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results
          .where((d) => d.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    return results;
  }

  /// Get district by ID
  static Future<District?> getDistrictById(String id) async {
    await initialize();
    try {
      return _districts?.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== VILLAGES ====================

  /// Get villages by district ID
  static Future<List<Village>> getVillagesByDistrict(String districtId) async {
    await initialize();
    return _villages?.where((v) => v.districtId == districtId).toList() ?? [];
  }

  /// Search villages by name (optionally filter by district)
  static Future<List<Village>> searchVillages(String query,
      {String? districtId}) async {
    await initialize();
    if (query.isEmpty && districtId == null) return [];

    var results = _villages ?? [];

    if (districtId != null) {
      results = results.where((v) => v.districtId == districtId).toList();
    }

    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      results = results
          .where((v) => v.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    return results;
  }

  /// Get village by ID
  static Future<Village?> getVillageById(String id) async {
    await initialize();
    try {
      return _villages?.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== UTILITIES ====================

  /// Clear cache (useful for testing or refresh)
  static void clearCache() {
    _provinces = null;
    _cities = null;
    _districts = null;
    _villages = null;
  }
}
