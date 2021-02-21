import 'package:flutter/services.dart';
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
    return {
      "GB": {
        "phoneCode": "44",
        "exampleNumberMobileNational": "07400 123456",
        "exampleNumberFixedLineNational": "0121 234 5678",
        "phoneMaskMobileNational": "00000 000000",
        "phoneMaskFixedLineNational": "0000 000 0000",
        "exampleNumberMobileInternational": "+44 7400 123456",
        "exampleNumberFixedLineInternational": "+44 121 234 5678",
        "phoneMaskMobileInternational": "+00 0000 000000",
        "phoneMaskFixedLineInternational": "+00 000 000 0000",
        "countryName": "United Kingdom",
      },
      "NG": {
        "phoneCode": "234",
        "exampleNumberMobileNational": "0809 664 6691",
        "exampleNumberFixedLineNational": "0809 664 6691",
        "phoneMaskMobileNational": "0000 000 0000",
        "phoneMaskFixedLineNational": "0000 000 0000",
        "exampleNumberMobileInternational": "+234 809 664 6691",
        "exampleNumberFixedLineInternational": "+234 809 234 6691",
        "phoneMaskMobileInternational": "+000 000 000 0000",
        "phoneMaskFixedLineInternational": "+000 000 000 0000",
        "countryName": "Nigeria",
      },
      "US": {
        "phoneCode": "1",
        "exampleNumberMobileNational": "(201) 555-0123",
        "exampleNumberFixedLineNational": "(201) 555-0123",
        "phoneMaskMobileNational": "(000) 000-0000",
        "phoneMaskFixedLineNational": "(000) 000-0000",
        "exampleNumberMobileInternational": "+1 201-555-0123",
        "exampleNumberFixedLineInternational": "+1 201-555-0123",
        "phoneMaskMobileInternational": "+0 000-000-0000",
        "phoneMaskFixedLineInternational": "+0 000-000-0000",
        "countryName": "United States",
      },
      "BR": {
        "phoneCode": "55",
        "exampleNumberMobileNational": "(11) 96123-4567",
        "exampleNumberFixedLineNational": "(11) 2345-6789",
        "phoneMaskMobileNational": "(00) 00000-0000",
        "phoneMaskFixedLineNational": "(00) 0000-0000",
        "exampleNumberMobileInternational": "+55 11 96123-4567",
        "exampleNumberFixedLineInternational": "+55 11 2345-6789",
        "phoneMaskMobileInternational": "+00 00 00000-0000",
        "phoneMaskFixedLineInternational": "+00 00 0000-0000",
        "countryName": "Brazil",
      },
    };
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
      'national_number': parsed.formatNational(),
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
}
