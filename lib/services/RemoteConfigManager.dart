import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigManager {
  RemoteConfig _remoteConfig;

  Future<RemoteConfig> getInstance() async {
    if (_remoteConfig == null) {
      _remoteConfig = await RemoteConfig.instance;
    }
    
    _remoteConfig.fetch(expiration: const Duration(seconds: 0));
    _remoteConfig.activateFetched();
    return _remoteConfig;
  }
}