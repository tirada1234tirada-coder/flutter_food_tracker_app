// ignore_for_file: unused_import, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/models/food.dart';
import 'package:flutter_food_tracker_app/services/supabase_service.dart';
import 'package:flutter_food_tracker_app/views/add_food_ui.dart';
import 'package:flutter_food_tracker_app/views/update_delete_food_ui.dart';

class ShowAllFoodTrackerUi extends StatefulWidget {
  const ShowAllFoodTrackerUi({super.key});

  @override
  State<ShowAllFoodTrackerUi> createState() => _ShowAllFoodTrackerUiState();
}

class _ShowAllFoodTrackerUiState extends State<ShowAllFoodTrackerUi> {
  // สร้างตัวแปรเก็บข้อมูลทั้งหมดที่ไปดึงมาจาก Supabase
  List<Food>? foodData;

  // สร้างคำสั่งเพื่อดึงข้อมูลจาก Supabase มาเก็บในตัวแปร foodData ผ่านทาง SupabaseService
  Future<void> fetchFoodData() async {
    final data = await SupabaseService().getAllFoods();

    if (!mounted) return;
    setState(() {
      foodData = data;
    });
  }

  @override
  void initState() {
    super.initState();
    // เรียกใช้คำสั่งเพื่อดึงข้อมูลตอนหน้าจอถูกเปิด
    fetchFoodData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),

      // ส่วนของ appBar
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44336),
        title: const Text(
          'Food Tracker',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      // ส่วนของ floatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // เปิดไป AddFoodTrackerUi() แบบย้อนกลับได้
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFoodTrackerUi(),
            ),
          );

          // เรียกให้ดึงข้อมูลใหม่มาอีกรอบ
          fetchFoodData();
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFFF44336),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // ส่วนของ body
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 24,
            ),
            Image.asset(
              'assets/images/logo.png',
              width: MediaQuery.of(context).size.width * 0.28,
              height: MediaQuery.of(context).size.width * 0.28,
              fit: BoxFit.contain,
            ),
            const SizedBox(
              height: 16,
            ),

            // พื้นที่แสดงข้อมูลการกินที่ดึงมาจาก Supabase
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 84,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: foodData == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF44336),
                        ),
                      )
                    : foodData!.isEmpty
                        ? const SizedBox.shrink()
                        : ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: foodData!.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = foodData![index];

                              return ListTile(
                                onTap: () async {
                                  // เปิดไปหน้าจอ UpdateDeleteFoodTrackerUi() แบบย้อนกลับได้
                                  // โดยที่ต้องส่งข้อมูลไปด้วย และพอย้อนกลับมาต้องไปดึงข้อมูลมาใหม่
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateDeleteFoodTrackerUi(
                                        foodDataDetail: item,
                                      ),
                                    ),
                                  );

                                  // กลับมาแล้วไปดึงข้อมูลมาใหม่
                                  fetchFoodData();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tileColor: index % 2 == 0
                                    ? const Color(0xFFE8F5E9)
                                    : const Color(0xFFFFEBEE),
                                leading: item.foodImageUrl == null ||
                                        item.foodImageUrl!.isEmpty
                                    ? Image.asset(
                                        'assets/images/logo.png',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        item.foodImageUrl!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                title: Text(
                                  "กิน: ${item.foodName ?? ''}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "วันที่ ${item.foodDate ?? ''} มื้อ: ${item.foodMeal ?? ''}",
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Color(0xFFF44336),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}