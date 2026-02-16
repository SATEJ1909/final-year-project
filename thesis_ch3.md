
# CHAPTER 3: SYSTEM ANALYSIS AND REQUIREMENTS

## 3.1 Feasibility Study

Before undertaking the development of the Ambulance Tracking System, a comprehensive feasibility study was conducted to evaluate the viability of the project across four dimensions: technical, economic, operational, and scheduling.

### 3.1.1 Technical Feasibility

The technical feasibility assessment evaluated whether the required technologies, tools, and infrastructure were available and capable of meeting the project's requirements.

**Hardware Requirements:**
The ATS requires smartphones with GPS capabilities for both ambulance drivers and police officers. Modern smartphones (Android 5.0+ or iOS 11+) universally include GPS receivers capable of providing the required positioning accuracy (5-20 meters). The backend requires a standard server capable of running Node.js, MongoDB, and Redis — all of which have minimal hardware requirements and can be hosted on cloud platforms.

**Software Technologies:**
All technologies required for the ATS are mature, well-documented, and actively maintained:
- Node.js (JavaScript runtime) — Stable release, 20+ years of JavaScript ecosystem maturity
- TypeScript — Static typing for JavaScript, widely adopted in enterprise applications
- Express.js — The most widely used Node.js web framework
- Socket.IO — The industry standard for real-time WebSocket communication
- MongoDB — The most popular document database, with extensive documentation
- Redis — High-performance in-memory store with built-in geospatial commands
- Flutter — Google's cross-platform mobile framework, reaching maturity
- OpenStreetMap — Free, open-source mapping platform with global coverage

**Internet Connectivity:**
The system requires internet connectivity for both mobile clients and the server. In urban areas where the system is intended to be deployed, 4G/LTE cellular coverage is generally available, providing sufficient bandwidth for the system's modest data requirements (approximately 10 KB per minute per user).

**Conclusion:** The project is technically feasible. All required technologies are available, mature, and capable of meeting the project's requirements.

### 3.1.2 Economic Feasibility

The economic feasibility assessment evaluated the costs associated with developing and deploying the ATS.

