// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:mekanik/app/componen/color.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';
// import '../../../data/data_endpoint/mekanik.dart';
// import '../../../data/data_endpoint/mekanikp2h.dart';
// import '../../../data/data_endpoint/proses_promax.dart';
// import '../../../data/endpoint.dart';
// import '../componen/step_gc.dart';
//
// class GeneralCheckupView extends StatefulWidget {
//   const GeneralCheckupView({Key? key}) : super(key: key);
//
//   @override
//   _GeneralCheckupViewState createState() => _GeneralCheckupViewState();
// }
//
// class _GeneralCheckupViewState extends State<GeneralCheckupView> {
//   Map<String, String?> status = {};
//   String? selectedMechanic;
//   String? selectedKodeJasa;
//   String? selectedIdMekanik;
//   bool showBody = false;
//   List<List<String>> dropdownOptionsList = [[]];
//   List<String?> selectedValuesList = [null];
//   DateTime? startTime;
//   DateTime? stopTime;
//   Map<String, String> startPromekMap = {};
//   Map<String, String> stopPromekMap = {};
//   Map<String, String> keterangan = {};
//   Map<String, String> promekId = {};
//   String? kodeBooking;
//   String? nama;
//   String? nama_jenissvc;
//   String? kategoriKendaraanId;
//   String? kendaraan;
//   String? nama_tipe;
//   String selectedItem = 'Pilih Mekanik';
//   bool showDetails = false;
//   TextEditingController textFieldController = TextEditingController();
//   List<String> selectedItems = [];
//   Map<String, bool> isStartedMap = {};
//   Map<String, TextEditingController> additionalInputControllers = {};
//   Map<String, TextEditingController> additionalInputControllersstart = {};
//   Map<String, TextEditingController> startControllers = {};
//   Map<String, TextEditingController> stopControllers = {};
//   Map<String, List<String>> startHistoryLogs = {};
//   Map<String, List<String>> stopHistoryLogs = {};
//
//   void updateSelectedIdMekanik(String item) {
//     selectedIdMekanik = itemToIdMekanikMap[item] ?? '';
//   }
//
//   Map<String, String> itemToIdMekanikMap = {};
//
//   Future<void> fetchAndCombineData() async {
//     try {
//       final promekResponse = await API.PromekProsesID(
//         kodebooking: kodeBooking ?? '',
//         kodejasa: selectedKodeJasa ?? '',
//         idmekanik: selectedIdMekanik ?? '',
//       );
//
//       final mekanikResponse = await API.MekanikID();
//
//       final List<DataPromek> dataPromek = promekResponse.dataPromek ?? [];
//       final List<DataMekanik> dataMekanik = mekanikResponse.dataMekanik ?? [];
//
//       for (var mekanik in dataMekanik) {
//         for (var promek in dataPromek) {
//           if (promek.idMekanik == mekanik.idMekanik) {
//             itemToIdMekanikMap[mekanik.nama ?? ''] = mekanik.idMekanik.toString();
//           }
//         }
//       }
//
//       if (dataMekanik.isNotEmpty && selectedItem == '') {
//         setState(() {
//           selectedItem = dataMekanik.first.nama ?? '';
//           selectedIdMekanik = dataMekanik.first.idMekanik.toString();
//         });
//       }
//     } catch (error) {
//       if (kDebugMode) {
//         print("Error fetching data: $error");
//       }
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAndCombineData();
//     final Map? args = Get.arguments;
//     kodeBooking = args?['kode_booking'];
//     nama = args?['nama'];
//     kategoriKendaraanId = args?['kategori_kendaraan_id'] ?? '';
//     kendaraan = args?['kategori_kendaraan'];
//     nama_jenissvc = args?['nama_jenissvc'];
//     nama_tipe = args?['nama_tipe'];
//     selectedItem = 'Pilih Mekanik';
//     WidgetsBinding.instance?.addPostFrameCallback((_) {
//       showModalBottomSheet<void>(
//         context: context,
//         isScrollControlled: true,
//         useRootNavigator: true,
//         builder: (BuildContext context) {
//           return Container(
//             decoration: const BoxDecoration(
//               color: Colors.white,
//             ),
//             height: MediaQuery.of(context).size.height,
//             width: double.infinity,
//             child:
//             Column(
//                 children: <Widget>[
//                   WillPopScope(
//                       onWillPop: () async {
//                         QuickAlert.show(
//                           barrierDismissible: false,
//                           context: Get.context!,
//                           type: QuickAlertType.confirm,
//                           headerBackgroundColor: Colors.yellow,
//                           text:
//                           'Anda Harus Selesaikan dahulu General Check Up untuk keluar dari Edit General Check Up',
//                           confirmBtnText: 'Kembali',
//                           title: 'Penting !!',
//                           cancelBtnText: 'Keluar',
//                           onCancelBtnTap: () {
//                             Navigator.of(context)
//                                 .popUntil((route) => route.isFirst);
//                           },
//                           confirmBtnColor: Colors.green,
//                         );
//                         return false;
//                       },
//                       child: _buildBottomSheet()),
//                 ]),
//           );
//         },
//       );
//     });
//   }
//   void updateStatus(String key, String? value) {
//     setState(() {
//       status[key] = value;
//     });
//   }
//   void handleSubmit() {
//     showModalBottomSheet(
//       enableDrag: true,
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16.0),
//           child: ListView(
//             children: [
//               for (String checkupItem in status.keys)
//                 ListTile(
//                   title: Text(checkupItem),
//                   subtitle: Text(status[checkupItem] ?? ''),
//                 ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//   Future<void> loadPromekData(String item) async {
//     print('$kodeBooking, $selectedKodeJasa, $selectedIdMekanik');
//
//     final promekResponse = await API.PromekProsesID(
//       kodebooking: kodeBooking ?? '',
//       kodejasa: selectedKodeJasa ?? '',
//       idmekanik: selectedIdMekanik ?? '',
//     );
//
//     if (promekResponse.dataPromek != null && promekResponse.dataPromek!.isNotEmpty) {
//       final firstData = promekResponse.dataPromek!.first;
//       startPromekMap[item] = firstData.startPromek ?? 'Waktu start tidak tersedia';
//       stopPromekMap[item] = firstData.stopPromek ?? 'Waktu stop tidak tersedia';
//       promekId[item] = firstData.promekId?.toString() ?? 'ID tidak tersedia';
//       keterangan[item] = firstData.keterangan ?? 'ID tidak tersedia';
//     } else {
//       startPromekMap[item] = 'Tidak ada data';
//       stopPromekMap[item] = 'Tidak ada data';
//       promekId[item] = 'Tidak ada data';
//       keterangan[item] = 'Tidak ada data';
//     }
//   }
//   Future<void> reloadData() async {
//     setState(() {});
//   }
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         QuickAlert.show(
//           barrierDismissible: false,
//           context: Get.context!,
//           type: QuickAlertType.confirm,
//           headerBackgroundColor: Colors.yellow,
//           text:
//           'Anda Harus Selesaikan dahulu General Check Up untuk keluar dari Edit General Check Up',
//           confirmBtnText: 'Kembali',
//           title: 'Penting !!',
//           cancelBtnText: 'Keluar',
//           onCancelBtnTap: () {
//             Navigator.of(context).popUntil((route) => route.isFirst);
//           },
//           confirmBtnColor: Colors.green,
//         );
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           surfaceTintColor: Colors.transparent,
//           systemOverlayStyle: const SystemUiOverlayStyle(
//             statusBarColor: Colors.transparent,
//             statusBarIconBrightness: Brightness.dark,
//             statusBarBrightness: Brightness.light,
//             systemNavigationBarColor: Colors.white,
//           ),
//           title: Container(
//             child: Column(
//               children: [
//                 const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Edit General Check UP/P2H',
//                       style:
//                       TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(
//                       width: 50,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Nama :',
//                             style: TextStyle(fontSize: 13),
//                           ),
//                           Text(
//                             nama ?? '',
//                             style: const TextStyle(
//                                 fontSize: 13, fontWeight: FontWeight.bold),
//                           ),
//                           const Text(
//                             'Kendaraan :',
//                             style: TextStyle(fontSize: 13),
//                           ),
//                           Text(
//                             nama_tipe ?? '',
//                             style: const TextStyle(
//                                 fontSize: 13, fontWeight: FontWeight.bold),
//                           ),
//                         ]),
//                     Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Jenis Service :',
//                             style: TextStyle(fontSize: 13),
//                           ),
//                           Text(
//                             nama_jenissvc ?? '',
//                             style: const TextStyle(
//                                 fontSize: 13, fontWeight: FontWeight.bold),
//                           ),
//                           const Text(
//                             'Kode Boking :',
//                             style: TextStyle(fontSize: 13),
//                           ),
//                           Text(
//                             kodeBooking ?? '',
//                             style: const TextStyle(
//                                 fontSize: 13, fontWeight: FontWeight.bold),
//                           ),
//                         ]),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//                 Container(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       foregroundColor: Colors.white,
//                       backgroundColor: Colors.blue, // foreground
//                     ),
//                     onPressed: () {
//                       showModalBottomSheet<void>(
//                         showDragHandle: true,
//                         context: context,
//                         enableDrag: false,
//                         backgroundColor: Colors.white,
//                         isScrollControlled: true,
//                         useRootNavigator: true,
//                         builder: (BuildContext context) {
//                           return SafeArea(child:
//                           Container(
//                             decoration: const BoxDecoration(
//                               color: Colors.white,
//                             ),
//                             width: double.infinity,
//                             child: Padding(
//                               padding: const EdgeInsets.all(0),
//                               child: SingleChildScrollView(
//                                 child: Column(
//                                   children: <Widget>[
//                                     Container(
//                                       decoration: const BoxDecoration(
//                                         color: Colors.white,
//                                       ),
//                                       // Use MediaQuery to make height responsive
//                                       height: MediaQuery.of(context).size.height * 0.9, // 90% of screen height
//                                       width: double.infinity,
//                                       child: _buildBottomSheet(),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//
//                           );
//                         },
//                       );
//                     },
//                     child: const Text('Mekanik'),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 10,
//                 ),
//               ],
//             ),
//           ),
//           toolbarHeight: 170,
//           leading: IconButton(
//             icon: const Icon(Icons.close, color: Colors.black),
//             onPressed: () {
//               QuickAlert.show(
//                 barrierDismissible: false,
//                 context: Get.context!,
//                 type: QuickAlertType.confirm,
//                 headerBackgroundColor: Colors.yellow,
//                 text:
//                 'Anda Harus Selesaikan dahulu General Check Up untuk keluar dari Edit General Check Up',
//                 confirmBtnText: 'Kembali',
//                 title: 'Penting !!',
//                 cancelBtnText: 'Keluar',
//                 onCancelBtnTap: () {
//                   Navigator.of(context).popUntil((route) => route.isFirst);
//                 },
//                 confirmBtnColor: Colors.green,
//               );
//             },
//           ),
//           centerTitle: false,
//           actions: const [],
//         ),
//         body: const MyStepperPage(),
//       ),
//     );
//   }
//
//   Widget _buildBottomSheet() {
//     return StatefulBuilder(
//       builder: (context, setState) {
//         return Container(
//           color: Colors.white,
//           height: MediaQuery.of(context).size.height,
//           width: double.infinity,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               SizedBox(height: 50,),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(10),
//                 margin: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.15),
//                       spreadRadius: 5,
//                       blurRadius: 10,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text('Pilih Jasa', style: TextStyle(fontWeight: FontWeight.bold),),
//                     RadioListTile<bool>(
//                       title: const Text('General check / P2H'),
//                       controlAffinity: ListTileControlAffinity.trailing,
//                       value: true,
//                       groupValue: showDetails ? true : null,
//                       onChanged: (bool? value) {
//                         setState(() {
//                           showDetails = value ?? false;
//                         });
//                       },
//                     ),
//                   ],),
//               ),
//               if (showDetails)
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(10),
//                   margin: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.15),
//                         spreadRadius: 5,
//                         blurRadius: 10,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const Text('Pilih Mekanik', style: TextStyle(fontWeight: FontWeight.bold),),
//                       FutureBuilder<MekanikP2H>(
//                         future: API.MekanikID(),
//                         builder: (context, snapshot) {
//                           if (snapshot.connectionState == ConnectionState.waiting) {
//                             return const Center(child: CircularProgressIndicator());
//                           } else if (snapshot.hasError) {
//                             return Center(child: Text('Error: ${snapshot.error}'));
//                           } else {
//                             final mechanics = snapshot.data?.dataMekanik ?? [];
//                             final services = snapshot.data?.dataJasa ?? [];
//
//                             if (kDebugMode) {
//                               print("Mechanics: ${mechanics.map((m) => m.toJson()).toList()}");
//                             }
//                             if (kDebugMode) {
//                               print("Services: ${services.map((s) => s.toJson()).toList()}");
//                             }
//
//                             // Set default values if mechanics and services are not empty and selectedItem is empty
//                             if (mechanics.isNotEmpty && selectedItem == null && services.isNotEmpty) {
//                               selectedItem = mechanics.first.nama!;
//                               selectedIdMekanik = mechanics.first.idMekanik.toString();
//                               selectedKodeJasa = services.first.kodeJasa;
//                               print("First Mechanic ID: ${mechanics.first.idMekanik}, First Service Code: ${services.first.kodeJasa}");
//                             }
//
//                             return DropdownButton<String>(
//                               value: selectedItem,
//                               onChanged: (String? newValue) {
//                                 // Dapatkan mechanic sesuai pilihan, atau kembalikan default jika tidak ditemukan
//                                 final selectedMechanic = mechanics.firstWhere(
//                                       (mechanic) => mechanic.nama == newValue,
//                                   orElse: () => DataMekanik(),
//                                 );
//
//                                 var matchingService = services.isNotEmpty ? services.first : DataJasa();
//
//                                 setState(() {
//                                   selectedItem = newValue!;
//                                   selectedIdMekanik = selectedMechanic.idMekanik.toString();
//                                   selectedKodeJasa = matchingService.kodeJasa ?? '';
//                                 });
//                               },
//                               items: [
//                                 DropdownMenuItem<String>(
//                                   value: 'Pilih Mekanik',
//                                   child: Text('Pilih Mekanik'),
//                                 ),
//                                 ...mechanics.map<DropdownMenuItem<String>>((mechanic) {
//                                   return DropdownMenuItem<String>(
//                                     value: mechanic.nama,
//                                     child: Text(mechanic.nama ?? ''),
//                                   );
//                                 }).toList(),
//                               ],
//                             );
//                           }
//                         },
//                       ),
//
//                       Container(
//                         width: double.infinity,
//                         child:
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: MyColors.appPrimaryColor,
//                               padding: EdgeInsets.symmetric(horizontal: 50,),
//                               textStyle: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                           onPressed: () async {
//                             print('$kodeBooking, $selectedKodeJasa, $selectedIdMekanik');
//                             final promekResponse = await API.PromekProsesID(
//                               kodebooking: kodeBooking ?? '',
//                               kodejasa: selectedKodeJasa ?? '',
//                               idmekanik: selectedIdMekanik ?? '',
//                             );
//                             if (promekResponse.dataPromek != null && promekResponse.dataPromek!.isNotEmpty) {
//                               final firstData = promekResponse.dataPromek!.first;
//                               if (firstData.startPromek != null) {
//                                 startPromekMap[selectedItem] = firstData.startPromek!;
//                               } else {
//                                 startPromekMap[selectedItem] = 'Waktu start tidak tersedia';
//                               }
//                             } else {
//                               startPromekMap[selectedItem] = 'Tidak ada data';
//                             }
//                             if (promekResponse.dataPromek != null && promekResponse.dataPromek!.isNotEmpty) {
//                               final firstData = promekResponse.dataPromek!.first;
//                               if (firstData.stopPromek != null) {
//                                 stopPromekMap[selectedItem] = firstData.stopPromek!;
//                               } else {
//                                 stopPromekMap[selectedItem] = 'Waktu start tidak tersedia';
//                               }
//                             } else {
//                               stopPromekMap[selectedItem] = 'Tidak ada data';
//                             }
//                             if (promekResponse.dataPromek != null && promekResponse.dataPromek!.isNotEmpty) {
//                               final firstData = promekResponse.dataPromek!.first;
//                               if (firstData.promekId != null) {
//                                 promekId[selectedItem] = firstData.promekId.toString();
//                               } else {
//                                 promekId[selectedItem] = 'Waktu start tidak tersedia';
//                               }
//                             } else {
//                               promekId[selectedItem] = 'Tidak ada data';
//                             }
//                             if (promekResponse.dataPromek != null && promekResponse.dataPromek!.isNotEmpty) {
//                               final firstData = promekResponse.dataPromek!.first;
//                               if (firstData.keterangan != null) {
//                                 keterangan[selectedItem] = firstData.keterangan??'';
//                               } else {
//                                 keterangan[selectedItem] = 'Keterangan tidak tersedia';
//                               }
//                             } else {
//                               keterangan[selectedItem] = 'Tidak ada data';
//                             }
//
//                             setState(() {
//                               selectedItems.add(selectedItem);
//                               isStartedMap[selectedItem] = false;
//                               additionalInputControllers[selectedItem] = TextEditingController();
//                             });
//                           },
//                           child: const Text('Tambah', style: TextStyle(color: Colors.white),),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               if (showDetails)
//                 const SizedBox(height: 20),
//               if (showDetails)
//                 Expanded(
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       print("Expanded constraints: $constraints");  // Check the constraints
//                       return ListView.builder(
//                         physics: AlwaysScrollableScrollPhysics(),
//                         itemCount: selectedItems.length,
//                         itemBuilder: (context, index) {
//                           return buildTextFieldAndStartButton(selectedItems[index]);
//                         },
//                       );
//                     },
//                   ),
//                 ),
//
//             ],
//           ),
//         );
//       },
//     );
//   }
//   Widget buildTextFieldAndStartButton(String item) {
//     if (!startControllers.containsKey(item)) {
//       startControllers[item] = TextEditingController();
//     }
//     if (!stopControllers.containsKey(item)) {
//       stopControllers[item] = TextEditingController();
//     }
//     // Initialize history logs if they don't exist
//     startHistoryLogs[item] ??= [];
//     stopHistoryLogs[item] ??= [];
//     promekId[item] ??= [].toString();
//     String startPromekText = startPromekMap[item] ?? 'Tidak ada data';
//     String stopPromekText = stopPromekMap[item] ?? 'Tidak ada data';
//     String keteranganText = keterangan[item] ?? 'Tidak ada data';
//
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: const EdgeInsets.all(10),
//           margin: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.15),
//                 spreadRadius: 5,
//                 blurRadius: 10,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               TextField(
//                 readOnly: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Mekanik yang Dipilih',
//                   labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                   border: OutlineInputBorder(),
//                 ),
//                 controller: TextEditingController(text: item),
//               ),
//               SizedBox(height: 10,),
//               if (isStartedMap[item] ?? false)
//                 TextField(
//                   controller: stopControllers[item],
//                   decoration: const InputDecoration(
//                     labelText: 'Keterangan',
//                     labelStyle: TextStyle(fontWeight: FontWeight.bold),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//               ElevatedButton(
//                 onPressed: () async {
//                   TextEditingController? currentController = isStartedMap[item] ?? true ? stopControllers[item] : startControllers[item];
//                   print('response : $startControllers');
//                   print('response : $promekId');
//
//                   if (!(isStartedMap[item] ?? false) || currentController!.text.isNotEmpty) {
//                     try {
//                       await API.promekID(
//                         role: isStartedMap[item] ?? false ? 'stop' : 'start',
//                         kodebooking: kodeBooking ?? '',
//                         kodejasa: selectedKodeJasa ?? '',
//                         idmekanik: selectedIdMekanik ?? '',
//                       );
//                       await API.updateketeranganID(
//                         promekid: promekId.toString(),
//                         keteranganpromek: startControllers[item]?.text ?? '',
//                       );
//                       Navigator.pop(Get.context!);
//                       setState(() {
//                         isStartedMap[item] = !(isStartedMap[item] ?? false);
//                         if (isStartedMap[item] ?? true) {
//                           stopHistoryLogs[item]!.add(currentController!.text);  // Log the stop action
//                         } else {
//                           startHistoryLogs[item]!.add(currentController!.text);  // Log the start action
//                         }
//                         currentController.clear();
//                       });
//                     } catch (e) {
//                       print("Failed to execute API call: $e");  // Handle any errors
//                     }
//                   } else {
//                     // Error dialog if text field is empty when stopping
//                     QuickAlert.show(
//                       barrierDismissible: false,
//                       context: Get.context!,
//                       type: QuickAlertType.warning,
//                       headerBackgroundColor: Colors.yellow,
//                       text:
//                       'Anda Harus isi Keterangan dahulu sebelum Stop',
//                       confirmBtnText: 'Oke',
//                       title: 'Penting !!',
//                       confirmBtnColor: Colors.green,
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isStartedMap[item] ?? false ? Colors.red : Colors.green,
//                 ),
//                 child: Text(isStartedMap[item] ?? false ? 'Stop' : 'Start'),
//               ),
//               // if (startHistoryLogs[item]!.isNotEmpty)
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   margin: const EdgeInsets.all(10),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.15),
//                         spreadRadius: 5,
//                         blurRadius: 10,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Start History:", style: TextStyle(fontWeight: FontWeight.bold)),
//                       Text('$startPromekText'),
//                       // const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
//                       // ...startHistoryLogs[item]!.map((log) => Text(log)).toList(),
//                     ],
//                   ),
//                 ),
//               // if (stopHistoryLogs[item]!.isNotEmpty)
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   margin: const EdgeInsets.all(10),
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.15),
//                         spreadRadius: 5,
//                         blurRadius: 10,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Stop History:", style: TextStyle(fontWeight: FontWeight.bold)),
//                       Text('$stopPromekText'),
//                       const Text("Keterangan", style: TextStyle(fontWeight: FontWeight.bold)),
//                       Text('$keteranganText'),
//                       // ...stopHistoryLogs[item]!.map((log) => Text(log)).toList(),
//                     ],
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//
//
//
// }
//
// class DropdownItem {
//   String selectedIdMekanik;
//   List<String> options;
//
//   DropdownItem(this.selectedIdMekanik, this.options);
// }