import 'package:flutter/material.dart';
import '../models/village.dart';
import '../services/address_service.dart';

/// Widget untuk memilih Kelurahan/Desa
class VillagePicker extends StatefulWidget {
  /// ID Kecamatan (required untuk filter)
  final String districtId;

  /// Callback ketika kelurahan dipilih
  final Function(Village) onSelected;

  /// Hint text untuk search bar
  final String? searchHint;

  /// Custom decoration untuk search field
  final InputDecoration? searchDecoration;

  const VillagePicker({
    Key? key,
    required this.districtId,
    required this.onSelected,
    this.searchHint,
    this.searchDecoration,
  }) : super(key: key);

  @override
  State<VillagePicker> createState() => _VillagePickerState();
}

class _VillagePickerState extends State<VillagePicker> {
  List<Village> _villages = [];
  List<Village> _filteredVillages = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVillages();
  }

  Future<void> _loadVillages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final villages =
          await AddressService.getVillagesByDistrict(widget.districtId);
      setState(() {
        _villages = villages;
        _filteredVillages = villages;
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
        _filteredVillages = _villages;
      } else {
        _filteredVillages = _villages
            .where((v) => v.name.toLowerCase().contains(query.toLowerCase()))
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
                  hintText: widget.searchHint ?? 'Cari kelurahan/desa...',
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
              onPressed: _loadVillages,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredVillages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Tidak ada kelurahan/desa ditemukan',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredVillages.length,
      itemBuilder: (context, index) {
        final village = _filteredVillages[index];
        return ListTile(
          title: Text(village.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            widget.onSelected(village);
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
