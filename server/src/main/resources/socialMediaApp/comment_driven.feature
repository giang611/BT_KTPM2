@comments-datadriven
Feature: Comment API Endpoints (Data Driven)

  Background:
    # --- CÁC BƯỚC TẠO USER GIỮ NGUYÊN ---
    * def baseUrl = 'http://localhost:8080'
    * def userEmail = 'test_' + java.util.UUID.randomUUID() + '@example.com'
    * def userPassword = 'password123'
    * def userName = 'Comment'
    * def userLastName = 'User'

    Given url baseUrl + '/api/auth/register'
    And request { name: '#(userName)', lastName: '#(userLastName)', email: '#(userEmail)', password: '#(userPassword)' }
    When method POST
    Then status 200

    Given url baseUrl + '/api/auth/login'
    And request { email: '#(userEmail)', password: '#(userPassword)' }
    When method POST
    Then status 200
    * def authToken = response

    # Giải mã token lấy userId
    * def payload = authToken.split('.')[1]
    * def Base64 = Java.type('java.util.Base64')
    * def decoder = Base64.getUrlDecoder()
    * def decodedBytes = decoder.decode(payload)
    * def decodedString = new java.lang.String(decodedBytes, 'UTF-8')
    * json payloadJson = decodedString
    * def userId = payloadJson.user.id

    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + authToken)' }

    * def postDesc = 'Post for testing comment ' + java.util.UUID.randomUUID()
    Given path '/api/posts/add'
    And request { userId: '#(userId)', description: '#(postDesc)' }
    When method POST
    Then status 201

    * def postId = response
  Scenario Outline: Create comments with various content types: <description>

    # 1. Tạo comment
    Given path '/api/comments/add'
    And request { postId: '#(postId)', userId: '#(userId)', description: '<commentContent>' }
    When method POST
    Then status 201
    And match response == "Added"

    # 2. Kiểm tra lại
    Given path '/api/comments/getallbypost', postId
    When method GET
    Then status 200

    # Kiểm tra trong danh sách trả về có chứa nội dung description vừa tạo không
    And match response[*].description contains '<commentContent>'

    Examples:
      | description           | commentContent                                  |
      | Simple Text           | Bai viet nay rat hay                            |
      | With Numbers          | Test user 123456                                |
      | Special Characters    | @#$%^&*()_+!                                    |