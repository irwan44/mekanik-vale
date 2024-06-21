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
  bool hasHistoryAbsen = false;
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initializeButtonState() async {
    final now = DateTime.now();
    final jakartaTime = now.toUtc().add(const Duration(hours: 7));
    final sixAM = DateTime(jakartaTime.year, jakartaTime.month, jakartaTime.day, 6, 0, 0);

    bool hasAbsenMasuk = await GetStorage().read('absen_masuk') ?? false;
    bool hasAbsenPulang = await GetStorage().read('absen_pulang') ?? false;

    String lastAttendanceDate = await _fetchLastAttendanceDate();
    String currentDate = DateFormat('yyyy-MM-dd').format(jakartaTime);

    var response = await API.AbsenHistoryID(idkaryawan: idkaryawan);
    bool hasHistory = response.historyAbsen != null && response.historyAbsen!.isNotEmpty;

    bool isSameDate = lastAttendanceDate == currentDate;

    setState(() {
      hasHistoryAbsen = hasHistory;

      isButtonDisabled = hasAbsenMasuk && isSameDate;
      isButtonDisabledpulang = hasAbsenPulang && isSameDate;
    });

    print('Waktu Jakarta: $jakartaTime');
    print('Absen Masuk: $hasAbsenMasuk, Absen Pulang: $hasAbsenPulang');
    print('Batas Waktu: 6AM: $sixAM');
    print('Last Attendance Date: $lastAttendanceDate, Current Date: $currentDate');
  }

  Future<String> _fetchLastAttendanceDate() async {
    try {
      final absenHistory = await API.AbsenHistoryID(idkaryawan: idkaryawan);
      if (absenHistory.historyAbsen != null && absenHistory.historyAbsen!.isNotEmpty) {
        final lastAttendance = absenHistory.historyAbsen!.first;
        return lastAttendance.tglAbsen ?? '';
      }
    } catch (e) {
      print('Error fetching last attendance date: $e');
    }
    return '';
  }

  void _fetchAbsenInfo() async {
    try {
      final absen = await API.InfoAbsenID();
      setState(() {
        id = absen?.dataAbsen?.id?.toString() ?? '';
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
    return Scaffold(
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
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 20),
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
                    const SizedBox(width: 10),
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
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Kehadiran Langsung',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
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
                                  children: [
                                    Text(
                                      'Absen Hari Ini',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade500,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      absen,
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const Text('Tidak ada data');
                              }
                            } else {
                              return const Text('Tidak ada data');
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isButtonDisabled || !hasHistoryAbsen
                            ? null
                            : () {
                          QuickAlert.show(
                            context: Get.context!,
                            type: QuickAlertType.info,
                            headerBackgroundColor: MyColors.appPrimaryColor,
                            title: 'Absen untuk hari ini',
                            confirmBtnText: 'Absen Sekarang',
                            confirmBtnColor: MyColors.appPrimaryColor,
                            onConfirmBtnTap: () async {
                              Navigator.pop(context);
                              var response = await API.AbsenMasukID(idkaryawan: idkaryawan);
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
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isButtonDisabledpulang || !hasHistoryAbsen
                            ? null
                            : () {
                          QuickAlert.show(
                            context: Get.context!,
                            type: QuickAlertType.info,
                            headerBackgroundColor: MyColors.appPrimaryColor,
                            title: 'Absen untuk hari ini',
                            confirmBtnText: 'Absen Sekarang',
                            confirmBtnColor: MyColors.appPrimaryColor,
                            onConfirmBtnTap: () async {
                              Navigator.pop(context);
                              var response = await API.AbsenPulangID(
                                  id: idkaryawan,
                                  keterangan: controller.catatan.text);
                              if (response.status == 'success') {
                                await GetStorage().write('absen_pulang', true);
                                setState(() {
                                  isButtonDisabledpulang = true;
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
                          'Absen Pulang',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Histori Absen',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<AbsenHistory>(
                  future: API.AbsenHistoryID(idkaryawan: idkaryawan),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if (snapshot.data != null &&
                          snapshot.data!.historyAbsen != null &&
                          snapshot.data!.historyAbsen!.isNotEmpty) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.historyAbsen!.length,
                          itemBuilder: (context, index) {
                            final history = snapshot.data!.historyAbsen![index];
                            return ListTile(
                              title: Text(history.tglAbsen ?? ''),
                              subtitle: Text('Masuk: ${history.jamMasuk ?? ''}, Pulang: ${history.jamKeluar ?? ''}'),
                            );
                          },
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
        ),
      ),
    );
  }

  void _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _updateTime();
    _initializeButtonState();
    _fetchAbsenInfo();
    _fetchidkaryawan();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }
}