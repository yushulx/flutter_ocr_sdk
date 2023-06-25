/// MrzResult class.
class MrzResult {
  /// Document type.
  String? type = '';

  /// Nationality.
  String? nationality = '';

  /// Surname.
  String? surname = '';

  /// Given name.
  String? givenName = '';

  /// Passport number.
  String? passportNumber = '';

  /// Issuing country.
  String? issuingCountry = '';

  /// Birth date.
  String? birthDate = '';

  /// Gender.
  String? gender = '';

  /// Expiration date.
  String? expiration = '';

  MrzResult(
      {String? type,
      String? nationality,
      String? surname,
      String? givenName,
      String? passportNumber,
      String? issuingCountry,
      String? birthDate,
      String? gender,
      String? expiration})
      : this.type = type ?? 'N/A',
        this.nationality = nationality ?? 'N/A',
        this.surname = surname ?? 'N/A',
        this.givenName = givenName ?? 'N/A',
        this.passportNumber = passportNumber ?? 'N/A',
        this.issuingCountry = issuingCountry ?? 'N/A',
        this.birthDate = birthDate ?? 'N/A',
        this.gender = gender ?? 'N/A',
        this.expiration = expiration ?? 'N/A';

  @override
  String toString() {
    if (type == null || type!.isEmpty) return "No results";

    String result = '';

    result += 'Type: $type\n\n';
    result += 'Nationality: $nationality\n\n';
    result += 'Surname: $surname\n\n';
    result += 'Given name: $givenName\n\n';
    result += 'Passport Number: $passportNumber\n\n';
    result += 'Issue Country: $issuingCountry\n\n';
    result += 'Date of birth: $birthDate\n\n';
    result += 'Gender: $gender\n\n';
    result += 'Expiration: $expiration\n\n';

    return result;
  }

  Map<String, dynamic> toJson() => {
        'type': type ?? '',
        'nationality': nationality ?? '',
        'surname': surname ?? '',
        'givenName': givenName ?? '',
        'passportNumber': passportNumber ?? '',
        'issuingCountry': issuingCountry ?? '',
        'birthDate': birthDate ?? '',
        'gender': gender ?? '',
        'expiration': expiration ?? '',
      };

  factory MrzResult.fromJson(Map<String, dynamic> json) {
    return MrzResult(
      type: json['type'],
      nationality: json['nationality'],
      surname: json['surname'],
      givenName: json['givenName'],
      passportNumber: json['passportNumber'],
      issuingCountry: json['issuingCountry'],
      birthDate: json['birthDate'],
      gender: json['gender'],
      expiration: json['expiration'],
    );
  }
}
