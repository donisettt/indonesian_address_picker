import 'package:flutter/material.dart';
import '../models/district.dart';
import '../services/address_service.dart';

/// Widget untuk memilih Kecamatan
class DistrictPicker extends StatefulWidget {
  /// ID Kota (required untuk filter)
  final String cityId;

  /// Callback ketika kecamatan dipilih
  final Function(District) onSelected;

  /// Hint text untuk search bar
  final String? searchHint;

  /// Custom decoration untuk search field
  final InputDecoration? searchDecoration;

  const DistrictPicker({
    Key? key,
    required this.cityId,
    required this.onSelected,
    this.searchHint,
    this.searchDecoration,
  }) : super(key: key);

  @override
  State<DistrictPicker> createState() => _DistrictPickerState();
}

class _DistrictPickerState extends State<DistrictPicker> {
  List<District> _districts = [];
  List<District> _filteredDistricts = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final districts = await AddressService.getDistrictsByCity(widget.cityId);
      setState(() {
        _districts = districts;
        _filteredDistricts = districts;
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
        _filteredDistricts = _districts;
      } else {
        _filteredDistricts = _districts
            .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
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
                  hintText: widget.searchHint ?? 'Cari kecamatan...',
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
              onPressed: _loadDistricts,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredDistricts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Tidak ada kecamatan ditemukan',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredDistricts.length,
      itemBuilder: (context, index) {
        final district = _filteredDistricts[index];
        return ListTile(
          title: Text(district.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            widget.onSelected(district);
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
