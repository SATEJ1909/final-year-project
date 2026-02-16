
# CHAPTER 4: SYSTEM DESIGN

## 4.1 System Architecture Overview

The Ambulance Tracking System follows a three-tier client-server architecture comprising a presentation tier (Flutter mobile application), an application tier (Node.js backend server), and a data tier (MongoDB and Redis). The architecture is designed to support real-time, bidirectional communication between clients and the server while maintaining clean separation of concerns.

The system employs two distinct communication patterns:
1. **Request-Response (HTTP/REST):** Used for authentication operations (signup, login) where the client sends a request and waits for a single response.
2. **Event-Driven (WebSocket/Socket.IO):** Used for all real-time operations including location updates, proximity alerts, and map broadcasts, where data flows bidirectionally without explicit request-response pairing.

This dual-protocol approach allows the system to leverage the simplicity of REST for stateless operations while using the efficiency of WebSocket for stateful, real-time streams.

## 4.2 High-Level Architecture Diagram

```
┌────────────────────────────────────────────────────────┐
│                  PRESENTATION TIER                      │
│                 (Flutter Mobile App)                     │
│                                                         │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │ Driver       │  │ Police       │  │ Auth          │  │
│  │ Screen       │  │ Screen       │  │ Screens       │  │
│  └──────┬──────┘  └──────┬───────┘  └───────┬───────┘  │
│         │                │                   │          │
│  ┌──────┴────────────────┴───────────────────┴───────┐  │
│  │              SERVICE LAYER                         │  │
│  │  SocketService | AuthService | MapApiService       │  │
│  └──────────────────────┬────────────────────────────┘  │
└─────────────────────────┼───────────────────────────────┘
                          │
            WebSocket     │    HTTP/REST
           (Socket.IO)    │    (Express)
                          │
┌─────────────────────────┼───────────────────────────────┐
│                APPLICATION TIER                          │
│               (Node.js Backend)                          │
│                                                          │
│  ┌──────────────────────┴──────────────────────────┐     │
│  │                  index.ts                        │     │
│  │         (Express + Socket.IO Server)             │     │
│  └─────┬────────────────┬───────────────┬──────────┘     │
│        │                │               │                │
│  ┌─────┴──────┐  ┌──────┴──────┐  ┌────┴─────────┐     │
│  │ Auth       │  │ Location    │  │ Routes       │     │
│  │ Controller │  │ Controller  │  │ (Express)    │     │
│  └─────┬──────┘  └──────┬──────┘  └──────────────┘     │
└────────┼────────────────┼──────────────────────────────┘
         │                │
┌────────┼────────────────┼──────────────────────────────┐
│        │     DATA TIER  │                               │
│  ┌─────┴──────┐  ┌──────┴──────┐                       │
│  │  MongoDB   │  │   Redis     │                       │
│  │            │  │             │                       │
│  │ - Users    │  │ - police_   │                       │
│  │ - Auth     │  │   locations │                       │
│  │   Data     │  │ - ambulance_│                       │
│  │            │  │   locations │                       │
│  │            │  │ - user_     │                       │
│  │            │  │   sockets   │                       │
│  └────────────┘  └─────────────┘                       │
└─────────────────────────────────────────────────────────┘
```

**Figure 4.1: High-Level System Architecture**

## 4.3 Backend Architecture

The backend follows the Model-View-Controller (MVC) architectural pattern adapted for a Node.js/TypeScript environment:

### 4.3.1 Directory Structure

```
backend/
├── src/
│   ├── index.ts              # Server entry point
│   ├── redisClient.ts        # Redis client initialization
│   ├── controller/
│   │   ├── authController.ts    # Authentication handlers
│   │   └── locationController.ts # Socket event handlers
│   ├── model/
│   │   └── userModel.ts       # Mongoose user schema
│   └── routes/
│       └── routes.ts          # Express route definitions
├── package.json              # Node.js dependencies
├── tsconfig.json             # TypeScript configuration
└── .env                      # Environment variables
```

