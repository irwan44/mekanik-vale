import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../../componen/color.dart';
import '../../../data/data_endpoint/detailhistory.dart';
import '../../../data/data_endpoint/detailsperpart.dart';
import '../../../data/data_endpoint/mekanik_pkb.dart';
import '../../../data/endpoint.dart';
import '../controllers/promek_controller.dart';
import 'imagedetail/imagedetail.dart';

class CardDetailPKBSperepart extends StatefulWidget {
  const CardDetailPKBSperepart({Key? key}) : super(key: key);

  @override
  State<CardDetailPKBSperepart> createState() => _CardDetailPKBSperepartState();
}

class _CardDetailPKBSperepartState extends State<CardDetailPKBSperepart> {
  late RefreshController _refreshController;
  final ImagePicker _picker = ImagePicker();
  List<AddedImageBefor> _addedImagesBefor = []; // Store AddedImage instead of XFile
  List<AddedImageAfter> _addedImagesAfter = []; // Store AddedImage instead of XFile

  Future<void> _pickImageBefore(ImageSource source, String photoType, String namaSparepart, String kodeSparepart) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      String id = DateTime.now().millisecondsSinceEpoch.toString(); // Generate unique id
      AddedImageBefor addedImage = AddedImageBefor(id: id, kodeSparepart: kodeSparepart, file: image);

