class Food {
  // ตัวแปรล้อกับคอลัมน์ในตาราง food_tracker_tb
  String? id;
  String? createdAt;
  String? foodDate;
  String? foodMeal;
  String? foodName;
  double? foodPrice;
  int? foodPerson;
  String? foodImageUrl;

  // Constructor เอาไว้แพ็กข้อมูล
  Food({
    this.id,
    this.createdAt,
    this.foodDate,
    this.foodMeal,
    this.foodName,
    this.foodPrice,
    this.foodPerson,
    this.foodImageUrl,
  });

  // การแปลงข้อมูลฝั่ง mobile เป็น JSON เพื่อส่งไปยัง Supabase : toJson
  Map<String, dynamic> toJson() => {
        "foodDate": foodDate,
        "foodMeal": foodMeal,
        "foodName": foodName,
        "foodPrice": foodPrice,
        "foodPerson": foodPerson,
        "foodImageUrl": foodImageUrl,
      };

  // การแปลงข้อมูลฝั่ง Supabase มาใช้ในฝั่ง mobile : fromJson
  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json["id"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        foodDate: json["foodDate"] as String?,
        foodMeal: json["foodMeal"] as String?,
        foodName: json["foodName"] as String?,
        foodPrice: json["foodPrice"] == null
            ? null
            : (json["foodPrice"] as num).toDouble(),
        foodPerson: json["foodPerson"] == null
            ? null
            : (json["foodPerson"] as num).toInt(),
        foodImageUrl: json["foodImageUrl"] as String?,
      );
}//เสร็จสิ้น