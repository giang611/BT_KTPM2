@comments
Feature: Comment API Endpoints

  Background:
    # 1. Tạo thông tin user và post
    * def baseUrl = 'http://localhost:8080'
    * def userEmail = 'commenttest_' + java.util.UUID.randomUUID() + '@example.com'
    * def userPassword = 'password123'
    * def userName = 'Comment'
    * def userLastName = 'User'

    # 2. Đăng ký user mới
    Given url baseUrl + '/api/auth/register'
    And request { name: '#(userName)', lastName: '#(userLastName)', email: '#(userEmail)', password: '#(userPassword)' }
    When method POST
    Then status 200

    # 3. Đăng nhập để lấy TOKEN
    Given url baseUrl + '/api/auth/login'
    And request { email: '#(userEmail)', password: '#(userPassword)' }
    When method POST
    Then status 200
    * def authToken = response

    # 4. Giải mã token để lấy userId
    * def payload = authToken.split('.')[1]
    * def Base64 = Java.type('java.util.Base64')
    * def decoder = Base64.getUrlDecoder()
    * def decodedBytes = decoder.decode(payload)
    * def decodedString = new java.lang.String(decodedBytes, 'UTF-8')
    * json payloadJson = decodedString
    * def userId = payloadJson.user.id

    # 5. Cấu hình Header và URL
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + authToken)' }

    # 6. TẠO MỘT BÀI POST ĐỂ BÌNH LUẬN
    * def postDesc = 'Post to be commented on ' + java.util.UUID.randomUUID()
    Given path '/api/posts/add'
    And request { userId: '#(userId)', description: '#(postDesc)' }
    When method POST
    Then status 201
    * def postId = response

  Scenario: Create, Get All By Post, and Delete a Comment

    # 1. Tạo comment (POST /api/comments/add)
    * def commentText = 'My first comment! ' + java.util.UUID.randomUUID()
    Given path '/api/comments/add'
    And request { postId: '#(postId)', userId: '#(userId)', text: '#(commentText)' }
    When method POST
    Then status 201
    And match response == "Added"

    # 2. Lấy comment ID
    Given path '/api/comments/getallbypost', postId + ''
    When method GET
    Then status 200
    * def commentId = response[0].id

    # 3. Lấy tất cả comment cho bài post
    Given path '/api/comments/getallbypost', postId + ''
    When method GET
    Then status 200
    # SỬA LỖI: Dùng biến commentId (SỐ), không dùng chuỗi 'commentId'
    And match response[*].id contains commentId

