@posts
Feature: Post API Endpoints

  Background:
    # 1. Tạo thông tin user
    * def baseUrl = 'http://localhost:8080'
    * def userEmail = 'posttest_' + java.util.UUID.randomUUID() + '@example.com'
    * def userPassword = 'password123'
    * def userName = 'Post'
    * def userLastName = 'User'

    # 2. Đăng ký user mới
    Given url baseUrl + '/api/auth/register'
    And request { name: '#(userName)', lastName: '#(userLastName)', email: '#(userEmail)', password: '#(userPassword)' }
    When method POST
    Then status 200

    # 3. Đăng nhập để lấy TOKEN (dưới dạng String)
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

    # 5. Cấu hình Header và URL chính cho kịch bản
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + authToken)' }

  Scenario: Create, Get, GetAll, Delete, Confirm Delete

    # 1. Tạo post
    * def postDesc = 'My new post ' + java.util.UUID.randomUUID()
    Given path '/api/posts/add'
    And request { userId: '#(userId)', description: '#(postDesc)' }
    When method POST
    Then status 201
    * def postId = response
    * print 'CREATED POST ID =', postId

    # 2. Lấy post theo id
    Given path '/api/posts/getbyid/' + postId
    When method GET
    Then status 200
    * print 'GET POST RESPONSE =', response
    And match response.id == postId

    # 3. Lấy tất cả post và check có post vừa tạo
    Given path '/api/posts/getall'
    When method GET
    Then status 200
    * print 'GET ALL POSTS RESPONSE =', response
    * def found = response.find(p => p.id == postId)
    And match found != null

    # 4. Xóa post
    Given path '/api/posts/delete'
    And param id = postId
    When method DELETE
    Then status 200
