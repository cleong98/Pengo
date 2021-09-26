import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pengo/config/color.dart';
import 'package:pengo/const/space_const.dart';
import 'package:pengo/helpers/theme/custom_font.dart';
import 'package:pengo/helpers/theme/theme_helper.dart';
import 'package:pengo/models/booking_item_model.dart';
import 'package:pengo/ui/penger/booking/booking_result.dart';
import 'package:pengo/ui/widgets/button/custom_button.dart';
import 'package:pengo/ui/widgets/layout/sliver_appbar.dart';
import 'package:pengo/ui/widgets/layout/sliver_body.dart';
import 'package:pengo/ui/widgets/list/custom_list_item.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class BookingView extends StatefulWidget {
  const BookingView({Key? key, required this.bookingItem}) : super(key: key);

  final BookingItem bookingItem;

  @override
  _BookingViewState createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView> {
  late List<String> timeslots;
  bool _isDateModalOpened = false;
  bool _isTimeModalOpened = false;
  bool _isPayModalOpened = false;

  late String _date = "";
  late String _time = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        CustomSliverAppBar(
          toolbarHeight: mediaQuery(context).size.height * 0.15,
          title: CustomListItem(
            width: mediaQuery(context).size.width / 1.6,
            leading: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Image.network(
                widget.bookingItem.poster,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: greyBgColor,
                  );
                },
              ),
            ),
            // leading: Container(
            //   decoration: const BoxDecoration(
            //     // color: Colors.grey,
            //     borderRadius: BorderRadius.all(
            //       Radius.circular(8),
            //     ),
            //   ),
            //   child: ,
            // ),
            content: <Widget>[
              Text(
                widget.bookingItem.title,
                style: TextStyle(
                  fontSize: textTheme(context).subtitle1!.fontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.bookingItem.geolocation?.name ??
                    widget.bookingItem.location.toString(),
                style: textTheme(context).subtitle2,
              ),
              Text(
                "RM ${widget.bookingItem.price}",
                style: textTheme(context).caption,
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                color: primaryColor,
                minHeight: 6,
                backgroundColor: greyBgColor,
                value: 0.2,
                semanticsLabel: "Booking flow progress",
              ),
            ),
          ),
        ),
        CustomSliverBody(content: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListTile(
                  onTap: () => _onDateTapped(context),
                  contentPadding: EdgeInsets.all(18),
                  title: Text(
                    "1. Pick a date",
                    style: textTheme(context).headline5,
                  ),
                  subtitle: Text(
                    _date.isEmpty ? "When you want to go?" : _date,
                    style: PengoStyle.text(context),
                  ),
                  trailing: Icon(_isDateModalOpened
                      ? Icons.keyboard_arrow_down_outlined
                      : Icons.keyboard_arrow_up_outlined),
                ),
                const Divider(),
                ListTile(
                  onTap: () => _onTimeTapped(context),
                  contentPadding: const EdgeInsets.all(18),
                  title: Text(
                    "2. Pick a time",
                    style: textTheme(context).headline5,
                  ),
                  subtitle: Text(
                    "Choose a time",
                    style: PengoStyle.text(context),
                  ),
                  trailing: Icon(_isTimeModalOpened
                      ? Icons.keyboard_arrow_down_outlined
                      : Icons.keyboard_arrow_up_outlined),
                ),
                const Divider(),
                ListTile(
                  onTap: () => _onPayTapped(context),
                  contentPadding: const EdgeInsets.all(18),
                  title: Text(
                    "3. Pay",
                    style: textTheme(context).headline5,
                  ),
                  subtitle: Text(
                    "Waiting for payment",
                    style: PengoStyle.text(context),
                  ),
                  trailing: Icon(_isPayModalOpened
                      ? Icons.keyboard_arrow_down_outlined
                      : Icons.keyboard_arrow_up_outlined),
                ),
              ],
            ),
          ),
        ])
      ],
    ));
  }

  Future<dynamic> _onDateTapped(BuildContext context) {
    setState(() {
      _isDateModalOpened = true;
    });
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Date",
                style: textTheme(context).headline6,
              ),
              const SizedBox(
                height: SECTION_GAP_HEIGHT,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SfDateRangePicker(
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                    final String formattedDate = DateFormat('dd/MM/yyyy')
                        .format(DateTime.parse(args.value.toString()));
                    setState(() {
                      _date = formattedDate;
                    });
                  },
                  selectionColor: textColor,
                  rangeSelectionColor: textColor,
                  todayHighlightColor: textColor,
                  minDate: DateTime.now(),
                  headerStyle: DateRangePickerHeaderStyle(
                    textStyle: TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.normal,
                        color: textColor),
                  ),
                  monthViewSettings: DateRangePickerMonthViewSettings(
                    viewHeaderStyle: DateRangePickerViewHeaderStyle(
                      textStyle: TextStyle(color: textColor),
                    ),
                  ),
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    todayTextStyle: TextStyle(color: textColor),
                    weekendTextStyle: TextStyle(color: textColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isDateModalOpened = true;
      });
    });
  }

  Future<dynamic> _onTimeTapped(BuildContext context) {
    setState(() {
      _isTimeModalOpened = true;
    });
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          height: mediaQuery(context).size.height * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Available time",
                style: PengoStyle.header(context),
              ),
              const SizedBox(
                height: SECTION_GAP_HEIGHT,
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: timeslots.length,
                  itemBuilder: (context, index) {
                    return Material(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0),
                        tileColor: whiteColor,
                        title: Text(
                          timeslots[index],
                          style: PengoStyle.title2(context),
                        ),
                        trailing: Chip(
                          backgroundColor: primaryColor,
                          label: GestureDetector(
                            onTap: () {
                              debugPrint("Book");
                            },
                            child: Text(
                              "Book",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      setState(() {
        _isTimeModalOpened = false;
      });
    });
  }

  Future<dynamic> _onPayTapped(BuildContext context) {
    setState(() {
      _isPayModalOpened = true;
    });
    return showCupertinoModalBottomSheet(
      context: context,
      builder: (BuildContext context) => SingleChildScrollView(
        controller: ModalScrollController.of(context),
        child: Container(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Pay with",
                style: textTheme(context).headline6,
              ),
              const SizedBox(
                height: SECTION_GAP_HEIGHT,
              ),
              CustomButton(
                text: Text("Pay"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Future.delayed(Duration(seconds: 1));
                  redirectToResultPage();
                },
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() async {
      setState(() {
        _isPayModalOpened = false;
      });
    });
  }

  Future<void> load() async {
    Future.delayed(const Duration(seconds: 3));
    setState(() {
      timeslots = <String>[
        "10:00 PM - 11:00 PM",
        "11:00 PM - 12:00 PM",
        "12:00 PM - 13:00 PM",
        "12:00 PM - 13:00 PM",
        "12:00 PM - 13:00 PM",
        "12:00 PM - 13:00 PM",
        "12:00 PM - 13:00 PM",
        "12:00 PM - 13:00 PM",
      ];
    });
  }

  void redirectToResultPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => BookingResultPage(
          bookingItem: widget.bookingItem,
        ),
      ),
      (_) => false,
    );
  }
}
