import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mekanik/app/componen/color.dart';
import 'package:mekanik/app/data/data_endpoint/abseninfo.dart';
import 'package:mekanik/app/data/data_endpoint/absenhistory.dart';
import 'package:mekanik/app/data/data_endpoint/profile.dart';
import 'package:mekanik/app/data/endpoint.dart';
import 'package:mekanik/app/modules/home/controllers/home_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'listhistory/listhistoryabsen.dart';

class AbsenView extends StatefulWidget {
  const AbsenView({Key? key}) : super(key: key);

  @override
  _AbsenViewState createState() => _AbsenViewState();
}

class _AbsenViewState extends State<AbsenView> {
  String _currentTime = '';
  String _currentDate = '';
  bool isButtonDisabled = false;
  bool isButtonDisabledpulang = false;
  String id = '';
  String idkaryawan = '';
  final controller = Get.put(HomeController());
  final _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _updateTime();
    _initializeButtonState();
    _fetchAbsenInfo();
    _fetchidkaryawan();
    _updateTime();
    _initializeButtonState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeButtonState() async {
    final now = DateTime.now();
    final jakartaTime = now.toUtc().add(const Duration(hours: 7));
    final sixAM = DateTime(jakartaTime.year, jakartaTime.month, jakartaTime.day, 6, 0);

    bool hasAbsenMasuk = await GetStorage().read('absen_masuk') ?? false;
    bool hasAbsenPulang = await GetStorage().read('absen_pulang') ?? false;


    setState(() {
      isButtonDisabled = hasAbsenMasuk || jakartaTime.isBefore(sixAM);
      isButtonDisabledpulang = hasAbsenPulang || jakartaTime.isBefore(sixAM);
    });

    print('Waktu Jakarta: $jakartaTime');
    print('Absen Masuk: $hasAbsenMasuk, Absen Pulang: $hasAbsenPulang');
    print('Batas Waktu: 6AM: $sixAM');
  }

