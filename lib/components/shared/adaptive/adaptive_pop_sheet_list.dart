import 'package:flutter/material.dart';
import 'package:spotube/collections/spotube_icons.dart';
import 'package:spotube/extensions/constrains.dart';

class PopSheetEntry<T> {
  final T? value;
  final VoidCallback? onTap;
  final Widget child;
  final bool enabled;

  const PopSheetEntry({
    required this.child,
    this.value,
    this.onTap,
    this.enabled = true,
  });
}

/// An adaptive widget that shows a [PopupMenuButton] when screen size is above
/// or equal to 640px
/// In smaller screen, a [IconButton] with a [showModalBottomSheet] is shown
class AdaptivePopSheetList<T> extends StatelessWidget {
  final List<PopSheetEntry<T>> children;
  final Widget? icon;
  final Widget? child;
  final bool useRootNavigator;

  final List<Widget>? headings;
  final String? tooltip;
  final ValueChanged<T>? onSelected;

  final BorderRadius borderRadius;

  const AdaptivePopSheetList({
    super.key,
    required this.children,
    this.icon,
    this.child,
    this.useRootNavigator = true,
    this.headings,
    this.onSelected,
    this.borderRadius = const BorderRadius.all(Radius.circular(999)),
    this.tooltip,
  }) : assert(
          !(icon != null && child != null),
          'Either icon or child must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    if (mediaQuery.mdAndUp) {
      return PopupMenuButton(
        icon: icon,
        tooltip: tooltip,
        child: child == null ? null : IgnorePointer(child: child),
        itemBuilder: (context) => children
            .map(
              (item) => PopupMenuItem(
                padding: EdgeInsets.zero,
                child: _AdaptivePopSheetListItem(
                  item: item,
                  onSelected: onSelected,
                ),
              ),
            )
            .toList(),
      );
    }

    void showSheet() {
      showModalBottomSheet(
        context: context,
        useRootNavigator: useRootNavigator,
        isScrollControlled: true,
        showDragHandle: true,
        constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height * 0.6,
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0).copyWith(top: 0),
            child: DefaultTextStyle(
              style: theme.textTheme.titleMedium!,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (headings != null) ...[
                      ...headings!,
                      const SizedBox(height: 8),
                      Divider(
                        color: theme.colorScheme.primary,
                        thickness: 0.3,
                        endIndent: 16,
                        indent: 16,
                      ),
                    ],
                    ...children.map(
                      (item) => _AdaptivePopSheetListItem(
                        item: item,
                        onSelected: onSelected,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    if (child != null) {
      return Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          onTap: showSheet,
          borderRadius: borderRadius,
          child: IgnorePointer(child: child),
        ),
      );
    }

    return IconButton(
      icon: icon ?? const Icon(SpotubeIcons.moreVertical),
      tooltip: tooltip,
      style: theme.iconButtonTheme.style?.copyWith(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: borderRadius,
          ),
        ),
      ),
      onPressed: showSheet,
    );
  }
}

class _AdaptivePopSheetListItem<T> extends StatelessWidget {
  final PopSheetEntry<T> item;
  final ValueChanged<T>? onSelected;
  const _AdaptivePopSheetListItem({
    super.key,
    required this.item,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: !item.enabled
          ? null
          : () {
              item.onTap?.call();
              Navigator.pop(context);
              if (item.value != null) {
                onSelected?.call(item.value as T);
              }
            },
      child: DefaultTextStyle(
        style: TextStyle(
          color: item.enabled
              ? theme.textTheme.bodyMedium!.color
              : theme.textTheme.bodyMedium!.color!.withOpacity(0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: item.child,
        ),
      ),
    );
  }
}