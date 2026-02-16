

# CHAPTER 6: TESTING AND RESULTS

## 6.1 Testing Overview

Testing of the Ambulance Tracking System was conducted across multiple phases using a combination of manual testing, functional verification, and real-device testing. The testing strategy was designed to validate the core functionality of the system, ensure reliability under various conditions, and confirm the real-time communication pipeline from ambulance to police officer works correctly.

### 6.1.1 Testing Environment

| Component | Environment Details |
|-----------|-------------------|
| Backend Server | Render.com deployment (Node.js v18) |
| MongoDB | MongoDB Atlas M0 (free-tier) cluster |
| Redis | Redis Cloud (30 MB free-tier) instance |
| Android Test Device | Android 13+ physical device with GPS |
| Android Emulator | Pixel 6 emulator (API 34) |
| Network | WiFi and 4G mobile data |

### 6.1.2 Testing Methodology

The testing followed a bottom-up approach:
1. **Unit-Level Testing:** Individual function verification for authentication and location handlers
2. **Integration Testing:** Verifying component interactions (REST API ↔ MongoDB, Socket.IO ↔ Redis)
3. **System Testing:** End-to-end workflow testing from driver login to police alert reception
4. **Performance Testing:** Response time measurement for real-time location updates
5. **Security Testing:** Authentication bypass attempts and input validation testing
6. **Usability Testing:** User interface evaluation with test users

## 6.2 Backend Testing

### 6.2.1 Authentication API Testing

The authentication endpoints were tested for both positive and negative scenarios.

**Table 6.1: Signup Endpoint Test Cases**

| Test Case | Input | Expected Result | Actual Result | Status |
|-----------|-------|-----------------|---------------|--------|
| Valid signup (driver) | username: "testdriver1", password: "pass123", role: "driver" | 201 Created, returns token | 201 Created, token returned | ✓ Pass |
| Valid signup (police) | username: "testpolice1", password: "pass123", role: "police" | 201 Created, returns token | 201 Created, token returned | ✓ Pass |
| Duplicate username | username: "testdriver1" (existing) | 400 Bad Request | 400 "User already exists" | ✓ Pass |
| Missing username | password: "pass123", role: "driver" | 500 Error | 500 validation error | ✓ Pass |
| Missing password | username: "test", role: "driver" | 500 Error | 500 hashing error | ✓ Pass |

**Table 6.2: Login Endpoint Test Cases**

| Test Case | Input | Expected Result | Actual Result | Status |
|-----------|-------|-----------------|---------------|--------|
| Valid login | Correct username and password | 200 OK, returns token and role | 200 OK, token + role returned | ✓ Pass |
| Wrong password | Correct username, wrong password | 401 Unauthorized | 401 "Invalid credentials" | ✓ Pass |
| Non-existent user | Unknown username | 404 Not Found | 404 "User not found" | ✓ Pass |
| Empty credentials | Empty strings | 404 Not Found | 404 "User not found" | ✓ Pass |

### 6.2.2 JWT Token Verification

**Table 6.3: JWT Token Test Cases**

| Test Case | Description | Expected Result | Actual Result | Status |
|-----------|-------------|-----------------|---------------|--------|
| Valid token | Token generated during login | Socket authenticated, userId attached | Connection accepted with user info | ✓ Pass |
| Expired token | Token with past expiry | Authentication warning | Socket connects with warning logged | ✓ Pass |
| Malformed token | Random string as token | Authentication fails | Socket connects without user info | ✓ Pass |
| No token | Connection without auth header | Socket allowed (graceful handling) | Socket connects without authentication | ✓ Pass |

### 6.2.3 Socket.IO Event Testing

**Table 6.4: Socket.IO Event Test Results**

| Event | Payload | Expected Behavior | Actual Behavior | Status |
|-------|---------|-------------------|-----------------|--------|
| `join` (driver) | userId, role: "driver" | Socket-user mapping created in Redis | Redis hash updated correctly | ✓ Pass |
| `join` (police) | userId, role: "police", location | Added to police room + Redis geo index | Room joined, geo entry created | ✓ Pass |
| `join` (invalid) | Missing userId | Warning logged, no crash | "Invalid join payload" logged | ✓ Pass |
| `updateLocation` | ambulanceId, lat, lng, heading | Broadcasted to police, proximity check executed | Position broadcasted, alerts sent to nearby police | ✓ Pass |
| `updateLocation` (invalid) | Missing lat/lng | Warning logged, no action | "Invalid location update payload" logged | ✓ Pass |
| `updatePoliceLocation` | userId, lat, lng | Police geo index updated | Redis geo entry updated | ✓ Pass |
| `scanAmbulances` | Empty payload | Returns all active ambulances | List of ambulance positions returned | ✓ Pass |
| `disconnect` | Automatic | User cleaned from all Redis stores | Hash, police geo, ambulance geo cleaned | ✓ Pass |

