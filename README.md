
# 🎨 LINE 貼圖製作工具（前後端分離 + API 架構）

這是一套使用前後端分離架構設計的 LINE 貼圖製作工具。前端提供直覺化圖片編輯介面，後端則提供一組 RESTful API 處理圖片相關操作，適合導入至貼圖製作、個人化影像服務、SaaS 平台等應用。

---

## 📁 專案結構

```
line-sticker-tool/
│
├── backend/                      # ASP.NET Core API 專案
│   ├── Controllers/
│   │   └── StickerController.cs      # 處理各種圖片功能的 API 端點
│   ├── Services/
│   │   └── ImageProcessingService.cs # 調用 ImageToolkit.dll 的核心邏輯
│   ├── Models/
│   │   └── CropRequest.cs 等模型      # 各功能所需的請求資料結構
│   ├── Program.cs
│   └── appsettings.json
│
├── frontend/                     # 前端靜態頁面
│   ├── index.html
│   ├── js/
│   │   └── main.js                  # 操作邏輯，與 API 溝通
│   ├── css/
│   │   └── style.css
│   └── templates/
│       └── cropToolOptions.html 等  # 工具面板模板
│
├── shared/                       # 共用程式庫
│   ├── ImageToolkit/             # C# 封裝模組原始碼
│   │   ├── Extensions.cs
│   │   ├── ImageEditor.cs
│   │   └── ImageToolkit.csproj
│   └── ImageToolkit.dll          # 編譯後 DLL，可供多專案共用
│
└── README.md
```

---

## ⚙️ 功能介紹

- ✅ 圖片上傳與預覽
- ✅ 裁剪指定區域
- ✅ 調整圖片大小
- ✅ 旋轉任意角度
- ✅ 亮度/對比度調整
- ✅ 自動去背（透明背景處理）
- ✅ 貼圖輸出為符合 LINE Creator Market 規格的 PNG

---

## 📡 後端 API 說明

| 方法 | 路徑                        | 說明                         |
|------|-----------------------------|------------------------------|
| POST | `/api/sticker/upload`       | 上傳圖片                    |
| POST | `/api/sticker/resize`       | 調整尺寸                    |
| POST | `/api/sticker/crop`         | 裁剪圖片                    |
| POST | `/api/sticker/rotate`       | 旋轉圖片                    |
| POST | `/api/sticker/brightness`   | 調整亮度                    |
| POST | `/api/sticker/contrast`     | 調整對比                    |
| POST | `/api/sticker/transparent`  | 背景透明處理                |
| GET  | `/api/sticker/export`       | 匯出圖片（回傳 Base64 PNG） |

---

## 🧩 ImageToolkit.dll 模組說明

此 DLL 封裝所有圖片處理邏輯，提供：

- `Resize()`
- `Crop()`
- `Rotate()`
- `AdjustBrightness()`
- `AdjustContrast()`
- `MakeBackgroundTransparent()`

### ✨ 優點

- 可於其他 C# 專案中共用（如桌面工具、雲端服務）
- 清晰接口，便於維護與擴充
- 可獨立單元測試與 CI 整合

---

## 🚀 快速啟動

### ▶️ 啟動後端

```bash
cd backend/
dotnet run
```

API 將於 http://localhost:5000 提供服務。

### 🌐 開啟前端

直接開啟瀏覽器打開：

```
frontend/index.html
```

前端會透過 `fetch()` 呼叫後端 API。

---

## 📦 延伸應用與擴充

| 模組              | 說明                                          |
|-------------------|-----------------------------------------------|
| ImageToolkit.dll  | 後端圖片邏輯模組，可供其他服務共用            |
| 多語系 UI 支援     | 使用 i18n 管理國際化                          |
| 身份驗證整合       | LINE Login / Google OAuth 支援                |
| 雲端儲存整合       | 匯出貼圖可上傳至 S3、Azure Blob、Google Drive |
| 可視化任務佇列     | 整合 Hangfire / Quartz.NET 處理大量任務       |

---

## 🛡️ 限制與注意事項

- 圖片上傳大小限制：5MB 以下
- 支援格式：PNG、JPG、WEBP
- 匯出尺寸符合 LINE 標準尺寸（如 370x320）

---

## 📄 LICENSE

MIT License 自由使用與修改，歡迎商用與二次開發。

---

## 📬 聯絡與支援

📧 jaywu3272@gmail.com  
📱 接案 / 客製化整合 / 教學諮詢歡迎聯繫
