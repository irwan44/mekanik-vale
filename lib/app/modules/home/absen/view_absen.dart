import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mekanik/app/data/data_endpoint/abseninfo.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../../componen/color.dart';
import '../../../data/data_endpoint/absenhistory.dart';
import '../../../data/data_endpoint/profile.dart';
import '../../../data/endpoint.dart';
import '../controllers/home_controller.dart';
import 'listhistory/listhistoryabsen.dart';

class AbsenView extends StatefulWidget {
  const AbsenView({super.key});

  @override
  State<AbsenView> createState() => _AbsenViewState();
}

class _AbsenViewState extends State<AbsenView> {
  String _currentTime = '';
  String _currentDate = '';
  bool isButtonDisabled = false;
  bool isButtonDisabledpulang = false;
  String id = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _setupTimer();
    _initializeButtonState();
    _fetchAbsenInfo();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setupTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateTime();
      _initializeButtonState();
    });
  }

  void _initializeButtonState() {
    bool hasAbsenMasuk = GetStorage().read('absen_masuk') ?? false;
    final now = DateTime.now();
    final jakartaTime = now.toUtc().add(Duration(hours: 7));
    final sixAM = DateTime(jakartaTime.year, jakartaTime.month, jakartaTime.day, 6, 0);
    final eightAM = DateTime(jakartaTime.year, jakartaTime.month, jakartaTime.day, 8, 0);

    setState(() {
      isButtonDisabled = hasAbsenMasuk || jakartaTime.isBefore(sixAM) || jakartaTime.isAfter(eightAM);
    });

    bool hasAbsenPulang = GetStorage().read('absen_pulang') ?? false;
    setState(() {
      isButtonDisabledpulang = hasAbsenPulang;
    });
  }

  void _fetchAbsenInfo() async {
    try {
      Absen? absen = await API.InfoAbsenID();
      if (absen != null) {
        setState(() {
          id = absen.dataAbsen?.id.toString() ?? '';
        });
      }
    } catch (e) {
      print('Error fetching absen info: $e');
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    final formattedDate = DateFormat('EEEE, d MMMM y').format(now);

    setState(() {
      _currentTime = formattedTime;
      _currentDate = formattedDate;
    });
  }

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    String idKaryawan = GetStorage().read('idKaryawan').toString();
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
          padding: EdgeInsets.all(20),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bgabsen.png"),
              fit: BoxFit.cover,
            ),
          ),
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 60,),
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
                    SizedBox(width: 10,),
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
                                  style: TextStyle(
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
                SizedBox(height : 30,),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 30,),
                      Text('Kehadiran Langsung', style: TextStyle(fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
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
                      SizedBox(height: 10,),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(),
                      ),
                      SizedBox(height: 10,),
                      Text('Jam kerja', style: TextStyle(fontWeight: FontWeight.bold,),),
                      SizedBox(height: 10,),
                      Text('08:00 AM - 05:00 PM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                      SizedBox(height: 20,),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: isButtonDisabled ? null : () {
                                QuickAlert.show(
                                  barrierDismissible: true,
                                  context: Get.context!,
                                  type: QuickAlertType.info,
                                  headerBackgroundColor: MyColors.appPrimaryColor,
                                  title: 'Absen untuk hari ini',
                                  confirmBtnText: 'Absen Sekarang',
                                  confirmBtnColor: MyColors.appPrimaryColor,
                                  onConfirmBtnTap: () async {
                                    var response = await API.AbsenMasukID(
                                      idkaryawan: idKaryawan,
                                    );
                                    if (response.status == 'success') {
                                      await GetStorage().write('absen_masuk', true);
                                      setState(() {
                                        isButtonDisabled = true;
                                      });
                                    }
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
                                    }
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
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(),
                      ),
                      SizedBox(height: 10,),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            SvgPicture.asset('assets/user-clock.svg', width: 26),
                            SizedBox(width: 10,),
                            Text('Riwayat Kehadiran', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                          ],
                        ),
                      ),
                      FutureBuilder(
                        future: API.AbsenHistoryID(idkaryawan: idKaryawan),
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
                                child: SingleChildScrollView(
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
    );
  }
}
