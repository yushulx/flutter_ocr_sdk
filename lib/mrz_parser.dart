import 'mrz_result.dart';

class MRZ {
  /// Parse two lines of MRZ string.
  static MrzResult parseTwoLines(String line1, String line2) {
    MrzResult mrzInfo = MrzResult();
    String type = line1.substring(0, 1);
    RegExp exp = RegExp(r'[I|P|V]');
    RegExpMatch? match = exp.firstMatch(type);
    if (match == null) {
      return mrzInfo;
    }

    if (type == 'P') {
      mrzInfo.type = 'PASSPORT (TD-3)';
    } else if (type == 'V') {
      if (line1.length == 44) {
        mrzInfo.type = 'VISA (MRV-A)';
      } else if (line1.length == 36) {
        mrzInfo.type = 'VISA (MRV-B)';
      }
    } else if (type == 'I') {
      mrzInfo.type = 'ID CARD (TD-2)';
    }

    // Get issuing State information
    String nation = line1.substring(2, 5);
    exp = RegExp(r'[0-9]');
    match = exp.firstMatch(nation);
    if (match != null) return mrzInfo;
    if (nation[nation.length - 1] == '<') {
      nation = nation.substring(0, 2);
    }
    mrzInfo.nationality = nation;
    // Get surname information
    line1 = line1.substring(5);
    int pos = line1.indexOf('<<');
    String surName = line1.substring(0, pos);
    exp = RegExp(r'[0-9]');
    match = exp.firstMatch(surName);
    if (match != null) return mrzInfo;
    surName = surName.replaceAll('<', ' ');
    mrzInfo.surname = surName;
    // Get givenname information
    String givenName = line1.substring(surName.length + 2);
    exp = RegExp(r'[0-9]');
    match = exp.firstMatch(givenName);
    if (match != null) return mrzInfo;
    givenName = givenName.replaceAll('<', ' ');
    givenName = givenName.trim();
    mrzInfo.givenName = givenName;
    // Get passport number information
    String docNumber = '';
    docNumber = line2.substring(0, 9);
    docNumber = docNumber.replaceAll('<', ' ');
    mrzInfo.docNumber = docNumber;
    // Get Nationality information
    String issueCountry = line2.substring(10, 13);
    exp = RegExp(r'[0-9]');
    match = exp.firstMatch(issueCountry);
    if (match != null) return mrzInfo;
    if (issueCountry[issueCountry.length - 1] == '<') {
      issueCountry = issueCountry.substring(0, 2);
    }
    mrzInfo.issuingCountry = issueCountry;
    // Get date of birth information
    String birth = line2.substring(13, 19);
    DateTime now = DateTime.now();
    int currentYear = now.year;
    if (int.parse(birth.substring(0, 2)) > (currentYear % 100)) {
      birth = '19$birth';
    } else {
      birth = '20$birth';
    }
    birth =
        '${birth.substring(0, 4)}/${birth.substring(4, 6)}/${birth.substring(6, 8)}';
    mrzInfo.birthDate = birth;

    // Get gender information
    String gender = line2[20];
    exp = RegExp(r'[M|F|x|<]');
    match = exp.firstMatch(gender);
    if (match == null) return mrzInfo;
    mrzInfo.gender = gender;
    // Get date of expiry information
    String expiry = line2.substring(21, 27);
    exp = RegExp(r'[A-Za-z]');
    match = exp.firstMatch(expiry);
    if (match != null) return mrzInfo;
    if (int.parse(expiry.substring(0, 2)) >= 60) {
      expiry = '19$expiry';
    } else {
      expiry = '20$expiry';
    }
    expiry =
        '${expiry.substring(0, 4)}/${expiry.substring(4, 6)}/${expiry.substring(6)}';
    mrzInfo.expiration = expiry;

    return mrzInfo;
  }

  /// Parse three lines of MRZ string.
  static MrzResult parseThreeLines(String line1, String line2, String line3) {
    MrzResult mrzInfo = MrzResult();
    String type = line1.substring(0, 1);
    RegExp exp = RegExp(r'[I|P|V]');
    RegExpMatch? match = exp.firstMatch(type);
    if (match == null) {
      return mrzInfo;
    }

    mrzInfo.type = 'ID CARD (TD-1)';
    // Get nationality information
    String nation = line2.substring(15, 18);
    exp = RegExp(r'[0-9]');
    match = exp.firstMatch(nation);
    if (match != null) return mrzInfo;
    nation = nation.replaceAll('<', '');
    mrzInfo.nationality = nation;
    // Get surname information
    int pos = line3.indexOf('<<');
    String surName = line3.substring(0, pos);
    exp = RegExp(r'[0-9]');
    match = exp.firstMatch(surName);
    if (match != null) return mrzInfo;
    surName = surName.replaceAll('<', ' ');
    surName.trim();
    mrzInfo.surname = surName;
    // Get givenname information
    String givenName = line3.substring(surName.length + 2);
    exp = RegExp(r'[0-9]');
    match = exp.firstMatch(givenName);
    if (match != null) return mrzInfo;
    givenName = givenName.replaceAll('<', ' ');
    givenName = givenName.trim();
    mrzInfo.givenName = givenName;
    // Get passport number information
    String docNumber = '';
    docNumber = line1.substring(5, 14);
    docNumber = docNumber.replaceAll('<', ' ');
    mrzInfo.docNumber = docNumber;
    // Get issuing country or organization information
    String issueCountry = line1.substring(2, 5);
    exp = RegExp(r'[0-9]');
    match = exp.firstMatch(issueCountry);
    if (match != null) return mrzInfo;
    issueCountry = issueCountry.replaceAll('<', '');
    mrzInfo.issuingCountry = issueCountry;
    // Get date of birth information
    String birth = line2.substring(0, 6);
    exp = RegExp(r'[A-Za-z]');
    match = exp.firstMatch(birth);
    if (match != null) return mrzInfo;

    DateTime now = DateTime.now();
    int currentYear = now.year;
    if (int.parse(birth.substring(0, 2)) > (currentYear % 100)) {
      birth = '19$birth';
    } else {
      birth = '20$birth';
    }
    birth =
        '${birth.substring(0, 4)}/${birth.substring(4, 6)}/${birth.substring(6, 8)}';
    mrzInfo.birthDate = birth;

    // Get gender information
    String gender = line2[7];
    exp = RegExp(r'[M|F|x|<]');
    match = exp.firstMatch(gender);
    if (match == null) return mrzInfo;
    gender = gender.replaceAll('<', 'X');
    mrzInfo.gender = gender;
    // Get date of expiry information
    String expiry = '20$line2.substring(8, 14)';
    exp = RegExp(r'[A-Za-z]');
    match = exp.firstMatch(expiry);
    if (match != null) return mrzInfo;
    expiry =
        '${expiry.substring(0, 4)}/${expiry.substring(4, 6)}/${expiry.substring(6)}';
    mrzInfo.expiration = expiry;

    return mrzInfo;
  }
}
