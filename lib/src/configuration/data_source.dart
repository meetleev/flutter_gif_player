enum GifPlayerDataSourceType {
  /// The gif was included in the app's asset files.
  asset,

  /// The gif was downloaded from the internet.
  network,

  /// The gif was loaded off of the local filesystem.
  file,

  /// The gif was loaded off of the memory.
  // memory,
}

class GifPlayerDataSource {
  /// Type of source of gif
  final GifPlayerDataSourceType type;

  /// Url of the gif
  final String url;

  /// Custom headers for player
  final Map<String, String> headers;

  /// Only set for [asset] gif. The package that the asset was loaded from.
  final String? package;

  GifPlayerDataSource(
    this.type,
    this.url, {
    this.package,
    this.headers = const {},
  });

  GifPlayerDataSource.network(this.url, {this.headers = const {}})
    : type = GifPlayerDataSourceType.network,
      package = null;

  GifPlayerDataSource.asset(this.url, {this.package})
    : type = GifPlayerDataSourceType.asset,
      headers = const {};

  GifPlayerDataSource.file(this.url)
    : type = GifPlayerDataSourceType.file,
      package = null,
      headers = const {};
}
