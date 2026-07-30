/// Bottom sheet (docs/41 §11.5). The default mobile surface for choices, filters,
/// and short forms. Rounded top corners, drag handle, safe-area aware, rises
/// above the keyboard.
library;

import 'package:flutter/material.dart';

abstract final class QBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: builder(sheetContext),
        );
      },
    );
  }
}
