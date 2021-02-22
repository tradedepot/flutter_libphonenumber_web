import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber_web/src/examples.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'src/libphonenumber-js.dart';

class FlutterLibphonenumberWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'flutter_libphonenumber',
      const StandardMethodCodec(),
      registrar,
    );
    final instance = FlutterLibphonenumberWeb();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'get_all_supported_regions':
        return getAllSupportedRegions();
      case 'format':
        final String phone = call.arguments['phone'];
        final String region = call.arguments['region'];
        final formatted = AsYouType(region).input(phone);
        return {
          'formatted': formatted,
        };
      case 'parse':
        return parse(call);
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: "The flutter_libphonenumber_web plugin doesn't implement "
              "the method '${call.method}'",
        );
    }
  }

  Future<Map> getAllSupportedRegions() async {
    final data = <String, Map<String, String>>{};

    getCountries().forEach((countryCode) {
      if (examples.containsKey(countryCode)) {
        final phone = parsePhoneNumber(examples[countryCode]!, countryCode);
        if (!phone.isValid()) return;

        final nationalNumber = phone.formatNational();
        final internationalNumber = phone.formatInternational();

        data[countryCode] = {
          'phoneCode': phone.countryCallingCode,
          'exampleNumberMobileNational': nationalNumber,
          'exampleNumberFixedLineNational': nationalNumber,
          'phoneMaskMobileNational': _maskNumber(nationalNumber),
          'phoneMaskFixedLineNational': _maskNumber(nationalNumber),
          'exampleNumberMobileInternational': internationalNumber,
          'exampleNumberFixedLineInternational': internationalNumber,
          'phoneMaskMobileInternational': _maskNumber(internationalNumber),
          'phoneMaskFixedLineInternational': _maskNumber(internationalNumber),
          'countryName': countryCode,
        };
      }
    });

    return data;
  }

  Future<Map?> parse(MethodCall call) async {
    final String phone = call.arguments['phone'];
    final String? region = call.arguments['region'];
    final parsed = parsePhoneNumber(phone, region);

    if (!parsed.isValid()) {
      // invalid phone number
      throw PlatformException(
        code: 'InvalidNumber',
        message: 'Number $phone is invalid',
      );
    }

    return {
      'national': parsed.formatNational(),
      'e164': parsed.number,
      'national_number':
          parsed.number.replaceFirst('+${parsed.countryCallingCode}', ''),
      'international': parsed.formatInternational(),
      'country_code': parsed.countryCallingCode,
      'type': formatNumberType(parsed.getType()),
    };
  }

  String formatNumberType(String? type) {
    if (type == null) return 'unknown';

    // 'PREMIUM_RATE' | 'TOLL_FREE' | 'SHARED_COST' | 'VOIP' | 'PERSONAL_NUMBER' | 'PAGER' | 'UAN' | 'VOICEMAIL' | 'FIXED_LINE_OR_MOBILE' | 'FIXED_LINE' | 'MOBILE'
    if (type == 'FIXED_LINE_OR_MOBILE') return 'fixedOrMobile';

    // convert snake_case to camelCase
    String formatted = '';
    final cases = type.toLowerCase().split('_');
    cases.forEach((element) {
      if (formatted.isEmpty) {
        formatted = element;
      } else {
        formatted +=
            element.substring(0, 1).toUpperCase() + element.substring(1);
      }
    });
    return formatted;
  }

  // Masks a phone number by replacing all digits with 0s
  String _maskNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'\d'), '0');
  }
}
