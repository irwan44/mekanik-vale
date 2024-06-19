import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mekanik/app/modules/home/componen/stats_grid.dart';
import 'package:mekanik/app/routes/app_pages.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../componen/color.dart';
import '../../../componen/loading_cabang_shimmer.dart';
import '../../../data/data_endpoint/profile.dart';
import '../../../data/endpoint.dart';
import '../absen/view_absen.dart';
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
  final _scaffoldKey =
      GlobalKey<ScaffoldState>(); // this is our key to the scaffold widget
  @override
  void initState() {
    _refreshController =
        RefreshController(); // we have to use initState because this part of the app have to restart
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    controller.checkForUpdate();
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          InkWell(
            onTap: () {
            Get.toNamed(Routes.AbsenView);
            },
      child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            child: const Row( children: [
              Text('Anda belum Absen', style: TextStyle(color: Colors.white,  fontWeight: FontWeight.bold),),
              SizedBox(width: 10,),
              Icon(Icons.warning,
              color: Colors.yellow,
              size: 18,
                  ),
                ],
              ),
            ),
          ),
        SizedBox(width: 10,)
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                  color: MyColors.appPrimaryColor, fontWeight: FontWeight.bold),
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
      body: SmartRefresher(
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
      ),
    );
  }

  _onLoading() {
    _refreshController
        .loadComplete(); // after data returned,set the //footer state to idle
  }

  _onRefresh() {
    HapticFeedback.lightImpact();
    setState(() {
// so whatever you want to refresh it must be inside the setState
      const StatsScreen(); // if you only want to refresh the list you can place this, so the two can be inside setState
      _refreshController
          .refreshCompleted(); // request complete,the header will enter complete state,
// resetFooterState : it will set the footer state from noData to idle
    });
  }
}
