# E-commerce
# Database Schema Design for Big Data Analytics

## 1. Giới thiệu tổng quan
Hệ thống lưu trữ dữ liệu đơn hàng được thiết kế theo mô hình **Dimensional Modeling** (Star Schema), tối ưu cho các tác vụ xử lý dữ liệu lớn (Big Data), báo cáo phân tích và tính toán song song. 

Hệ thống ưu tiên **Hiệu suất ghi (Write-Throughput)** và **Khả năng mở rộng (Scalability)** bằng cách lược bỏ các ràng buộc khóa ngoại (Foreign Key) vật lý và áp dụng kỹ thuật phân vùng dữ liệu (Data Partitioning).

---

## 2. Kiến trúc Data Model

### 2.1. Dimension Tables (Bảng chiều)
- **`users`**: Lưu trữ thông tin định danh khách hàng.
- **`products`**: Danh mục sản phẩm và thông tin giá niêm yết.

### 2.2. Fact Tables (Bảng sự kiện)
- **`orders`**: Bảng tổng hợp giao dịch, được phân vùng theo thời gian.
- **`order_items`**: Chi tiết từng dòng hàng trong đơn hàng (Grain thấp nhất).

---

## 3. Chi tiết Schema

### Bảng: `users`
| Column | Type | Description |
| :--- | :--- | :--- |
| `user_id` | SERIAL (PK) | Định danh duy nhất của người dùng |
| `username` | VARCHAR(50) | Tên đăng nhập |
| `email` | VARCHAR(100) | Địa chỉ email |
| `created_at` | TIMESTAMP | Thời điểm tạo tài khoản |

### Bảng: `products`
| Column | Type | Description |
| :--- | :--- | :--- |
| `product_id` | SERIAL (PK) | Định danh duy nhất của sản phẩm |
| `product_name` | VARCHAR(255) | Tên sản phẩm |
| `price` | DECIMAL(10,2) | Giá bán hiện tại |
| `category` | VARCHAR(50) | Phân loại ngành hàng |

### Bảng: `orders` (Partitioned)
*Lưu ý: Khóa chính bao gồm cả cột phân vùng để tối ưu hóa truy vấn theo thời gian.*
| Column | Type | Description |
| :--- | :--- | :--- |
| `order_id` | SERIAL | ID đơn hàng |
| `user_id` | INT | Tham chiếu đến người dùng (Logical FK) |
| `order_date` | TIMESTAMP | **Partition Key** - Thời điểm đặt hàng |
| `total_amount` | DECIMAL(10,2) | Tổng giá trị đơn hàng |

---

## 4. Chiến lược Phân vùng (Partitioning Strategy)

Dữ liệu bảng `orders` được phân vùng theo **Range Partitioning** dựa trên cột `order_date`. Điều này cho phép:
1. **Partition Pruning**: Cơ sở dữ liệu chỉ quét các phân vùng cần thiết khi truy vấn theo thời gian, giảm đáng kể I/O.
2. **Data Lifecycle Management**: Dễ dàng lưu trữ (archive) hoặc xóa bỏ dữ liệu cũ theo từng năm mà không ảnh hưởng đến toàn bộ hệ thống.

**Các phân vùng hiện tại:**
- `orders_2024`: Chứa dữ liệu từ `2024-01-01` đến trước `2025-01-01`.
- `orders_2025`: Chứa dữ liệu từ `2025-01-01` đến trước `2026-01-01`.

---

## 5. Đặc thù Big Data & Tối ưu hóa

### 5.1. No Physical Constraints
Để đạt tốc độ nạp dữ liệu (Ingestion Rate) cao nhất, hệ thống **không sử dụng Foreign Key Constraints**. 
- **Lợi ích**: Giảm overhead kiểm tra ràng buộc khi nạp hàng triệu dòng dữ liệu cùng lúc.
- **Xử lý**: Tính toàn vẹn dữ liệu được đảm bảo ở tầng **ETL Pipeline** hoặc **Application Logic**.

### 5.2. Query Optimization
- Mặc dù không có FK, các cột `user_id` và `product_id` nên được đánh **Index** để tối ưu hóa các phép JOIN trong môi trường phân tích.
- Khuyến khích sử dụng các câu lệnh truy vấn có kèm theo điều kiện lọc `order_date` để tận dụng tối đa sức mạnh của phân vùng.

---

## 6. Hướng dẫn khởi tạo (SQL)
*(Đính kèm mã nguồn SQL khởi tạo schema đã cung cấp ở các bước trước)*
```sql
-- Xem file script đính kèm để biết chi tiết cấu trúc CREATE TABLE