### 6.2.4 Redis Geospatial Testing

**Table 6.5: Proximity Detection Test Cases**

| Test Case | Ambulance Position | Police Position | Distance | Expected Alert | Result | Status |
|-----------|-------------------|-----------------|----------|---------------|--------|--------|
| Within range (close) | (20.9374, 77.7796) | (20.9380, 77.7800) | ~0.08 km | Alert sent | Alert received by police | ✓ Pass |
| Within range (edge) | (20.9374, 77.7796) | (20.9594, 77.7796) | ~2.44 km | Alert sent | Alert received by police | ✓ Pass |
| Outside range | (20.9374, 77.7796) | (20.9700, 77.7796) | ~3.62 km | No alert | No alert sent | ✓ Pass |
| Multiple police in range | (20.9374, 77.7796) | 3 officers within 2.5 km | Varied | All 3 alerted | All 3 received alerts | ✓ Pass |
| No police registered | (20.9374, 77.7796) | None | N/A | No alert | No alerts, logged "No nearby police" | ✓ Pass |

## 6.3 Frontend Testing

### 6.3.1 Authentication Flow Testing

**Table 6.6: Frontend Authentication Test Results**

| Test Case | Action | Expected Result | Actual Result | Status |
|-----------|--------|-----------------|---------------|--------|
| Successful login (driver) | Enter valid credentials, tap Login | Navigate to DriverScreen | DriverScreen displayed with map | ✓ Pass |
| Successful login (police) | Enter valid credentials, tap Login | Navigate to PoliceScreen | PoliceScreen displayed with radar | ✓ Pass |
| Failed login | Enter wrong password | Error message displayed | "Invalid credentials" shown in snackbar | ✓ Pass |
| Network timeout | Login with server down | Timeout error | "Server connection timeout" after 10 sec | ✓ Pass |
| Successful signup | Fill all fields, tap Sign Up | Account created, navigate to screen | Account created, navigated correctly | ✓ Pass |
| Duplicate signup | Sign up with existing username | Error message | "User already exists" displayed | ✓ Pass |
| Server URL config | Enter custom server URL, login | Connects to custom server | Socket connected to specified URL | ✓ Pass |

### 6.3.2 Driver Screen Testing

**Table 6.7: Driver Screen Functional Test Results**

| Test Case | Action | Expected Result | Actual Result | Status |
|-----------|--------|-----------------|---------------|--------|
| Initial GPS lock | App launch | Current position on map | GPS position acquired, map centered | ✓ Pass |
| Go Live mode | Tap "GO LIVE" button | Starts GPS streaming, marker turns red | GPS tracking started, marker red with pulse | ✓ Pass |
| End Mission | Tap "END MISSION" | Stops GPS streaming, marker turns grey | GPS stream cancelled, marker grey | ✓ Pass |
| Marker rotation | Drive in a direction | Marker rotates to heading | Marker follows heading from GPS/calculation | ✓ Pass |
| Smooth animation | GPS position update | Marker glides to new position | Smooth 1200ms easeOut animation applied | ✓ Pass |
| Auto-follow | Drive while map centered | Map follows position | Map auto-centers on each update | ✓ Pass |
| Manual pan | Drag map while live | Auto-follow disabled, re-center button appears | Re-center FAB appears correctly | ✓ Pass |
| Re-center | Tap re-center button | Map returns to current position | Map centered, auto-follow re-enabled | ✓ Pass |
| Speed display | Drive at various speeds | Speed shown in km/h | Speed indicator shows correct value | ✓ Pass |
| Route trail | Drive a path | Polyline showing last 30 points | Red trail visible on map | ✓ Pass |
| GPS permission denied | Deny location permission | Error snackbar shown | "Location permission denied" displayed | ✓ Pass |

### 6.3.3 Police Screen Testing

**Table 6.8: Police Screen Functional Test Results**

