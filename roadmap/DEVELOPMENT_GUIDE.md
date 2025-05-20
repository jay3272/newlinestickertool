
# 🛠️ 開發指南：LINE 貼圖編輯工具

本指南為 LINE 貼圖編輯工具（後端 API + 前端分離 + 圖像處理 DLL）開發流程與建議步驟。

---

## ✅ 開發 Roadmap

### 🚧 第一階段：需求分析與規劃

| 步驟 | 任務內容                             | 備註                        |
|------|--------------------------------------|-----------------------------|
| 1    | 明確功能模組（裁切、縮放、亮度等）     | 來自既有 JavaScript 功能     |
| 2    | 確認 API 設計（RESTful 結構）          | 使用 Swagger 做設計規範     |
| 3    | 設定專案結構（Backend / Frontend 分離） | 確保資料夾與 DLL 共用合理化 |
| 4    | 選定開發工具與框架                    | .NET 8, VS2022, npm, etc.  |

---

### 🛠️ 第二階段：後端建置 (ASP.NET Core)

| 步驟 | 任務內容                                             | 備註                     |
|------|------------------------------------------------------|--------------------------|
| 1    | 建立 ASP.NET Core Web API 專案                        | 使用 `dotnet new webapi` |
| 2    | 引入 ImageToolkit.dll                                 | 放置於 shared 資料夾中   |
| 3    | 實作 `ImageProcessingService`（處理 DLL 操作邏輯）     | Resize, Crop, Brightness |
| 4    | 撰寫 Controller 端點（StickerController）             | 對應各種前端工具操作     |
| 5    | 撰寫 Models（CropRequest, ResizeRequest 等）         | 使用 DTO 傳輸資料        |
| 6    | 實作身分驗證（LINE Login / Google OAuth）             | 建議用 OAuth 2 + Middleware |
| 7    | 加入多語系支援（i18n JSON）                          | 回傳語系訊息 API         |

---

### 💻 第三階段：前端整合 (HTML/CSS/JS)

| 步驟 | 任務內容                                         | 備註                          |
|------|--------------------------------------------------|-------------------------------|
| 1    | 建立 index.html 與模組化的工具面板 template       | CropToolOptions.html 等       |
| 2    | 撰寫 main.js（改為使用 API 而非直接 Canvas 操作） | 使用 `fetch` 呼叫後端 API     |
| 3    | 加入語系切換功能（引入 i18n.js + 語言 JSON）      | 多語系 UI 展現                 |
| 4    | 加入登入邏輯（LINE Login / Google OAuth Redirect）| 使用 JS SDK 或 OAuth flow     |
| 5    | 處理 API 回傳資料並更新 Canvas / UI               | 使用 base64 或 BLOB 圖像     |

---

### 🧪 第四階段：測試與驗證

| 步驟 | 任務內容                              | 備註                  |
|------|---------------------------------------|-----------------------|
| 1    | 使用 Postman 或 Swagger 測試 API      | 確保 API 完整性與錯誤處理 |
| 2    | 單元測試（XUnit for Service）         | 對 Resize / Crop 等做單測 |
| 3    | 前端 E2E 測試（Playwright / Cypress） | 模擬整體流程           |
| 4    | 測試登入與語系切換                    | 多國語系驗證           |

---

### 🚀 第五階段：部署與上線

| 步驟 | 任務內容                               | 備註                              |
|------|----------------------------------------|-----------------------------------|
| 1    | 後端部署至 Azure / Linux / IIS          | 可使用 Docker 容器或 IIS + Kestrel |
| 2    | 前端部署到 GitHub Pages / Firebase     | 或使用 Azure Static Web Apps     |
| 3    | 設定環境變數與登入金鑰                 | 包含 OAuth Callback URLs          |
| 4    | 實際測試匯出 PNG 圖片                   | 確保透明背景/貼圖尺寸正確         |

---

## 📄 建議起始順序（重點）

```
1️⃣ 建立專案目錄架構（Shared / Backend / Frontend）
2️⃣ 撰寫 ImageToolkit.dll 與核心處理 Service
3️⃣ 建好 API Controller 對應功能
4️⃣ 撰寫前端 JS 串接 API 與顯示結果
5️⃣ 多語系與登入整合
6️⃣ 測試與修正
7️⃣ 部署與版本控管
```
