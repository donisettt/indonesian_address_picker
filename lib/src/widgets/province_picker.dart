import 'package:flutter/material.dart';
import '../models/province.dart';
import '../services/address_service.dart';

/// Widget untuk memilih Provinsi
class ProvincePicker extends StatefulWidget {
  /// Callback ketika provinsi dipilih
  final Function(Province) onSelected;

  /// Hint text untuk search bar
  final String? searchHint;

  /// Custom decoration untuk search field
  final InputDecoration? searchDecoration;

  const ProvincePicker({
    Key? key,
    required this.onSelected,
    this.searchHint,
    this.searchDecoration,
  }) : super(key: key);

  @override
  State<ProvincePicker> createState() => _ProvincePickerState();
}

class _ProvincePickerState extends State<ProvincePicker> {
  List<Province> _provinces = [];
  List<Province> _filteredProvinces = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final provinces = await AddressService.getProvinces();
      setState(() {
        _provinces = provinces;
        _filteredProvinces = provinces;
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
        _filteredProvinces = _provinces;
      } else {
        _filteredProvinces = _provinces
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
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
                  hintText: widget.searchHint ?? 'Cari provinsi...',
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
      return const Center(
        child: CircularProgressIndicator(),
      );
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
              onPressed: _loadProvinces,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredProvinces.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Tidak ada provinsi ditemukan',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredProvinces.length,
      itemBuilder: (context, index) {
        final province = _filteredProvinces[index];
        return ListTile(
          title: Text(province.name),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            widget.onSelected(province);
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
