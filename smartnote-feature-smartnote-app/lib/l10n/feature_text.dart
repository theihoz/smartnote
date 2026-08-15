import 'package:flutter/widgets.dart';

String featureText(
  BuildContext context, {
  required String vi,
  required String en,
}) => Localizations.localeOf(context).languageCode == 'en' ? en : vi;
