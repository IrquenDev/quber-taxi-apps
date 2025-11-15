import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Widget that displays a network image with intelligent caching and invalidation support
/// 
/// Features:
/// - Disk and memory caching via cached_network_image
/// - Cache invalidation via cacheKey parameter
/// - Customizable placeholder and error widgets
/// - Supports circular images via CircleAvatar mode
class SmartCachedImage extends StatelessWidget {
  /// The URL of the image to load
  final String? imageUrl;

  /// Optional cache key for cache invalidation
  /// When this changes, the image will be reloaded even if the URL is the same
  /// Use this to force refresh when content updates but URL stays the same
  final String? cacheKey;

  /// Width of the image
  final double? width;

  /// Height of the image
  final double? height;

  /// How the image should be fitted
  final BoxFit fit;

  /// Widget to show while loading
  final Widget? placeholder;

  /// Widget to show on error
  final Widget? errorWidget;

  /// Placeholder asset path (SVG)
  final String? placeholderAsset;

  /// Background color for placeholder
  final Color? backgroundColor;

  /// Placeholder color for SVG
  final Color? placeholderColor;

  /// Whether to display as a CircleAvatar
  final bool useCircleAvatar;

  /// Radius for CircleAvatar (only used if useCircleAvatar is true)
  final double? radius;

  /// Border radius for rounded corners (only used if useCircleAvatar is false)
  final BorderRadius? borderRadius;

  /// Callback when image finishes loading
  final VoidCallback? onImageLoaded;

  const SmartCachedImage({
    super.key,
    required this.imageUrl,
    this.cacheKey,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.placeholderAsset,
    this.backgroundColor,
    this.placeholderColor,
    this.useCircleAvatar = false,
    this.radius,
    this.borderRadius,
    this.onImageLoaded,
  }) : assert(
          !useCircleAvatar || radius != null,
          'radius must be provided when useCircleAvatar is true',
        );

  /// Creates a circular cached image (convenience constructor)
  const SmartCachedImage.circle({
    super.key,
    required this.imageUrl,
    this.cacheKey,
    required this.radius,
    this.placeholderAsset,
    this.backgroundColor,
    this.placeholderColor,
    this.placeholder,
    this.errorWidget,
    this.onImageLoaded,
  })  : useCircleAvatar = true,
        width = null,
        height = null,
        fit = BoxFit.cover,
        borderRadius = null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Build placeholder widget
    final defaultPlaceholder = _buildPlaceholder(colorScheme);
    final loadingWidget = placeholder ?? defaultPlaceholder;

    // Build error widget
    final defaultErrorWidget = _buildPlaceholder(colorScheme);
    final errorPlaceholder = errorWidget ?? defaultErrorWidget;

    // If no URL, show placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      if (useCircleAvatar) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? colorScheme.onSecondary,
          child: defaultPlaceholder,
        );
      }
      return loadingWidget;
    }

    // Build cache key (URL + optional cacheKey for invalidation)
    final effectiveCacheKey = cacheKey != null ? '$imageUrl?cacheKey=$cacheKey' : imageUrl!;

    // Build the cached network image
    final cachedImage = _CachedImageWithCallback(
      imageUrl: imageUrl!,
      cacheKey: effectiveCacheKey,
      width: width,
      height: height,
      fit: fit,
      placeholder: loadingWidget,
      errorWidget: errorPlaceholder,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
      onImageLoaded: onImageLoaded,
    );

    // Return as CircleAvatar or regular widget
    if (useCircleAvatar) {
      if (imageUrl == null || imageUrl!.isEmpty) {
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? colorScheme.onSecondary,
          child: defaultPlaceholder,
        );
      }
      
      // Use CachedNetworkImage with ClipOval for better control over loading/error states
      return ClipOval(
        child: Container(
          width: radius! * 2,
          height: radius! * 2,
          color: backgroundColor ?? colorScheme.onSecondary,
          child: _CachedImageWithCallback(
            imageUrl: imageUrl!,
            cacheKey: effectiveCacheKey,
            width: radius! * 2,
            height: radius! * 2,
            fit: BoxFit.cover,
            placeholder: Center(child: loadingWidget),
            errorWidget: errorPlaceholder,
            fadeInDuration: const Duration(milliseconds: 200),
            fadeOutDuration: const Duration(milliseconds: 100),
            onImageLoaded: onImageLoaded,
          ),
        ),
      );
    }

    // Apply border radius if provided
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: cachedImage,
      );
    }

    return cachedImage;
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    if (placeholderAsset != null) {
      final size = useCircleAvatar ? (radius! * 1.2) : (width ?? height ?? 48.0);
      return SvgPicture.asset(
        placeholderAsset!,
        width: size,
        height: size,
        colorFilter: placeholderColor != null
            ? ColorFilter.mode(placeholderColor!, BlendMode.srcIn)
            : null,
      );
    }

    final size = useCircleAvatar ? (radius! * 1.2) : (width ?? height ?? 48.0);
    return Icon(
      Icons.person,
      size: size,
      color: placeholderColor ?? colorScheme.onSecondaryContainer,
    );
  }
}

/// Internal widget that wraps CachedNetworkImage and detects when image finishes loading
class _CachedImageWithCallback extends StatefulWidget {
  final String imageUrl;
  final String cacheKey;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget placeholder;
  final Widget errorWidget;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final VoidCallback? onImageLoaded;

  const _CachedImageWithCallback({
    required this.imageUrl,
    required this.cacheKey,
    this.width,
    this.height,
    required this.fit,
    required this.placeholder,
    required this.errorWidget,
    required this.fadeInDuration,
    required this.fadeOutDuration,
    this.onImageLoaded,
  });

  @override
  State<_CachedImageWithCallback> createState() => _CachedImageWithCallbackState();
}

class _CachedImageWithCallbackState extends State<_CachedImageWithCallback> {
  bool _hasLoaded = false;
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;

  @override
  void initState() {
    super.initState();
    _setupImageListener();
  }

  void _setupImageListener() {
    // Get the image provider from CachedNetworkImageProvider
    final imageProvider = CachedNetworkImageProvider(
      widget.imageUrl,
      cacheKey: widget.cacheKey,
    );

    // Resolve the image to get the ImageStream
    final ImageStream stream = imageProvider.resolve(const ImageConfiguration());

    // Listen to the stream to detect when image loads
    _imageListener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        // Image has finished loading
        if (!_hasLoaded && widget.onImageLoaded != null) {
          _hasLoaded = true;
          // Call callback after frame is complete to avoid setState during build
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted && widget.onImageLoaded != null) {
              widget.onImageLoaded!();
            }
          });
        }
      },
      onError: (exception, stackTrace) {
        // Handle error if needed
      },
    );

    _imageStream = stream;
    _imageStream?.addListener(_imageListener!);
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageListener!);
    super.dispose();
  }

  @override
  void didUpdateWidget(_CachedImageWithCallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset loaded state if cacheKey or URL changed
    if (oldWidget.cacheKey != widget.cacheKey || oldWidget.imageUrl != widget.imageUrl) {
      _hasLoaded = false;
      _imageStream?.removeListener(_imageListener!);
      _setupImageListener();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      cacheKey: widget.cacheKey,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => widget.placeholder,
      errorWidget: (context, url, error) => widget.errorWidget,
      fadeInDuration: widget.fadeInDuration,
      fadeOutDuration: widget.fadeOutDuration,
    );
  }
}
