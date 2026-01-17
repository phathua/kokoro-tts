# Tài liệu tích hợp Kokoro TTS API với React

Tài liệu này hướng dẫn cách tích hợp các endpoint từ Kokoro TTS Space vào ứng dụng React sử dụng thư viện `@gradio/client`.

## 1. Cài đặt

Cài đặt thư viện client trong dự án React của bạn:

```bash
npm i -D @gradio/client
```

## 2. Các Endpoint khả dụng

Dựa trên mã nguồn `app.py`, dưới đây là các API endpoint chính được tự động tạo ra (do `api_name` được đặt mặc định theo tên hàm Python):

| Endpoint          | Chức năng                    | Input                               | Output            |
| ----------------- | ---------------------------- | ----------------------------------- | ----------------- |
| `/generate_first` | Tạo âm thanh TTS (Generate)  | `text`, `voice`, `speed`, `use_gpu` | `audio`, `tokens` |
| `/generate_all`   | Tạo âm thanh TTS dạng Stream | `text`, `voice`, `speed`, `use_gpu` | `audio` (chunks)  |
| `/tokenize_first` | Lấy danh sách phoneme tokens | `text`, `voice`                     | `tokens`          |
| `/predict`        | API rút gọn (chạy CPU)       | `text`, `voice`, `speed`            | `audio`           |

## 3. Hướng dẫn sử dụng trong React

### Kết nối Client

```javascript
import { Client } from "@gradio/client";

// Thay "LJKJHI/Kokoro-TTS" bằng tên Space thực tế của bạn nếu khác
const app = await Client.connect("LJKJHI/Kokoro-TTS");
```

### Ví dụ: Tạo giọng nói (Text to Speech)

Hàm này gọi endpoint `/generate_first` để chuyển văn bản thành âm thanh.

```javascript
import { useState } from "react";
import { Client } from "@gradio/client";

const TextToSpeech = () => {
  const [audioSrc, setAudioSrc] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleGenerate = async () => {
    setLoading(true);
    try {
      // 1. Kết nối đến Space
      const client = await Client.connect("LJKJHI/Kokoro-TTS");

      // 2. Gửi request đến endpoint "/generate_first"
      const result = await client.predict("/generate_first", {
        text: "Hello world, this is a test of Kokoro TTS.",
        voice: "af_heart", // Mã giọng đọc (xem bảng mã bên dưới)
        speed: 1, // Tốc độ: 0.5 - 2.0
        use_gpu: false, // True nếu Space có GPU, False nếu chạy CPU
      });

      // 3. Xử lý kết quả trả về
      // API trả về mảng dữ liệu: [AudioInfo, TokenString]
      // result.data[0] chứa thông tin file âm thanh (url, path, etc.)
      if (result.data && result.data[0]) {
        setAudioSrc(result.data[0].url);
      }

      console.log("Tokens:", result.data[1]); // Log các phoneme tokens
    } catch (error) {
      console.error("Lỗi tạo giọng nói:", error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <button onClick={handleGenerate} disabled={loading}>
        {loading ? "Đang tạo..." : "Đọc văn bản"}
      </button>

      {audioSrc && (
        <audio controls src={audioSrc} style={{ marginTop: "20px" }} />
      )}
    </div>
  );
};

export default TextToSpeech;
```

### Ví dụ: Lấy Phoneme Tokens (Phân tích ngữ âm)

```javascript
const getTokens = async (text) => {
  const client = await Client.connect("LJKJHI/Kokoro-TTS");
  const result = await client.predict("/tokenize_first", {
    text: text,
    voice: "af_heart",
  });

  return result.data[0]; // Trả về chuỗi token
};
```

## 4. Tham số đầu vào

### Mã Giọng Đọc (Voice Codes)

Dưới đây là các mã `voice` phổ biến bạn có thể dùng:

**Giọng Mỹ (US)**

- `af_heart`: 🇺🇸 🚺 Heart (Mặc định)
- `af_bella`: 🇺🇸 🚺 Bella
- `af_nicole`: 🇺🇸 🚺 Nicole
- `af_sky`: 🇺🇸 🚺 Sky
- `am_michael`: 🇺🇸 🚹 Michael
- `am_adam`: 🇺🇸 🚹 Adam

**Giọng Anh (UK)**

- `bf_emma`: 🇬🇧 🚺 Emma
- `bf_isabella`: 🇬🇧 🚺 Isabella
- `bm_george`: 🇬🇧 🚹 George
- `bm_lewis`: 🇬🇧 🚹 Lewis

### Tốc độ (Speed)

- Kiểu: `Number`
- Phạm vi: `0.5` đến `2.0`
- Mặc định: `1`

### GPU (Hardware)

- Kiểu: `Boolean`
- Nếu bạn deploy trên Space miễn phí (CPU Basic), hãy luôn để `use_gpu: false`.
- Nếu bạn nâng cấp lên GPU runtime, đặt `use_gpu: true` để tốc độ nhanh hơn.
