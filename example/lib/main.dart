import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  final phoneController = TextEditingController();
  final countryController = TextEditingController(text: '+44');
  final manualFormatController = TextEditingController();
  String? parsedData;

  /// Used to format numbers as mobile or land line
  var globalPhoneType = PhoneNumberType.mobile;

  /// Use international or national phone format
  var globalPhoneFormat = PhoneNumberFormat.international;

  final initFuture = FlutterLibphonenumber().init();
  // final initFuture = Future.delayed(Duration(milliseconds: 1500));

  /// Will try to parse the country from the override country code field
  String get overrideCountryCode {
    if (countryController.text.isNotEmpty) {
      try {
        return CountryManager()
            .countries
            .firstWhere((element) =>
                element.phoneCode ==
                countryController.text.replaceAll(RegExp(r'[^\d]+'), ''))
            .countryCode;
      } catch (_) {
        return '';
      }
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<void>(
        future: initFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text('flutter_libphonenumber'),
              ),
              body: Center(
                child: Text('error: ${snapshot.error}'),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  title: const Text('flutter_libphonenumber'),
                ),
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: max(
                        0,
                        24 - MediaQuery.of(context).padding.bottom,
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),

                        /// Get all region codes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              child: Text('Print all region data'),
                              onPressed: () async {
                                // await FlutterLibphonenumber().init();

                                final res = await FlutterLibphonenumber()
                                    .getAllSupportedRegions();
                                print(res['GB']);
                                print(res['US']);
                                print(res['BR']);
                              },
                            ),

                            /// Spacer
                            SizedBox(width: 20),

                            Expanded(
                              child: Column(
                                children: [
                                  /// Mobile or land line toggle
                                  Row(
                                    children: [
                                      Switch(
                                        value: globalPhoneType ==
                                                PhoneNumberType.mobile
                                            ? true
                                            : false,
                                        onChanged: (val) {
                                          setState(
                                            () => globalPhoneType =
                                                (val == false
                                                    ? PhoneNumberType.fixedLine
                                                    : PhoneNumberType.mobile),
                                          );
                                        },
                                      ),

                                      /// Spacer
                                      SizedBox(width: 5),

                                      Flexible(
                                        child: globalPhoneType ==
                                                PhoneNumberType.mobile
                                            ? Text('Format as Mobile')
                                            : Text('Format as FixedLine'),
                                      ),
                                    ],
                                  ),

                                  /// National or international line toggle
                                  Row(
                                    children: [
                                      Switch(
                                        value: globalPhoneFormat ==
                                                PhoneNumberFormat.national
                                            ? true
                                            : false,
                                        onChanged: (val) {
                                          setState(
                                            () => globalPhoneFormat = (val ==
                                                    false
                                                ? PhoneNumberFormat
                                                    .international
                                                : PhoneNumberFormat.national),
                                          );
                                        },
                                      ),

                                      /// Spacer
                                      SizedBox(width: 5),

                                      Flexible(
                                        child: globalPhoneFormat ==
                                                PhoneNumberFormat.national
                                            ? Text('National')
                                            : Text('International'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),

                        /// Spacer
                        SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 10),

                        /// Format as you type
                        Text('Format as you type (synchronous using masks)'),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// Country code input
                            Container(
                              width: 50,
                              child: TextField(
                                controller: countryController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: '+44',
                                ),
                                onChanged: (v) {
                                  setState(() {});
                                },
                                inputFormatters: [],
                              ),
                            ),

                            /// Spacer
                            SizedBox(width: 30),

                            /// Phone input
                            Container(
                              width: 160,
                              child: TextField(
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.phone,
                                controller: phoneController,
                                decoration: InputDecoration(
                                  hintText: '7777-777777',
                                ),
                                inputFormatters: [
                                  LibPhonenumberTextFormatter(
                                    phoneNumberType: globalPhoneType,
                                    phoneNumberFormat: globalPhoneFormat,
                                    overrideSkipCountryCode:
                                        overrideCountryCode,
                                    onCountrySelected: (val) {
                                      print(
                                          'Detected country: ${val?.countryName}');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        /// Spacer
                        SizedBox(height: 10),

                        Text(
                          'If country code is not empty, phone number will format expecting no country code.',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),

                        /// Spacer
                        SizedBox(height: 20),
                        Divider(),
                        SizedBox(height: 20),

                        Text(
                          'Manually format / parse the phone number.\nAsync uses FlutterLibphonenumber().format().\nSync uses FlutterLibphonenumber().formatPhone.',
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),

                        /// Manual Phone input
                        Container(
                          width: 180,
                          child: TextField(
                            keyboardType: TextInputType.phone,
                            textAlign: TextAlign.center,
                            controller: manualFormatController,
                            decoration: InputDecoration(
                              hintText: '7777-777777',
                            ),
                          ),
                        ),

                        /// Spacer
                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            /// Manually format the phone input
                            Flexible(
                              child: ElevatedButton(
                                child: Text(
                                  'Format (Async)',
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () async {
                                  // Asynchronous formatting with native call into libphonenumber
                                  final res =
                                      await FlutterLibphonenumber().format(
                                    manualFormatController.text,
                                    'US', // TODO: how can we not have to set this manually?
                                  );
                                  setState(
                                    () => manualFormatController.text =
                                        res['formatted'] ?? '',
                                  );
                                },
                              ),
                            ),

                            /// Spacer
                            SizedBox(width: 10),

                            Flexible(
                              child: ElevatedButton(
                                child: Text(
                                  'Format (Sync)',
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () async {
                                  if (CountryManager().countries.isEmpty) {
                                    print(
                                        'Warning: countries list is empty which means init hs not be run yet. Can\'t format synchronously until init has been executed.');
                                  }
                                  // Synchronous formatting with no native call into libphonenumber, just a dart call to mask the input
                                  setState(
                                    () => manualFormatController.text =
                                        FlutterLibphonenumber()
                                            .formatNumberSync(
                                      manualFormatController.text,
                                      phoneNumberType: globalPhoneType,
                                      phoneNumberFormat: globalPhoneFormat,
                                    ),
                                  );
                                },
                              ),
                            ),

                            /// Spacer
                            SizedBox(width: 10),

                            /// Manually format the phone input
                            Flexible(
                              child: ElevatedButton(
                                child: Text(
                                  'Parse',
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () async {
                                  try {
                                    final res = await FlutterLibphonenumber()
                                        .parse(manualFormatController.text);

                                    JsonEncoder encoder =
                                        JsonEncoder.withIndent('  ');

                                    setState(() =>
                                        parsedData = encoder.convert(res));
                                  } catch (e) {
                                    print(e);
                                    setState(() => parsedData = null);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),

                        /// Spacer
                        SizedBox(height: 10),

                        Text(parsedData ?? 'Number invalid'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text('flutter_libphonenumber'),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