### 4.3.2 Component Responsibilities

**Server Entry (index.ts):**
- Initializes Express application with middleware (CORS, JSON parsing)
- Creates HTTP server and attaches Socket.IO
- Configures Socket.IO authentication middleware for JWT verification
- Sets up Socket.IO event listeners and delegates to controllers
- Connects to MongoDB via Mongoose
- Starts listening on configured port

**Auth Controller (authController.ts):**
- Handles user signup with input validation, password hashing, and JWT generation
- Handles user login with credential verification and JWT generation
- Implements role normalization (frontend-friendly roles to database roles)

**Location Controller (locationController.ts):**
- Handles `join` events: maps userId to socketId in Redis, joins police room
- Handles `updateLocation` events: stores ambulance position, broadcasts to police room, performs proximity search
- Handles `disconnect` events: cleans up Redis entries (socket mappings, geospatial data)

**Redis Client (redisClient.ts):**
- Creates and connects Redis client using async initialization pattern
- Provides error handling and graceful failure on connection errors
- Exports connected client for use by other modules

**User Model (userModel.ts):**
- Defines Mongoose schema with username (unique, lowercase, trimmed), password (hashed, not selected by default), and role (enum: driver/police)
- Enables automatic timestamps (createdAt, updatedAt)

**Routes (routes.ts):**
- Defines Express router with POST routes for signup and login
- Maps routes to auth controller functions

## 4.4 Frontend Architecture

The Flutter frontend follows the Screen-Service pattern, separating UI presentation from business logic and data access:

### 4.4.1 Directory Structure

```
frontend/lib/
├── main.dart                        # App entry point
├── services/
│   ├── socket_io_service.dart       # Socket.IO client service
│   ├── auth_service.dart            # Authentication API service
│   ├── map_api_service.dart         # Map routing/geocoding service
│   └── osm_search_service.dart      # Place search service
└── presentation/
    └── screens/
        ├── home_screen.dart         # Landing page
        ├── login_screen.dart        # Login form
        ├── signup_screen.dart       # Registration form
        ├── driver_screen.dart       # Driver map interface
        └── police_screen.dart       # Police monitoring interface
```

### 4.4.2 State Management

The ATS uses the Provider pattern for state management, specifically the `ChangeNotifier` mixin with `ChangeNotifierProvider`. The `SocketService` class extends `ChangeNotifier` and serves as the primary state container for real-time connection status and data streams.

```
ChangeNotifierProvider<SocketService>
         │
         ├── HomeScreen (reads connection status)
         ├── LoginScreen (initiates connection after auth)
         ├── DriverScreen (sends location updates)
         └── PoliceScreen (receives updates and alerts)
```

The Provider pattern was chosen for its simplicity, minimal boilerplate, and suitability for the ATS's relatively straightforward state management needs. More complex state management solutions (BLoC, Riverpod, Redux) were considered but deemed unnecessary for the project's scope.

### 4.4.3 Service Layer Design

**SocketService:**
- Manages Socket.IO connection lifecycle (connect, reconnect, disconnect)
- Exposes `Stream<AmbulancePosition>` and `Stream<ProximityAlert>` for reactive UI updates
- Provides methods for sending location updates and police location updates
- Tracks connection status via `ConnectionStatus` enum
- Persists socket URL in SharedPreferences for flexible deployment

**AuthService:**
- Provides static methods for signup and login via HTTP POST requests
- Stores JWT token, role, and userId in SharedPreferences
- Includes error handling with descriptive error messages
- Supports timeout handling for network requests

**MapApiService:**
- Integrates with OSRM (Open Source Routing Machine) for route calculation
- Provides geocoding (address → coordinates) via Nominatim
- Provides reverse geocoding (coordinates → address) via Nominatim

**OSMSearchService:**
- Provides location search suggestions using Nominatim API
- Supports conversion of place names to LatLng coordinates

