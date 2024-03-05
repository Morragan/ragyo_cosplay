import "package:flutter/material.dart";

class DrawerItem extends StatelessWidget {
  const DrawerItem({
    super.key,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.selected,
  });

  final void Function() onTap;
  final IconData icon;
  final String title;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
      visualDensity: const VisualDensity(vertical: 3),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
