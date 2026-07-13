// ************************************************************
// * WT Flutter FrameWork
// * @version : 1.3
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************

import 'package:flutter/material.dart';

/// Base class for a screen's view: a small template-style holder that carries
/// assigned variables and builds a widget tree, with ready-made
/// [scaffold]/[loading]/[error]/[empty] helpers.
abstract class WtView {

  final Map<String, dynamic> _vars = {};

  /// Assigns a template variable [value] under [key] (read back with [get]).
  void assign(String key, dynamic value) {
    _vars[key] = value;
  }

  /// Reads an assigned variable as [T], or null if absent/mistyped.
  T? get<T>(String key) => _vars[key] as T?;

  /// The assigned `title` variable (empty string if unset).
  String get title => get<String>('title') ?? '';

  /// Builds this view's widget tree. Implement in your subclass.
  Widget build(BuildContext context);

  /// A standard [Scaffold] with an optional app bar titled by [title].
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

  /// A centered progress indicator for loading states.
  Widget loading() {
    return const Center(child: CircularProgressIndicator());
  }

  /// A centered error panel showing [message].
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

  /// A centered empty-state panel with an optional [message].
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

/// A [WtView] that resolves a [Future] and renders loading/error/empty/data
/// states automatically via a `FutureBuilder`. Implement [loadData] and
/// [buildData].
abstract class WtAsyncView<T> extends WtView {
  /// Loads the data this view depends on.
  Future<T> loadData();

  /// Builds the view once [loadData] resolves with [data].
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
