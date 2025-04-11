class VinResult {
  String? vinString;
  String? wmi;
  String? region;
  String? vds;
  String? checkDigit;
  String? modelYear;
  String? plantCode;
  String? serialNumber;

  VinResult({
    String? vinString,
    String? wmi,
    String? region,
    String? vds,
    String? checkDigit,
    String? modelYear,
    String? plantCode,
    String? serialNumber,
  })  : vinString = vinString ?? 'N/A',
        wmi = wmi ?? 'N/A',
        region = region ?? 'N/A',
        vds = vds ?? 'N/A',
        checkDigit = checkDigit ?? 'N/A',
        modelYear = modelYear ?? 'N/A',
        plantCode = plantCode ?? 'N/A',
        serialNumber = serialNumber ?? 'N/A';

  @override
  String toString() {
    return "VIN String: " +
        vinString! +
        "\n" +
        "WMI: " +
        wmi! +
        "\n" +
        "Region: " +
        region! +
        "\n" +
        "VDS: " +
        vds! +
        "\n" +
        "Check Digit: " +
        checkDigit! +
        "\n" +
        "Model Year: " +
        modelYear! +
        "\n" +
        "Manufacturer plant: " +
        plantCode! +
        "\n" +
        "Serial Number: " +
        serialNumber!;
  }

  Map<String, dynamic> toJson() => {
        'vinString': vinString,
        'wmi': wmi,
        'region': region,
        'vds': vds,
        'checkDigit': checkDigit,
        'modelYear': modelYear,
        'plantCode': plantCode,
        'serialNumber': serialNumber,
      };

  factory VinResult.fromJson(Map<String, dynamic> json) {
    return VinResult(
      vinString: json['vinString'],
      wmi: json['wmi'],
      region: json['region'],
      vds: json['vds'],
      checkDigit: json['checkDigit'],
      modelYear: json['modelYear'],
      plantCode: json['plantCode'],
      serialNumber: json['serialNumber'],
    );
  }
}