**Development Costs:**
- Development tools (VS Code, Android Studio, Flutter SDK) — Free/Open Source
- Backend hosting (development) — Free tier available on Render.com, Heroku, Railway
- MongoDB hosting — Free tier (512 MB) on MongoDB Atlas
- Redis hosting — Free tier (30 MB) on Redis Cloud
- Domain and SSL — Free (Let's Encrypt for SSL, free subdomains from hosting providers)

**Deployment Costs:**
- Cloud hosting for production — Approximately $10-50/month for small-scale deployment
- No per-user licensing costs (all technologies are open source)
- No hardware procurement costs (uses existing smartphones)

**Operational Costs:**
- Server maintenance — Minimal, automated with cloud hosting
- Data costs — Negligible (approximately 10 KB/minute per user)

**Conclusion:** The project is economically feasible. The total development and deployment cost is minimal, and the system leverages existing smartphone hardware that does not require additional investment.

### 3.1.3 Operational Feasibility

The operational feasibility assessment evaluated whether the target users (ambulance drivers and traffic police officers) would be able to effectively use the system.

**User Proficiency:**
Both ambulance drivers and traffic police officers are generally familiar with smartphone usage, including map applications and messaging apps. The ATS's user interface is designed to be intuitive and requires minimal training.

**Organizational Acceptance:**
The system addresses a recognized need in emergency response coordination. Traffic police departments have expressed interest in technologies that can improve their effectiveness during emergency situations. The system's low cost and minimal infrastructure requirements reduce organizational barriers to adoption.

**Integration with Existing Workflows:**
The ATS is designed to complement rather than replace existing emergency response workflows. Traffic police officers can continue their current duties while receiving additional proximity alerts through the ATS.

**Conclusion:** The project is operationally feasible. The target users have the technical proficiency to use the system, and the system is designed to integrate seamlessly with existing workflows.

### 3.1.4 Schedule Feasibility

The project was planned for development over a period of approximately 4-5 months, following the academic calendar for final-year projects. The development was divided into the following phases:

| Phase | Duration | Activities |
|---|---|---|
| Research and Planning | 3 weeks | Literature review, requirement analysis, technology evaluation |
| System Design | 2 weeks | Architecture design, database design, API design, UI wireframes |
| Backend Development | 4 weeks | Server setup, authentication, Socket.IO, Redis integration |
| Frontend Development | 5 weeks | Flutter app, screens, map integration, real-time features |
| Integration and Testing | 3 weeks | End-to-end testing, bug fixes, performance optimization |
| Documentation | 3 weeks | Thesis writing, code documentation |

**Conclusion:** The project is schedule-feasible within the allotted academic timeframe.

## 3.2 Requirement Analysis

Requirement analysis was conducted through a combination of methods:

1. **Domain Research:** Study of existing emergency response systems, traffic management practices, and the specific challenges faced by ambulance drivers and traffic police officers in Indian cities.

2. **Stakeholder Interviews:** Informal discussions with ambulance service personnel and traffic police officers to understand their operational challenges, communication gaps, and technology preferences.

3. **Technology Assessment:** Evaluation of available technologies for real-time tracking, communication, and geospatial processing to determine the most appropriate tech stack.

4. **Competitive Analysis:** Review of existing ambulance tracking systems and emergency response platforms to identify features, limitations, and opportunities for differentiation.

The requirement analysis identified two primary user personas:

**Persona 1 — Ambulance Driver (Driver):**
- Age: 25-50 years
- Technical proficiency: Basic smartphone user
- Primary need: Focus on driving, minimal interaction with the app during emergencies
- Key requirements: Simple interface, automatic location broadcasting, one-tap journey controls

**Persona 2 — Traffic Police Officer (Police):**
- Age: 25-55 years
- Technical proficiency: Basic to intermediate smartphone user
- Primary need: Advance warning of approaching ambulances for traffic management
- Key requirements: Map view showing ambulance positions, clear proximity alerts, distance information

## 3.3 Functional Requirements

The functional requirements of the ATS are categorized by module:

### 3.3.1 Authentication Module

| Req. ID | Requirement | Priority |
|---|---|---|
| FR-AUTH-01 | The system shall allow new users to register with a username, password, and role (driver/police) | High |
| FR-AUTH-02 | The system shall authenticate registered users via username and password | High |
| FR-AUTH-03 | The system shall generate a JWT token upon successful authentication | High |
| FR-AUTH-04 | The system shall persist the JWT token on the client device for session management | High |
| FR-AUTH-05 | The system shall prevent duplicate usernames during registration | High |
| FR-AUTH-06 | The system shall hash passwords before storing in the database | High |
| FR-AUTH-07 | The system shall provide a logout function that clears stored credentials | Medium |

### 3.3.2 Location Tracking Module

| Req. ID | Requirement | Priority |
|---|---|---|
| FR-LOC-01 | The system shall capture the driver's GPS position at configurable intervals | High |
| FR-LOC-02 | The system shall transmit location updates to the server via WebSocket | High |
| FR-LOC-03 | The system shall include latitude, longitude, and heading in each update | High |
| FR-LOC-04 | The system shall display the driver's current position on a map | High |
| FR-LOC-05 | The system shall show a route trail/polyline of the driver's recent path | Medium |
| FR-LOC-06 | The system shall display current speed derived from GPS data | Medium |
| FR-LOC-07 | The system shall provide a toggle for starting/stopping location broadcasting | High |

### 3.3.3 Proximity Alert Module

| Req. ID | Requirement | Priority |
|---|---|---|
| FR-ALERT-01 | The system shall store police officer locations in a geospatial index | High |
| FR-ALERT-02 | The system shall query the geospatial index on each ambulance location update | High |
| FR-ALERT-03 | The system shall identify police officers within 2.5 km of the ambulance | High |
| FR-ALERT-04 | The system shall send targeted alerts to identified nearby police officers | High |
| FR-ALERT-05 | The system shall display visual alert banners on the police officer's screen | High |
| FR-ALERT-06 | The system shall include ambulance ID and alert message in the notification | Medium |

### 3.3.4 Map and Visualization Module

| Req. ID | Requirement | Priority |
|---|---|---|
| FR-MAP-01 | The system shall display an interactive map using OpenStreetMap tiles | High |
| FR-MAP-02 | The system shall show distinct markers for ambulances and police positions | High |
| FR-MAP-03 | The system shall update ambulance markers in real-time as positions change | High |
| FR-MAP-04 | The system shall support map zoom, pan, and rotation interactions | Medium |
| FR-MAP-05 | The system shall provide a "locate me" function to center the map on the user | Medium |
| FR-MAP-06 | The system shall animate marker movements for smooth visual updates | Low |

## 3.4 Non-Functional Requirements

| Req. ID | Category | Requirement | Target |
|---|---|---|---|
| NFR-01 | Performance | End-to-end location update latency | < 1 second |
| NFR-02 | Performance | Geospatial query latency | < 100 ms |
| NFR-03 | Performance | Frontend frame rate | 60 FPS |
| NFR-04 | Performance | Map initial render time | < 2 seconds |
| NFR-05 | Scalability | Concurrent ambulance connections | 500+ |
| NFR-06 | Scalability | Concurrent police connections | 1000+ |
| NFR-07 | Security | Password storage | bcrypt hashing (10 rounds) |
| NFR-08 | Security | Authentication mechanism | JWT tokens |
| NFR-09 | Reliability | Socket reconnection on disconnect | Automatic (5 attempts) |
| NFR-10 | Usability | Learning time for new users | < 5 minutes |
| NFR-11 | Compatibility | Android support | Android 5.0+ |
| NFR-12 | Compatibility | iOS support | iOS 11+ |
| NFR-13 | Network | Data consumption per user | < 15 KB/minute |
| NFR-14 | Availability | System uptime target | 99% |

## 3.5 User Roles and Use Cases

The ATS supports two distinct user roles, each with specific capabilities and use cases:

### 3.5.1 Driver Role

The driver role is assigned to ambulance personnel who are responsible for driving the emergency vehicle. Their primary interactions with the system include:

**Use Case UC-01: User Registration (Driver)**
- Actor: Ambulance Driver
- Precondition: The user does not have an existing account
- Flow: 1) Open the app → 2) Navigate to signup → 3) Enter username, password → 4) Select "Ambulance Driver" role → 5) Submit registration → 6) System creates account and returns JWT token → 7) User is redirected to the driver screen
- Postcondition: User account is created in MongoDB, JWT token is stored locally

