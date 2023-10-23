class OctoBeatScanResult {
  final String name;
  final String address;
  OctoBeatScanResult({
    required this.name,
    required this.address,
  });

  static OctoBeatScanResult fromMap(dynamic map) {
    return OctoBeatScanResult(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
    );
  }

  @override
  String toString() => 'OctoBeatScanResult(name: $name, address: $address)';
}
