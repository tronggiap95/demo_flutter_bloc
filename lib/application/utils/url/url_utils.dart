import 'package:url_launcher/url_launcher.dart';

class UrlUtils {
  static void launchUrl(String? url) async {
    if (url != null && await canLaunch(Uri.encodeFull(url))) {
      await launch(
        Uri.encodeFull(url),
        forceSafariVC: false,
      );
    }
  }
}
