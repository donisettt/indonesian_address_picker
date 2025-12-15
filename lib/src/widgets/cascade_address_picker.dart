import 'package:flutter/material.dart';
import '../models/province.dart';
import '../models/city.dart';
import '../models/district.dart';
import '../models/village.dart';
import 'province_picker.dart';
import 'city_picker.dart';
import 'district_picker.dart';
import 'village_picker.dart';

/// Widget cascade untuk pilih alamat lengkap
/// Provinsi → Kota → Kecamatan → Kelurahan/Desa
class CascadeAddressPicker extends StatefulWidget {
  /// Callback ketika semua dipilih
  final Function(Province, City, District?, Village?)? onComplete;

  /// Apakah wajib pilih sampai kelurahan?
  final bool requireVillage;

  /// Apakah wajib pilih sampai kecamatan?
  final bool requireDistrict;

  const CascadeAddressPicker({
    Key? key,
    this.onComplete,
    this.requireVillage = false,
    this.requireDistrict = false,
  }) : super(key: key);

  @override
  State<CascadeAddressPicker> createState() => _CascadeAddressPickerState();
}

class _CascadeAddressPickerState extends State<CascadeAddressPicker> {
  Province? _selectedProvince;
  City? _selectedCity;
  District? _selectedDistrict;
  Village? _selectedVillage;

  void _selectProvince() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: ProvincePicker(
          onSelected: (province) {
            setState(() {
              _selectedProvince = province;
              _selectedCity = null;
              _selectedDistrict = null;
              _selectedVillage = null;
            });
          },
        ),
      ),
    );
  }

  void _selectCity() {
    if (_selectedProvince == null) {
      _showSnackBar('Pilih provinsi terlebih dahulu');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: CityPicker(
          provinceId: _selectedProvince!.id,
          onSelected: (city) {
            setState(() {
              _selectedCity = city;
              _selectedDistrict = null;
              _selectedVillage = null;
            });
          },
        ),
      ),
    );
  }

  void _selectDistrict() {
    if (_selectedCity == null) {
      _showSnackBar('Pilih kota terlebih dahulu');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: DistrictPicker(
          cityId: _selectedCity!.id,
          onSelected: (district) {
            setState(() {
              _selectedDistrict = district;
              _selectedVillage = null;
            });
          },
        ),
      ),
    );
  }

  void _selectVillage() {
    if (_selectedDistrict == null) {
      _showSnackBar('Pilih kecamatan terlebih dahulu');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: VillagePicker(
          districtId: _selectedDistrict!.id,
          onSelected: (village) {
            setState(() {
              _selectedVillage = village;
            });
            // Call onComplete callback
            if (widget.onComplete != null) {
              widget.onComplete!(
                _selectedProvince!,
                _selectedCity!,
                _selectedDistrict,
                _selectedVillage,
              );
            }
          },
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Pilih Alamat Lengkap',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pilih provinsi, kota, kecamatan, dan kelurahan/desa',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Provinsi
            _buildSelectButton(
              label: 'Provinsi',
              value: _selectedProvince?.name,
              onTap: _selectProvince,
              icon: Icons.public,
            ),
            const SizedBox(height: 12),

            // Kota
            _buildSelectButton(
              label: 'Kabupaten/Kota',
              value: _selectedCity?.name,
              onTap: _selectCity,
              enabled: _selectedProvince != null,
              icon: Icons.location_city,
            ),
            const SizedBox(height: 12),

            // Kecamatan
            _buildSelectButton(
              label: 'Kecamatan',
              value: _selectedDistrict?.name,
              onTap: _selectDistrict,
              enabled: _selectedCity != null,
              icon: Icons.map,
            ),
            const SizedBox(height: 12),

            // Kelurahan/Desa
            _buildSelectButton(
              label: 'Kelurahan/Desa',
              value: _selectedVillage?.name,
              onTap: _selectVillage,
              enabled: _selectedDistrict != null,
              icon: Icons.home,
            ),
            const SizedBox(height: 24),

            // Summary Card
            if (_selectedProvince != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Alamat Terpilih:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildAddressRow('Provinsi', _selectedProvince?.name),
                      if (_selectedCity != null)
                        _buildAddressRow('Kota', _selectedCity?.name),
                      if (_selectedDistrict != null)
                        _buildAddressRow('Kecamatan', _selectedDistrict?.name),
                      if (_selectedVillage != null)
                        _buildAddressRow(
                            'Kelurahan/Desa', _selectedVillage?.name),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectButton({
    required String label,
    String? value,
    VoidCallback? onTap,
    bool enabled = true,
    required IconData icon,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? Colors.blue[300]! : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: enabled ? Colors.white : Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: enabled ? Colors.blue[600] : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? 'Pilih $label',
                    style: TextStyle(
                      fontSize: 16,
                      color: value != null ? Colors.black : Colors.grey[400],
                      fontWeight:
                          value != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: enabled ? Colors.blue[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(String label, String? value) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
