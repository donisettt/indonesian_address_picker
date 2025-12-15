import 'package:flutter/material.dart';
import '../models/city.dart';
import '../services/address_service.dart';

/// Widget untuk memilih Kabupaten/Kota
class CityPicker extends StatefulWidget {
  /// ID Provinsi (required untuk filter)
  final String provinceId;

  /// Callback ketika kota dipilih
  final Function(City) onSelected;

  /// Hint text untuk search bar
  final String? searchHint;

  /// Custom decoration untuk search field
  final InputDecoration? searchDecoration;

  const CityPicker({
    Key? key,
    required this.provinceId,
    required this.onSelected,
    this.searchHint,
    this.searchDecoration,
  }) : super(key: key);

  @override
  State<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends State<CityPicker> {
  List<City> _cities = [];
  List<City> _filteredCities = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cities =
          await AddressService.getCitiesByProvince(widget.provinceId);
      setState(() {
        _cities = cities;
        _filteredCities = cities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _cities;
      } else {
        _filteredCities = _cities
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: widget.searchDecoration ??
                InputDecoration(
                  hintText: widget.searchHint ?? 'Cari kabupaten/kota...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
            onChanged: _onSearch,
          ),
        ),

        // List or Loading or Error
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCities,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredCities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Tidak ada kota ditemukan',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredCities.length,
      itemBuilder: (context, index) {
        final city = _filteredCities[index];
        return ListTile(
          title: Text(city.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            widget.onSelected(city);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
