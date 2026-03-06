# Shopping List App

แอปพลิเคชันจัดการรายการซื้อของ (Shopping List) พัฒนาด้วย **Flutter** เน้นการออกแบบที่เรียบง่าย (Minimalist UI) คลีนๆ สไตล์ iOS และเชื่อมต่อข้อมูลแบบ Real-time ผ่าน **Firebase Realtime Database**

## Features (ฟีเจอร์เด่น)
- **Smart Icons:** ระบบเปลี่ยนไอคอนหน้ารายการสินค้าให้อัตโนมัติตามหมวดหมู่และชื่อที่พิมพ์ (เช่น พิมพ์ Milk จะแสดงไอคอนแก้วน้ำ)
- **Intelligent Autocomplete:** ระบบแนะนำชื่อสินค้าขณะพิมพ์ โดยกรองเฉพาะคำที่ขึ้นต้นด้วยตัวอักษรนั้นๆ (Starts with) เพื่อความรวดเร็วและแม่นยำ
- **Auto-Category Selection:** ระบบเดาหมวดหมู่สินค้าอัตโนมัติจากชื่อที่กำลังพิมพ์ ทำงานประสานกับ Autocomplete ทันทีที่เลือกคำ
- **Minimalist UI Design:** ปรับแต่งช่องกรอกข้อมูล (TextField) และ Dropdown ให้เป็นแบบขอบมน ใช้ `hintText` ซ่อนเส้นขอบ ตัดปัญหา UI ทับซ้อนเพื่อให้ดูทันสมัย
- **Real-time Sync:** รองรับการเพิ่ม ลบ และแสดงผลข้อมูลทันทีผ่าน REST API ของ Firebase

## Application Flow (โฟลว์การทำงานของระบบ)
1. **หน้าจอหลัก (Home Screen):** เมื่อเปิดแอปพลิเคชัน ระบบจะทำการร้องขอข้อมูล (GET Request) จาก Firebase มาแสดงผลเป็นรายการพร้อมไอคอนประจำหมวดหมู่
2. **หน้าเพิ่มสินค้า (Add Item):** - ผู้ใช้พิมพ์ตัวอักษรแรกในช่อง Name
   - ระบบ Autocomplete จะแสดงรายการแนะนำสินค้า
   - เมื่อผู้ใช้พิมพ์หรือเลือกชื่อสินค้า ระบบ Auto-Category จะเปลี่ยนหมวดหมู่ใน Dropdown ให้อัตโนมัติทันที
   - ผู้ใช้ระบุจำนวน (Quantity) และกดปุ่ม Add Item
3. **การบันทึกข้อมูล:** ระบบทำการเช็คความถูกต้อง (Validation) และส่งข้อมูล (POST Request) กลับไปยัง Firebase หากสำเร็จจะย้อนกลับมาหน้าหลักพร้อมอัปเดต UI ทันที
4. **การลบสินค้า:** ผู้ใช้สามารถปัดซ้าย/ขวา (Swipe to dismiss) ที่รายการ เพื่อส่งคำสั่งลบข้อมูลออกจาก Firebase (DELETE Request)


## Known Issues & Solutions (ปัญหาที่พบและวิธีการแก้ไข)

**1. ปัญหาไม่สามารถรันบนระบบปฏิบัติการ Android ได้ (รองรับเฉพาะ iOS Simulator และ Chrome)**
- **ปัญหา:** เมื่อทำการรันบน Android Emulator มักจะเกิด Error ขัดข้อง
- **สาเหตุ:** เกิดจากปัญหา Version Mismatch ของ Flutter SDK/Packages บางตัวที่ใช้ในโปรเจกต์นี้ ไม่ตรงกับ Gradle เวอร์ชันปัจจุบันของฝั่ง Android
- **วิธีการจัดการ:** ตัดสินใจรันทดสอบและพัฒนาบน **iOS Simulator** และ **Chrome** เป็นหลัก เนื่องจากการบังคับอัปเดตเวอร์ชัน SDK แบบ Global ในคอมพิวเตอร์ตอนนี้ **จะส่งผลกระทบทำให้โปรเจกต์เก่าๆ ที่อิงกับเวอร์ชันเดิมพัง (Build failed) ได้** จึงเลี่ยงการอัปเดตเพื่อรักษาเสถียรภาพของโปรเจกต์อื่นๆ ไว้ก่อน

**2. ปัญหาหน้าจอแจ้งเตือน Error สีแดง (RenderFlex Overflow)**
- **ปัญหา:** หน้าจอแสดงผล Error ขอบแดงเมื่อคีย์บอร์ดเด้งขึ้นมา หรือเมื่อช่อง Autocomplete พยายามขยายพื้นที่จนล้นหน้าจอ
- **วิธีการแก้ไข:** ทำการแก้ปัญหาโดยนำ `SingleChildScrollView` มาครอบฟอร์มทั้งหมดเพื่อให้หน้าจอสามารถไถเลื่อนได้ และประยุกต์ใช้ `LayoutBuilder` ในการจำกัดขนาดความกว้างของหน้าต่าง Autocomplete ไม่ให้ล้นกรอบ

**3. ปัญหาเส้นขอบ TextField ขาด/แหว่ง เมื่อใช้งานบน iOS**
- **ปัญหา:** รูปแบบ Material Design ทำให้ตัวหนังสือ Label ลอยไปทับเส้นขอบ ซึ่งทำให้ UI ดูไม่คลีน
- **วิธีการแก้ไข:** ปรับปรุง UI โดยเปลี่ยนจากการใช้ `labelText` มาเป็น `hintText` แทน พร้อมตั้งค่าขอบด้วย `OutlineInputBorder` สีเทาอ่อน เพื่อให้ได้ดีไซน์ที่เรียบง่ายและเป็นมิตรกับผู้ใช้งานมากขึ้น

 Tech Stack
- **Framework:** Flutter (Dart)
- **Backend/Database:** Firebase Realtime Database
- **Networking:** `http` package (REST API Integration)


## ผลลัพธ์การทำงานของแอป


## โครงสร้าง

<p align="center">
<img width="317" height="385" alt="โครงสร้าง" src="https://github.com/user-attachments/assets/a2447458-bbdf-4fe3-a299-04bdead1d622" />
</p>


---

## grocery_list

<p align="center">
lign="center">
<imga<img width="709" height="1435" alt="grocery_list" src="https://github.com/user-attachments/assets/8d4142d7-a47c-4945-9494-dc30af1aa5c2")/>
</p>
![Uploading grocery_list.png…]()

---

## หน้า new_item

<p align="center">
<img width="709" height="1440" alt="new_item" src="https://github.com/user-attachments/assets/4bd5f68e-bd06-4841-913c-b63752de21d2" />
</p>

---

## หน้า การเดาชื่อสินค้า

<p align="center">
<img width="705" height="1429" alt="การเดาชื่อสินค้า" src="https://github.com/user-attachments/assets/d4a5f8ac-bf0d-469e-8ec7-8ca5979990cf" />
</p>

---


##  หน้า หมวดหมู่

<p align="center">
<img width="704" height="1431" alt=" หมวดหมู่" src="https://github.com/user-attachments/assets/b6d51cfa-708f-43a4-977f-50c8ee9d2bf0" />
</p>

---

## หน้า เลือก หมวดหมู่ อัตโมัตฺ

<p align="center">
<img width="691" height="1427" alt="เลือก หมวดหมู่ อัตโมัตฺ" src="https://github.com/user-attachments/assets/b2116004-2816-472b-bdfd-6a8f5cf0c97d" />
</p>