      setState(() {
        _addedImagesBefor.add(addedImage);
      });
      print('Selected image path: ${image.path}');
    }
  }
  Future<void> _pickImageAfter(ImageSource source, String photoType, String namaSparepart, String kodeSparepart) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      String id = DateTime.now().millisecondsSinceEpoch.toString(); // Generate unique id
      AddedImageAfter addedImage = AddedImageAfter(id: id, kodeSparepart: kodeSparepart, file: image);

      setState(() {
        _addedImagesAfter.add(addedImage);
      });
      print('Selected image path: ${image.path}');
    }
  }


  void _showPicker(BuildContext context, String title, String photoType, String? namaSparepart, String? kodeSparepart) {
    showModalBottomSheet(
      showDragHandle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child:Column(
                  children: [
                    Text('Upload Photo $title', style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.appPrimaryColor, fontSize: 15),),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Nama Sparepart :', style: TextStyle(fontWeight: FontWeight.normal),),
                    Text('$namaSparepart', style: TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Kode Sparepart :', style: TextStyle(fontWeight: FontWeight.normal),),
                        Text('$kodeSparepart', style: TextStyle(fontWeight: FontWeight.bold),),
                      ])),

              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  if (photoType == 'Before') {
                    _pickImageBefore(ImageSource.gallery, photoType, namaSparepart!, kodeSparepart!);
                  } else if (photoType == 'After') {
                    _pickImageAfter(ImageSource.gallery, photoType, namaSparepart!, kodeSparepart!);
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  if (photoType == 'Before') {
                    _pickImageBefore(ImageSource.camera, photoType, namaSparepart!, kodeSparepart!);
                  } else if (photoType == 'After') {
                    _pickImageAfter(ImageSource.camera, photoType, namaSparepart!, kodeSparepart!);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _reloadData() {
    setState(() {
    });
  }
  @override
  void initState() {
    _refreshController = RefreshController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments = Get.arguments as Map<String, dynamic>?;
    final String kodeSvc = arguments?['kode_svc'] ?? '';
    print(arguments);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
        ),
        title: Text('Detail', style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.appPrimaryColor)),
        centerTitle: false,
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(),
        onLoading: _onLoading,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: FutureBuilder<DetailSpertpart>(
            future: API.DetailSpertpartID(kodesvc: kodeSvc),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final dataSvc = snapshot.data!.dataPhotosparepart?.dataSvc;
                final dataSvcDtlJasa = snapshot.data!.dataPhotosparepart!.detailSparepart;
                final photoSparepart = snapshot.data!.dataPhotosparepart!.photoSparepart;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${dataSvc?.tipeSvc}', style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.appPrimaryColor, fontSize: 15)),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Tanggal & Jam Estimasi :'),
                                    Text('${dataSvc?.tglEstimasi}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Jam Selesai'),
                                    Text('${dataSvc?.jamSelesai ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cabang'),
                              Text('${dataSvc?.namaCabang}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Kode Estimasi'),
                              Text('${dataSvc?.kodeEstimasi}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tipe Pelanggan :'),
                              Text('${dataSvc?.tipePelanggan ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),
                      Text('Detail Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.appPrimaryColor)),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nama :'),
                          Text('${dataSvc?.nama}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          const Text('No Handphone :'),
                          Text('${dataSvc?.hp}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5),
                          const Text('Alamat :'),
                          Text('${dataSvc?.alamat}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),
                      Text('Kendaraan Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.appPrimaryColor)),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Merk :'),
                              Text('${dataSvc?.namaMerk}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Tipe :'),
                              Text('${dataSvc?.namaTipe}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tahun :'),
                              Text('${dataSvc?.tahun}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Warna :'),
                              Text('${dataSvc?.warna}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Divider(color: Colors.grey),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('No Polisi :'),
                          Text('${dataSvc?.noPolisi}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),
                      Text('Sparepart', style: TextStyle(fontWeight: FontWeight.bold, color: MyColors.appPrimaryColor)),
                      Column(
                        children: [
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                if (photoSparepart != null)
                                  Column(
                                    children: [
                                      for (int index = 0; index < (dataSvcDtlJasa?.length ?? 0); index++)
                                        Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '${dataSvcDtlJasa?[index].namaSparepart}',
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                      Text(
                                                        '${dataSvcDtlJasa?[index].kodeSparepart}',
                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    const Text('Harga :'),
                                                    Text(
                                                      'Rp. ${NumberFormat('#,##0', 'id_ID').format(dataSvcDtlJasa?[index].hargaSparepart ?? 0)}',
                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            if (photoSparepart != null)
                                              Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(height: 10),
                                                          Text(
                                                            'Before Photos :',
                                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                          ),
                                                        ],
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () => _showPicker(
                                                            context,
                                                            'Before ',
                                                            'Before',
                                                            dataSvcDtlJasa?[index].namaSparepart,
                                                            dataSvcDtlJasa?[index].kodeSparepart),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: MyColors.appPrimaryColor,
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                          elevation: 0,
                                                        ),
                                                        child: const Text(
                                                          'Upload Photo Before',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (getBeforePhotos(
                                                      photoSparepart,
                                                      dataSvcDtlJasa?[index].namaSparepart ?? "",
                                                      dataSvcDtlJasa?[index].kodeSparepart ?? "")
                                                      .isNotEmpty)
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(height: 10),
                                                        SizedBox(
                                                          height: 120,
                                                          child: ListView.builder(
                                                            scrollDirection: Axis.horizontal,
                                                            itemCount: getBeforePhotos(
                                                                photoSparepart,
                                                                dataSvcDtlJasa?[index].namaSparepart ?? "",
                                                                dataSvcDtlJasa?[index].kodeSparepart ?? ""
                                                            ).length + _addedImagesBefor.where((img) => img.kodeSparepart == dataSvcDtlJasa?[index].kodeSparepart).length,
                                                            itemBuilder: (context, photoIndex) {
                                                              if (photoIndex < getBeforePhotos(
                                                                  photoSparepart,
                                                                  dataSvcDtlJasa?[index].namaSparepart ?? "",
                                                                  dataSvcDtlJasa?[index].kodeSparepart ?? ""
                                                              ).length) {
                                                                // Display existing photos
                                                                final List<PhotoSparepart> photos = getBeforePhotos(
                                                                    photoSparepart,
                                                                    dataSvcDtlJasa?[index].namaSparepart ?? "",
                                                                    dataSvcDtlJasa?[index].kodeSparepart ?? ""
                                                                );
                                                                final String imageUrl = photos[photoIndex].photoUrl ?? '';
                                                                final String photoId = photos[photoIndex].id.toString();
                                                                final String kodesparepart = photos[photoIndex].kodeSparepart??'';

                                                                return buildPhotoWidget(imageUrl, photoId, kodesparepart);
                                                              } else {
                                                                // Display newly added images filtered by kodeSparepart
                                                                final List<AddedImageBefor> filteredAddedImages = _addedImagesBefor.where((img) => img.kodeSparepart == dataSvcDtlJasa?[index].kodeSparepart).toList();
                                                                final AddedImageBefor addedImage = filteredAddedImages[photoIndex - getBeforePhotos(
                                                                    photoSparepart,
                                                                    dataSvcDtlJasa?[index].namaSparepart ?? "",
                                                                    dataSvcDtlJasa?[index].kodeSparepart ?? ""
                                                                ).length];

                                                                final String imageUrl = addedImage.file.path; // Adjust based on how XFile is stored
                                                                final String photoId = addedImage.id;
                                                                final String kodeSparepart = addedImage.kodeSparepart; // Get kodeSparepart from AddedImage

                                                                return buildPhotoWidget(imageUrl, photoId, kodeSparepart);
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          SizedBox(height: 10),
                                                          Text(
                                                            'After Photos :',
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold, fontSize: 18),
                                                          ),
                                                        ],
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () => _showPicker(
                                                            context,
                                                            'After ',
                                                            'After',
                                                            dataSvcDtlJasa?[index].namaSparepart,
                                                            dataSvcDtlJasa?[index].kodeSparepart),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: MyColors.appPrimaryColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(20)),
                                                          elevation: 0,
                                                        ),
                                                        child: const Text(
                                                          'Upload Photo After',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (getAfterPhotos(
                                                      photoSparepart,
                                                      dataSvcDtlJasa?[index].namaSparepart ?? "",
                                                      dataSvcDtlJasa?[index].kodeSparepart ?? "")
                                                      .isNotEmpty)
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        const SizedBox(height: 10),
                                                        SizedBox(
                                                          height: 120,
                                                          child: ListView.builder(
                                                            scrollDirection: Axis.horizontal,
                                                            itemCount: getAfterPhotos(
                                                                photoSparepart,
                                                                dataSvcDtlJasa?[index].namaSparepart ?? "",
                                                                dataSvcDtlJasa?[index].kodeSparepart ?? ""
                                                            ).length + _addedImagesAfter.where((img) => img.kodeSparepart == dataSvcDtlJasa?[index].kodeSparepart).length,
                                                            itemBuilder: (context, photoIndex) {
                                                              if (photoIndex < getAfterPhotos(
                                                                  photoSparepart,
                                                                  dataSvcDtlJasa?[index].namaSparepart ?? "",
                                                                  dataSvcDtlJasa?[index].kodeSparepart ?? ""
                                                              ).length) {
                                                                // Display existing photos
                                                                final List<PhotoSparepart> photos = getAfterPhotos(
                                                                    photoSparepart,
                                                                    dataSvcDtlJasa?[index].namaSparepart ?? "",
                                                                    dataSvcDtlJasa?[index].kodeSparepart ?? ""
                                                                );
                                                                final String imageUrl = photos[photoIndex].photoUrl ?? '';
                                                                final String photoId = photos[photoIndex].id.toString();
                                                                final String kodesparepart = photos[photoIndex].kodeSparepart??'';

                                                                return buildPhotoWidget(imageUrl, photoId, kodesparepart);
                                                              } else {
                                                                // Display newly added images filtered by kodeSparepart
                                                                final List<AddedImageAfter> filteredAddedImages = _addedImagesAfter.where((img) => img.kodeSparepart == dataSvcDtlJasa?[index].kodeSparepart).toList();
                                                                final AddedImageAfter addedImage = filteredAddedImages[photoIndex - getAfterPhotos(
                                                                    photoSparepart,
                                                                    dataSvcDtlJasa?[index].namaSparepart ?? "",
                                                                    dataSvcDtlJasa?[index].kodeSparepart ?? ""
                                                                ).length];

                                                                final String imageUrl = addedImage.file.path; // Adjust based on how XFile is stored
                                                                final String photoId = addedImage.id;
                                                                final String kodeSparepart = addedImage.kodeSparepart; // Get kodeSparepart from AddedImage

                                                                return buildPhotoWidget(imageUrl, photoId, kodeSparepart);
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            const Divider(color: Colors.grey),
                                          ],
                                        ),
                                    ],
                                  ),

                                const Divider(color: Colors.grey),
                              ],
                            ),
                        ],
                      )
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No data available'));
              }
            },
          ),
        ),
      ),
    );
  }
  Widget buildPhotoWidget(String imageUrl, String photoId, String kodeSparepart) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageDetailScreen(
                    imageUrl: imageUrl,
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.startsWith('http') ?
              Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ) :
              Image.file(
                File(imageUrl),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () async {
                print(photoId);
                QuickAlert.show(
                  barrierDismissible: true,
                  context: Get.context!,
                  type: QuickAlertType.info,
                  headerBackgroundColor:
                  Colors.yellow,
                  title:
                  'Anda yakin ingin menghapusnya?',
                  confirmBtnText: 'Hapus',
                  cancelBtnText: 'Batal',
                  confirmBtnColor: Colors.green,
                  onConfirmBtnTap: () async {
                    var response =
                    await API.DeletesPerpartID(
                        id: photoId);
                    if (response.status == true) {
                      _reloadData();
                      Navigator.of(Get.context!)
                          .pop();
                    } else {}
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                ),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _onLoading() {
    _refreshController.loadComplete();
  }

  void _onRefresh() {
    HapticFeedback.lightImpact();
    setState(() {
      // Refresh logic here
    });
    _refreshController.refreshCompleted();
  }

  List<PhotoSparepart> getBeforePhotos(List<PhotoSparepart> photoSparepart, String namaSparepart, String kodeSparepart) {
    return photoSparepart.where((photo) => photo.photoType?.toLowerCase() == 'before' && photo.kodeSparepart == kodeSparepart).toList();
  }

  List<PhotoSparepart> getAfterPhotos(List<PhotoSparepart> photoSparepart, String namaSparepart, String kodeSparepart) {
    return photoSparepart.where((photo) => photo.photoType?.toLowerCase() == 'after' && photo.kodeSparepart == kodeSparepart).toList();
  }

}
class AddedImageBefor {
  String id;
  String kodeSparepart;
  XFile file;

  AddedImageBefor({
    required this.id,
    required this.kodeSparepart,
    required this.file,
  });
}
class AddedImageAfter {
  String id;
  String kodeSparepart;
  XFile file;

  AddedImageAfter({
    required this.id,
    required this.kodeSparepart,
    required this.file,
  });
}