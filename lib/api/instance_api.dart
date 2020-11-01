class InstanceApi {
  static String getUrl(String instance) {
    if (!instance.startsWith('https://'))
      instance = 'https://'+instance;
    return instance + '/api/v1/instance';
  }
}