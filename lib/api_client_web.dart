import 'dart:convert';
import 'dart:js_interop';

@JS('fetch')
external JSPromise<JSResponse> _fetch(JSString url, [JSRequestInit? init]);

extension type JSResponse._(JSObject _) implements JSObject {
  external JSPromise<JSString> text();
}

extension type JSRequestInit._(JSObject _) implements JSObject {
  external factory JSRequestInit({
    JSString? method,
    JSString? body,
  });
}

Future<dynamic> apiGet(String url) async {
  final resp = await _fetch(url.toJS).toDart;
  final text = (await resp.text().toDart).toDart;
  return jsonDecode(text);
}

Future<dynamic> apiPost(String url, Map<String, dynamic> data) async {
  final resp = await _fetch(
    url.toJS,
    JSRequestInit(
      method: 'POST'.toJS,
      body: jsonEncode(data).toJS,
    ),
  ).toDart;
  final text = (await resp.text().toDart).toDart;
  return jsonDecode(text);
}

Future<dynamic> apiPut(String url, Map<String, dynamic> data) async {
  final resp = await _fetch(
    url.toJS,
    JSRequestInit(
      method: 'PUT'.toJS,
      body: jsonEncode(data).toJS,
    ),
  ).toDart;
  final text = (await resp.text().toDart).toDart;
  return jsonDecode(text);
}

Future<dynamic> apiDelete(String url) async {
  final resp = await _fetch(
    url.toJS,
    JSRequestInit(
      method: 'DELETE'.toJS,
    ),
  ).toDart;
  final text = (await resp.text().toDart).toDart;
  return text.isNotEmpty ? jsonDecode(text) : {};
}
