@follows
Feature: Follow API Endpoints

  Background:
    # --- Cài đặt chung ---
    * def baseUrl = 'http://localhost:8080'
    * def Base64 = Java.type('java.util.Base64')
    * def decoder = Base64.getUrlDecoder()

    # --- TẠO USER A (Người theo dõi) ---
    * def userAEmail = 'follower_' + java.util.UUID.randomUUID() + '@example.com'
    * def userAPassword = 'password123'
    * def userAName = 'Follower'
    * def userALastName = 'User'

    Given url baseUrl + '/api/auth/register'
    And request { name: '#(userAName)', lastName: '#(userALastName)', email: '#(userAEmail)', password: '#(userAPassword)' }
    When method POST
    Then status 200

    Given url baseUrl + '/api/auth/login'
    And request { email: '#(userAEmail)', password: '#(userAPassword)' }
    When method POST
    Then status 200
    * def authTokenA = response
    * json payloadA = new java.lang.String(decoder.decode(authTokenA.split('.')[1]), 'UTF-8')
    * def userIdA = payloadA.user.id

    # --- TẠO USER B (Người được theo dõi) ---
    * def userBEmail = 'following_' + java.util.UUID.randomUUID() + '@example.com'
    * def userBPassword = 'password123'
    * def userBName = 'Following'
    * def userBLastName = 'User'

    Given url baseUrl + '/api/auth/register'
    And request { name: '#(userBName)', lastName: '#(userBLastName)', email: '#(userBEmail)', password: '#(userBPassword)' }
    When method POST
    Then status 200

    Given url baseUrl + '/api/auth/login'
    And request { email: '#(userBEmail)', password: '#(userBPassword)' }
    When method POST
    Then status 200
    * def authTokenB = response
    * json payloadB = new java.lang.String(decoder.decode(authTokenB.split('.')[1]), 'UTF-8')
    * def userIdB = payloadB.user.id

    # --- Cấu hình kịch bản ---
    * url baseUrl
    * configure headers = { Authorization: '#("Bearer " + authTokenA)' }

  Scenario: Follow and Unfollow a User

    # 1. User A theo dõi User B
    Given path '/api/follows/add'
    And request { userId: '#(userIdA)', followingId: '#(userIdB)' }
    When method POST
    Then status 200
    And match response == "Followed"

    # 2. User A hủy theo dõi User B
    Given path '/api/follows/delete'
    And request { userId: '#(userIdA)', followingId: '#(userIdB)' }
    When method POST
    Then status 200
    And match response == "Unfollowed"