**Use Case UC-02: User Login (Driver)**
- Actor: Ambulance Driver
- Precondition: The user has an existing account
- Flow: 1) Open the app → 2) Navigate to login → 3) Enter credentials → 4) Submit → 5) System validates and returns JWT → 6) User is redirected to the driver screen
- Postcondition: JWT token is stored locally, user is authenticated

**Use Case UC-03: Start Emergency Mission**
- Actor: Ambulance Driver
- Precondition: User is authenticated and on the driver screen
- Flow: 1) Tap "GO LIVE" button → 2) System starts GPS tracking → 3) Location updates are sent to server every 3 seconds → 4) Map shows current position with animated marker → 5) Speed indicator displays current speed
- Postcondition: Driver's location is being broadcast to all connected police officers

**Use Case UC-04: End Emergency Mission**
- Actor: Ambulance Driver
- Precondition: An emergency mission is active
- Flow: 1) Tap "END MISSION" button → 2) System stops GPS tracking → 3) Location broadcasting ceases → 4) Server cleans up ambulance data from Redis
- Postcondition: Ambulance tracking is stopped, driver is marked as offline

### 3.5.2 Police Role

The police role is assigned to traffic police officers who monitor ambulance movements and manage traffic accordingly.

**Use Case UC-05: User Registration (Police)**
- Actor: Traffic Police Officer
- Similar to UC-01, but role is "Traffic Police"

