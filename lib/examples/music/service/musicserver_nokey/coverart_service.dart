import 'api_client.dart';

/// ======================
/// 封面图服务
/// ======================

class CoverArtArchiveService {
  static const String _baseHost = 'coverartarchive.org';
  final ApiClient _client;

  CoverArtArchiveService(ApiClient client) : _client = client;

  /// 获取某个 release 的封面 JSON 信息
  /// 文档：https://coverartarchive.org/
  Future<CoverArtReleaseImages> getReleaseImages(String releaseMbid) async {
    final uri = Uri.https(
      _baseHost,
      '/release/$releaseMbid',
    );

    final json = await _client.getJson(uri);

    return CoverArtReleaseImages.fromJson(json);
  }

  /// 直接返回 front 封面的 URL（如果有）
  /// size:
  ///   - null 表示原图
  ///   - '250', '500', '1200' 等（由官方支持）
  String buildFrontCoverUrl(
      String releaseMbid, {
        String? size,
      }) {
    // e.g. https://coverartarchive.org/release/{mbid}/front-250
    final path = size == null
        ? '/release/$releaseMbid/front'
        : '/release/$releaseMbid/front-$size';

    return Uri.https(_baseHost, path).toString();
  }

  /// 通用构造某张图片的 URL
  String buildImageUrl(
      String releaseMbid, {
        required String type, // front / back / 其它
        String? size,
      }) {
    final path = size == null
        ? '/release/$releaseMbid/$type'
        : '/release/$releaseMbid/$type-$size';
    return Uri.https(_baseHost, path).toString();
  }
}

/// ===== 模型 =====

class CoverArtReleaseImages {
  final String release;
  final List<CoverArtImage> images;

  CoverArtReleaseImages({
    required this.release,
    required this.images,
  });

  factory CoverArtReleaseImages.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List<dynamic>? ?? [];
    return CoverArtReleaseImages(
      release: json['release'] as String? ?? '',
      images: imagesJson
          .map((e) => CoverArtImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 获取第一个 front 图片（如果有）
  CoverArtImage? get primaryFrontImage {
    return images.firstWhere(
          (img) => img.types.contains('Front'),
      orElse: () => images.isNotEmpty ? images.first : null as CoverArtImage,
    );
  }
}

class CoverArtImage {
  final String imageUrl;
  final bool front;
  final bool back;
  final List<String> types;
  final Map<String, String> thumbnails;

  CoverArtImage({
    required this.imageUrl,
    required this.front,
    required this.back,
    required this.types,
    required this.thumbnails,
  });

  factory CoverArtImage.fromJson(Map<String, dynamic> json) {
    final thumbs = json['thumbnails'] as Map<String, dynamic>? ?? {};

    return CoverArtImage(
      imageUrl: json['image'] as String? ?? '',
      front: json['front'] as bool? ?? false,
      back: json['back'] as bool? ?? false,
      types: (json['types'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      thumbnails: thumbs.map((key, value) => MapEntry(
        key,
        value.toString(),
      )),
    );
  }

  /// 获取某个尺寸的缩略图，比如 "250", "500", "1200"
  String? thumbnailOf(String sizeKey) => thumbnails[sizeKey];
}
