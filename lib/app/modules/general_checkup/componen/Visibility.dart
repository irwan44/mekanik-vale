// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import '../../../data/data_endpoint/general_chackup.dart';
//
// class GcuItem extends StatefulWidget {
//   final Gcus gcu;
//   final String? dropdownValue;
//   final TextEditingController deskripsiController;
//   final ValueChanged<String?> onDropdownChanged;
//   final ValueChanged<String?> onDescriptionChanged;
//
//   const GcuItem({
//     Key? key,
//     required this.gcu,
//     required this.dropdownValue,
//     required this.deskripsiController,
//     required this.onDropdownChanged,
//     required this.onDescriptionChanged,
//   }) : super(key: key);
//
//   @override
//   _GcuItemState createState() => _GcuItemState();
// }
// class _GcuItemState extends State<GcuItem> {
//   String? dropdownValue;
//   String? description;
//
//   @override
//   void initState() {
//     super.initState();
//     dropdownValue = ''; // Inisialisasi nilai dropdownValue di initState
//     description = ''; // Inisialisasi nilai description di initState
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Flexible(
//               child: Text(
//                 widget.gcu.gcu ?? '',
//                 textAlign: TextAlign.start,
//                 softWrap: true,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Flexible(
//               child: DropdownButton<String>(
//                 value: dropdownValue,
//                 hint: dropdownValue == '' ? const Text('Pilih') : null,
//                 onChanged: (String? value) {
//                   setState(() {
//                     dropdownValue = value;
//                   });
//                 },
//                 items: <String>['', 'Oke', 'Not Oke'].map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ],
//         ),
//         if (dropdownValue == 'Not Oke')
//           TextField(
//             onChanged: (text) {
//               setState(() {
//                 description = text;
//               });
//             },
//             decoration: const InputDecoration(
//               hintText: 'Keterangan',
//             ),
//           ),
//       ],
//     );
//   }
// }