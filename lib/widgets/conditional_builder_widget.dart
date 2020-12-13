import 'package:flutter/material.dart';

class ConditionalBuilder extends StatelessWidget {
  const ConditionalBuilder(
      {Key key,
      this.conditionalStream,
      this.child,
      this.initialData = false,
      this.transformBool = false})
      : super(key: key);

  @required
  final Stream<bool> conditionalStream;

  final bool initialData;

  final bool transformBool;

  @required
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      key: key,
      initialData: initialData,
      stream: conditionalStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final _shouldBuildChild =
              transformBool ? !snapshot.data : snapshot.data;
          if (_shouldBuildChild) {
            return child;
          }

          return Container();
        } else if (snapshot.hasError) {
          return Container(
            color: Colors.red,
            child: Text(
              snapshot.error.toString(),
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return Container();
      },
    );
  }
}
