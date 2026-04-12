/// Gumlet Image Proxy (GIP) URL builder.
///
/// Rewrites an image URL to route through the Gumlet Fetch CDN:
///   https://ero2.gumlet.io/fetch/{percent-encoded-original-url}?format=webp
///
/// - Video URLs are never proxied (Gumlet is an image CDN).
/// - Favicons and non-http(s) URLs are passed through unchanged.
/// - Quality is intentionally omitted — configure it on your Gumlet dashboard.

const _proxyHost = 'ero2.gumlet.io';

const _videoExtensions = {
  'mp4', 'webm', 'mov', 'avi', 'mkv', 'flv', 'ogv',
};

/// Returns the Gumlet proxy URL for [url] when [enabled] is true.
/// Returns [url] unchanged when [enabled] is false or the URL should be skipped.
String toGumletUrl(String url, {required bool enabled}) {
  if (!enabled || url.isEmpty) return url;

  final uri = Uri.tryParse(url);
  if (uri == null) return url;
  if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) return url;
  if (uri.host == _proxyHost) return url; // already proxied

  final ext = url.split('.').last.split('?').first.toLowerCase();
  if (_videoExtensions.contains(ext)) return url; // skip video files

  final encoded = Uri.encodeComponent(url);
  return Uri(
    scheme: 'https',
    host: _proxyHost,
    pathSegments: ['fetch', encoded],
    queryParameters: {'format': 'webp'},
  ).toString();
}
