@posts-datadriven
Feature: Post API Endpoints (Data Driven)

  Background:
    # --- GIỮ NGUYÊN PHẦN SETUP USER VÀ TOKEN ---
    * def baseUrl = 'http://localhost:8080'
    # Tạo email ngẫu nhiên để mỗi dòng dữ liệu là một user mới (tránh conflict)
    * def userEmail = 'posttest_' + java.util.UUID.randomUUID() + '@example.com'
    * def userPassword = 'password123'
    * def userName = 'Post'
    * def userLastName = 'User'

    # 1. Đăng ký
    Given url baseUrl + '/api/auth/register'
    And request { name: '#(userName)', lastName: '#(userLastName)', email: '#(userEmail)', password: '#(userPassword)' }
    When method POST
    Then status 200

    # 2. Đăng nhập lấy Token
    Given url baseUrl + '/api/auth/login'
    And request { email: '#(userEmail)', password: '#(userPassword)' }
    When method POST
    Then status 200
    * def authToken = response

    # 3. Giải mã token lấy userId
    * def payload = authToken.split('.')[1]
    * def Base64 = Java.type('java.util.Base64')
    * def decoder = Base64.getUrlDecoder()
    * def decodedBytes = decoder.decode(payload)
    * def decodedString = new java.lang.String(decodedBytes, 'UTF-8')
    * json payloadJson = decodedString
    * def userId = payloadJson.user.id

    # 4. Config chung
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + authToken)' }

  # --- PHẦN DATA DRIVEN ---
  Scenario Outline: Create and Manage Post with content: <caseName>

    # 1. Tạo post với nội dung từ bảng Examples
    Given path '/api/posts/add'
    And request { userId: '#(userId)', description: '<description>' }
    When method POST
    Then status 201

    # Lấy ID trả về (đã confirm là trả về số nguyên)
    * def postId = response
    * print 'CREATED POST ID =', postId

    # 2. Lấy post theo id và kiểm tra nội dung
    Given path '/api/posts/getbyid/' + postId
    When method GET
    Then status 200
    * print 'GET POST RESPONSE =', response
    And match response.id == postId
    # Kiểm tra thêm: nội dung trả về phải khớp với nội dung gửi đi
    And match response.description == '<description>'

    # 3. Lấy tất cả post và check tồn tại
    Given path '/api/posts/getall'
    When method GET
    Then status 200

    # Tìm bài viết trong list trả về
    * def found = response.find(p => p.id == postId)
    And match found != null
    And match found.description == '<description>'

    # 4. Xóa post
    Given path '/api/posts/delete'
    And param id = postId
    When method DELETE
    Then status 200

    # 5. Xác nhận post đã xóa (Thường sẽ trả về 404 hoặc 500 tùy Backend xử lý Exception)
    # Nếu backend chưa handle exception "Not Found", chỗ này có thể cần sửa thành 500
    Given path '/api/posts/getbyid/' + postId
    When method GET
    Then status 404

    # Bảng dữ liệu test
    Examples:
      | caseName            | description                             |
      | Simple String       | Hello World this is my post             |
      | Special Char        | Post with special chars: @#$%^&*()      |
      | Vietnamese          | Xin chào, đây là bài viết Tiếng Việt    |
      | Numbers only        | 1234567890                              |
      | Very Long String    | This is a very long post content to test if the database can handle large text input correctly without truncation or errors. |