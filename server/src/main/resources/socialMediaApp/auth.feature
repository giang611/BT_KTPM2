@auth
Feature: Authentication API Endpoints

  # Cấu hình URL cơ sở
  Background:
    * url 'http://localhost:8080/api/auth'

  @debug
  Scenario:
    Given path 'ping'
    When method GET
    Then status 200
    And match response == "auth ok"

  Scenario: Register a new user successfully
    * def randomEmail = 'testuser_' + java.util.UUID.randomUUID() + '@example.com'

    Given path 'register'
    And request { name: 'Test', lastName: 'User', email: '#(randomEmail)', password: 'password123' }
    When method POST
    Then status 200
    And match response == '#string'
    And match response != ''

  Scenario: Attempt to register with a duplicate email
    * def duplicateEmail = 'duplicate_' + java.util.UUID.randomUUID() + '@example.com'
    * def userPayload = { name: 'Duplicate', lastName: 'User', email: '#(duplicateEmail)', password: 'password123' }

    # Lần 1: Đăng ký thành công
    Given path 'register'
    And request userPayload
    When method POST
    Then status 200

    # Lần 2: Đăng ký với cùng email
    Given path 'register'
    And request userPayload
    When method POST
    Then status 400
    And match response == "Email already exist"

  Scenario: Login successfully
    * def loginEmail = 'login_' + java.util.UUID.randomUUID() + '@example.com'
    * def loginPassword = 'securePassword'
    * def registerPayload = { name: 'Login', lastName: 'User', email: '#(loginEmail)', password: '#(loginPassword)' }

    # Bước 1: Đăng ký user
    Given path 'register'
    And request registerPayload
    When method POST
    Then status 200
    * print 'Registered user for login test: ', loginEmail

    # Bước 2: Đăng nhập
    Given path 'login'
    And request { email: '#(loginEmail)', password: '#(loginPassword)' }
    When method POST
    Then status 200
    * def authToken = response
    * print 'Auth Token: ', authToken
    And match authToken == '#string'

  Scenario: Attempt to login with bad credentials (wrong password)
    * def badPassEmail = 'badpass_' + java.util.UUID.randomUUID() + '@example.com'
    * def registerPayload = { name: 'Bad', lastName: 'Pass', email: '#(badPassEmail)', password: 'correctPassword' }

    # Bước 1: Đăng ký user
    Given path 'register'
    And request registerPayload
    When method POST
    Then status 200

    # Bước 2: Đăng nhập sai mật khẩu
    Given path 'login'
    And request { email: '#(badPassEmail)', password: 'wrongPassword' }
    When method POST
    Then status 401