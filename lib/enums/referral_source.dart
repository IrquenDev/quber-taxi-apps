import 'package:quber_taxi/l10n/app_localizations.dart';

enum ReferralSource {

  friend("FRIEND"),
  poster("POSTER"),
  playStore("PLAY_STORE");

  final String apiValue;

  static String nameOf(ReferralSource referralSource, AppLocalizations localizations) {
    return switch(referralSource) {
      ReferralSource.friend => localizations.referralSourceFriend,
      ReferralSource.poster => localizations.referralSourcePoster,
      ReferralSource.playStore => localizations.referralSourcePlayStore
    };
  }

  const ReferralSource(this.apiValue);
}