# language: zh-TW
功能: MongoDB 結構設計模式展示 API 測試

  背景:
    假設 測試的 API 服務主機為 "http://localhost:8080"

  場景: 應支援嵌入式文件模式 (Embedded Documents)
    當 我對 "/api/patterns/embedded" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "name": "Alice",                       |   "_id": "{createdUserId}",
        "address": {                           |   "name": "Alice",
          "city": "Taipei",                    |   "address": {
          "zip": "100"                         |     "city": "Taipei",
        }                                      |     "zip": "100"
      }                                        |   }
                                               | }
      """
    當 我對 "/api/patterns/embedded/query" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "id": "{createdUserId}"                |   "_id": "{createdUserId}",
      }                                        |   "name": "Alice",
                                               |   "address": {
                                               |     "city": "Taipei",
                                               |     "zip": "100"
                                               |   }
                                               | }
      """

  場景: 應支援引用模式 (References)
    當 我對 "/api/patterns/references/users" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "name": "Bob"                          |   "_id": "{createdUserId}",
                                               |   "name": "Bob"
      }                                        | }
      """
    當 我對 "/api/patterns/references/orders" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "userId": "{createdUserId}",           |   "_id": "{createdOrderId}",
        "amount": 500                          |   "userId": "{createdUserId}",
      }                                        |   "amount": 500
                                               | }
      """
    當 我對 "/api/patterns/references/orders/query" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "id": "{createdOrderId}"               |   "_id": "{createdOrderId}",
      }                                        |   "userId": {
                                               |     "_id": "{createdUserId}",
                                               |     "name": "Bob"
                                               |   },
                                               |   "amount": 500
                                               | }
      """

  場景: 應支援擴充引用模式 (Extended Reference Pattern)
    當 我對 "/api/patterns/extended-references/users" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "name": "Charlie"                      |   "_id": "{createdUserId}",
                                               |   "name": "Charlie"
      }                                        | }
      """
    當 我對 "/api/patterns/extended-references/orders" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "userId": "{createdUserId}",           |   "_id": "{createdOrderId}",
        "userName": "Charlie",                 |   "userId": "{createdUserId}",
        "amount": 800                          |   "userName": "Charlie",
      }                                        |   "amount": 800
                                               | }
      """
    當 我對 "/api/patterns/extended-references/orders/query" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "id": "{createdOrderId}"               |   "_id": "{createdOrderId}",
      }                                        |   "userId": "{createdUserId}",
                                               |   "userName": "Charlie",
                                               |   "amount": 800
                                               | }
      """

  場景: 應支援子集模式 (Subset Pattern)
    當 我對 "/api/patterns/subset/products" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "name": "iPhone"                       |   "_id": "{createdProductId}",
                                               |   "name": "iPhone",
                                               |   "recentReviews": []
      }                                        | }
      """
    當 我對 "/api/patterns/subset/reviews" 依序發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "productId": "{createdProductId}",     |   "review": {
        "user": "UserA",                       |     "_id": "{reviewId1}",
        "rating": 5,                           |     "productId": "{createdProductId}",
        "comment": "Great"                     |     "user": "UserA",
      }                                        |     "rating": 5,
                                               |     "comment": "Great"
                                               |   },
                                               |   "product": {
                                               |     "_id": "{createdProductId}",
                                               |     "name": "iPhone",
                                               |     "recentReviews": [
                                               |       {
                                               |         "_id": "{recentReviewId1}",
                                               |         "user": "UserA",
                                               |         "rating": 5
                                               |       }
                                               |     ]
                                               |   }
                                               | }
      ------------------------------------------------------------------------------------
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "productId": "{createdProductId}",     |   "review": {
        "user": "UserB",                       |     "_id": "{reviewId2}",
        "rating": 4,                           |     "productId": "{createdProductId}",
        "comment": "Nice"                      |     "user": "UserB",
      }                                        |     "rating": 4,
                                               |     "comment": "Nice"
                                               |   },
                                               |   "product": {
                                               |     "_id": "{createdProductId}",
                                               |     "name": "iPhone",
                                               |     "recentReviews": [
                                               |       {
                                               |         "_id": "{recentReviewId2}",
                                               |         "user": "UserB",
                                               |         "rating": 4
                                               |       },
                                               |       {
                                               |         "_id": "{recentReviewId1}",
                                               |         "user": "UserA",
                                               |         "rating": 5
                                               |       }
                                               |     ]
                                               |   }
                                               | }
      ------------------------------------------------------------------------------------
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "productId": "{createdProductId}",     |   "review": {
        "user": "UserC",                       |     "_id": "{lastReviewId}",
        "rating": 3,                           |     "productId": "{createdProductId}",
        "comment": "OK"                        |     "user": "UserC",
      }                                        |     "rating": 3,
                                               |     "comment": "OK"
                                               |   },
                                               |   "product": {
                                               |     "_id": "{createdProductId}",
                                               |     "name": "iPhone",
                                               |     "recentReviews": [
                                               |       {
                                               |         "_id": "{recentReviewId3}",
                                               |         "user": "UserC",
                                               |         "rating": 3
                                               |       },
                                               |       {
                                               |         "_id": "{recentReviewId2}",
                                               |         "user": "UserB",
                                               |         "rating": 4
                                               |       }
                                               |     ]
                                               |   }
                                               | }
      """

  場景: 應支援分桶模式 (Bucket Pattern)
    當 我對 "/api/patterns/bucket/measurements" 依序發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "sensorId": "A01",                     |   "_id": "{bucketId}",
        "date": "2026-09-21",                  |   "sensorId": "A01",
        "time": "10:00",                       |   "date": "2026-09-21",
        "temperature": 25.1                    |   "measurements": [
      }                                        |     {
                                               |       "_id": "{mId1}",
                                               |       "time": "10:00",
                                               |       "temperature": 25.1
                                               |     }
                                               |   ]
                                               | }
      ------------------------------------------------------------------------------------
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "sensorId": "A01",                     |   "_id": "{bucketId}",
        "date": "2026-09-21",                  |   "sensorId": "A01",
        "time": "10:01",                       |   "date": "2026-09-21",
        "temperature": 25.2                    |   "measurements": [
      }                                        |     {
                                               |       "_id": "{mId1}",
                                               |       "time": "10:00",
                                               |       "temperature": 25.1
                                               |     },
                                               |     {
                                               |       "_id": "{mId2}",
                                               |       "time": "10:01",
                                               |       "temperature": 25.2
                                               |     }
                                               |   ]
                                               | }
      """

  場景: 應支援屬性模式 (Attribute Pattern)
    當 我對 "/api/patterns/attributes" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "name": "Laptop",                      |   "_id": "{productId}",
        "attributes": [                        |   "name": "Laptop",
          { "k": "color", "v": "black" },      |   "attributes": [
          { "k": "ram", "v": "32GB" }          |     { "_id": "{attrId1}", "k": "color", "v": "black" },
        ]                                      |     { "_id": "{attrId2}", "k": "ram", "v": "32GB" }
      }                                        |   ]
                                               | }
      """
    當 我對 "/api/patterns/attributes/query" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {}                                       | [
                                               |   {
                                               |     "_id": "{productId}",
                                               |     "name": "Laptop",
                                               |     "attributes": [
                                               |       { "_id": "{attrId1}", "k": "color", "v": "black" },
                                               |       { "_id": "{attrId2}", "k": "ram", "v": "32GB" }
                                               |     ]
                                               |   }
                                               | ]
      """

  場景: 應支援多型模式 (Polymorphic Pattern)
    當 我對 "/api/patterns/polymorphic" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "type": "car",                         |   "_id": "{carId}",
        "doors": 4,                            |   "type": "car",
        "engine": "2.0"                        |   "doors": 4,
      }                                        |   "engine": "2.0"
                                               | }
      """
    當 我對 "/api/patterns/polymorphic" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "type": "motorcycle",                  |   "_id": "{motorcycleId}",
        "engine": "0.6",                       |   "type": "motorcycle",
        "hasSidecar": false                    |   "engine": "0.6",
      }                                        |   "hasSidecar": false
                                               | }
      """
    當 我對 "/api/patterns/polymorphic/query" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {}                                       | [
                                               |   {
                                               |     "_id": "{carId}",
                                               |     "type": "car",
                                               |     "doors": 4,
                                               |     "engine": "2.0"
                                               |   },
                                               |   {
                                               |     "_id": "{motorcycleId}",
                                               |     "type": "motorcycle",
                                               |     "engine": "0.6",
                                               |     "hasSidecar": false
                                               |   }
                                               | ]
      """

  場景: 應支援計算模式 (Computed Pattern)
    當 我對 "/api/patterns/computed/products" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "name": "Book"                         |   "_id": "{productId}",
                                               |   "name": "Book",
                                               |   "reviewCount": 0,
                                               |   "averageRating": 0,
                                               |   "totalSales": 0
      }                                        | }
      """
    當 我對 "/api/patterns/computed/reviews" 依序發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "productId": "{productId}",            |   "_id": "{productId}",
        "rating": 5                            |   "name": "Book",
      }                                        |   "reviewCount": 1,
                                               |   "averageRating": 5,
                                               |   "totalSales": 0
                                               | }
      ------------------------------------------------------------------------------------
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "productId": "{productId}",            |   "_id": "{productId}",
        "rating": 4                            |   "name": "Book",
      }                                        |   "reviewCount": 2,
                                               |   "averageRating": 4.5,
                                               |   "totalSales": 0
                                               | }
      """
    當 我對 "/api/patterns/computed/sales" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "productId": "{productId}",            |   "_id": "{productId}",
        "amount": 150                          |   "name": "Book",
      }                                        |   "reviewCount": 2,
                                               |   "averageRating": 4.5,
                                               |   "totalSales": 150
                                               | }
      """

  場景: 應支援綱要版本化模式 (Schema Versioning)
    當 我對 "/api/patterns/versioning" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "schemaVersion": 1,                    |   "_id": "{v1UserId}",
        "name": "Alice Chen"                   |   "schemaVersion": 1,
      }                                        |   "name": "Alice Chen"
                                               | }
      """
    當 我對 "/api/patterns/versioning" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "schemaVersion": 2,                    |   "_id": "{v2UserId}",
        "firstName": "Bob",                    |   "schemaVersion": 2,
        "lastName": "Wang"                     |   "firstName": "Bob",
      }                                        |   "lastName": "Wang"
                                               | }
      """
    當 我對 "/api/patterns/versioning/query" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "id": "{v1UserId}"                     |   "schemaVersion": 1,
      }                                        |   "fullName": "Alice Chen"
                                               | }
      """
    當 我對 "/api/patterns/versioning/query" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "id": "{v2UserId}"                     |   "schemaVersion": 2,
      }                                        |   "fullName": "Bob Wang"
                                               | }
      """

  場景: 應支援離群值模式 (Outlier Pattern)
    當 我對 "/api/patterns/outlier/users" 發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "name": "VIP-User"                     |   "_id": "{userId}",
                                               |   "name": "VIP-User",
                                               |   "items": [],
                                               |   "hasOverflow": false
      }                                        | }
      """
    當 我對 "/api/patterns/outlier/items" 依序發送 POST 請求，對照如下：
      """
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "userId": "{userId}",                  |   "user": {
        "item": "item-1"                       |     "_id": "{userId}",
      }                                        |     "name": "VIP-User",
                                               |     "items": ["item-1"],
                                               |     "hasOverflow": false
                                               |   }
                                               | }
      ------------------------------------------------------------------------------------
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "userId": "{userId}",                  |   "user": {
        "item": "item-2"                       |     "_id": "{userId}",
      }                                        |     "name": "VIP-User",
                                               |     "items": ["item-1", "item-2"],
                                               |     "hasOverflow": false
                                               |   }
                                               | }
      ------------------------------------------------------------------------------------
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "userId": "{userId}",                  |   "user": {
        "item": "item-3"                       |     "_id": "{userId}",
      }                                        |     "name": "VIP-User",
                                               |     "items": ["item-1", "item-2", "item-3"],
                                               |     "hasOverflow": false
                                               |   }
                                               | }
      ------------------------------------------------------------------------------------
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "userId": "{userId}",                  |   "user": {
        "item": "item-4"                       |     "_id": "{userId}",
      }                                        |     "name": "VIP-User",
                                               |     "items": ["item-1", "item-2", "item-3", "item-4"],
                                               |     "hasOverflow": false
                                               |   }
                                               | }
      ------------------------------------------------------------------------------------
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "userId": "{userId}",                  |   "user": {
        "item": "item-5"                       |     "_id": "{userId}",
      }                                        |     "name": "VIP-User",
                                               |     "items": ["item-1", "item-2", "item-3", "item-4", "item-5"],
                                               |     "hasOverflow": false
                                               |   }
                                               | }
      ------------------------------------------------------------------------------------
      REQ (Request)                            | RESP (Response)
      {                                        | {
        "userId": "{userId}",                  |   "user": {
        "item": "item-6"                       |     "_id": "{userId}",
      }                                        |     "name": "VIP-User",
                                               |     "items": ["item-1", "item-2", "item-3", "item-4", "item-5"],
                                               |     "hasOverflow": true
                                               |   },
                                               |   "overflow": {
                                               |     "_id": "{overflowId}",
                                               |     "userId": "{userId}",
                                               |     "items": ["item-6"]
                                               |   }
                                               | }
      """
