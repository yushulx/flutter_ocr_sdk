/// MrzResult class.
class MrzResult {
  /// Document type.
  String type = '';

  /// Nationality.
  String nationality = '';

  /// Surname.
  String surname = '';

  /// Given name.
  String givenName = '';

  /// Passport number.
  String passportNumber = '';

  /// Issuing country.
  String issuingCountry = '';

  /// Birth date.
  String birthDate = '';

  /// Gender.
  String gender = '';

  /// Expiration date.
  String expiration = '';

  @override
  String toString() {
    if (type.isEmpty) return "No results";

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
}
