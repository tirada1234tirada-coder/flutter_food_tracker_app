// ignore_for_file: unused_import, use_build_context_synchronously, must_be_immutable

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/models/food.dart';
import 'package:flutter_food_tracker_app/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateDeleteFoodTrackerUi extends StatefulWidget {
  // สร้างตัวแปรมารับค่าที่ส่งมา
  Food? foodDataDetail;

  // เอาค่าที่ส่งมาใส่ให้กับตัวแปร
  UpdateDeleteFoodTrackerUi({super.key, this.foodDataDetail});

  @override
  State<UpdateDeleteFoodTrackerUi> createState() =>
      _UpdateDeleteFoodTrackerUiState();
}

class _UpdateDeleteFoodTrackerUiState extends State<UpdateDeleteFoodTrackerUi> {
  // ส่วนของโค้ดที่เกี่ยวกับการเปิดกล้องถ่ายภาพ
  Uint8List? imageBytes;
  XFile?
      imageFile; // เอาไว้เก็บรูปใหม่เพื่อจะ upload ไปเก็บที่ bucket -> storage -> supabase

  // เปิดกล้องถ่ายภาพ
  Future<void> selectImageFromCamera() async {
    imageFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);

    // ตรวจสอบว่าได้ถ่ายไหม
    if (imageFile != null) {
      final byte = await imageFile!.readAsBytes();
      setState(() {
        imageBytes = byte;
      });
    }
  }

  // ตัวเลือกมื้ออาหาร
  final List<String> mealOptions = ['เช้า', 'กลางวัน', 'เย็น', 'ว่าง'];
  String selectedMeal = 'เช้า';

  // ส่วนของโค้ดที่เกี่ยวข้องกับการ upload & save ข้อมูล
  String imageURL = "";

  // สร้างตัวควบคุม TextField
  TextEditingController foodNameCtrl = TextEditingController();
  TextEditingController foodPriceCtrl = TextEditingController();
  TextEditingController foodPersonCtrl = TextEditingController();
  TextEditingController foodDateCtrl = TextEditingController();

  // เปิดปฏิทินเลือกวันที่
  Future<void> selectFoodDate() async {
    DateTime initialDate = DateTime.now();
    if (foodDateCtrl.text.isNotEmpty) {
      final parsed = DateTime.tryParse(foodDateCtrl.text);
      if (parsed != null) {
        initialDate = parsed;
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final String year = picked.year.toString().padLeft(4, '0');
      final String month = picked.month.toString().padLeft(2, '0');
      final String day = picked.day.toString().padLeft(2, '0');
      setState(() {
        foodDateCtrl.text = '$year-$month-$day';
      });
    }
  }

  void showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> uploadAndSaveData() async {
    // ตรวจสอบว่าผู้ใช้ป้อนข้อมูลครบหรือไม่
    if (foodNameCtrl.text.trim().isEmpty ||
        foodPriceCtrl.text.trim().isEmpty ||
        foodPersonCtrl.text.trim().isEmpty ||
        foodDateCtrl.text.trim().isEmpty) {
      showWarningSnackBar('กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }

    final double? parsedPrice = double.tryParse(foodPriceCtrl.text.trim());
    if (parsedPrice == null) {
      showWarningSnackBar('กรุณากรอกจำนวนเงินให้ถูกต้อง');
      return;
    }

    final int? parsedPerson = int.tryParse(foodPersonCtrl.text.trim());
    if (parsedPerson == null) {
      showWarningSnackBar('กรุณากรอกจำนวนคนให้ถูกต้อง');
      return;
    }

    // กำหนดค่ารูปว่าได้มีรูปเดิมก่อนแล้วหรือไม่
    imageURL = widget.foodDataDetail?.foodImageUrl ?? '';

    // กรณีที่มีการถ่ายภาพใหม่ ให้อัปโหลดรูปภาพเก็บใน Storage
    // และหากมีรูปอยู่ก่อนแล้วต้องลบรูปภาพนั้นออกจาก Storage ด้วย
    if (imageFile != null) {
      if (imageURL.isNotEmpty) {
        String oldImageName = imageURL.split('/').last;
        await SupabaseService().deleteImageFile(oldImageName);
      }
      imageURL = await SupabaseService().uploadImageFile(imageFile!);
    }

    // ผ่าน validate มาได้ก็แพ็คข้อมูลเพื่อส่งไปอัปเดตลง table
    Food foodData = Food(
      foodName: foodNameCtrl.text.trim(),
      foodMeal: selectedMeal,
      foodPrice: parsedPrice,
      foodPerson: parsedPerson,
      foodDate: foodDateCtrl.text.trim(),
      foodImageUrl: imageURL,
    );

    // ส่งข้อมูลที่แพ็คไปอัปเดตลง table
    await SupabaseService().updateFood(foodData, widget.foodDataDetail!.id!);

    // หลังจากบันทึกเสร็จแสดงข้อความแจ้ง
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'อัปโหลดและบันทึกแก้ไขข้อมูลเรียบร้อยแล้ว',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // ย้อนกลับไปหน้า ShowAllFoodTrackerUi()[cite: 1]
    Navigator.pop(context);
  }

  Future<void> deleteFoodData() async {
    // ลบไฟล์ออกจาก bucket แต่ต้องตรวจสอบก่อนว่าข้อมูลนั้นมีรูปไหม
    final String currentImageUrl = widget.foodDataDetail?.foodImageUrl ?? '';
    if (currentImageUrl.isNotEmpty) {
      String imageName = currentImageUrl.split('/').last;
      await SupabaseService().deleteImageFile(imageName);
    }

    // ลบข้อมูลออกจาก table[cite: 1, 6]
    await SupabaseService().deleteFood(widget.foodDataDetail!.id!);

    // แสดงข้อความแจ้งว่าลบเสร็จแล้วด้วย SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'ลบข้อมูลเสร็จสิ้น',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // ย้อนกลับไปหน้าก่อนหน้า
    Navigator.pop(context);
  }

  @override
  void initState() {
    foodNameCtrl.text = widget.foodDataDetail?.foodName ?? '';
    foodPriceCtrl.text = widget.foodDataDetail?.foodPrice?.toString() ?? '';
    foodPersonCtrl.text = widget.foodDataDetail?.foodPerson?.toString() ?? '';
    foodDateCtrl.text = widget.foodDataDetail?.foodDate ?? '';
    selectedMeal = widget.foodDataDetail?.foodMeal ?? 'เช้า';
    super.initState();
  }

  @override
  void dispose() {
    foodNameCtrl.dispose();
    foodPriceCtrl.dispose();
    foodPersonCtrl.dispose();
    foodDateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String oldImageUrl = widget.foodDataDetail?.foodImageUrl ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      // ส่วนของ appBar
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44336),
        title: const Text(
          'Food Tracker (แก้ไข/ลบ)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
      ),

      // ส่วนของ body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 30,
            bottom: 40,
            left: 24,
            right: 24,
          ),
          child: Center(
            child: Column(
              children: [
                // ใช้ Ternary Operator ในการตรวจสอบรูป
                imageFile != null
                    ? InkWell(
                        onTap: () {
                          selectImageFromCamera();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            imageBytes!,
                            width: MediaQuery.of(context).size.width * 0.38,
                            height: MediaQuery.of(context).size.width * 0.38,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : oldImageUrl.isEmpty
                        ? InkWell(
                            onTap: () {
                              selectImageFromCamera();
                            },
                            child: Icon(
                              Icons.add_a_photo,
                              size: MediaQuery.of(context).size.width * 0.35,
                              color: Colors.grey,
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              selectImageFromCamera();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                oldImageUrl,
                                width: MediaQuery.of(context).size.width * 0.38,
                                height: MediaQuery.of(context).size.width * 0.38,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                const SizedBox(height: 24),

                // กินอะไร
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'กินอะไร',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: foodNameCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'เช่น KFC, Pizza',
                  ),
                ),
                const SizedBox(height: 18),

                // กินมื้อไหน
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'กินมื้อไหน',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: mealOptions.map((meal) {
                    final bool isSelected = selectedMeal == meal;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedMeal = meal;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF9E9E9E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            meal,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // กินไปเท่าไหร่
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'กินไปเท่าไหร่',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: foodPriceCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'เช่น 299.50',
                  ),
                ),
                const SizedBox(height: 18),

                // กินกันกี่คน
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'กินกันกี่คน',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: foodPersonCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'เช่น 3',
                  ),
                ),
                const SizedBox(height: 18),

                // กินไปวันไหน
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'กินไปวันไหน',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: foodDateCtrl,
                  readOnly: true,
                  onTap: selectFoodDate,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'เช่น 2020-01-31',
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 30.0),

                // ปุ่มกดบันทึกแก้ไข
                ElevatedButton(
                  onPressed: () {
                    uploadAndSaveData();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(350.0, 52.0),
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'บันทึกแก้ไข',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),

                // ปุ่มกดลบข้อมูล
                ElevatedButton(
                  onPressed: () async {
                    await deleteFoodData();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(350.0, 52.0),
                    backgroundColor: const Color(0xFFF44336),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'ลบข้อมูล',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
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