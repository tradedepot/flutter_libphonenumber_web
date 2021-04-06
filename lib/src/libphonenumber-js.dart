@JS('libphonenumber')
library libphonenumber;

import "package:js/js.dart";

external Phone Function(String phonenumber, [String? countryCode])
    get parsePhoneNumber;

external List<String> Function() get getCountries;

external Phone Function(
  String countryCode,
  Map examples,
) get getExampleNumber;

@JS()
class Phone {
  external String get country;

  external String get countryCallingCode;

  external String get number;

  external bool Function() get isValid;

  external String? Function() get getType;

  external String Function(String format) get format;

  external String Function([Map formatNumberOptionsWithoutIDD])
      get formatInternational;

  external String Function([Map formatNumberOptionsWithoutIDD])
      get formatNational;
}

@JS()
class AsYouType {
  external factory AsYouType([String region]);

  external String Function(String text) get input;
}
