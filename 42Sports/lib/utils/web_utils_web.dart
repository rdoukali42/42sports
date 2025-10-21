// Web-specific utilities
import 'dart:html' as html;

class WebUtils {
  static String getCurrentUrl() {
    return html.window.location.href;
  }

  static void replaceUrl(String url) {
    html.window.history.replaceState(null, '', url);
  }
}
