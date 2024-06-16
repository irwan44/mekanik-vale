import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/data_endpoint/pkb.dart';

class CardDetailPKB extends StatefulWidget {
  const CardDetailPKB({Key? key}) : super(key: key);

  @override
  State<CardDetailPKB> createState() => _CardDetailPKBState();
}

class _CardDetailPKBState extends State<CardDetailPKB> {
  late Map<String, dynamic> args;
  late List<Jasa> jasaList;

  @override
  void initState() {
    super.initState();
    args = Get.arguments as Map<String, dynamic>;

    // Retrieve jasa data from args and convert it to List<Jasa>
    List<dynamic> jasaData = args['jasa'] ?? [];
    jasaList = jasaData.map((jasaJson) => Jasa.fromJson(jasaJson)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            args['tipe_svc'] ?? '',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Tanggal & Jam PKB:', args['tgl_pkb'] ?? ''),
          _buildInfoRow('Jam Selesai:', args['jam_selesai'] ?? '-'),
          _buildInfoRow('Cabang:', args['nama_cabang'] ?? ''),
          _buildInfoRow('Kode PKB:', args['kode_pkb'] ?? '', color: Colors.green),
          _buildInfoRow('Tipe Pelanggan:', args['tipe_pelanggan'] ?? ''),
          const Divider(color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            'Detail Pelanggan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
          _buildDetailText('Nama:', args['nama'] ?? ''),
          _buildDetailText('No Handphone:', args['hp'] ?? ''),
          _buildDetailText('Alamat:', args['alamat'] ?? ''),
          const Divider(color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            'Kendaraan Pelanggan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 16,
            ),
          ),
          _buildInfoRow('Merk:', args['nama_merk'] ?? ''),
          _buildInfoRow('Tipe:', args['nama_tipe'] ?? ''),
          _buildInfoRow('Tahun:', args['tahun'] ?? '-'),
          _buildInfoRow('Warna:', args['warna'] ?? '-'),
          _buildInfoRow('Kategori Kendaraan:', args['kategori_kendaraan'] ?? '-'),
          _buildInfoRow('Transmisi:', args['transmisi'] ?? '-'),
          _buildInfoRow('No Polisi:', args['no_polisi'] ?? '-'),
          const Divider(color: Colors.grey),
          _buildDetailSection('Keluhan:', args['keluhan'] ?? '-'),
          const Divider(color: Colors.grey),
          _buildJasaSection('Jasa Service', jasaList),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  String formatCurrency(int? amount) {
    if (amount == null) {
      return 'Rp. -';
    }
    var format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return format.format(amount);
  }

  Widget _buildInfoRow(String title, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailText(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildDetailSection(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.normal,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJasaSection(String title, List<dynamic> jasaList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        jasaList.isEmpty
            ? Text(
          'Tidak ada jasa tersedia',
          style: TextStyle(color: Colors.grey),
        )
            : Column(
          children: jasaList.map((jasa) {
            return Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jasa['nama_jasa'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Kode Jasa: ${jasa['kode_jasa'] ?? ''}'),
                  Text('Harga: ${formatCurrency(jasa['harga_jasa'] ?? 0)}'),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

}
