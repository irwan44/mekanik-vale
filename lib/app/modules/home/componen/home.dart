import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mekanik/app/modules/home/componen/stats_grid.dart';
import 'package:mekanik/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../../componen/color.dart';
import '../../../componen/loading_cabang_shimmer.dart';
import '../../../componen/loading_search_shimmer.dart';
import '../../../data/data_endpoint/absenhistory.dart';
import '../../../data/data_endpoint/abseninfo.dart';
import '../../../data/data_endpoint/profile.dart';
import '../../../data/endpoint.dart';
import '../absen/listhistory/absensekarang.dart';
import '../absen/listhistory/indikator.dart';
import '../controllers/home_controller.dart';
import 'bar_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final controller = Get.put(HomeController());
  late RefreshController _refreshController; // the refresh controller
  String idkaryawan = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // this is our key to the scaffold widget

  @override
  void initState() {
    _refreshController = RefreshController(); // we have to use initState because this part of the app have to restart
    super.initState();
    _fetchidkaryawan();
  }

  void _fetchidkaryawan() async {
    try {
      final idkaryawan2 = await API.profileiD();
      setState(() {
        idkaryawan = idkaryawan2?.data?.id.toString() ?? '';
        print('$idkaryawan');
      });
    } catch (e) {
      print('Error fetching absen info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.checkForUpdate();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          InkWell(
            onTap: () {
              Get.toNamed(Routes.AbsenView);
            },
            child: FutureBuilder(
              future: API.AbsenHistoryID(idkaryawan: idkaryawan),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.connectionState != ConnectionState.waiting &&
                    snapshot.data != null) {
                  AbsenHistory getDataAcc = snapshot.data!;
                  final currentTime = DateTime.now();
                  HistoryAbsen? matchingAbsen;

                  if (getDataAcc.historyAbsen != null && getDataAcc.historyAbsen!.isNotEmpty) {
                    for (var e in getDataAcc.historyAbsen!) {
                      if (e.jamMasuk != null && e.tglAbsen != null) {
                        final dateStr = e.tglAbsen!;
                        final timeStr = e.jamMasuk!;
                        final dateTimeStr = '$dateStr $timeStr';
                        try {
                          final jamMasuk = DateFormat('yyyy-MM-dd HH:mm').parse(dateTimeStr);

                          // Compare date and hours
                          final isSameDay = jamMasuk.year == currentTime.year &&
                              jamMasuk.month == currentTime.month &&
                              jamMasuk.day == currentTime.day;

                          if (isSameDay && (jamMasuk.hour == currentTime.hour || jamMasuk.isBefore(currentTime))) {
                            matchingAbsen = e;
                            break;
                          }
                        } catch (e) {
                          // Handle parsing error if necessary
                        }
                      }
                    }
                  }

                  if (matchingAbsen != null) {
                    final timeStr = matchingAbsen.jamMasuk!;
                    final jamMasuk = DateFormat('HH:mm').parse(timeStr); // Parse without date

                    return Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 475),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                        children: [
                          HistoryAbsensiIndikator(
                            items: matchingAbsen,
                            jamMasuk: DateFormat('HH:mm').format(jamMasuk),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: const Row(
                        children: [
                          Text('Anda Belum Absen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                          Icon(Icons.celebration_rounded, color: Colors.yellow, size: 18),
                        ],
                      ),
                    );
                  }
                } else {
                  return SizedBox(
                    height: Get.height - 250,
                    child: const SingleChildScrollView(
                      child: Column(
                        children: [],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(width: 10),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(color: MyColors.appPrimaryColor, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<Profile>(
              future: API.profileiD(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const loadcabang();
                } else if (snapshot.hasError) {
                  return loadcabang();
                } else {
                  if (snapshot.data != null) {
                    final cabang = snapshot.data!.data?.cabang ?? "";
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cabang,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Text('Tidak ada data');
                  }
                }
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            header: const WaterDropHeader(),
            onLoading: _onLoading,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  sliver: SliverToBoxAdapter(
                    child: StatsGrid(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20.0),
                  sliver: SliverToBoxAdapter(
                    child: BarChartSample2(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _onLoading() {
    _refreshController.loadComplete(); // after data returned,set the //footer state to idle
  }

  _onRefresh() {
    HapticFeedback.lightImpact();
    setState(() {
      // so whatever you want to refresh it must be inside the setState
      const StatsScreen(); // if you only want to refresh the list you can place this, so the two can be inside setState
      _refreshController.refreshCompleted(); // request complete,the header will enter complete state,
    });
  }
}