## 4.5 Database Design

### 4.5.1 MongoDB Schema — User Collection

```
Collection: users
{
  _id: ObjectId           (auto-generated primary key)
  username: String        (required, unique, lowercase, trimmed)
  password: String        (required, bcrypt hashed, select: false)
  role: String            (required, enum: ['driver', 'police'])
  createdAt: Date         (auto-generated timestamp)
  updatedAt: Date         (auto-generated timestamp)
}

Indexes:
  - _id: Primary key (default)
  - username: Unique index (enforced by schema)
```

The `select: false` option on the password field ensures that password hashes are not included in query results by default, providing an additional layer of security. When password verification is needed (during login), the field is explicitly selected using `.select('+password')`.

### 4.5.2 Entity-Relationship Diagram

```
+-------------------+
|      USER         |
+-------------------+
| _id (PK)          |
| username (UNIQUE)  |
| password (HASH)   |
| role (ENUM)       |
| createdAt         |
| updatedAt         |
+-------------------+
        |
        | 1:1 (runtime)
        |
+-------------------+
|  SOCKET SESSION   |
| (Redis: user_sockets) |
+-------------------+
| userId (FK)       |
| socketId          |
+-------------------+
        |
        | 1:1 (runtime, conditional)
        |
+-------------------+          +-------------------+
| POLICE LOCATION   |          | AMBULANCE LOCATION|
| (Redis: police_   |          | (Redis: ambulance_|
|  locations - GEO)  |          |  locations - GEO) |
+-------------------+          +-------------------+
| userId (member)   |          | ambulanceId       |
| longitude         |          | longitude         |
| latitude          |          | latitude          |
+-------------------+          +-------------------+
```

## 4.6 Redis Data Structures

Redis serves as the real-time data layer, managing three key data structures:

### 4.6.1 Police Locations (Geospatial Set)

```
Key: police_locations
Type: Sorted Set with Geospatial index
Members: userId values of connected police officers
Data: longitude, latitude coordinates

Operations:
  GEOADD police_locations <longitude> <latitude> <userId>
  GEOSEARCH police_locations FROMLONLAT <lng> <lat> BYRADIUS 2.5 km
  ZREM police_locations <userId>
```

### 4.6.2 Ambulance Locations (Geospatial Set)

```
Key: ambulance_locations
Type: Sorted Set with Geospatial index
Members: ambulanceId (same as userId for drivers)
Data: longitude, latitude coordinates

Operations:
  GEOADD ambulance_locations <longitude> <latitude> <ambulanceId>
  GEOSEARCH ambulance_locations FROMLONLAT <lng> <lat> BYRADIUS 100 km
  GEOPOS ambulance_locations <ambulanceId>
  ZREM ambulance_locations <userId>
```

### 4.6.3 User-Socket Mapping (Hash)

```
Key: user_sockets
Type: Hash
Fields: userId → socketId mapping

Operations:
  HSET user_sockets <userId> <socketId>
  HGET user_sockets <userId>
  HDEL user_sockets <userId>
  HGETALL user_sockets (for reverse lookup during disconnect)
```

## 4.7 API Design

### 4.7.1 REST API Endpoints

| Method | Endpoint | Description | Request Body | Response |
|---|---|---|---|---|
| POST | `/api/v1/user/signup` | Register new user | `{username, password, role}` | `{success, message, token, role, id}` |
| POST | `/api/v1/user/login` | Authenticate user | `{username, password}` | `{success, message, token, role, id}` |

### 4.7.2 Request/Response Format

**Signup Request:**
```json
{
  "username": "string (required)",
  "password": "string (required)",
  "role": "driver | police (required)"
}
```

**Successful Signup Response (201):**
```json
{
  "success": true,
  "message": "User created successfully",
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "role": "driver",
  "id": "65a1b2c3d4e5f6..."
}
```

