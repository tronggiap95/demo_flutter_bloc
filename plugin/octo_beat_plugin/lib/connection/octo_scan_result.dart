class OctoScanResult {
  final String name;
  final String address;
  OctoScanResult({
    required this.name,
    required this.address,
  });

  static OctoScanResult fromMap(dynamic map) {
    return OctoScanResult(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
    );
  }

  @override
  String toString() => 'OctoScanResult(name: $name, address: $address)';
}