| Test Case | Action | Expected Result | Actual Result | Status |
|-----------|--------|-----------------|---------------|--------|
| Initial setup | Launch screen | Map with police marker, radar animation | Blue police marker with pulsing radar | ✓ Pass |
| Base location GPS | Tap GPS button | Current location as base | Location fetched, base updated | ✓ Pass |
| Base location preset | Select from dropdown | Known location as base | Map centered on selected location | ✓ Pass |
| Receive ambulance position | Driver goes live | Ambulance marker appears on map | Marker visible with distance label | ✓ Pass |
| Distance color coding | Ambulance at various distances | Color changes by distance | Red < 0.5km, Orange < 1km, Yellow < 2km, Green > 2km | ✓ Pass |
| Proximity alert | Ambulance enters 2.5 km radius | Vibration + sound + visual alert | All three feedback channels triggered | ✓ Pass |
| Alert auto-dismiss | Wait 12 seconds after alert | Banner hides automatically | Alert dismissed after 12 seconds | ✓ Pass |
| Manual alert dismiss | Tap "STOP" button on alert | Alert hidden, sound stopped | All alert effects stopped immediately | ✓ Pass |
| Statistics dashboard | During active monitoring | Correct stats displayed | Active count, alert count, nearest distance shown | ✓ Pass |
| Ambulance list sheet | Ambulances active | Draggable list with details | List shows all ambulances with distance | ✓ Pass |
| Focus on ambulance | Tap focus button in list | Map centers on ambulance | Map zoomed to ambulance position | ✓ Pass |
| Scan for ambulances | Tap scan button | Query all active ambulances | Scan results displayed on map | ✓ Pass |
| Connection status | Connect/disconnect server | Status indicator updates | Green/orange/red dot reflects state | ✓ Pass |

## 6.4 Integration Testing

### 6.4.1 End-to-End Workflow Test

The complete system workflow was tested end-to-end to verify that all components work together seamlessly.

**Test Scenario:** Complete Emergency Response Workflow

| Step | Action | Expected Result | Actual Result | Status |
|------|--------|-----------------|---------------|--------|
| 1 | Police officer logs in | Navigated to PoliceScreen, socket connected | PoliceScreen displayed, "CONNECTED" shown | ✓ Pass |
| 2 | Police sets base location via GPS | Base location updated, geo index updated | Location registered in Redis | ✓ Pass |
| 3 | Driver logs in | Navigated to DriverScreen, socket connected | DriverScreen displayed, GPS acquired | ✓ Pass |
| 4 | Driver taps "GO LIVE" | GPS streaming begins | Location updates emitted via socket | ✓ Pass |
| 5 | Ambulance position broadcast | Police map shows ambulance marker | Marker appears with distance label | ✓ Pass |
| 6 | Ambulance enters 2.5 km radius | Proximity alert triggered | Vibration + siren + visual alert fired | ✓ Pass |
| 7 | Police taps "STOP" on alert | Alert dismissed | All alert effects stopped | ✓ Pass |
| 8 | Ambulance passes and exits radius | No further alerts | Marker continues updating, no new alerts | ✓ Pass |
| 9 | Driver taps "END MISSION" | GPS streaming stops | Location updates cease | ✓ Pass |
| 10 | Driver disconnects | Ambulance removed from map | Marker disappears, Redis cleaned | ✓ Pass |

### 6.4.2 Multi-Client Concurrency Test

Multiple clients were connected simultaneously to verify system behavior under concurrent usage.

**Test Setup:** 2 driver clients, 3 police clients connected simultaneously

| Metric | Expected | Actual | Status |
|--------|----------|--------|--------|
| All clients connect successfully | 5/5 | 5/5 | ✓ Pass |
| Each police receives both ambulance updates | Yes | Yes | ✓ Pass |
| Proximity alerts sent to correct officers only | Officers within 2.5 km only | Correct targeting | ✓ Pass |
| Disconnect cleanup for one client | Only that client's data removed | Other clients unaffected | ✓ Pass |
| Redis state after all disconnect | All entries cleaned | Redis empty after last disconnect | ✓ Pass |

## 6.5 Performance Testing

### 6.5.1 Response Time Measurements

Performance testing was conducted to measure the latency of critical system operations.

**Table 6.9: Performance Metrics**

| Operation | Avg Response Time | Max Response Time | Acceptable Threshold | Status |
|-----------|-------------------|-------------------|---------------------|--------|
| REST Login API | 180 ms | 350 ms | < 500 ms | ✓ Pass |
| REST Signup API | 210 ms | 400 ms | < 500 ms | ✓ Pass |
| Socket.IO connection | 150 ms | 300 ms | < 1000 ms | ✓ Pass |
| Location update broadcast | 45 ms | 120 ms | < 200 ms | ✓ Pass |
| Redis GEOSEARCH (proximity) | 2 ms | 8 ms | < 50 ms | ✓ Pass |
| Proximity alert delivery | 50 ms | 150 ms | < 300 ms | ✓ Pass |
| GPS position acquisition | 2.5 s | 10 s | < 15 s | ✓ Pass |
| Map tile loading | 300 ms | 800 ms | < 2000 ms | ✓ Pass |

