import 'package:flutter/services.dart';

import 'flutter_ocr_sdk.dart';

class MRZ {
  /// Parsing MRZ string to get detailed information.
  static String parse(String line1, String line2) {
    // https://en.wikipedia.org/wiki/Machine-readable_passport
    String result = "";
    // Type
    String tmp = "Type: ";
    tmp += line1[0];
    result += tmp + '\n\n';

    // Issuing country
    tmp = "Issuing country: ";
    tmp += line1.substring(2, 5);
    result += tmp + '\n\n';

    // Surname
    int index = 5;
    tmp = "Surname: ";
    for (; index < 44; index++) {
      if (line1[index] != '<') {
        tmp += line1[index];
      } else {
        break;
      }
    }
    result += tmp + '\n\n';

    // Given names
    tmp = "Given Names: ";
    index += 2;
    for (; index < 44; index++) {
      if (line1[index] != '<') {
        tmp += line1[index];
      } else {
        tmp += ' ';
      }
    }
    result += tmp + '\n\n';

    // Passport number
    tmp = "Passport number: ";
    index = 0;
    for (; index < 9; index++) {
      if (line2[index] != '<') {
        tmp += line2[index];
      } else {
        break;
      }
    }
    result += tmp + '\n\n';

    // Nationality
    tmp = "Nationality: ";
    tmp += line2.substring(10, 13);
    result += tmp + '\n\n';

    // Date of birth
    tmp = line2.substring(13, 19);
    tmp = tmp.substring(0, 2) +
        '/' +
        tmp.substring(2, 4) +
        '/' +
        tmp.substring(4, 6);
    tmp = "Date of birth (YYMMDD): " + tmp;
    result += tmp + '\n\n';

    // Sex
    tmp = "Sex: ";
    tmp += line2[20];
    result += tmp + '\n\n';

    // Expiration date of passport
    tmp = line2.substring(21, 27);
    tmp = tmp.substring(0, 2) +
        '/' +
        tmp.substring(2, 4) +
        '/' +
        tmp.substring(4, 6);
    tmp = "Expiration date of passport (YYMMDD): " + tmp;
    result += tmp + '\n\n';

    // Personal number
    if (line2[28] != '<') {
      tmp = "Personal number: ";
      for (index = 28; index < 42; index++) {
        if (line2[index] != '<') {
          tmp += line2[index];
        } else {
          break;
        }
      }
      result += tmp + '\n\n';
    }

    return result;
  }
}
