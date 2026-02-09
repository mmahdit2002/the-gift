import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class SmartAssetImage extends StatelessWidget {
  final String assetPath;
  final BoxFit fit;
  final double? width;
  final double? height;

  /// Optional tint for SVGs (applied via SvgPicture.colorFilter).
  final Color? svgColor;

  /// Blend mode used with [svgColor]. Typical is BlendMode.srcIn.
  final BlendMode svgColorBlendMode;

  /// Advanced: provide your own filter (overrides [svgColor] if set).
  final ColorFilter? svgColorFilter;
  final bool matchTextDirection;

  const SmartAssetImage({
    required this.assetPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.svgColor,
    this.svgColorBlendMode = BlendMode.srcIn,
    this.svgColorFilter,
    this.matchTextDirection = false,
    super.key,
  }) : assert(svgColor == null || svgColorFilter == null, 'Provide either svgColor or svgColorFilter, not both.');

  Future<SvgStringLoader> _loadSvgLoader(BuildContext context) async {
    String svgData;
    try {
      svgData = await DefaultAssetBundle.of(context).loadString(assetPath);
    } catch (assetError) {
      debugPrint('SVG asset failed for $assetPath: $assetError');
      if (kIsWeb) {
        try {
          final assetUrl = Uri.base.resolve(assetPath).toString();
          final response = await http.get(Uri.parse(assetUrl));
          if (response.statusCode == 200) {
            svgData = response.body;
          } else {
            throw Exception('HTTP error: ${response.statusCode}');
          }
        } catch (networkError) {
          debugPrint('SVG network failed for $assetPath: $networkError');
          throw networkError;
        }
      } else {
        throw assetError;
      }
    }

    // -------------------------------------------------------------------------
    // FIX: Sanitize SVG String to remove percentage dimensions
    // -------------------------------------------------------------------------
    // Flutter SVG parser often crashes on "100%" values for width/height.
    // We remove them so it falls back to the viewBox.
    svgData = svgData.replaceAll(
      RegExp(
        r'(width|height)\s*=\s*["'
        ']100%["'
        ']',
      ),
      '',
    );

    final loader = SvgStringLoader(svgData);
    await loader.loadBytes(context);
    return loader;
  }

  @override
  Widget build(BuildContext context) {
    final assetUrl = Uri.base.resolve(assetPath).toString();
    final isSvg = assetPath.toLowerCase().endsWith('.svg');

    final ColorFilter? effectiveSvgFilter = svgColorFilter ?? (svgColor != null ? ColorFilter.mode(svgColor!, svgColorBlendMode) : null);

    if (isSvg) {
      return FutureBuilder<SvgStringLoader>(
        future: _loadSvgLoader(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SvgPicture(snapshot.data!, width: width, height: height, fit: fit, colorFilter: effectiveSvgFilter, matchTextDirection: matchTextDirection);
          }
          if (snapshot.hasError) {
            debugPrint('SVG load/parse error: ${snapshot.error}');
            return kIsWeb ? _ErrorViewWithUrl(url: assetUrl) : const _ErrorView();
          }
          return const Center(child: SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3)));
        },
      );
    }

    // Non-SVG (images) stays the same
    if (kIsWeb) {
      return Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image.asset failed for $assetPath: $error');
          return Image.network(
            assetUrl,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Image.network failed for $assetUrl: $error');
              return _ErrorViewWithUrl(url: assetUrl);
            },
          );
        },
      );
    }

    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Image.asset failed (native) for $assetPath: $error');
        return const _ErrorView();
      },
    );
  }
}

class _ErrorViewWithUrl extends StatelessWidget {
  final String url;

  const _ErrorViewWithUrl({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image, size: 40, color: Colors.white70),
          const SizedBox(height: 8),
          const Text("Failed to load", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          SelectableText(
            url,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image, size: 40, color: Colors.white70),
          const SizedBox(height: 8),
          const Text("Failed to load", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
