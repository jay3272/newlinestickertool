
# 📦 Line Sticker Tool - 系統規劃文件

## 🚧 第一階段：需求分析與規劃

| 步驟 | 任務內容                             | 備註                                  |
|------|--------------------------------------|---------------------------------------|
| 1    | 明確功能模組                         | 來自既有 JavaScript 功能              |
| 2    | 確認 API 設計（RESTful 結構）        | 使用 Swagger 做設計規範               |
| 3    | 設定專案結構（Backend / Frontend 分離） | 確保資料夾與 DLL 共用合理化         |
| 4    | 選定開發工具與框架                   | .NET 8, VS2022, npm 等現代開發工具     |

---

## 🥇 第一階段：核心圖像處理功能（MVP）
目標：重現既有 JavaScript 的功能，提供 API 能支援貼圖處理。

| 功能模組       | 說明                            | API Endpoint（建議）           |
|----------------|----------------------------------|--------------------------------|
| 圖片上傳       | 上傳圖片轉為可編輯格式            | `POST /api/sticker/upload`     |
| 裁切 (Crop)     | 選擇區域裁切                      | `POST /api/sticker/crop`       |
| 縮放 (Resize)   | 設定寬高縮放                      | `POST /api/sticker/resize`     |
| 旋轉 (Rotate)   | 任意角度旋轉                      | `POST /api/sticker/rotate`     |
| 亮度調整       | 增亮、變暗                        | `POST /api/sticker/brightness` |
| 對比度調整     | 增強或降低對比                    | `POST /api/sticker/contrast`   |
| 背景透明       | 清除背景色（白轉透明）            | `POST /api/sticker/transparent`|
| 匯出圖片       | 輸出圖片為 PNG 檔案              | `GET /api/sticker/export`      |

---

## 🥈 第二階段：常用圖像編輯擴充功能

| 功能模組         | 說明                                  | 建議 API Endpoint             |
|------------------|---------------------------------------|-------------------------------|
| 反轉 (Flip)       | 水平或垂直翻轉                        | `POST /api/sticker/flip`       |
| 模糊 (Blur)       | 模糊處理（高斯/平均）                | `POST /api/sticker/blur`       |
| 銳化 (Sharpen)     | 增加細節清晰度                        | `POST /api/sticker/sharpen`    |
| 色相 / 飽和度     | 調整顏色感覺（類 Instagram 效果）   | `POST /api/sticker/hsl`        |
| 灰階 / 懷舊色調   | 轉為灰階或加上懷舊棕色               | `POST /api/sticker/filters`    |
| 加邊框           | 加上指定寬度與顏色邊框                | `POST /api/sticker/border`     |
| 水印             | 加上自定浮水印（圖片或文字）          | `POST /api/sticker/watermark`  |

---

## 🥉 第三階段：進階應用與系統功能

| 功能模組               | 說明                                  | 建議 API Endpoint               |
|------------------------|---------------------------------------|----------------------------------|
| 批次處理 (Batch)        | 一次處理多張圖片                      | `POST /api/sticker/batch`        |
| 操作歷史 (Undo/Redo)   | 還原上一步、重做                     | `POST /api/sticker/undo/redo`    |
| 預覽產生器              | 即時預覽處理效果                      | `GET /api/sticker/preview`       |
| 儲存草稿 / 載入草稿     | 儲存處理中的圖片與設定                | `POST /api/sticker/draft/save`   |
| 樣板產生器              | 自定貼圖範本載入                      | `GET /api/sticker/template`      |

---

## 🛠️ 選定開發工具與框架

| 模組          | 技術 / 工具            | 說明與用途 |
|---------------|------------------------|------------|
| Backend       | ASP.NET Core 8.0       | 架設 Web API，呼叫圖像處理 DLL |
| Frontend      | Vanilla JS / HTML（可替 Vue/React） | 操作介面與 API 串接 |
| 共用函式庫    | .NET Class Library (ImageToolkit.dll) | 封裝圖像處理功能 |
| 語言 / 編譯器 | C# 12 / Roslyn         | 用於核心 DLL 與後端邏輯 |
| 開發環境      | Visual Studio 2022 / Rider | 開發與除錯 |
| 套件管理      | NuGet / npm            | 管理前後端依賴 |
| 圖像處理支援  | System.Drawing.Common / SkiaSharp | 常用圖像函式庫 |
| 測試工具      | xUnit / Postman / Swagger UI | 測試與 API 文件產生 |
| 國際化        | i18next / JSON 語系檔案 | 多語系支援 |
| 認證登入      | LINE Login / Google OAuth | 使用者登入授權 |
| API 文件      | Swagger / Swashbuckle  | 自動 API 文件 |
| 部署工具      | Docker / IIS / Azure   | 跨平台部署支援 |
