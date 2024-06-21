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

import 'listhistory/absensekarang.dart';
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
    _fetchAbsenInfo();
    _fetchidkaryawan();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeButtonState() async {
    try {
      final response = await API.AbsenHistoryID(idkaryawan: idkaryawan);
      if (response.historyAbsen != null && response.historyAbsen!.isNotEmpty) {
        final lastAbsen = response.historyAbsen!.last;
        final absenDateStr = lastAbsen.tglAbsen ?? '';
        if (absenDateStr.isNotEmpty) {
          final absenDate = DateFormat('yyyy-MM-dd').parse(absenDateStr);
          final currentDate = DateTime.now();
          final isSameDay = absenDate.year == currentDate.year &&
              absenDate.month == currentDate.month &&
              absenDate.day == currentDate.day;

          setState(() {
            isButtonDisabled = isSameDay;
          });
        } else {
          setState(() {
            isButtonDisabled = false;
          });
        }
      } else {
        setState(() {
          isButtonDisabled = false;
        });
      }
    } catch (e) {
      print('Error initializing button state: $e');
      setState(() {
        isButtonDisabled = false;
      });
    }
  }

  void _initializeButtonpulangState() async {
    try {
      final response = await API.AbsenHistoryID(idkaryawan: idkaryawan);
      if (response.historyAbsen != null && response.historyAbsen!.isNotEmpty) {
        final lastAbsen = response.historyAbsen!.last;
        final absenDateStr = lastAbsen.tglAbsen ?? ''; // Provide a default empty string if null
        final jamPulang = lastAbsen.jamKeluar;

        if (absenDateStr.isNotEmpty) {
          final absenDate = DateFormat('yyyy-MM-dd').parse(absenDateStr);
          final currentDate = DateTime.now();
          final isSameDay = absenDate.year == currentDate.year &&
              absenDate.month == currentDate.month &&
              absenDate.day == currentDate.day;

          setState(() {
            // If it's the same day and jamPulang is not null, disable the button
            isButtonDisabledpulang = isSameDay && jamPulang != null;
          });
        } else {
          setState(() {
            isButtonDisabledpulang = false;
          });
        }
      } else {
        setState(() {
          isButtonDisabledpulang = false;
        });
      }
    } catch (e) {
      print('Error initializing button pulang state: $e');
      setState(() {
        isButtonDisabledpulang = false;
      });
    }
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
      _initializeButtonState();
      _initializeButtonpulangState(); // Ensure this is called after idkaryawan is fetched
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
                        FutureBuilder(
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
                                  if (e.jamMasuk != null) {
                                    final timeStr = e.jamMasuk!;
                                    try {
                                      final jamMasuk = DateFormat('HH:mm').parse(timeStr); // Parse without date
                                      // Compare only hours
                                      if (jamMasuk.hour == currentTime.hour) {
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
                                      HistoryAbsensiSekarang(
                                        items: matchingAbsen,
                                        jamMasuk: DateFormat('HH:mm').format(jamMasuk),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Text(
                                  "Anda belum absen hari ini",
                                  style: TextStyle(fontSize: 20, color: MyColors.appPrimaryColor, fontWeight: FontWeight.bold),
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
                                          idkaryawan: idkaryawan);
                                      if (response.status == 'success') {
                                        setState(() {
                                          const AbsenView();
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
                          ),
                          onConfirmBtnTap: () async {
                            Navigator.pop(Get.context!);
                            var response = await API.AbsenPulangID(
                                id: id,
                                keterangan: controller.catatan.text
                            );
                            if (response.status == 'success') {
                              setState(() {
                                isButtonDisabledpulang = true;
                              });
                              QuickAlert.show(
                                context: Get.context!,
                                type: QuickAlertType.success,
                                text: 'Berhasil Absen Pulang',
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
                            _initializeButtonpulangState();
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
                          future: API.AbsenHistoryID(idkaryawan: idkaryawan),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.connectionState != ConnectionState.waiting &&
                                snapshot.data != null) {
                              AbsenHistory getDataAcc = snapshot.data!;
                              return Column(
                                children: AnimationConfiguration.toStaggeredList(
                                  duration: const Duration(milliseconds: 475),
                                  childAnimationBuilder: (widget) => SlideAnimation(
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
                                      children: [],
                                    ),
                                  ));
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
      const AbsenView(); // if you only want to refresh the list you can place this, so the two can be inside setState
      _initializeButtonState(); // Refresh button state after pull to refresh
      _refreshController.refreshCompleted();
    });
  }
}