  void _fetchAbsenInfo() async {
    try {
      final absen = await API.InfoAbsenID();
      setState(() {
        id = absen?.dataAbsen?.id.toString() ?? '';
        print('$id');
      });
    } catch (e) {
      print('Error fetching absen info: $e');
    }
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
  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm:ss').format(now);
      _currentDate = DateFormat('EEEE, d MMMM y').format(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: MyColors.appPrimaryColor,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bgabsen.png"),
              fit: BoxFit.cover,
            ),
          ),
          width: double.infinity,
          child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            header: const WaterDropHeader(),
            onLoading: _onLoading,
            onRefresh: _onRefresh,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20,),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 20,),
                  Row(
                    children: [
                      Stack(
                        alignment: const Alignment(0.9, 0.9),
                        children: <Widget>[
                          const CircleAvatar(
                            backgroundImage: AssetImage("assets/avatar.png"),
                            radius: 20.0,
                          ),
                          Container(
                            height: 10,
                            width: 10,
                            alignment: Alignment.bottomRight,
                            child: Image.asset("assets/success_logo.png"),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10,),
                      FutureBuilder<Profile>(
                        future: API.profileiD(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            if (snapshot.data != null) {
                              final nama = snapshot.data!.data?.namaKaryawan ?? "";
                              final hp = snapshot.data!.data?.hp ?? "";
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nama,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    hp,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
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
                  const SizedBox(height : 30,),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 30,),
                        const Text('Kehadiran Langsung', style: TextStyle(fontWeight: FontWeight.bold),),
                        const SizedBox(height: 10,),
                        FutureBuilder<Absen>(
                          future: API.InfoAbsenID(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              if (snapshot.data != null) {
                                final absen = snapshot.data!.dataAbsen?.jamMasuk ?? "";
                                if (absen.isNotEmpty) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        absen,
                                        style: TextStyle(fontSize: 40, color: MyColors.appPrimaryColor, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Text(
                                    "Anda belum absen hari ini",
                                    style: TextStyle(fontSize: 20, color: MyColors.appPrimaryColor, fontWeight: FontWeight.bold),
                                  );
                                }
                              } else {
                                return const Text('Tidak ada data');
                              }
                            }
                          },
                        ),
                        Text(
                          '$_currentDate',
                          style: TextStyle(fontSize: 20, color: MyColors.appPrimaryColor),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Divider(),
                        ),
                        const SizedBox(height: 10,),
                        const Text('Jam kerja', style: TextStyle(fontWeight: FontWeight.bold,),),
                        const SizedBox(height: 10,),
                        const Text('08:00 AM - 05:00 PM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                        const SizedBox(height: 20,),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: isButtonDisabled ? null : () {
                                  QuickAlert.show(
                                    context: Get.context!,
                                    type: QuickAlertType.info,
                                    headerBackgroundColor: MyColors.appPrimaryColor,
                                    title: 'Absen untuk hari ini',
                                    confirmBtnText: 'Absen Sekarang',
                                    confirmBtnColor: MyColors.appPrimaryColor,
                                    onConfirmBtnTap: () async {
                                      Navigator.pop(context);
                                      var response = await API.AbsenMasukID(
                                        idkaryawan: idkaryawan,
                                      );
                                      if (response.status == 'success') {
                                        await GetStorage().write('absen_masuk', true);
                                        setState(() {
                                          isButtonDisabled = true;
                                        });
                                        QuickAlert.show(
                                          context: Get.context!,
                                          type: QuickAlertType.success,
                                          text: 'Berhasil Absen',
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      } else {
                                        QuickAlert.show(
                                          context: Get.context!,
                                          type: QuickAlertType.error,
                                          text: response.message,
                                        );
                                      }
                                      _initializeButtonState(); // Refresh button state after absen
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.appPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Absen Masuk',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: isButtonDisabledpulang ? null : () {
                                  QuickAlert.show(
                                    context: context,
                                    type: QuickAlertType.warning,
                                    barrierDismissible: true,
                                    title: 'Absen pulang untuk hari ini',
                                    confirmBtnText: 'Absen Pulang',
                                    confirmBtnColor: MyColors.appPrimaryColor,
                                    widget: TextFormField(
                                      controller: controller.catatan,
                                      decoration: const InputDecoration(
                                        alignLabelWithHint: true,
                                        hintText: 'catatan',
                                        prefixIcon: Icon(
                                          Icons.mail_lock_rounded,
                                        ),
                                      ),
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.phone,
                                    ),
                                    onConfirmBtnTap: () async {
                                      var response = await API.AbsenPulangID(
                                          id: id,
                                          keterangan: controller.catatan.text
                                      );
                                      if (response.status == 'success') {
                                        await GetStorage().write('absen_pulang', true);
                                        setState(() {
                                          isButtonDisabledpulang = true;
                                        });
                                        _initializeButtonState(); // Refresh button state after absen pulang
                                      }
                                      Navigator.pop(Get.context!);
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.appPrimaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Absen Pulang',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Divider(),
                        ),
                        const SizedBox(height: 10,),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              SvgPicture.asset('assets/user-clock.svg', width: 26),
                              const SizedBox(width: 10,),
                              const Text('Riwayat Kehadiran', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                            ],
                          ),
                        ),
                        FutureBuilder(
                          future: API.AbsenHistoryID(
                              idkaryawan: idkaryawan),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.connectionState !=
                                    ConnectionState.waiting &&
                                snapshot.data != null) {
                              AbsenHistory getDataAcc = snapshot.data!;
                              return Column(
                                children: AnimationConfiguration.toStaggeredList(
                                  duration: const Duration(milliseconds: 475),
                                  childAnimationBuilder: (widget) =>
                                      SlideAnimation(
                                        child: FadeInAnimation(
                                          child: widget,
                                        ),
                                      ),
                                  children: getDataAcc.historyAbsen != null
                                      ? getDataAcc.historyAbsen!
                                      .map((e) {
                                    return HistoryAbsensi(items: e);
                                  }).toList()
                                      : [Container()],
                                ),
                              );
                            } else {
                              return SizedBox(
                                  height: Get.height - 250,
                                  child: const SingleChildScrollView(
                                    child: Column(
                                      children: [
                                      ],
                                    ),
                                  )
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onLoading() {
    _refreshController.loadComplete();
  }

  void _onRefresh() async {
    HapticFeedback.lightImpact();
    setState(() {
      _initializeButtonState(); // Refresh button state after pull to refresh
      _refreshController.refreshCompleted();
    });
  }
}
