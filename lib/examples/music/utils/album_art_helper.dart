

import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../service/lastfm_service.dart';

/// 根据「专辑艺人 + 专辑名」获取专辑封面的本地缓存路径。
///
/// 调用流程：
/// 1. 计算缓存目录和缓存文件名（基于 albumArtist + album）
/// 2. 如果本地已存在缓存图片，直接返回该文件路径；
/// 3. 如果不存在：
///    - 调用 Last.fm 服务获取专辑封面 URL；
///    - 尝试解析为更高分辨率的图片 URL（例如 300x300 -> 600x600）；
///    - 优先下载高分辨率版本，如果失败则回退到原始 URL；
///    - 下载成功后写入缓存文件，并返回文件路径；
/// 4. 任意环节失败则返回 null（调用方据此决定用占位图等）。
Future<String?> getAlbumArtPath(String albumArtist, String album) async {
  try {
    // 1. 获取系统临时目录，并在其中创建一个专门用于专辑封面的子目录
    final Directory tempDir = await getTemporaryDirectory();
    final Directory cacheDir =
    Directory(path.join(tempDir.path, 'album_art_cache'));

    // 确保目录存在（recursive: true 防止上层目录不存在）
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    // 2. 基于「艺人 + 专辑」生成一个相对安全的文件名
    //    专辑名里可能包含 / \ : * ? " < > | 这些在部分文件系统是非法的，所以需要做简单过滤。
    final String safeFileName =
    _sanitizeFileName('$albumArtist - $album', suffix: '.jpg');

    final String filePath = path.join(cacheDir.path, safeFileName);
    final File file = File(filePath);

    // 3. 如果缓存文件已存在，直接返回缓存路径 —— 避免重复下载
    if (await file.exists()) {
      // debugPrint("Album art cache found | $albumArtist | $album");
      return filePath;
    }

    // 4. 本地无缓存，向 Last.fm 请求专辑封面 URL
    final String? albumArtUrl =
    await LastfmService().getLargestAlbumArt(albumArtist, album);

    // 若远端也没有专辑封面，直接返回 null，交给调用方处理（比如显示占位图）
    if (albumArtUrl == null || albumArtUrl.isEmpty) {
      return null;
    }

    // 5. 尝试构造更高分辨率的图片 URL，如 300x300 -> 600x600
    final String highResUrl = _getHigherResolutionUrl(albumArtUrl);

    // 6. 下载图片并写入缓存
    try {
      // 优先尝试高分辨率地址
      http.Response response = await http.get(Uri.parse(highResUrl));

      // 如果高分辨率返回 404（不存在），或者其它非 200 状态，则尝试原始 URL
      if (response.statusCode != 200 && highResUrl != albumArtUrl) {
        response = await http.get(Uri.parse(albumArtUrl));
      }

      // 只有真正拿到 200 的响应才写入文件
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      }

      // 其它状态码（比如 403/500 等），视为下载失败
      return null;
    } catch (e) {
      // 网络异常 / 解析错误 / 写文件异常 等，都统一吞掉并返回 null
      // debugPrint('Error downloading album art: $e');
      return null;
    }
  } catch (e) {
    // 一般是文件系统或路径相关错误：获取临时目录失败、创建目录失败等等
    // debugPrint('Error in getAlbumArtPath: $e');
    return null;
  }
}

/// 将 URL 中的 300x300 替换为 600x600，以获取更高分辨率的封面。
///
/// - 如果 URL 中包含 "300x300"，则将其全部替换为 "600x600"；
/// - 如果不包含，则直接返回原始 URL；
///
/// 注意：
/// - 此逻辑依赖于 Last.fm 的图片 URL 命名规则；
/// - 如果将来 Last.fm 改了 URL 模式，这个函数也要对应调整。
String _getHigherResolutionUrl(String originalUrl) {
  if (originalUrl.contains('300x300')) {
    return originalUrl.replaceAll('300x300', '600x600');
  }
  return originalUrl;
}

/// 对文件名做简单的“安全处理”，避免包含可能导致文件系统报错的字符。
///
/// - [rawName] 原始文件名（不含路径）
/// - [suffix] 文件后缀名（如 ".jpg"）
///
/// 处理规则：
/// - 只允许：字母、数字、空格、下划线、连字符、点号；
/// - 其它字符统一替换为下划线 `_`；
/// - 最终文件名 = 过滤后的 baseName + suffix；
String _sanitizeFileName(String rawName, {String suffix = ''}) {
  // 去掉前后空白并限制长度（防止特别长的专辑名导致文件名过长）
  final trimmed = rawName.trim();

  // 只保留 [a-zA-Z0-9 _.-]，其余全部替换为 '_'
  final sanitized = trimmed.replaceAll(RegExp(r'[^a-zA-Z0-9 _\.-]'), '_');

  // 可以按需裁剪长度（避免极端情况超过文件系统限制）
  const maxLength = 100; // 够用且安全
  final shortened =
  sanitized.length > maxLength ? sanitized.substring(0, maxLength) : sanitized;

  return '$shortened$suffix';
}
