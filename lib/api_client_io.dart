import 'dart:convert';
import 'dart:io';

Future<dynamic> apiGet(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body);
  } finally {
    client.close();
  }
}

Future<dynamic> apiPost(String url, Map<String, dynamic> data) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.add(utf8.encode(jsonEncode(data)));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body);
  } finally {
    client.close();
  }
}

Future<dynamic> apiPut(String url, Map<String, dynamic> data) async {
  final client = HttpClient();
  try {
    final request = await client.putUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    request.add(utf8.encode(jsonEncode(data)));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body);
  } finally {
    client.close();
  }
}

Future<dynamic> apiDelete(String url) async {
  final client = HttpClient();
  try {
    final request = await client.deleteUrl(Uri.parse(url));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return body.isNotEmpty ? jsonDecode(body) : {};
  } finally {
    client.close();
  }
}
