import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pengo/bloc/records/booking_record_repo.dart';
import 'package:pengo/config/color.dart';
import 'package:pengo/const/icon_const.dart';
import 'package:pengo/const/space_const.dart';
import 'package:pengo/helpers/geo/geo_helper.dart';
import 'package:pengo/helpers/theme/custom_font.dart';
import 'package:pengo/models/booking_item_model.dart';
import 'package:pengo/models/booking_record_model.dart';
import 'package:pengo/models/providers/auth_model.dart';
import 'package:pengo/ui/video/video_meet.dart';
import 'package:pengo/ui/widgets/api/loading.dart';
import 'package:pengo/ui/widgets/layout/sliver_appbar.dart';
import 'package:pengo/ui/widgets/layout/sliver_body.dart';
import 'package:pengo/ui/widgets/mapbox/map_view.dart';
import 'package:provider/src/provider.dart';

class BookingRecordDetailPage extends StatefulWidget {
  const BookingRecordDetailPage({Key? key, required this.id}) : super(key: key);

  final int id;

  @override
  _BookingRecordDetailPageState createState() =>
      _BookingRecordDetailPageState();
}

class _BookingRecordDetailPageState extends State<BookingRecordDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: Container(),
            actions: <Widget>[
              FutureBuilder(
                  future: RecordRepo().fetchRecord(
                    recordId: widget.id,
                    showStats: true,
                  ),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<BookingRecord> snapshot,
                  ) {
                    if (snapshot.hasData) {
                      final BookingRecord _currRecord = snapshot.data!;
                      final DateTime now = DateTime.now();

                      final Duration gap =
                          _currRecord.formattedBookDateTime!.difference(now);

                      return Row(
                        children: <Widget>[
                          if (_currRecord.item?.isVirtual == true &&
                              context.watch<AuthModel>().user != null)
                            IconButton(
                              onPressed: () {
                                Navigator.of(context, rootNavigator: true).push(
                                    CupertinoPageRoute(
                                        builder: (BuildContext context) {
                                  return VideoMeetPage(
                                    user: context.watch<AuthModel>().user!,
                                    subject: _currRecord.item!.title,
                                    roomName: DateFormat("yyyy-MM-dd HH:mm")
                                        .format(
                                            _currRecord.formattedBookDateTime!),
                                  );
                                }));
                              },
                              icon: Icon(
                                Icons.video_call,
                              ),
                            ),
                          if (_currRecord.item?.geolocation != null)
                            IconButton(
                              onPressed: () async {
                                double lat = double.tryParse(
                                      Provider.of<GeoHelper>(context,
                                              listen: false)
                                          .currentPos()!['latitude']
                                          .toString(),
                                    ) ??
                                    0;

                                double lng = double.tryParse(
                                      Provider.of<GeoHelper>(context,
                                              listen: false)
                                          .currentPos()!['longitude']
                                          .toString(),
                                    ) ??
                                    0;

                                try {
                                  final posFromDevice =
                                      await GeoHelper().getDeviceLocation();
                                  lat = posFromDevice.latitude;
                                  lng = posFromDevice.longitude;

                                  debugPrint("use device location $lat $lng");
                                } catch (e) {
                                  debugPrint(
                                      "use user saved location $lat $lng");
                                }

                                if (lat == 0 || lng == 0) return;

                                Navigator.of(context, rootNavigator: true).push(
                                  CupertinoPageRoute(
                                      builder: (BuildContext context) {
                                    return MapView(
                                      destinationName: _currRecord.item!.title,
                                      bookingLat: _currRecord
                                          .item!.geolocation!.latitude,
                                      bookingLng: _currRecord
                                          .item!.geolocation!.longitude,
                                      initialLat: lat,
                                      initialLng: lng,
                                    );
                                  }),
                                );
                              },
                              icon: Icon(
                                Icons.map,
                                color: primaryColor,
                              ),
                            ),
                        ],
                      );
                    }
                    return const SizedBox();
                  })
            ],
          ),
          CustomSliverBody(
            content: <Widget>[
              FutureBuilder<BookingRecord>(
                future: RecordRepo().fetchRecord(
                  recordId: widget.id,
                  showStats: true,
                ),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<BookingRecord> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget();
                  }

                  if (snapshot.hasData) {
                    final BookingRecord record = snapshot.data!;
                    final BookingItem item = record.item!;

                    final DateTime? startDate = record.bookDate?.startDate;
                    final DateTime? endDate = record.bookDate?.endDate;

                    String? fSd;
                    String? fSt;
                    if (startDate != null) {
                      fSd =
                          DateFormat("yyyy-MM-dd").format(startDate.toLocal());
                      fSt = record.bookTime;
                      // ?? DateFormat().add_jm().format(startDate());
                    }
                    String? fEd;
                    String? fEt;
                    if (endDate != null) {
                      fEd = DateFormat("yyyy-MM-dd").format(endDate.toLocal());
                      // fEt = DateFormat().add_jm().format(endDate());
                    }

                    String bookDateAndTime = fSd ?? "";

                    if (fEd != null) {
                      bookDateAndTime =
                          bookDateAndTime + " to " + fEd + "($fSt)";
                    }

                    return Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 185,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              item.poster,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            height: SECTION_GAP_HEIGHT * 2,
                          ),
                          Text(
                            item.title,
                            style: PengoStyle.navigationTitle(context),
                          ),
                          const SizedBox(
                            height: SECTION_GAP_HEIGHT,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            minLeadingWidth: 20,
                            leading: SvgPicture.asset(
                              CALENDAR_ICON_PATH,
                              width: 21,
                              color: secondaryTextColor,
                            ),
                            title: Text(
                              "Booking date",
                              style: PengoStyle.title2(context),
                            ),
                            subtitle: Text(
                              bookDateAndTime,
                              style: PengoStyle.smallerText(context).copyWith(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                          if (record.streetAddress != null)
                            const SizedBox(
                              height: SECTION_GAP_HEIGHT,
                            ),
                          if (record.streetAddress != null)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              minLeadingWidth: 20,
                              leading: SvgPicture.asset(
                                LOCATION_ICON_PATH,
                                width: 21,
                                color: secondaryTextColor,
                              ),
                              title: Text(
                                "Location",
                                style: PengoStyle.title2(context),
                              ),
                              subtitle: Text(
                                record.streetAddress ?? "",
                                style: PengoStyle.smallerText(context).copyWith(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: SECTION_GAP_HEIGHT,
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            minLeadingWidth: 20,
                            leading: SvgPicture.asset(
                              CALENDAR_ICON_PATH,
                              width: 21,
                              color: secondaryTextColor,
                            ),
                            title: Text(
                              "Other",
                              style: PengoStyle.title2(context),
                            ),
                            subtitle: Text(
                              "${record.aheadUserCount} people ahead of you",
                              style: PengoStyle.smallerText(context).copyWith(
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: SECTION_GAP_HEIGHT,
                          ),
                        ],
                      ),
                    );
                  }
                  return Container();
                },
              ),
            ],
          )
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: FutureBuilder<BookingRecord>(
          future: RecordRepo().fetchRecord(
            recordId: widget.id,
            showStats: true,
          ),
          builder: (
            BuildContext context,
            AsyncSnapshot<BookingRecord> snapshot,
          ) {
            if (snapshot.hasData) {
              final BookingRecord record = snapshot.data!;
              final DateTime now = DateTime.now();

              final Duration gap =
                  record.formattedBookDateTime!.difference(now);

              if (gap.isNegative) {
                return const SizedBox();
              }

              return Container(
                height: 100.0,
                width: double.maxFinite,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
                child: Row(children: <Widget>[
                  Text(
                    "You have",
                    style: PengoStyle.header(context).copyWith(
                      color: whiteColor,
                    ),
                  ),
                  const Spacer(),
                  if (gap.isNegative == false)
                    TweenAnimationBuilder<Duration>(
                      duration: gap,
                      tween: Tween<Duration>(
                        begin: gap,
                        end: Duration.zero,
                      ),
                      onEnd: () {
                        print('Timer ended');
                      },
                      builder: (
                        BuildContext context,
                        Duration value,
                        Widget? child,
                      ) {
                        final int days = value.inSeconds ~/ (24 * 60 * 60) % 24;
                        final int hours = value.inSeconds ~/ (60 * 60) % 24;
                        final int minutes = (value.inSeconds ~/ 60) % 60;
                        final int seconds = value.inSeconds % 60;

                        if (days < 0 &&
                            hours < 0 &&
                            minutes < 0 &&
                            seconds < 0) {
                          return Container();
                        }

                        return Row(
                          children: [
                            Countdown(
                              label: "days",
                              value: days.toString().padLeft(2, '0'),
                            ),
                            Countdown(
                              label: "hours",
                              value: hours.toString().padLeft(2, '0'),
                            ),
                            Countdown(
                              label: "min",
                              value: minutes.toString().padLeft(2, '0'),
                            ),
                            Countdown(
                              label: "sec",
                              value: seconds.toString().padLeft(2, '0'),
                            ),
                          ],
                        );
                      },
                    ),
                ]),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}

class Countdown extends StatelessWidget {
  const Countdown({
    Key? key,
    required this.label,
    required this.value,
    this.padding,
  }) : super(key: key);

  final String label;
  final String value;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                value.toString(),
                style: PengoStyle.navigationTitle(context).copyWith(
                  color: whiteColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              label,
              style: PengoStyle.title2(context).copyWith(
                color: whiteColor,
              ),
            ),
          ]),
    );
  }
}
