# MongoDB Schema Design Showcase

這個專案用來快速理解 MongoDB 10 種常見的 Schema 設計模式。不用啃厚厚的理論書，直接看 feature 檔最快！

---

## 💡 專案特色

### 1. 超直覺的「左 REQ 右 RESP」並排格式
為了讓大家看得舒服，這裡的 feature 檔採用獨特的**左右對照排版**。不用在長長的 JSON 裡滾來滾去，一眼就看懂輸入與輸出的結構對應：

```gherkin
REQ (Request)                            | RESP (Response)
{                                        | {
  "name": "Alice",                       |   "_id": "{createdUserId}",
  "address": {                           |   "name": "Alice",
    "city": "Taipei",                    |   "address": {
    "zip": "100"                         |     "city": "Taipei",
  }                                      |     "zip": "100"
}                                        |   }
                                         | }
```

### 2. 改完 code 點兩下馬上有結果
想試試看修改 Schema 或 API 邏輯？
1. 直接修改 `models.js` 或 `server.js`。
2. 執行根目錄的 **`run-tests.bat`**。
3. 它會自動啟動 Docker（內含 MongoDB & Express）、安裝套件並跑完 Cucumber 測試。
4. 跑完會停在視窗，**按任意鍵就能直接重跑**。你可以一邊修改、一邊無限循環驗證！

---

## 📂 10 大 MongoDB 設計模式直達車

直接點擊連結即可跳轉到 `mongodb_patterns.feature` 的對應行數，用看的直接學：

1. [嵌入式文件模式 (Embedded) `L7`](test/features/mongodb_patterns.feature#L7) — 適合一對一或簡單的一對多關係，讀取速度最快。
2. [引用模式 (References) `L33`](test/features/mongodb_patterns.feature#L33) — 傳統關聯式資料庫的外鍵做法，適合子文件會無限增長的場景。
3. [擴充引用模式 (Extended Reference) `L64`](test/features/mongodb_patterns.feature#L64) — 在主文件冗餘常用欄位，減少 JOIN 次數。
4. [子集模式 (Subset) `L94`](test/features/mongodb_patterns.feature#L94) — 只在主集合存最新幾筆子數據，舊數據分開存，解決一對多數量爆表問題。
5. [分桶模式 (Bucket) `L183`](test/features/mongodb_patterns.feature#L183) — IoT 或時間序列數據必用，按時段將多筆數據打包在同一個 Document 內。
6. [屬性模式 (Attribute) `L220`](test/features/mongodb_patterns.feature#L220) — 適合多規格的商品屬性，將不可預測的欄位化為統一的鍵值對陣列。
7. [多型模式 (Polymorphic) `L248`](test/features/mongodb_patterns.feature#L248) — 同集合放不同結構的文件，保留共通欄位、各文件自由擴充。
8. [計算模式 (Computed) `L288`](test/features/mongodb_patterns.feature#L288) — 將頻繁讀取的計算結果（如平均評分、銷量）先算好存起來，轉化為 $O(1)$ 讀取。
9. [綱要版本化 (Schema Versioning) `L332`](test/features/mongodb_patterns.feature#L332) — 在文件寫入 `schemaVersion`，讀取時由程式轉換，實現零停機更新。
10. [離群值模式 (Outlier) `L369`](test/features/mongodb_patterns.feature#L369) — 針對極少數的 VIP（如好友數特別多）進行超量分流儲存。

---

## 🛠️ 準備工作

你只需要：
* **Docker** & **Docker Compose** (跑資料庫與 API 服務)
* **Node.js** (在本地執行測試指令)

現在就雙擊 **`run-tests.bat`** 開始體驗吧！