**Error Response (400/401/500):**
```json
{
  "success": false,
  "message": "Error description string"
}
```

## 4.8 WebSocket Event Design

### 4.8.1 Client-to-Server Events

| Event | Emitter | Payload | Description |
|---|---|---|---|
| `join` | Driver/Police | `{userId, role, location?}` | Identify user and register in system |
| `updateLocation` | Driver | `{ambulanceId, lat, lng, heading?}` | Send ambulance position update |
| `updatePoliceLocation` | Police | `{userId?, lat, lng}` | Update police officer position |
| `scanAmbulances` | Police | `{}` | Request all active ambulance positions |
| `journey_end` | Driver | `{ambulanceId}` | Signal end of emergency mission |

### 4.8.2 Server-to-Client Events

| Event | Target | Payload | Description |
|---|---|---|---|
| `ambulancePositionUpdate` | Police room (broadcast) | `{ambulanceId, lat, lng, heading}` | Broadcast ambulance position |
| `ambulanceProximityAlert` | Specific police socket | `{ambulanceId, message}` | Targeted proximity alert |
| `scanResult` | Requesting socket | `{success, ambulances[]}` | Response to scan request |

## 4.9 Authentication Flow Design

```
Client                          Server                        MongoDB
  |                               |                              |
  |--- POST /signup ------------>|                               |
  |   {username, password, role} |                               |
  |                               |--- findOne({username}) ----->|
  |                               |<-- null (not found) ---------|
  |                               |                              |
  |                               |--- bcrypt.hash(password) --->|
  |                               |                              |
  |                               |--- create({username,         |
  |                               |     hashedPassword, role})--->|
  |                               |<-- user document ------------|
  |                               |                              |
  |                               |--- jwt.sign({id, role}) ---->|
  |                               |                              |
  |<-- 201 {token, role, id} ----|                               |
  |                               |                              |
  |--- Store token locally ------>|                              |
  |                               |                              |
  |--- Socket.IO connect ------->|                               |
  |   (auth: {token})            |                               |
  |                               |--- jwt.verify(token) ------->|
  |                               |<-- {id, role} ---------------|
  |<-- Connected -----------------|                              |
```

## 4.10 Geospatial Algorithm Design

The proximity detection algorithm executes on every ambulance location update:

```
Algorithm: Proximity Detection and Alert

Input: ambulanceId, lat, lng, heading
Output: Proximity alerts sent to nearby police officers

BEGIN
  1. VALIDATE input (ambulanceId, lat, lng must not be null)
  
  2. STORE ambulance location:
     Redis GEOADD ambulance_locations lng lat ambulanceId
  
  3. BROADCAST position to police room:
     io.to('police').emit('ambulancePositionUpdate', {ambulanceId, lat, lng, heading})
  
  4. SEARCH for nearby police:
     nearbyPolice = Redis GEOSEARCH police_locations
                    FROMLONLAT lng lat
                    BYRADIUS 2.5 km
  
  5. FOR EACH policeId IN nearbyPolice:
     a. socketId = Redis HGET user_sockets policeId
     b. IF socketId exists:
        io.to(socketId).emit('ambulanceProximityAlert', {
          ambulanceId,
          message: "Ambulance {ambulanceId} is approaching!"
        })
END
```

**Haversine Distance Calculation (used internally by Redis GEOSEARCH):**

```
function haversineDistance(lat1, lon1, lat2, lon2):
  R = 6371 km (Earth's mean radius)
  dLat = toRadians(lat2 - lat1)
  dLon = toRadians(lon2 - lon1)
  a = sin(dLat/2)^2 + cos(toRadians(lat1)) * cos(toRadians(lat2)) * sin(dLon/2)^2
  c = 2 * atan2(sqrt(a), sqrt(1-a))
  distance = R * c
  return distance
```

## 4.11 User Interface Design

### 4.11.1 Design Principles

