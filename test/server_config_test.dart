import 'package:test/test.dart';
import 'package:phantom3d/config/server_config.dart';

void main() {
  group('Test all server config functions', () {
    test('Local Host functions', () {
      final socketRenderStartCall = getUrltoStartRenderInstance(true);
      final getObjectListCall = getUrltoGetObjectList(true);
      final uploadModelCall = getUrltoUploadModel(true);
      final socketFollowCall = getUrltoFollowRenderInstance(true, '123-456');
      final getClientListCall = getUrltoGetClientList(true);

      expect(socketRenderStartCall, equals('ws://localhost:8000/webg3n'));
      expect(getObjectListCall, equals('http://localhost:8000/objects'));
      expect(uploadModelCall, equals('http://localhost:8000/loadModel'));
      expect(socketFollowCall,
          equals('ws://localhost:8000/rtcwebg3n?uuid=123-456&'));
      expect(getClientListCall, equals('http://localhost:8000/allclients'));
    });

    test('Remote Host Functions', () {
      final socketRenderStartCall = getUrltoStartRenderInstance(false);
      final getObjectListCall = getUrltoGetObjectList(false);
      final uploadModelCall = getUrltoUploadModel(false);
      final socketFollowCall = getUrltoFollowRenderInstance(false, '123-456');
      final getClientListCall = getUrltoGetClientList(false);

      expect(socketRenderStartCall, equals('ws://35.247.177.137:8000/webg3n'));
      expect(getObjectListCall, equals('http://35.247.177.137:8000/objects'));
      expect(uploadModelCall, equals('http://35.247.177.137:8000/loadModel'));
      expect(socketFollowCall,
          equals('ws://35.247.177.137:8000/rtcwebg3n?uuid=123-456&'));
      expect(
          getClientListCall, equals('http://35.247.177.137:8000/allclients'));
    });
  });
}
