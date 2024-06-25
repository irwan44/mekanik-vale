import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mekanik/app/componen/color.dart';
import 'package:mekanik/app/data/data_endpoint/kategory.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:search_page/search_page.dart';

import '../../../componen/loading_cabang_shimmer.dart';
import '../../../componen/loading_search_shimmer.dart';
import '../../../componen/loading_shammer_booking.dart';
import '../../../data/data_endpoint/boking.dart';
import '../../../data/data_endpoint/profile.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';
import '../../../tester/tester_kategori.dart';
import '../componen/card_booking.dart';
import '../controllers/boking_controller.dart';

class BokingView3 extends StatefulWidget {
  const BokingView3({super.key});

  @override
  State<BokingView3> createState() => _BokingView3State();
}

class _BokingView3State extends State<BokingView3> {
  void clearCachedBoking() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BokingView2(
      clearCachedBoking: clearCachedBoking,
    );
  }
}

class BokingView2 extends StatefulWidget {
  final VoidCallback
  clearCachedBoking; // Menggunakan VoidCallback untuk tipe fungsi tanpa parameter

  const BokingView2({super.key, required this.clearCachedBoking});

  @override
  State<BokingView2> createState() => _BokingView2State();
}

class _BokingView2State extends State<BokingView2> {
  late List<RefreshController> _refreshControllers;
  final controller = Get.put(BokingController());
  @override
  void initState() {
    _refreshControllers = List.generate(14, (index) => RefreshController());
    super.initState();
  }
  Future<void> handleBookingTap(DataBooking e) async {
    HapticFeedback.lightImpact();
    if (kDebugMode) {
      print('Nilai e.namaJenissvc: ${e.namaService ?? ''}');
    }
    if (e.bookingStatus != null && e.namaService != null) {
      if (e.bookingStatus!.toLowerCase() == 'booking' &&
          e.namaService!.toLowerCase() != 'repair & maintenance') {
        Get.toNamed(
          Routes.APPROVE,
          arguments: {
            'tgl_booking': e.tglBooking ?? '',
            'jam_booking': e.jamBooking ?? '',
            'nama': e.nama ?? '',
            'kode_kendaraan': e.kodeKendaraan ?? '',
            'kode_pelanggan': e.kodePelanggan ?? '',
            'kode_booking': e.kodeBooking ?? '',
            'nama_jenissvc': e.namaService ?? '',
            'no_polisi': e.noPolisi ?? '',
            'nama_merk': e.namaMerk ?? '',
            'keluhan': e.keluhan ?? '',
            'tahun': e.tahun ?? '',
            'warna': e.warna ?? '',
            'booking_id': e.tglBooking ?? '',
            'nama_tipe': e.namaTipe ?? '',
            'alamat': e.alamat ?? '',
            'hp': e.hp ?? '',
            'hp_pic': e.hpPic ?? '',
            'kode_pelanggan': e.kodePelanggan ?? '',
            'kategori_kendaraan': e.kategoriKendaraan ?? '',
          },
        );
      } else if (e.bookingStatus!.toLowerCase() == 'booking' &&
          e.namaService!.toLowerCase() != 'general check up/p2h') {
        Get.toNamed(
          Routes.APPROVE,
          arguments: {
            'tgl_booking': e.tglBooking ?? '',
            'booking_id': e.tglBooking ?? '',
            'jam_booking': e.jamBooking ?? '',
            'nama': e.nama ?? '',
            'keluhan': e.keluhan ?? '',
            'kode_kendaraan': e.kodeKendaraan ?? '',
            'kode_pelanggan': e.kodePelanggan ?? '',
            'nama_jenissvc': e.namaService ?? '',
            'no_polisi': e.noPolisi ?? '',
            'kode_booking': e.kodeBooking ?? '',
            'tahun': e.tahun ?? '',
            'warna': e.warna ?? '',
            'ho': e.hp ?? '',
            'kode_booking': e.kodeBooking ?? '',
            'nama_merk': e.namaMerk ?? '',
            'transmisi': e.transmisi ?? '',
            'nama_tipe': e.namaTipe ?? '',
            'alamat': e.alamat ?? '',
            'status': e.bookingStatus ?? '',
          },
        );
      }
    } else {
      print('Status atau namaJenissvc bernilai null');
    }

    if (e.bookingStatus != null && e.namaService != null) {
      if (e.bookingStatus!.toLowerCase() == 'approve' &&
          e.namaService!.toLowerCase() != 'repair & maintenance') {
        final generalData = await API.kategoriID();
        String kategoriKendaraanId = '';
        if (generalData != null) {
          final matchingKategori = generalData
              .dataKategoriKendaraan
              ?.where((kategori) =>
          kategori.kategoriKendaraan == e.kategoriKendaraan)
              .firstOrNull;
          if (matchingKategori != null &&
              matchingKategori is DataKategoriKendaraan) {
            kategoriKendaraanId =
                matchingKategori.kategoriKendaraanId ?? '';
          }
        }
        Get.toNamed(
          Routes.GENERAL_CHECKUP,
          arguments: {
            'tgl_booking': e.tglBooking ?? '',
            'booking_id': e.bookingId.toString(),
            'jam_booking': e.jamBooking ?? '',
            'nama': e.nama ?? '',
            'kode_booking': e.kodeBooking ?? '',
            'kode_kendaraan': e.kodeKendaraan ?? '',
            'kode_pelanggan': e.kodePelanggan ?? '',
            'nama_jenissvc': e.namaService ?? '',
            'no_polisi': e.noPolisi ?? '',
            'tahun': e.tahun ?? '',
            'keluhan': e.keluhan ?? '',
            'kategori_kendaraan': e.kategoriKendaraan ?? '',
            'kategori_kendaraan_id': kategoriKendaraanId,
            'warna': e.warna ?? '',
            'ho': e.hp ?? '',
            'kode_booking': e.kodeBooking ?? '',
            'nama_merk': e.namaMerk ?? '',
            'transmisi': e.transmisi ?? '',
            'nama_tipe': e.namaTipe ?? '',
            'alamat': e.alamat ?? '',
            'status': e.bookingStatus ?? '',
          },
        );
      } else if (e.bookingStatus!.toLowerCase() == 'approve' &&
          e.namaService!.toLowerCase() != 'general check up/p2h') {
        final generalData = await API.kategoriID();
        String kategoriKendaraanId = '';
        if (generalData != null) {
          final matchingKategori = generalData.dataKategoriKendaraan?.firstWhere(
                (kategori) => kategori.kategoriKendaraan == e.kategoriKendaraan,
            orElse: () => DataKategoriKendaraan(kategoriKendaraanId: '', kategoriKendaraan: ''),
          );
          if (matchingKategori != null && matchingKategori is DataKategoriKendaraan) {
            kategoriKendaraanId = matchingKategori.kategoriKendaraanId ?? '';
          }
        }
        Get.toNamed(
          Routes.REPAIR_MAINTENEN,
          arguments: {
            'tgl_booking': e.tglBooking ?? '',
            'booking_id': e.bookingId.toString(),
            'jam_booking': e.jamBooking ?? '',
            'nama': e.nama ?? '',
            'kategori_kendaraan_id': kategoriKendaraanId,
            'kategori_kendaraan': e.kategoriKendaraan ?? '',
            'kode_booking': e.kodeBooking ?? '',
            'nama_jenissvc': e.namaService ?? '',
            'no_polisi': e.noPolisi ?? '',
            'tahun': e.tahun ?? '',
            'warna': e.warna ?? '',
            'keluhan': e.keluhan ?? '',
            'kode_kendaraan': e.kodeKendaraan ?? '',
            'kode_pelanggan': e.kodePelanggan ?? '',
            'ho': e.nama ?? '',
            'kode_booking': e.kodeBooking ?? '',
            'nama_merk': e.namaMerk ?? '',
            'transmisi': e.transmisi ?? '',
            'nama_tipe': e.namaTipe ?? '',
            'alamat': e.alamat ?? '',
            'status': e.bookingStatus ?? '',
          },
        );
      }
    } else {
      print('Status atau namaJenissvc bernilai null');
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 12,
      child: WillPopScope(
        onWillPop: () async {
   Get.toNamed(Routes.HOME);
   return false;
    },
    child:
      Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          toolbarHeight: 60,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () =>  Get.toNamed(Routes.HOME),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking',
                style: TextStyle(
                    color: MyColors.appPrimaryColor,
                    fontWeight: FontWeight.bold),
              ),
              FutureBuilder<Profile>(
                future: API.profileiD(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const loadcabang();
                  } else if (snapshot.hasError) {
                    return const loadcabang();
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
                      return const loadcabang();
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            FutureBuilder(
              future: API.bokingid(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: loadsearch(),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  final data = snapshot.data!.dataBooking;

                  if (data != null && data.isNotEmpty) {
                    return InkWell(
                      onTap: () => showSearch(
                        context: context,
                        delegate: SearchPage<DataBooking>(
                          items: data,
                          searchLabel: 'Cari Booking',
                          searchStyle: GoogleFonts.nunito(color: Colors.black),
                          showItemsOnEmpty: true,
                          failure: Center(
                            child: Text(
                              'Booking Tidak Ditemukan :(',
                              style: GoogleFonts.nunito(),
                            ),
                          ),
                          filter: (booking) => [
                            booking.nama,
                            booking.noPolisi,
                            booking.bookingStatus,
                            booking.namaMerk,
                            booking.namaTipe,
                          ],
                          builder: (booking) => BokingList(
                            items: booking,
                            onTap: () {
                              handleBookingTap(booking);
                            },
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: MyColors.appPrimaryColor,
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(
                        'Pencarian',
                        style: GoogleFonts.nunito(fontSize: 16),
                      ),
                    );
                  }
                } else {
                  return const Center(
                    child: loadsearch(),
                  );
                }
              },
            ),
            const SizedBox(width: 20)
          ],
          bottom: TabBar(
            isScrollable: true,
            labelColor:
            MyColors.appPrimaryColor, // Change label color as needed
            unselectedLabelColor:
            Colors.grey, // Change unselected label color as needed
            indicatorColor: MyColors.appPrimaryColor,
            tabs: const [
              Tab(text: 'Semua'),
              Tab(text: 'Booking'),
              Tab(text: 'Approve'),
              Tab(text: 'Diproses'),
              Tab(text: 'Estimasi'),
              Tab(text: 'PKB'),
              Tab(text: 'PKB tutup'),
              Tab(text: 'Selesai Dikerjakan'),
              Tab(text: 'Invoice'),
              Tab(text: 'Lunas'),
              Tab(text: 'Ditolak'),
              Tab(text: 'Cancel Booking'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabContent(null),
            _buildTabContent('booking'),

            _buildTabContent('approve'),
            _buildTabContent('diproses'),
            _buildTabContent('estimasi'),
            _buildTabContent('pkb'),
            _buildTabContent('pkb tutup'),
            _buildTabContent('selesai dikerjakan'),
            _buildTabContent('invoice'),
            _buildTabContent('lunas'),
            _buildTabContent('ditolak'),
            _buildTabContent('cancel booking'),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildTabContent(String? status) {
    DataBooking? selectedData;
    return SmartRefresher(
      controller: _refreshControllers[_getStatusIndex(status)],
      enablePullDown: true,
      header: const WaterDropHeader(),
      onRefresh: () => _onRefresh(status),
      onLoading: () => _onLoading(status),
      child: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Boking>(
              future: API.bokingid(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SingleChildScrollView(
                    child: Loadingshammer(),
                  );
                } else if (snapshot.hasError) {
                  return Container(
                    height: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/booking.png',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Belum ada data Booking',
                          style: TextStyle(
                              color: MyColors.appPrimaryColor,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  Boking getDataAcc = snapshot.data!;
                  if (getDataAcc.status == false) {
                    return Container(
                      height: 500,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/booking.png',
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Belum ada data Booking',
                            style: TextStyle(
                                color: MyColors.appPrimaryColor,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    );
                  } else if (getDataAcc.message == 'Invalid token: Expired') {
                    Get.offAllNamed(Routes.SIGNIN);
                    return const SizedBox.shrink();
                  }

                  // Filter data berdasarkan status
                  List<DataBooking> filteredList = status != null
                      ? getDataAcc.dataBooking!
                      .where((item) => item.bookingStatus!.toLowerCase() == status)
                      .toList()
                      : getDataAcc.dataBooking!;

                  // Sort data berdasarkan tgl_booking dan jam_booking dari terbaru ke terlama
                  filteredList.sort((a, b) {
                    DateTime? aDateTime;
                    DateTime? bDateTime;

                    try {
                      aDateTime = DateTime.parse('${a.tglBooking} ${a.jamBooking}');
                    } catch (e) {
                      aDateTime = null;
                    }

                    try {
                      bDateTime = DateTime.parse('${b.tglBooking} ${b.jamBooking}');
                    } catch (e) {
                      bDateTime = null;
                    }

                    // Handle cases where parsing fails
                    if (aDateTime == null && bDateTime == null) {
                      return 0;
                    } else if (aDateTime == null) {
                      return 1;
                    } else if (bDateTime == null) {
                      return -1;
                    } else {
                      return bDateTime.compareTo(aDateTime);
                    }
                  });

                  if (filteredList.isEmpty) {
                    return Container(
                      height: 500,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icons/booking.png',
                            width: 100.0,
                            height: 100.0,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Belum ada data Booking',
                            style: TextStyle(
                                color: MyColors.appPrimaryColor,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 475),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: filteredList
                          .map(
                            (e) => BokingList(
                            items: e,
                                onTap: () async {
                                  HapticFeedback.lightImpact();
                                  if (kDebugMode) {
                                    print('Nilai e.namaService: ${e.namaService ?? ''}');
                                  }

                                  if (e.bookingStatus != null && e.namaService != null) {
                                    if (e.bookingStatus!.toLowerCase() == 'booking') {
                                      Get.toNamed(
                                        Routes.APPROVE,
                                        arguments: {
                                          'tgl_booking': e.tglBooking ?? '',
                                          'jam_booking': e.jamBooking ?? '',
                                          'nama': e.nama ?? '',
                                          'kode_kendaraan': e.kodeKendaraan ?? '',
                                          'kode_pelanggan': e.kodePelanggan ?? '',
                                          'kode_booking': e.kodeBooking ?? '',
                                          'nama_jenissvc': e.namaService ?? '',
                                          'no_polisi': e.noPolisi ?? '',
                                          'nama_merk': e.namaMerk ?? '',
                                          'keluhan': e.keluhan ?? '',
                                          'tahun': e.tahun ?? '',
                                          'warna': e.warna ?? '',
                                          'type_order': e.typeOrder ?? '',
                                          'booking_id': e.tglBooking ?? '',
                                          'nama_tipe': e.namaTipe ?? '',
                                          'alamat': e.alamat ?? '',
                                          'hp': e.hp ?? '',
                                          'hp_pic': e.hpPic ?? '',
                                          'booking_id': e.bookingId ?? '',
                                          'kategori_kendaraan': e.kategoriKendaraan ?? '',
                                        },
                                      );
                                    } else if (e.bookingStatus!.toLowerCase() == 'approve') {
                                      if (e.typeOrder != null && e.typeOrder!.toLowerCase() == 'emergency service') {
                                        Get.toNamed(
                                          Routes.EmergencyView,
                                          arguments: {
                                            'tgl_booking': e.tglBooking ?? '',
                                            'booking_id': e.bookingId.toString(),
                                            'jam_booking': e.jamBooking ?? '',
                                            'nama': e.nama ?? '',
                                            'location': e.location ?? '',
                                            'kode_booking': e.kodeBooking ?? '',
                                            'kode_kendaraan': e.kodeKendaraan ?? '',
                                            'kode_pelanggan': e.kodePelanggan ?? '',
                                            'nama_jenissvc': e.namaService ?? '',
                                            'no_polisi': e.noPolisi ?? '',
                                            'tahun': e.tahun ?? '',
                                            'keluhan': e.keluhan ?? '',
                                            'type_order': e.typeOrder ?? '',
                                            'kategori_kendaraan': e.kategoriKendaraan ?? '',
                                            'kategori_kendaraan_id': '',
                                            'warna': e.warna ?? '',
                                            'hp': e.hp ?? '',
                                            'nama_merk': e.namaMerk ?? '',
                                            'transmisi': e.transmisi ?? '',
                                            'nama_tipe': e.namaTipe ?? '',
                                            'alamat': e.alamat ?? '',
                                            'status': e.bookingStatus ?? '',
                                          },
                                        );
                                      } else {
                                        final generalData = await API.kategoriID();
                                        String kategoriKendaraanId = '';

                                        if (generalData != null) {
                                          final matchingKategori = generalData.dataKategoriKendaraan?.firstWhere(
                                                (kategori) => kategori.kategoriKendaraan == e.kategoriKendaraan,
                                            orElse: () => DataKategoriKendaraan(kategoriKendaraanId: '', kategoriKendaraan: ''),
                                          );

                                          if (matchingKategori != null && matchingKategori is DataKategoriKendaraan) {
                                            kategoriKendaraanId = matchingKategori.kategoriKendaraanId ?? '';
                                          }
                                        }

                                        if (e.namaService!.toLowerCase() == 'repair & maintenance') {
                                          Get.toNamed(
                                            Routes.REPAIR_MAINTENEN,
                                            arguments: {
                                              'tgl_booking': e.tglBooking ?? '',
                                              'booking_id': e.bookingId.toString(),
                                              'jam_booking': e.jamBooking ?? '',
                                              'nama': e.nama ?? '',
                                              'kode_booking': e.kodeBooking ?? '',
                                              'kode_kendaraan': e.kodeKendaraan ?? '',
                                              'kode_pelanggan': e.kodePelanggan ?? '',
                                              'nama_jenissvc': e.namaService ?? '',
                                              'no_polisi': e.noPolisi ?? '',
                                              'tahun': e.tahun ?? '',
                                              'keluhan': e.keluhan ?? '',
                                              'type_order': e.typeOrder ?? '',
                                              'kategori_kendaraan_id': kategoriKendaraanId,
                                              'kategori_kendaraan': e.kategoriKendaraan ?? '',
                                              'warna': e.warna ?? '',
                                              'hp': e.hp ?? '',
                                              'nama_merk': e.namaMerk ?? '',
                                              'transmisi': e.transmisi ?? '',
                                              'nama_tipe': e.namaTipe ?? '',
                                              'alamat': e.alamat ?? '',
                                              'status': e.bookingStatus ?? '',
                                            },
                                          );
                                        } else {
                                          Get.toNamed(
                                            Routes.GENERAL_CHECKUP,
                                            arguments: {
                                              'tgl_booking': e.tglBooking ?? '',
                                              'booking_id': e.bookingId.toString(),
                                              'jam_booking': e.jamBooking ?? '',
                                              'nama': e.nama ?? '',
                                              'kode_booking': e.kodeBooking ?? '',
                                              'kode_kendaraan': e.kodeKendaraan ?? '',
                                              'kode_pelanggan': e.kodePelanggan ?? '',
                                              'nama_jenissvc': e.namaService ?? '',
                                              'no_polisi': e.noPolisi ?? '',
                                              'tahun': e.tahun ?? '',
                                              'keluhan': e.keluhan ?? '',
                                              'type_order': e.typeOrder ?? '',
                                              'kategori_kendaraan_id': kategoriKendaraanId,
                                              'kategori_kendaraan': e.kategoriKendaraan ?? '',
                                              'warna': e.warna ?? '',
                                              'hp': e.hp ?? '',
                                              'nama_merk': e.namaMerk ?? '',
                                              'transmisi': e.transmisi ?? '',
                                              'nama_tipe': e.namaTipe ?? '',
                                              'alamat': e.alamat ?? '',
                                              'status': e.bookingStatus ?? '',
                                            },
                                          );
                                        }
                                      }
                                    } else {
                                      print('Booking status tidak sesuai dengan kondisi yang ditentukan');
                                    }
                                  } else {
                                    print('Booking status atau namaService bernilai null');
                                  }
                                }
                            ),
                      ).toList(),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('No data'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onLoading(String? status) {
    _refreshControllers[_getStatusIndex(status)].loadComplete();
  }

  void _onRefresh(String? status) {
    HapticFeedback.lightImpact();
    API.bokingid();
    widget.clearCachedBoking();
    _refreshControllers[_getStatusIndex(status)].refreshCompleted();
  }

  int _getStatusIndex(String? status) {
    switch (status) {
      case 'booking':
        return 1;
      case 'approve':
        return 2;
      case 'diproses':
        return 3;
      case 'estimasi':
        return 4;
      case 'selesai dikerjakan':
        return 5;
      case 'pkb':
        return 6;
      case 'pkb tutup':
        return 7;
      case 'invoice':
        return 8;
      case 'lunas':
        return 9;
      case 'ditolak':
        return 10;
      default:
        return 0; // Semua
    }
  }
}
