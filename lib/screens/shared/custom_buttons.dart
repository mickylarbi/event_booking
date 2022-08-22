import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final void Function()? _onPressed;
  final String labelText;
  const CustomElevatedButton(
      {Key? key, required void Function()? onPressed, required this.labelText})
      : _onPressed = onPressed,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(labelText),
      ),
    );
  }
}

class SkipTextButton extends StatelessWidget {
  const SkipTextButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Skip'),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String labelText;
  final void Function()? onPressed;
  const CustomTextButton(
      {Key? key, required this.labelText, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        labelText,
        style: const TextStyle(color: Colors.blue),
      ),
    );
  }
}

class GoogleButton extends StatelessWidget {
  const GoogleButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: SizedBox(
        child: TextButton.icon(
          onPressed: () {},
          icon: Image.asset(
            'assets/images/google_icon.png',
            height: 24,
          ),
          label: const Text('Continue with Google'),
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomFlatButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget? child;
  final Color? backgroundColor;
  final AlignmentGeometry alignment;
  const CustomFlatButton({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.blue,
    required this.onPressed,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      textStyle: TextStyle(
        color: onPressed != null ? Colors.white : Colors.grey,
        letterSpacing: .5,
      ),
      borderRadius: BorderRadius.circular(14),
      color: onPressed != null ? backgroundColor : Colors.grey[200],
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: IconTheme(
          data: IconThemeData(
              color: onPressed != null ? Colors.white : Colors.grey),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24),
            child: Align(alignment: alignment, child: child),
          ),
        ),
      ),
    );
  }
}
