# Chính sách phân phối tài liệu LENLAB

Ngày: 07/11/2026. Đây là chính sách chọn file, không xác nhận quyền public toàn bộ tài sản dự án.

`docs/` mặc định không track. Root `.gitignore` chỉ mở từng đường dẫn Markdown đã rà soát: scope/cleanup, bản đồ code, reports P0/P1, audit/roadmap và backend-design draft. Không dùng ngoại lệ `!docs/**/*.md`; file mới phải được rà soát rồi whitelist tường minh.

- Markdown được chọn không có mẫu key/token phổ biến qua quét heuristic; email demo ở batch 1 thuộc example.com. Proposal vẫn giữ DRAFT/PROPOSED, không được coi là policy đã duyệt.
- `PART-1.md`: nhật ký lịch sử dài và thông tin demo cũ, giữ local để tránh hiểu nhầm trạng thái hiện tại.
- `FE-SCOPE-CLEANUP-FILES.md`, `FE-SCOPE-CLEANUP-MANIFEST.json`: inventory nội bộ có đường dẫn local, giữ local.
- DOCX/PDF gốc giữ local do chưa rõ quyền phân phối. Bốn DOCX đã quét text XML, chưa thấy mẫu secret phổ biến; chưa chứng nhận metadata/ảnh/attachments. PDF chưa trích xuất/rà soát nội dung đầy đủ. Không file gốc nào được whitelist.
- Link lịch sử tới bản gốc/inventory bị exclude có thể chỉ mở ở workspace nội bộ. Người clone dùng README/scope/audit/roadmap; bản gốc cần chủ dự án cấp quyền riêng.
- URL Figma không có token không phải credential; quyền phân phối thiết kế/ảnh vẫn cần xác nhận trước repo public. `.design/assets.json` là manifest bảo trì local, không công khai mặc định.

Không đưa keys, URL ký/token, credential thật, signing files, dữ liệu khách thật hoặc profile cá nhân vào Markdown. `.env.example` chỉ giữ placeholder. Ignore không bảo vệ file đã track ở repo khác: khi có history/index phải kiểm lại trước push.

Các báo cáo rà soát Git là tài liệu nội bộ, được giữ local và ignore theo từng đường dẫn; không phải đầu vào cần thiết để clone/chạy FE mock. Whitelist công khai được ghi tường minh trong root `.gitignore`. Việc không public báo cáo không giải quyết các điểm còn chờ về license, quyền phân phối ảnh/dữ liệu hoặc kiểm chứng clean clone.
