import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mekanik/app/modules/home/componen/stats_grid.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../componen/color.dart';
import '../../../componen/loading_cabang_shimmer.dart';
import '../../../data/data_endpoint/profile.dart';
import '../../../data/endpoint.dart';
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
      backgroundColor: MyColors.appPrimaryBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: MyColors.appPrimaryDarkmod,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle:  SystemUiOverlayStyle(
          statusBarColor:  MyColors.appPrimaryDarkmod,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: MyColors.appPrimaryDarkmod,
        ),
        centerTitle: false,
        actions: [
          Image.asset(
            'assets/logo_autobenz.png',
            width: 100.0,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 20,)
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<Profile>(
              future: API.profileiD(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else if (snapshot.hasError) {
                  return  Container();
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
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              sliver: SliverToBoxAdapter(
                child: StatsGrid(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 20.0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: MyColors.appPrimaryDarkmod,
                    borderRadius: const BorderRadius.all(Radius.circular(20))
                  ),
                  child: BarChartSample2(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildHeader() {
    return const SliverPadding(
      padding: EdgeInsets.all(20.0),
      sliver: SliverToBoxAdapter(
        child: Text(
          'Statistics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRegionTabBar() {
    return SliverToBoxAdapter(
      child: DefaultTabController(
        length: 2,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          height: 50.0,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }

  SliverPadding _buildStatsTabBar() {
    return const SliverPadding(
      padding: EdgeInsets.all(20.0),
      sliver: SliverToBoxAdapter(),
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
