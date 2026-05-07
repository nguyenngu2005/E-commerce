import java.sql.*;

public class InsertComparison {
    public static void main(String[] args) {
        // --- THÔNG TIN KẾT NỐI (Chỉnh sửa tại đây) ---
        System.setProperty("user.timezone", "UTC");
        String url = "jdbc:postgresql://localhost:5433/ecommerce";
        String user = "postgres";
        String pass = "12345";
        int totalRecords = 100000;
        int batchSize = 1000;

        try (Connection conn = DriverManager.getConnection(url, user, pass)) {
            System.out.println("=== BẮT ĐẦU THỰC NGHIỆM ===");

            // --- KỊCH BẢN 1: SINGLE INSERT ---
            // Bước 1: Truncate sạch bảng trước khi chạy Single
            truncateTable(conn);

            System.out.println("Đang chạy Single Insert...");
            long startSingle = System.currentTimeMillis();
            runSingleInsert(conn, totalRecords);
            long timeSingle = System.currentTimeMillis() - startSingle;

            // Kiểm tra số lượng sau khi chạy Single
            long countSingle = getRowCount(conn);
            System.out.println("-> Hoàn thành Single. Số dòng trong DB: " + countSingle);

            // --- KỊCH BẢN 2: BATCH PROCESSING ---
            // Bước 2: Truncate sạch bảng trước khi chạy Batch
            truncateTable(conn);

            System.out.println("Đang chạy Batch Processing...");
            long startBatch = System.currentTimeMillis();
            runBatchInsert(conn, totalRecords, batchSize);
            long timeBatch = System.currentTimeMillis() - startBatch;

            // Kiểm tra số lượng sau khi chạy Batch
            long countBatch = getRowCount(conn);
            System.out.println("-> Hoàn thành Batch. Số dòng trong DB: " + countBatch);

            // --- IN KẾT QUẢ TỔNG HỢP ---
            System.out.println("\n========================================");
            System.out.println("BÁO CÁO HIỆU NĂNG (" + totalRecords + " dòng):");
            System.out.println("- Single Insert    : " + timeSingle + " ms");
            System.out.println("- Batch Processing : " + timeBatch + " ms");
            System.out.println("- Tốc độ cải thiện : " + (timeSingle / timeBatch) + " lần");
            System.out.println("========================================\n");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Hàm xóa sạch dữ liệu và reset ID tự tăng (SERIAL) về 1
    private static void truncateTable(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement()) {
            // RESTART IDENTITY giúp ID bắt đầu lại từ 1 cho mỗi lần test
            st.execute("TRUNCATE TABLE test_insert RESTART IDENTITY");
            System.out.println("[System] Đã Truncate bảng test_insert.");
        }
    }

    // Hàm đếm số dòng thực tế trong Database
    private static long getRowCount(Connection conn) throws SQLException {
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT count(*) FROM test_insert")) {
            if (rs.next()) return rs.getLong(1);
        }
        return 0;
    }

    private static void runSingleInsert(Connection conn, int total) throws SQLException {
        String sql = "INSERT INTO test_insert (value) VALUES (?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= total; i++) {
                ps.setInt(1, 1); // Gán giá trị 1 cho Single
                ps.executeUpdate();
            }
        }
    }

    private static void runBatchInsert(Connection conn, int total, int size) throws SQLException {
        conn.setAutoCommit(false);
        String sql = "INSERT INTO test_insert (value) VALUES (?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            for (int i = 1; i <= total; i++) {
                ps.setInt(1, 2); // Gán giá trị 2 cho Batch
                ps.addBatch();
                if (i % size == 0) {
                    ps.executeBatch();
                    conn.commit();
                }
            }
            ps.executeBatch();
            conn.commit();
        }
        conn.setAutoCommit(true);
    }
}