The ATS user interface follows Material Design 3 guidelines with a focus on:
- **Clarity:** Information hierarchy that surfaces critical data (position, alerts) prominently
- **Minimalism:** Reduced visual clutter during emergency scenarios when drivers need to focus
- **Color Coding:** Consistent use of colors to convey meaning (red for emergency/live, blue for police, green for GPS OK)
- **Responsiveness:** Adaptive layout for different screen sizes

### 4.11.2 Color Palette

| Color | Hex Code | Usage |
|---|---|---|
| Primary Blue | #007AFF | Navigation, buttons, branding |
| Dark Navy | #1D2A3A | Headings, text |
| Emergency Red | #E53935 | Live mode, end mission, alerts |
| Success Green | #4CAF50 | GPS status, success indicators |
| Warning Orange | #FF9800 | Moderate speed, caution |
| White | #FFFFFF | Backgrounds |
| Light Gray | #F5F5F5 | Secondary backgrounds |

### 4.11.3 Screen Designs

**Home Screen:**
- Professional landing page with navigation bar (ATS logo, Login/Signup buttons)
- Hero section with emergency icon, title, subtitle, and CTA buttons
- Feature cards highlighting GPS Tracking, Proximity Alerts, and Security
- Footer with copyright information

**Driver Screen:**
- Full-screen map view as primary element
- Custom vehicle marker with directional arrow and pulsing animation
- Route trail polyline showing recent path
- Floating navigation header (dark overlay) showing navigation status and speed
- Bottom action card with mission controls (GO LIVE / END MISSION)
- Re-center button when map is manually panned

**Police Screen:**
- Full-screen map view with police station marker
- Multiple ambulance markers updated in real-time
- Proximity alert banner (animated slide-in from top)
- Scan button for discovering active ambulances
- Connection status indicator
- Nearby ambulances list with distance calculations

## 4.12 Sequence Diagrams

### 4.12.1 User Authentication Sequence

```
User        Flutter App       Express Server      MongoDB
 |              |                   |                 |
 |--Enter creds->|                  |                 |
 |              |--POST /login----->|                 |
 |              |                   |--findOne()----->|
 |              |                   |<--user doc------|
 |              |                   |--bcrypt.compare->|
 |              |                   |--jwt.sign()----->|
 |              |<--{token,role,id}-|                 |
 |              |--Store in prefs-->|                 |
 |<-Navigate----|                   |                 |
```

### 4.12.2 Location Update and Proximity Alert Sequence

```
Driver App    Socket.IO Server    Redis         Police App
   |               |                |               |
   |--updateLoc--->|                |               |
   |  {id,lat,lng} |                |               |
   |               |--GEOADD------->|               |
   |               |                |               |
   |               |--emit to police room---------->|
   |               |  (ambulancePositionUpdate)     |
   |               |                |               |
   |               |--GEOSEARCH---->|               |
   |               |<--nearby[]-----|               |
   |               |                |               |
   |               |--HGET--------->| (for each     |
   |               |<--socketId-----|  nearby police)|
   |               |                |               |
   |               |--emit(alert)------------------>|
   |               |                |   (targeted)  |
   |               |                |               |--Show Alert
```

## 4.13 Class Diagrams

### 4.13.1 Backend Class Diagram

```
+---------------------+
|     UserModel       |
+---------------------+
| - username: String  |
| - password: String  |
| - role: String      |
| - createdAt: Date   |
| - updatedAt: Date   |
+---------------------+
| + findOne()         |
| + create()          |
| + select()          |
+---------------------+

+---------------------+       +---------------------+
|  AuthController     |       | LocationController  |
+---------------------+       +---------------------+
| + signup(req, res)  |       | + handleJoin()      |
| + login(req, res)   |       | + handleUpdateLoc() |
+---------------------+       | + handleDisconnect()|
                               +---------------------+

+---------------------+
|   RedisClient       |
+---------------------+
| + geoAdd()          |
| + geoSearch()       |
| + geoPos()          |
| + hSet()            |
| + hGet()            |
| + hDel()            |
| + hGetAll()         |
| + zRem()            |
+---------------------+
```

