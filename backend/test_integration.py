"""
Integration Tests for Authentication Flow
Tests the complete signup → signin → get-session flow
"""

import os
import sys
import json
import requests
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:8000"
TEST_EMAIL = f"test_{datetime.now().timestamp()}@example.com"
TEST_PASSWORD = "TestPassword123!"
TEST_NAME = "Test User"

# Colors for output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def print_test(name):
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}TEST: {name}{RESET}")
    print(f"{BLUE}{'='*60}{RESET}")

def print_pass(msg):
    print(f"{GREEN}✓ PASS: {msg}{RESET}")

def print_fail(msg):
    print(f"{RED}✗ FAIL: {msg}{RESET}")

def print_info(msg):
    print(f"{YELLOW}ℹ INFO: {msg}{RESET}")

def print_request(method, url, data=None, headers=None):
    print(f"\n{YELLOW}REQUEST:{RESET}")
    print(f"  Method: {method}")
    print(f"  URL: {url}")
    if headers:
        print(f"  Headers: {json.dumps(headers, indent=2)}")
    if data:
        print(f"  Body: {json.dumps(data, indent=2)}")

def print_response(response):
    print(f"\n{YELLOW}RESPONSE:{RESET}")
    print(f"  Status: {response.status_code}")
    print(f"  Headers: {dict(response.headers)}")
    try:
        print(f"  Body: {json.dumps(response.json(), indent=2)}")
    except:
        print(f"  Body: {response.text}")

# ============================================
# TEST 1: Health Check
# ============================================
def test_health_check():
    print_test("Health Check")
    
    url = f"{BASE_URL}/health"
    print_request("GET", url)
    
    try:
        response = requests.get(url)
        print_response(response)
        
        if response.status_code == 200:
            print_pass("Health check passed")
            return True
        else:
            print_fail(f"Expected 200, got {response.status_code}")
            return False
    except Exception as e:
        print_fail(f"Connection failed: {str(e)}")
        return False

# ============================================
# TEST 2: Signup
# ============================================
def test_signup():
    print_test("Signup - Create New User")
    
    url = f"{BASE_URL}/api/auth/sign-up/email"
    data = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD,
        "name": TEST_NAME
    }
    print_request("POST", url, data)
    
    try:
        response = requests.post(url, json=data)
        print_response(response)
        
        if response.status_code == 200:
            result = response.json()
            
            # Validate response structure
            required_fields = ["id", "email", "name", "token", "expires_at"]
            missing_fields = [f for f in required_fields if f not in result]
            
            if missing_fields:
                print_fail(f"Missing fields in response: {missing_fields}")
                return False, None
            
            # Validate response values
            if result["email"] != TEST_EMAIL:
                print_fail(f"Email mismatch: expected {TEST_EMAIL}, got {result['email']}")
                return False, None
            
            if result["name"] != TEST_NAME:
                print_fail(f"Name mismatch: expected {TEST_NAME}, got {result['name']}")
                return False, None
            
            if not result["token"]:
                print_fail("Token is empty")
                return False, None
            
            print_pass(f"Signup successful")
            print_info(f"User ID: {result['id']}")
            print_info(f"Token: {result['token'][:50]}...")
            
            return True, result
        else:
            print_fail(f"Expected 200, got {response.status_code}")
            return False, None
    except Exception as e:
        print_fail(f"Request failed: {str(e)}")
        return False, None

# ============================================
# TEST 3: Get Session After Signup
# ============================================
def test_get_session_after_signup(signup_result):
    print_test("Get Session - After Signup (Should Work)")
    
    if not signup_result:
        print_fail("No signup result to test")
        return False
    
    token = signup_result["token"]
    url = f"{BASE_URL}/api/auth/get-session"
    headers = {
        "Authorization": f"Bearer {token}"
    }
    print_request("GET", url, headers=headers)
    
    try:
        response = requests.get(url, headers=headers)
        print_response(response)
        
        if response.status_code == 200:
            result = response.json()
            
            # Validate response structure
            required_fields = ["id", "user_id", "token", "expires_at", "created_at"]
            missing_fields = [f for f in required_fields if f not in result]
            
            if missing_fields:
                print_fail(f"Missing fields in response: {missing_fields}")
                return False
            
            print_pass("Get session successful after signup")
            print_info(f"Session ID: {result['id']}")
            print_info(f"User ID: {result['user_id']}")
            
            return True
        elif response.status_code == 404:
            print_fail("Session not found (404) - This is the bug!")
            print_info("The signup endpoint doesn't create a session record in the database")
            return False
        elif response.status_code == 401:
            print_fail("Unauthorized (401) - Token issue")
            return False
        else:
            print_fail(f"Expected 200, got {response.status_code}")
            return False
    except Exception as e:
        print_fail(f"Request failed: {str(e)}")
        return False

# ============================================
# TEST 4: Signin
# ============================================
def test_signin():
    print_test("Signin - Login with Credentials")
    
    url = f"{BASE_URL}/api/auth/sign-in/email"
    data = {
        "email": TEST_EMAIL,
        "password": TEST_PASSWORD
    }
    print_request("POST", url, data)
    
    try:
        response = requests.post(url, json=data)
        print_response(response)
        
        if response.status_code == 200:
            result = response.json()
            
            # Validate response structure
            required_fields = ["id", "email", "token", "expires_at"]
            missing_fields = [f for f in required_fields if f not in result]
            
            if missing_fields:
                print_fail(f"Missing fields in response: {missing_fields}")
                return False, None
            
            print_pass("Signin successful")
            print_info(f"User ID: {result['id']}")
            print_info(f"Token: {result['token'][:50]}...")
            
            return True, result
        else:
            print_fail(f"Expected 200, got {response.status_code}")
            return False, None
    except Exception as e:
        print_fail(f"Request failed: {str(e)}")
        return False, None

# ============================================
# TEST 5: Get Session After Signin
# ============================================
def test_get_session_after_signin(signin_result):
    print_test("Get Session - After Signin (Should Work)")
    
    if not signin_result:
        print_fail("No signin result to test")
        return False
    
    token = signin_result["token"]
    url = f"{BASE_URL}/api/auth/get-session"
    headers = {
        "Authorization": f"Bearer {token}"
    }
    print_request("GET", url, headers=headers)
    
    try:
        response = requests.get(url, headers=headers)
        print_response(response)
        
        if response.status_code == 200:
            result = response.json()
            print_pass("Get session successful after signin")
            print_info(f"Session ID: {result['id']}")
            return True
        else:
            print_fail(f"Expected 200, got {response.status_code}")
            return False
    except Exception as e:
        print_fail(f"Request failed: {str(e)}")
        return False

# ============================================
# TEST 6: Invalid Token
# ============================================
def test_invalid_token():
    print_test("Get Session - Invalid Token (Should Fail)")
    
    url = f"{BASE_URL}/api/auth/get-session"
    headers = {
        "Authorization": "Bearer invalid_token_here"
    }
    print_request("GET", url, headers=headers)
    
    try:
        response = requests.get(url, headers=headers)
        print_response(response)
        
        if response.status_code == 401:
            print_pass("Correctly rejected invalid token")
            return True
        else:
            print_fail(f"Expected 401, got {response.status_code}")
            return False
    except Exception as e:
        print_fail(f"Request failed: {str(e)}")
        return False

# ============================================
# TEST 7: No Token
# ============================================
def test_no_token():
    print_test("Get Session - No Token (Should Fail)")
    
    url = f"{BASE_URL}/api/auth/get-session"
    print_request("GET", url)
    
    try:
        response = requests.get(url)
        print_response(response)
        
        if response.status_code == 401:
            print_pass("Correctly rejected request without token")
            return True
        else:
            print_fail(f"Expected 401, got {response.status_code}")
            return False
    except Exception as e:
        print_fail(f"Request failed: {str(e)}")
        return False

# ============================================
# TEST 8: Duplicate Email
# ============================================
def test_duplicate_email():
    print_test("Signup - Duplicate Email (Should Fail)")
    
    url = f"{BASE_URL}/api/auth/sign-up/email"
    data = {
        "email": TEST_EMAIL,
        "password": "AnotherPassword123!",
        "name": "Another User"
    }
    print_request("POST", url, data)
    
    try:
        response = requests.post(url, json=data)
        print_response(response)
        
        if response.status_code == 409:
            print_pass("Correctly rejected duplicate email")
            return True
        else:
            print_fail(f"Expected 409, got {response.status_code}")
            return False
    except Exception as e:
        print_fail(f"Request failed: {str(e)}")
        return False

# ============================================
# TEST 9: Wrong Password
# ============================================
def test_wrong_password():
    print_test("Signin - Wrong Password (Should Fail)")
    
    url = f"{BASE_URL}/api/auth/sign-in/email"
    data = {
        "email": TEST_EMAIL,
        "password": "WrongPassword123!"
    }
    print_request("POST", url, data)
    
    try:
        response = requests.post(url, json=data)
        print_response(response)
        
        if response.status_code == 401:
            print_pass("Correctly rejected wrong password")
            return True
        else:
            print_fail(f"Expected 401, got {response.status_code}")
            return False
    except Exception as e:
        print_fail(f"Request failed: {str(e)}")
        return False

# ============================================
# MAIN TEST RUNNER
# ============================================
def run_all_tests():
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}INTEGRATION TEST SUITE - Authentication Flow{RESET}")
    print(f"{BLUE}{'='*60}{RESET}")
    print(f"Base URL: {BASE_URL}")
    print(f"Test Email: {TEST_EMAIL}")
    
    results = {}
    
    # Test 1: Health Check
    results["health_check"] = test_health_check()
    if not results["health_check"]:
        print_fail("Backend is not running. Start it with: python -m uvicorn main:app --reload")
        return results
    
    # Test 2: Signup
    signup_pass, signup_result = test_signup()
    results["signup"] = signup_pass
    
    # Test 3: Get Session After Signup (BUG TEST)
    results["get_session_after_signup"] = test_get_session_after_signup(signup_result)
    
    # Test 4: Signin
    signin_pass, signin_result = test_signin()
    results["signin"] = signin_pass
    
    # Test 5: Get Session After Signin
    results["get_session_after_signin"] = test_get_session_after_signin(signin_result)
    
    # Test 6: Invalid Token
    results["invalid_token"] = test_invalid_token()
    
    # Test 7: No Token
    results["no_token"] = test_no_token()
    
    # Test 8: Duplicate Email
    results["duplicate_email"] = test_duplicate_email()
    
    # Test 9: Wrong Password
    results["wrong_password"] = test_wrong_password()
    
    # Print Summary
    print(f"\n{BLUE}{'='*60}{RESET}")
    print(f"{BLUE}TEST SUMMARY{RESET}")
    print(f"{BLUE}{'='*60}{RESET}")
    
    passed = sum(1 for v in results.values() if v)
    total = len(results)
    
    for test_name, result in results.items():
        status = f"{GREEN}PASS{RESET}" if result else f"{RED}FAIL{RESET}"
        print(f"  {test_name}: {status}")
    
    print(f"\n{BLUE}Total: {passed}/{total} tests passed{RESET}")
    
    if passed == total:
        print(f"{GREEN}✓ ALL TESTS PASSED!{RESET}")
    else:
        print(f"{RED}✗ SOME TESTS FAILED{RESET}")
    
    return results

if __name__ == "__main__":
    run_all_tests()