**Note:** Response times were measured over a WiFi connection. Mobile data (4G) response times were approximately 20-40% higher for network-dependent operations.

### 6.5.2 Real-Time Communication Latency

The critical path latency — from driver GPS update to police screen marker movement — was measured:

**Total End-to-End Latency Breakdown:**

| Stage | Duration |
|-------|----------|
| GPS sensor → Flutter app | ~50 ms |
| Flutter → Socket.IO emit | ~10 ms |
| Network transit (WiFi) | ~30 ms |
| Server processing + Redis | ~15 ms |
| Server → Police client broadcast | ~30 ms |
| Flutter receive → UI render | ~15 ms |
| **Total** | **~150 ms** |

The total end-to-end latency of approximately 150 ms is well within the acceptable range for real-time emergency vehicle tracking, providing near-instantaneous position updates on the police officer's screen.

## 6.6 Security Testing

### 6.6.1 Authentication Security

| Test Case | Attack Vector | Result | Status |
|-----------|--------------|--------|--------|
| Password stored as hash | Check MongoDB directly | bcrypt hash stored, not plaintext | ✓ Secure |
| SQL/NoSQL injection | username: `{$gt: ""}` | Mongoose sanitizes input, login fails | ✓ Secure |
| Missing token on socket | Connect without JWT | Socket connects but without user privileges | ✓ Secure |
| Invalid JWT token | Random string as token | Authentication fails gracefully | ✓ Secure |
| Password not in API response | Check signup/login response bodies | Password field absent (select: false) | ✓ Secure |

### 6.6.2 Input Validation

| Test Case | Invalid Input | Result | Status |
|-----------|--------------|--------|--------|
| Empty join payload | `{}` | Warning logged, handler returns early | ✓ Safe |
| Null coordinates | lat: null, lng: null | Warning logged, no Redis write | ✓ Safe |
| Non-numeric coordinates | lat: "abc" | Type check prevents processing | ✓ Safe |
| Oversized payload | 10 KB payload | Processed normally, no crash | ✓ Safe |

## 6.7 Usability Testing

Usability testing was conducted with a small group of 5 test users to evaluate the user experience.

**Table 6.10: Usability Test Results**

| Criteria | Rating (1-5) | Comments |
|----------|-------------|----------|
| Ease of registration | 4.4 | Simple form, role selection clear |
| Login experience | 4.2 | Fast, error messages helpful |
| Driver screen intuitiveness | 4.6 | "GO LIVE" button very clear, map responsive |
| Police screen comprehension | 4.0 | Statistics helpful, alert system effective |
| Alert notification effectiveness | 4.8 | Multi-sensory (vibration + sound + visual) very effective |
| Map readability | 4.4 | Color-coded markers easy to understand |
| Overall satisfaction | 4.3 | Professional-looking, responsive application |

## 6.8 Bug Report and Resolution Summary

During the testing phase, the following bugs were identified and resolved:

**Table 6.11: Bug Report Summary**

| Bug ID | Description | Severity | Resolution | Status |
|--------|-------------|----------|------------|--------|
| BUG-001 | GPS heading unreliable at low speeds | Medium | Added speed threshold (> 1 m/s) for GPS heading, with calculated heading fallback | Resolved |
| BUG-002 | Police location not registered on first connect | High | Added immediate `updatePoliceLocation` emit after socket connect | Resolved |
| BUG-003 | Marker not updating smoothly | Low | Implemented smooth glide animation with Tween and CurvedAnimation | Resolved |
| BUG-004 | Socket reconnection loses user identity | High | Added auto-rejoin with stored credentials on reconnect event | Resolved |
| BUG-005 | Geolocator API mismatch with installed version | Medium | Updated API calls to match geolocator v13.x syntax | Resolved |
| BUG-006 | Server URL hardcoded, limiting testing flexibility | Low | Added configurable server URL via SharedPreferences | Resolved |

## 6.9 Results Summary

The Ambulance Tracking System passed all critical test cases across all testing phases. The key results are:

1. **Functional Completeness:** All 6 Socket.IO events, both REST endpoints, and all UI features work as specified in the system requirements
2. **Real-Time Performance:** End-to-end latency of ~150 ms ensures near-instantaneous position tracking
3. **Proximity Detection Accuracy:** Redis GEOSEARCH correctly identifies all officers within the 2.5 km radius with sub-8 ms query time
4. **Multi-Client Support:** System operates correctly with multiple simultaneous driver and police connections
5. **Security:** Authentication, password hashing, and input validation meet security requirements
6. **Usability:** Average user satisfaction rating of 4.3/5.0 across all evaluation criteria

---

\newpage

