// ไฟล์นี้จะประกอบด้วยโค้ดคำสั่งที่จะทำงานกับ supabase
// เช่น อัปไฟล์ เพิ่ม ลบ แก้ไข ค้นหา/ตรวจสอบ/ดึง/ดู ข้อมูลในตาราง
import 'package:flutter_food_tracker_app/models/food.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // *** สิ่งสำคัญจะต้องสร้างตัวแทน ที่จะทำงานกับ supabase *** //
  final supabase = Supabase.instance.client;

  // ต่อจากนี้จะเป็นส่วนของเมธอดการทำงานต่างๆ กับ supabase
  // เมธอดอัปโหลดไฟล์ไปยัง bucket ที่อยู่ใน storage ของ supabase
  Future<String> uploadImageFile(XFile xfile) async {
    // ตั้งชื่อไฟล์เพื่อไม่ให้ซ้ำกันเวลาอยู่ใน bucket
    final newFileName =
        '${DateTime.now().millisecondsSinceEpoch}_&{xfile.name}';

    // upload ไฟล์
    await supabase.storage.from('food_tracker_bk').uploadBinary(
          newFileName,
          await xfile.readAsBytes(),
          fileOptions: FileOptions(contentType: xfile.mimeType),
        );

    // คืนค่า URL ของไฟล์ที่อัปโหลดเข้าไปใน bucket เพื่อเอาไปบันทึกลง table
    return supabase.storage.from('food_tracker_bk').getPublicUrl(newFileName);
  }

  // เมธอดเพิ่มข้อมูลไปยัง table ที่อยู่ใน database Supabase
  Future<void> insertFood(Food food) async {
    await supabase.from('food_tracker_tb').insert(food.toJson());
  }

  // เมธอดดึงข้อมูลทั้งหมดจาก table ที่อยู่ใน database ของ Supabase
  Future<List<Food>> getAllFoods() async {
    // คำสั่งดึงข้อมูลจาก supabase เรียงลำดับตามเวลาที่สร้างล่าสุดก่อน
    final response = await supabase.from('food_tracker_tb').select('*')
        .order('created_at', ascending: false);

    // เอาข้อมูลที่ดึงมาซึ่งเป็น JSON แปลงเป็นข้อมูล Object ที่ใช้ใน Project
    return response.map((e) => Food.fromJson(e)).toList();
  }

  // เมธอดลบไฟล์ที่ bucket ที่อยู่ใน storage ของ Supabase
  Future<void> deleteImageFile(String fileName) async {
    await supabase.storage.from('food_tracker_bk').remove([fileName]);
  }

  // เมธอดแก้ไขข้อมูลใน table ที่อยู่ใน database ของ Supabase (U - Update)
  Future<void> updateFood(Food food, String id) async {
    await supabase.from('food_tracker_tb').update(food.toJson()).eq('id', id);
  }

  // เมธอดลบข้อมูลออกจาก table ที่อยู่ใน database ของ Supabase (D - Delete)
  Future<void> deleteFood(String id) async {
    await supabase.from('food_tracker_tb').delete().eq('id', id);
  }
}