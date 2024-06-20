// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:quickalert/models/quickalert_type.dart';
// import 'package:quickalert/widgets/quickalert_dialog.dart';
//
// import '../../../data/data_endpoint/mekanik.dart';
// import '../../../data/data_endpoint/mekanikp2h.dart';
// import '../../../data/endpoint.dart';
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   String selectedItem = '';
//   bool showDetails = false; // Variabel untuk kontrol visibilitas layout
//   TextEditingController textFieldController = TextEditingController();
//   List<String> selectedItems = [];
//   Map<String, bool> isStartedMap = {}; // Tracks the start/stop status for each item
//   Map<String, TextEditingController> additionalInputControllers = {}; // Separate controllers for additional inputs
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Dropdown'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               margin: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.15),
//                     spreadRadius: 5,
//                     blurRadius: 10,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child:
//           RadioListTile<bool>(
//             title: const Text('General check / P2H'),
//             controlAffinity: ListTileControlAffinity.trailing,
//             value: true,
//             groupValue: showDetails ? true : null,
//             onChanged: (bool? value) {
//               setState(() {
//                 showDetails = true; // Setelah memilih Jasa, atur menjadi true untuk menampilkan layout
//               });
//             },
//           ),
//           ),
//           if (showDetails) // Kontrol visibilitas layout dengan variabel showDetails
//             FutureBuilder<MekanikP2H>(
//               future: API.MekanikID(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else {
//                   final mechanics = snapshot.data!. ?? [];
//                   if (mechanics.isNotEmpty && selectedItem == '') {
//                     selectedItem = mechanics.first.nama ?? ''; // Set default selected item if none selected
//                   }
//                   return DropdownButton<String>(
//                     value: selectedItem,
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         selectedItem = newValue ?? '';
//                         textFieldController.text = newValue ?? ''; // Update the text field controller
//                       });
//                     },
//                     items: mechanics.map<DropdownMenuItem<String>>((mechanic) {
//                       return DropdownMenuItem<String>(
//                         value: mechanic.nama ?? '',
//                         child: Text(mechanic.nama ?? ''),
//                       );
//                     }).toList(),
//                   );
//                 }
//               },
//             ),
//           if (showDetails) // Kontrol visibilitas layout dengan variabel showDetails
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   selectedItems.add(selectedItem);
//                   isStartedMap[selectedItem] = false; // Initialize start status as false
//                   additionalInputControllers[selectedItem] = TextEditingController(); // Initialize a new TextEditingController for additional inputs
//                 });
//               },
//               child: Text('Tambah'),
//             ),
//           if (showDetails) // Kontrol visibilitas layout dengan variabel showDetails
//             SizedBox(height: 20),
//           if (showDetails) // Kontrol visibilitas layout dengan variabel showDetails
//             Expanded(
//               child: ListView.builder(
//                 itemCount: selectedItems.length,
//                 itemBuilder: (context, index) {
//                   return buildTextFieldAndStartButton(selectedItems[index]);
//                 },
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildTextFieldAndStartButton(String item) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               readOnly: true,
//               decoration: InputDecoration(
//                 labelText: 'Selected Item',
//                 border: OutlineInputBorder(),
//               ),
//               controller: TextEditingController(text: item),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () {
//                 // Cek apakah sudah start dan TextField terisi sebelum mengizinkan untuk stop
//                 if (isStartedMap[item] ?? false) {
//                   if (additionalInputControllers[item]?.text.isNotEmpty ?? false) {
//                     setState(() {
//                       isStartedMap[item] = false;  // Hanya berhenti jika TextField terisi
//                     });
//                   } else {
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
//                 } else {
//                   setState(() {
//                     isStartedMap[item] = true;  // Mulai jika belum start
//                   });
//                 }
//               },
//               child: Text(isStartedMap[item] ?? false ? 'Stop' : 'Start'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isStartedMap[item] ?? false ? Colors.red : Colors.green,
//               ),
//             ),
//             if (isStartedMap[item] ?? false)
//               SizedBox(height: 10),
//             if (isStartedMap[item] ?? false)
//               TextField(
//                 controller: additionalInputControllers[item],
//                 decoration: InputDecoration(
//                   labelText: 'Enter additional details',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }
