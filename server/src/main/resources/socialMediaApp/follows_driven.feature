@follows-datadriven
Feature: Follow API Endpoints (Data Driven)

  Background:
    * def baseUrl = 'http://localhost:8080'
    * def Base64 = Java.type('java.util.Base64')
    * def decoder = Base64.getUrlDecoder()

  Scenario Outline: Follow and Unfollow flow: <followerName> -> <followedName>

    # --- 1. TẠO USER A (Người đi theo dõi) ---
    * def emailA = 'userA_' + java.util.UUID.randomUUID() + '@test.com'
    Given url baseUrl + '/api/auth/register'
    And request { name: '<followerName>', lastName: 'User', email: '#(emailA)', password: 'password123' }
    When method POST
    Then status 200

    # Đăng nhập User A lấy ID
    Given url baseUrl + '/api/auth/login'
    And request { email: '#(emailA)', password: 'password123' }
    When method POST
    Then status 200
    * def authTokenA = response
    * json payloadA = new java.lang.String(decoder.decode(authTokenA.split('.')[1]), 'UTF-8')
    * def userIdA = payloadA.user.id

    # --- 2. TẠO USER B (Người được theo dõi) ---
    * def emailB = 'userB_' + java.util.UUID.randomUUID() + '@test.com'
    Given url baseUrl + '/api/auth/register'
    And request { name: '<followedName>', lastName: 'User', email: '#(emailB)', password: 'password123' }
    When method POST
    Then status 200

    # Đăng nhập User B lấy ID
    Given url baseUrl + '/api/auth/login'
    And request { email: '#(emailB)', password: 'password123' }
    When method POST
    Then status 200
    * def authTokenB = response
    * json payloadB = new java.lang.String(decoder.decode(authTokenB.split('.')[1]), 'UTF-8')
    * def userIdB = payloadB.user.id

    # --- CẤU HÌNH HEADER CHO USER A ---
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + authTokenA)' }

    # --- 3. THỰC HIỆN FOLLOW ---
    Given path '/api/follows/add'
    # Kiểm tra lại model FollowRequest của bạn:
    # Nếu Java là private int userId; private int followingId; thì JSON dưới đây đúng.
    And request { userId: '#(userIdA)', followingId: '#(userIdB)' }
    When method POST
    Then status 200
    And match response == "Followed"

    # --- 4. THỰC HIỆN UNFOLLOW ---
    # Lưu ý: Controller của bạn dùng @PostMapping("/delete") chứ không phải DELETE method
    Given path '/api/follows/delete'
    And request { userId: '#(userIdA)', followingId: '#(userIdB)' }
    When method POST
    Then status 200
    And match response == "Unfollowed"

    # Dữ liệu test (Mỗi dòng tạo ra 1 cặp user mới để test)
    Examples:
      | followerName | followedName |
      | Alice        | Bob          |
      | John         | Jane         |
      | Naruto       | Sasuke       |