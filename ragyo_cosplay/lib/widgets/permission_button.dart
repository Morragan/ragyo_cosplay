import "package:flutter/material.dart";

class PermissionButton extends StatelessWidget {
  const PermissionButton({
    super.key,
    required this.text,
    required this.completed,
    required this.onPressed,
  });

  final String text;
  final bool completed;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: OutlinedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 20),
            Icon(completed ? Icons.check : Icons.pending_outlined),
            const SizedBox(width: 20),
            Text(
              text,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
