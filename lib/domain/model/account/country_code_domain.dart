class CountryCodeDomain {
  final String? name;
  final String? alpha2;
  final String? dial;
  final String? flag;

  CountryCodeDomain({
    this.name,
    this.alpha2,
    this.dial,
    this.flag,
  });

  CountryCodeDomain copyWith({
    String? name,
    String? alpha2,
    String? dial,
    String? flag,
  }) {
    return CountryCodeDomain(
      name: name ?? this.name,
      alpha2: alpha2 ?? this.alpha2,
      dial: dial ?? this.dial,
      flag: flag ?? this.flag,
    );
  }

  @override
  String toString() {
    return 'CountryCodeDomain(name: $name, alpha2: $alpha2, dial: $dial, flag: $flag)';
  }
}