### 4.13.2 Frontend Class Diagram

```
+-----------------------------+
|       SocketService          |
| (extends ChangeNotifier)     |
+-----------------------------+
| - _socket: IO.Socket?       |
| - _connectionStatus: Enum   |
| - _currentUserId: String?   |
| - _currentRole: String?     |
| - _currentLocation: LatLng? |
+-----------------------------+
| + connectAndListen()         |
| + sendLocationUpdate()       |
| + updatePoliceLocation()     |
| + scanAmbulances()           |
| + disconnect()               |
| + positionUpdateStream       |
| + alertStream                |
+-----------------------------+

+-----------------------------+
|       AuthService            |
+-----------------------------+
| + signUp()                   |
| + login()                    |
| + getToken() (static)        |
| + getRole() (static)        |
| + getUserId() (static)       |
| + logout() (static)         |
+-----------------------------+

+-----------------------------+     +-----------------------------+
|     AmbulancePosition       |     |     ProximityAlert          |
+-----------------------------+     +-----------------------------+
| + ambulanceId: String       |     | + ambulanceId: String       |
| + lat: double               |     | + message: String           |
| + lng: double               |     +-----------------------------+
| + heading: double?          |     | + fromJson()                |
+-----------------------------+     +-----------------------------+
| + fromJson()                |
+-----------------------------+
```

## 4.14 Component Diagram

```
+------------------------------------------------------------------+
|                        CLIENT DEVICE                              |
|                                                                   |
|  ┌────────────┐  ┌────────────┐  ┌────────────┐                  |
|  │ HomeScreen  │  │LoginScreen │  │SignupScreen │                  |
|  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘                  |
|         └───────────────┼───────────────┘                         |
|                         │                                         |
|         ┌───────────────┼───────────────┐                         |
|  ┌──────┴─────┐                  ┌──────┴─────┐                  |
|  │DriverScreen│                  │PoliceScreen│                  |
|  └──────┬─────┘                  └──────┬─────┘                  |
|         └───────────────┬───────────────┘                         |
|                         │                                         |
|  ┌──────────────────────┴─────────────────────────┐              |
|  │              SERVICE LAYER                      │              |
|  │  ┌────────────┐┌──────────┐┌──────────────────┐│              |
|  │  │SocketService││AuthService││MapApiService    ││              |
|  │  └─────┬──────┘└─────┬────┘└────────┬─────────┘│              |
|  └────────┼─────────────┼──────────────┼──────────┘              |
+───────────┼─────────────┼──────────────┼──────────────────────────+
            │ WebSocket   │ HTTP         │ HTTP
            │(Socket.IO)  │(REST)        │(External APIs)
+───────────┼─────────────┼──────────────┼──────────────────────────+
|           │    SERVER    │             │                           |
|  ┌────────┴─────────────┴──┐   ┌──────┴──────────────┐           |
|  │      Express Server      │   │  External Services  │           |
|  │  ┌─────────┐┌──────────┐│   │  - OSRM (routing)   │           |
|  │  │Socket.IO││  Routes  ││   │  - Nominatim (geo)   │           |
|  │  └────┬────┘└────┬─────┘│   └─────────────────────┘           |
|  │  ┌────┴────┐┌────┴─────┐│                                     |
|  │  │Location ││  Auth    ││                                     |
|  │  │Controller│Controller││                                     |
|  │  └────┬────┘└────┬─────┘│                                     |
|  └───────┼──────────┼──────┘                                     |
|          │          │                                             |
|  ┌───────┴──┐  ┌────┴─────┐                                     |
|  │  Redis   │  │ MongoDB  │                                     |
|  └──────────┘  └──────────┘                                     |
+──────────────────────────────────────────────────────────────────+
```

---

\newpage