**Use Case UC-06: Monitor Ambulance Positions**
- Actor: Traffic Police Officer
- Precondition: User is authenticated and on the police screen
- Flow: 1) Map displays the officer's current position → 2) All active ambulances appear as markers on the map → 3) Ambulance markers update in real-time → 4) Officer can zoom/pan to view different areas
- Postcondition: Officer has real-time visibility of all ambulance positions

**Use Case UC-07: Receive Proximity Alert**
- Actor: Traffic Police Officer
- Precondition: Officer is authenticated and their location is registered in Redis
- Flow: 1) An ambulance's location update triggers a geospatial query → 2) Server finds the officer within 2.5 km → 3) Server sends targeted alert → 4) Officer's screen displays visual alert banner with ambulance ID and warning message → 5) Officer can dismiss the alert
- Postcondition: Officer is aware of approaching ambulance and can take action

**Use Case UC-08: Scan for Active Ambulances**
- Actor: Traffic Police Officer
- Flow: 1) Officer triggers scan → 2) Server queries Redis for all active ambulances → 3) Results are returned with positions → 4) Ambulance markers are displayed on map
- Postcondition: All active ambulances are visible on the officer's map

## 3.6 Use Case Diagrams

### 3.6.1 Use Case Diagram — Driver Role

```
+------------------------------------------+
|           Ambulance Tracking System       |
|                                           |
|  +-------------------+                   |
|  |  Register Account  |<---              |
|  +-------------------+    \              |
|                             \             |
|  +-------------------+      \            |
|  |   Login            |<-----Actor       |
|  +-------------------+    (Driver)       |
|                             /             |
|  +-------------------+    /              |
|  | Start Mission      |<---              |
|  +-------------------+    \              |
|                             \             |
|  +-------------------+      \            |
|  | End Mission        |<-----/           |
|  +-------------------+                   |
|                                           |
|  +-------------------+                   |
|  | View Map           |<--- (Driver)     |
|  +-------------------+                   |
|                                           |
|  +-------------------+                   |
|  | Locate Me          |<--- (Driver)     |
|  +-------------------+                   |
+------------------------------------------+
```

### 3.6.2 Use Case Diagram — Police Role

```
+------------------------------------------+
|           Ambulance Tracking System       |
|                                           |
|  +-------------------+                   |
|  |  Register Account  |<---              |
|  +-------------------+    \              |
|                             \             |
|  +-------------------+      \            |
|  |   Login            |<-----Actor       |
|  +-------------------+    (Police)       |
|                             /             |
|  +-------------------+    /              |
|  | Monitor Ambulances |<---              |
|  +-------------------+    \              |
|                             \             |
|  +-------------------+      \            |
|  | Receive Alerts     |<-----/           |
|  +-------------------+                   |
|                                           |
|  +-------------------+                   |
|  | Scan Ambulances    |<--- (Police)     |
|  +-------------------+                   |
|                                           |
|  +-------------------+                   |
|  | View Map           |<--- (Police)     |
|  +-------------------+                   |
+------------------------------------------+
```

## 3.7 Data Flow Diagrams

### 3.7.1 Level-0 (Context) Data Flow Diagram

```
+----------+                                   +----------+
|          |  --- Location Updates ---------->  |          |
|  Driver  |                                    |   ATS    |
|  (App)   |  <-- Connection Status ----------  | (Server) |
|          |                                    |          |
+----------+                                   +----------+
                                                     |  ^
                                                     |  |
                                            Alerts   |  | Location
                                                     v  |
                                                +----------+
                                                |          |
                                                |  Police  |
                                                |  (App)   |
                                                |          |
                                                +----------+
```

