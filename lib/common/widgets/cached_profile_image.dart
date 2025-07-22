import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/image/image_cache_service.dart';

class CachedProfileImage extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final String? placeholderAsset;
  final Color? backgroundColor;
  final Color? placeholderColor;
  final BoxFit fit;

  const CachedProfileImage({
    super.key,
    this.imageUrl,
    required this.radius,
    this.placeholderAsset,
    this.backgroundColor,
    this.placeholderColor,
    this.fit = BoxFit.cover,
  });

  @override
  State<CachedProfileImage> createState() => _CachedProfileImageState();
}

class _CachedProfileImageState extends State<CachedProfileImage> {
  File? _cachedImageFile;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedProfileImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      setState(() {
        _cachedImageFile = null;
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final cachedFile = await ImageCacheService().getCachedImage(widget.imageUrl!);
      if (mounted) {
        setState(() {
          _cachedImageFile = cachedFile;
          _isLoading = false;
          _hasError = cachedFile == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cachedImageFile = null;
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? colorScheme.onSecondary,
      child: _isLoading
          ? SizedBox(
              width: widget.radius * 0.5,
              height: widget.radius * 0.5,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.placeholderColor ?? colorScheme.onSecondaryContainer,
                ),
              ),
            )
          : _cachedImageFile != null
              ? ClipOval(
                  child: Image.file(
                    _cachedImageFile!,
                    fit: widget.fit,
                    width: widget.radius * 2,
                    height: widget.radius * 2,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(colorScheme);
                    },
                  ),
                )
              : _buildPlaceholder(colorScheme),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    if (widget.placeholderAsset != null) {
      return SvgPicture.asset(
        widget.placeholderAsset!,
        width: widget.radius * 1.2,
        height: widget.radius * 1.2,
        colorFilter: ColorFilter.mode(
          widget.placeholderColor ?? colorScheme.onSecondaryContainer,
          BlendMode.srcIn,
        ),
      );
    }
    
    return Icon(
      Icons.person,
      size: widget.radius * 1.2,
      color: widget.placeholderColor ?? colorScheme.onSecondaryContainer,
    );
  }
} 