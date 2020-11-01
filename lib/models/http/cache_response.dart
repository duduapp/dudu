

class CacheResponse {
  dynamic content;
  CacheResponseType type;

  CacheResponse(this.content, this.type);
}

enum CacheResponseType {
  net, // from internet
  cache, // from cache
  stale, // expire and network is not available
}