### 3.7.2 Level-1 Data Flow Diagram

```
Driver App ──> [1.0 Authentication] ──> MongoDB (User Data)
                     |
                     v
Driver App ──> [2.0 Location Processing] ──> Redis (Geospatial Index)
                     |
                     v
              [3.0 Proximity Detection] ──> Redis (Police Locations)
                     |
                     v
              [4.0 Alert Dispatch] ──> Police App (Proximity Alert)
                     |
                     v
              [5.0 Map Broadcasting] ──> Police App (Position Updates)
```

### 3.7.3 Level-2 Data Flow Diagram — Location Update Flow

```
Driver GPS ──> Geolocator ──> Socket.IO Client
                                    |
                                    v (updateLocation event)
                              Socket.IO Server
                                    |
                    +---------------+---------------+
                    |               |               |
                    v               v               v
             [Store in Redis] [Broadcast to   [GEOSEARCH for
              ambulance_locations  police room]  nearby police]
                                                    |
                                                    v
                                             [Send targeted
                                              alert to each
                                              nearby officer]
```

## 3.8 Hardware and Software Requirements

### 3.8.1 Hardware Requirements

**Development Hardware:**

| Component | Minimum | Recommended |
|---|---|---|
| Processor | Intel i3 / AMD Ryzen 3 | Intel i5+ / AMD Ryzen 5+ |
| RAM | 8 GB | 16 GB |
| Storage | 50 GB free space | 100 GB SSD |
| Display | 1366x768 | 1920x1080 |
| Internet | Broadband connection | High-speed broadband |
| Mobile Device | Android 5.0+ with GPS | Android 10+ with GPS |

**Server Hardware (Production):**

| Component | Minimum | Recommended |
|---|---|---|
| vCPU | 1 core | 2+ cores |
| RAM | 1 GB | 4 GB |
| Storage | 10 GB SSD | 50 GB SSD |
| Network | 100 Mbps | 1 Gbps |

### 3.8.2 Software Requirements

**Development Software:**

| Software | Version | Purpose |
|---|---|---|
| Node.js | 18+ | Backend runtime |
| TypeScript | 5.x | Backend language |
| Flutter SDK | 3.2.3+ | Frontend framework |
| Dart SDK | 3.2.3+ | Frontend language |
| VS Code | Latest | Code editor |
| Android Studio | Latest | Android debugging |
| MongoDB | 6.0+ | Database |
| Redis | 7.0+ | In-memory store |
| Git | 2.x | Version control |
| Chrome / Edge | Latest | Web debugging |

**Runtime Dependencies (Backend):**

| Package | Version | Purpose |
|---|---|---|
| express | 5.1.0 | HTTP framework |
| socket.io | 4.8.1 | WebSocket server |
| mongoose | 8.19.1 | MongoDB ODM |
| redis | 5.8.3 | Redis client |
| jsonwebtoken | 9.0.2 | JWT generation/verification |
| bcrypt | 6.0.0 | Password hashing |
| cors | 2.8.5 | CORS middleware |
| dotenv | 17.2.3 | Environment variables |
| zod | 4.1.12 | Input validation |

**Runtime Dependencies (Frontend):**

| Package | Version | Purpose |
|---|---|---|
| flutter_map | 6.1.0 | OpenStreetMap rendering |
| latlong2 | 0.9.0 | Geographic coordinates |
| geolocator | 10.1.0 | GPS location access |
| socket_io_client | 2.0.3+1 | Socket.IO client |
| shared_preferences | 2.2.0 | Local key-value storage |
| provider | 6.1.2 | State management |
| dio | 5.0.0 | HTTP client |
| lottie | 3.1.0 | Animations |
| vibration | 2.0.1 | Haptic feedback |
| audioplayers | 5.2.1 | Audio playback |

---

\newpage

