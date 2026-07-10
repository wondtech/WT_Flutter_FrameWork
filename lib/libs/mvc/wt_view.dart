// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.1
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';

abstract class WtView {

  final Map<String, dynamic> _vars = {};

  void assign(String key, dynamic value) {
    _vars[key] = value;
  }

  T? get<T>(String key) => _vars[key] as T?;

  String get title => get<String>('title') ?? '';

  Widget build(BuildContext context);

  Widget scaffold({
    required BuildContext context,
    required Widget body,
    Widget? floatingActionButton,
    List<Widget>? actions,
    Widget? drawer,
    bool showAppBar = true,
  }) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              actions: actions,
              elevation: 0,
            )
          : null,
      drawer: drawer,
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }

  Widget loading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget error(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget empty({String message = 'No data found'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

abstract class WtAsyncView<T> extends WtView {
  Future<T> loadData();

  Widget buildData(BuildContext context, T data);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: loadData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loading();
        } else if (snapshot.hasError) {
          return error(snapshot.error.toString());
        } else if (!snapshot.hasData) {
          return empty();
        }
        return buildData(context, snapshot.data as T);
      },
    );
  }
}
