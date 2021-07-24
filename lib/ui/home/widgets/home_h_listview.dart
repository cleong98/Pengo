import 'package:flutter/material.dart';
import 'package:pengo/ui/widgets/stacks/h_stack.dart';

class HomeHListView extends StatefulWidget {
  const HomeHListView({
    Key? key,
    required this.textTheme,
    required this.children,
    required this.title,
  }) : super(key: key);

  final TextTheme textTheme;
  final String title;
  final List<Widget> children;

  @override
  _HomeHListViewState createState() => _HomeHListViewState();
}

class _HomeHListViewState extends State<HomeHListView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(widget.title, style: widget.textTheme.headline6),
            const Spacer(),
            const Text(
              "See all",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.22,
            child: HStack(
              children: widget.children,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(),
        )
      ],
    );
  }
}
