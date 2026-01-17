# Sử dụng Python 3.11 để tương thích tốt với Kokoro
FROM python:3.11-slim

# Thiết lập thư mục làm việc
WORKDIR /app

# Cài đặt các gói hệ thống cần thiết (espeak-ng cho TTS, git cho pip install git+...)
RUN apt-get update && apt-get install -y \
    espeak-ng \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy file requirements và cài đặt dependencies
COPY requirements.txt .
# Cài đặt thêm spaces (cần thiết cho Hugging Face Spaces compatibility) và numpy wheel nếu cần
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir spaces

# Copy toàn bộ mã nguồn vào image
COPY . .

# Tạo user non-root để chạy an toàn (Render khuyến nghị)
RUN useradd -m -u 1000 user
USER user
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Expose cổng (chỉ mang tính chất tài liệu, Render sẽ tự map)
EXPOSE 7860

# Lệnh chạy ứng dụng
CMD ["python", "app.py"]
