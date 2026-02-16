

# CHAPTER 5: IMPLEMENTATION

## 5.1 Development Environment Setup

The development of the Ambulance Tracking System required the configuration of separate but complementary environments for the backend and frontend components. This section describes the tools, configurations, and setup procedures used during development.

### 5.1.1 Backend Development Environment

The backend was developed using Node.js with TypeScript, providing type safety and modern JavaScript features. The development environment was configured as follows:

**Runtime and Language:**
- Node.js v18+ was installed as the server-side JavaScript runtime
- TypeScript v5.x was used for static type checking and compilation
- The `tsconfig.json` was configured with `"module": "ESNext"` and `"moduleResolution": "node16"` to support ES Module syntax with the `"type": "module"` setting in `package.json`

**Package Management:**
- npm (Node Package Manager) was used for dependency management
- All dependencies were specified in `package.json` with version constraints

**Build and Run Scripts:**
The following npm scripts were configured for the development workflow:

```json
{
  "scripts": {
    "build": "tsc",
    "start": "node dist/index.js",
    "dev": "tsc -b && node dist/index.js"
  }
}
```

The `dev` script performs a TypeScript build followed by immediate execution, providing a quick development cycle. The separate `build` and `start` scripts support production deployment where the build step is performed once and the compiled JavaScript is executed.

**Environment Configuration:**
Environment variables were managed using the `dotenv` package, with a `.env` file containing:
- `DATABASE_URL` — MongoDB connection string (MongoDB Atlas cloud instance)
- `REDIS_URL` — Redis connection string (Redis Cloud instance)
- `JWT_SECRET` — Secret key for JWT token signing
- `PORT` — Server port number (default: 3000)

### 5.1.2 Frontend Development Environment

The Flutter framework was used for cross-platform mobile application development:

**SDK and Tools:**
- Flutter SDK v3.2.3+ was installed with the Dart SDK v3.2.3+
- Android Studio was used for Android emulator management and debugging
- VS Code served as the primary code editor with Flutter and Dart extensions
- Chrome DevTools were used for debugging network requests and WebSocket connections

**Project Configuration:**
The Flutter project was initialized with the name `ats_frontend` and configured through `pubspec.yaml` with the following key settings:
- SDK constraint: `>=3.2.3 <4.0.0`
- Material Design 3 enabled
- Asset declarations for SVG images and audio files

**Assets:**
The project includes the following assets:
- `assets/images/hero_illustration.svg` — Home screen illustration
- `assets/images/ambulance_marker.svg` — Custom ambulance marker for map display
- `assets/sounds/siren.mp3` — Proximity alert siren sound

### 5.1.3 Database and Services Setup

**MongoDB Atlas:**
A free-tier MongoDB Atlas cluster was provisioned for persistent data storage. The cluster provides 512 MB of storage with automatic backups and is accessible via a connection string configured in the backend's `.env` file.

**Redis Cloud:**
A free-tier Redis Cloud instance was provisioned for in-memory geospatial data storage. Redis Cloud provides 30 MB of memory, which is sufficient for storing thousands of geospatial entries. The connection is established using the `redis` npm package (v5.8.3) with the URL configured in the `.env` file.

**Deployment:**
The backend was deployed on Render.com, providing a publicly accessible URL (`https://final-year-app.onrender.com`) for both the REST API and WebSocket connections.

## 5.2 Backend Implementation

The backend is implemented as a Node.js/TypeScript application following the MVC (Model-View-Controller) architectural pattern. The source code is organized into a clean directory structure with clear separation of concerns.

### 5.2.1 Project Structure

```
backend/
├── src/
│   ├── index.ts                    # Server entry point (158 lines)
│   ├── redisClient.ts              # Redis client initialization (35 lines)
│   ├── controller/
│   │   ├── authController.ts       # Authentication handlers (94 lines)
│   │   └── locationController.ts   # Socket event handlers (145 lines)
│   ├── model/
│   │   └── userModel.ts            # Mongoose user schema (11 lines)
│   └── routes/
│       └── routes.ts               # Express route definitions (9 lines)
├── package.json
├── tsconfig.json
└── .env
```

The backend codebase is notably compact at approximately 452 lines of TypeScript across 6 source files, demonstrating that a powerful real-time system can be built with minimal code when leveraging appropriate frameworks and libraries.

## 5.3 Server Entry Point and Configuration

The server entry point (`index.ts`) is the central orchestration module that initializes all components and wires them together. It performs the following key functions:

**1. Express Application Setup:**

```typescript
import express from 'express'
import cors from 'cors'

const app = express();
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json());
app.use("/api/v1/user", userRouter);
```

The Express application is configured with CORS middleware to allow cross-origin requests from the Flutter mobile application, JSON body parsing middleware for handling request payloads, and the user router for authentication endpoints.

**2. HTTP Server and Socket.IO Initialization:**

```typescript
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    allowedHeaders: ["Content-Type"],
  }
});
```

The HTTP server is created from the Express application, and Socket.IO is attached to it. This approach allows both REST API endpoints and WebSocket connections to operate on the same port, simplifying deployment and configuration.

**3. JWT Authentication Middleware for WebSocket:**

```typescript
io.use((socket, next) => {
  try {
    const token = socket.handshake.auth?.token || socket.handshake.query?.token;
    if (!token) return next();
    const payload = jwt.verify(token as string, JWT_SECRET) as any;
    (socket as any).userId = payload.id;
    (socket as any).role = payload.role;
    return next();
  } catch (err) {
    console.warn('Socket authentication failed:', err);
    return next();
  }
});
```

Socket.IO middleware intercepts each new connection attempt and extracts the JWT token from either the `auth` object or query parameters. Upon successful verification, the user's ID and role are attached to the socket object for use in subsequent event handlers.

**4. Socket Event Registration:**

The server registers listeners for six distinct Socket.IO events:
- `join` — User identification and room management
- `updateLocation` — Ambulance GPS position updates
- `updatePoliceLocation` — Police officer position updates
- `scanAmbulances` — Query for all active ambulances
- `journey_end` — Driver signals end of emergency mission
- `disconnect` — Cleanup on client disconnection

**5. Database Connection and Server Start:**

```typescript
async function main() {
  await mongoose.connect(process.env.DATABASE_URL as string);
  // ... server setup ...
  const PORT = Number(process.env.PORT) || 3000;
  server.listen(PORT, '0.0.0.0', () => {
    console.log('Server running on http://0.0.0.0:' + PORT);
  });
}
main();
```

The server binds to `0.0.0.0` to accept connections from any network interface, which is necessary for deployment on cloud platforms.

## 5.4 Database Models and Schema

The ATS uses a single MongoDB collection (`users`) for persistent data. The Mongoose schema is defined in `userModel.ts`:

```typescript
import mongoose from 'mongoose'

const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true, trim: true, lowercase: true },
    password: { type: String, required: true, select: false },
    role: { type: String, required: true, enum: ['driver', 'police'] }
}, { timestamps: true })

const UserModel = mongoose.model('User', userSchema)
export default UserModel;
```

**Key Design Decisions:**

1. **`select: false` on password:** The password field is excluded from query results by default. This prevents accidental exposure of password hashes in API responses. When password verification is needed during login, the field is explicitly selected using `.select('+password')`.

2. **`unique: true` on username:** MongoDB enforces uniqueness at the database level, preventing duplicate registrations even under concurrent requests.

3. **`trim: true` and `lowercase: true`:** Input normalization ensures that usernames like "John", " john ", and "JOHN" are all treated as the same username, preventing confusion and duplicate accounts.

4. **`enum: ['driver', 'police']` on role:** The schema enforces that only valid roles can be stored, providing data integrity at the database level.

5. **`timestamps: true`:** Mongoose automatically manages `createdAt` and `updatedAt` fields, providing audit trail information without manual date handling.

## 5.5 Authentication Module

The authentication module (`authController.ts`) implements two primary functions: user registration (signup) and user authentication (login).

### 5.5.1 Signup Implementation

```typescript
export const signup = async(req: Request, res: Response) => {
    try {
        const {username, password, role} = req.body;
        const normalizedRole = role === 'driver' ? 'driver' : 'police';
        
        const existingUser = await UserModel.findOne({username});
        if(existingUser) {
            return res.status(400).json({
                success: false,
                message: "User already exists"
            });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const user = await UserModel.create({
            username,
            password: hashedPassword,
            role: normalizedRole
        });
        
        const token = jwt.sign({ id: user._id, role: user.role }, JWT_SECRET);
        return res.status(201).json({
            success: true,
            message: "User created successfully",
            token,
            role: user.role,
            id: user._id
        });
    } catch (error: any) {
        return res.status(500).json({ success: false, message: error.message });
    }
}
```

The signup flow follows these steps:
1. Extract username, password, and role from the request body
2. Normalize the role to ensure consistency with the database enum
3. Check for an existing user with the same username
4. Hash the password using bcrypt with 10 salt rounds
5. Create the user document in MongoDB
6. Generate a JWT token containing the user's ID and role
7. Return the token, role, and user ID in the response

### 5.5.2 Login Implementation

```typescript
export const login = async(req: Request, res: Response) => {
    try {
        const {username, password} = req.body;
        const user = await UserModel.findOne({username}).select('+password');

        if(!user) {
            return res.status(404).json({ success: false, message: "User not found" });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if(!isMatch) {
            return res.status(401).json({ success: false, message: "Invalid credentials" });
        }
        
        const token = jwt.sign({ id: user._id, role: user.role }, JWT_SECRET);
        return res.status(200).json({
            success: true,
            message: "User logged in successfully",
            token,
            role: user.role,
            id: user._id
        });
    } catch (error: any) {
        return res.status(500).json({ success: false, message: error.message });
    }
}
```

The login flow uses `.select('+password')` to explicitly include the password hash (which is excluded by default) for comparison using `bcrypt.compare()`. The use of separate HTTP status codes (404 for user not found, 401 for invalid credentials) provides clear error differentiation for the frontend.

## 5.6 Real-Time Location Controller

The location controller (`locationController.ts`) is the core real-time processing module that handles user connections, location updates, and proximity detection. It defines three Redis key constants for data organization:

```typescript
const POLICE_GEO_KEY = 'police_locations';
const AMBULANCE_GEO_KEY = 'ambulance_locations';
const USER_SOCKET_HASH_KEY = 'user_sockets';
```

### 5.6.1 Join Handler

The `handleJoin` function processes new user connections:

```typescript
export async function handleJoin(socket: Socket, payload: JoinPayload): Promise<void> {
  const { userId, role, location } = payload;
  if (!userId || !role) return;

  // Map userId to socketId for targeted messaging
  await redisClient.hSet(USER_SOCKET_HASH_KEY, userId, socket.id);

  if (role === 'police') {
    socket.join('police');
    if (location?.lat && location?.lng) {
      await redisClient.geoAdd(POLICE_GEO_KEY, {
        longitude: location.lng,
        latitude: location.lat,
        member: userId,
      });
    }
  }
}
```

Key operations:
1. **Socket-User Mapping:** Each user's ID is mapped to their Socket.IO socket ID in a Redis hash, enabling the server to send targeted messages to specific users.
2. **Room Assignment:** Police officers are added to the 'police' Socket.IO room, enabling efficient broadcast of ambulance position updates to all police clients.
3. **Geospatial Registration:** If the police officer provides their location, it is stored in the Redis geospatial index for proximity queries.

### 5.6.2 Location Update Handler

The `handleUpdateLocation` function is the most critical function in the system, executing on every ambulance location update:

```typescript
export async function handleUpdateLocation(io: Server, payload: LocationUpdatePayload): Promise<void> {
  const { ambulanceId, lat, lng, heading } = payload;
  if (!ambulanceId || lat == null || lng == null) return;

  // 1. Store ambulance position in Redis
  await redisClient.geoAdd(AMBULANCE_GEO_KEY, {
    longitude: lng, latitude: lat, member: ambulanceId,
  });

  // 2. Broadcast to all police officers
  io.to('police').emit('ambulancePositionUpdate', { ambulanceId, lat, lng, heading });

  // 3. Proximity search: find police within 2.5 km
  const nearbyPolice = await redisClient.geoSearch(POLICE_GEO_KEY,
    { longitude: lng, latitude: lat },
    { radius: 2.5, unit: 'km' }
  );

  // 4. Send targeted alerts to each nearby officer
  for (const policeId of nearbyPolice) {
    const socketId = await redisClient.hGet(USER_SOCKET_HASH_KEY, policeId);
    if (socketId) {
      io.to(socketId).emit('ambulanceProximityAlert', {
        ambulanceId,
        message: `Ambulance ${ambulanceId} is approaching your location!`,
      });
    }
  }
}
```

This function performs four operations in sequence:
1. **Store:** The ambulance's position is stored/updated in the Redis geospatial index
2. **Broadcast:** The position is broadcast to all connected police officers via the 'police' room
3. **Search:** A geospatial radius search finds all police officers within 2.5 km
4. **Alert:** Targeted proximity alerts are sent to each nearby officer using their specific socket ID

### 5.6.3 Disconnect Handler

The `handleDisconnect` function performs cleanup when a user disconnects:

```typescript
export async function handleDisconnect(socket: Socket): Promise<void> {
  const allUsers = await redisClient.hGetAll(USER_SOCKET_HASH_KEY);
  const userId = Object.keys(allUsers).find(key => allUsers[key] === socket.id);

  if (userId) {
    await redisClient.hDel(USER_SOCKET_HASH_KEY, userId);
    await redisClient.zRem(POLICE_GEO_KEY, userId);
    await redisClient.zRem(AMBULANCE_GEO_KEY, userId);
  }
}
```

The disconnect handler performs a reverse lookup from socket ID to user ID (since Socket.IO provides only the socket ID during disconnect events), then removes the user from all Redis data structures: the socket mapping hash, the police geospatial index, and the ambulance geospatial index.

## 5.7 Redis Client and Geospatial Operations

The Redis client module (`redisClient.ts`) implements an async initialization pattern:

```typescript
import { createClient } from 'redis';
import type { RedisClientType } from 'redis';

const initializeRedisClient = async (): Promise<RedisClientType> => {
  const client: RedisClientType = createClient({
    url: process.env.REDIS_URL as string,
  });

  client.on('error', (err: any) => console.error('Redis Client Error', err));

  try {
    await client.connect();
    console.log('Successfully connected to Redis.');
  } catch (err) {
    console.error('Could not connect to Redis:', err);
    process.exit(1);
  }
  return client;
};

const redisClient = await initializeRedisClient();
export default redisClient;
```

The module uses ES Module top-level `await` to initialize and connect the Redis client before exporting it. This ensures that any module importing `redisClient` receives a fully connected, ready-to-use client instance. If the Redis connection fails, the process exits with code 1, as Redis is a critical dependency for the system's real-time functionality.

## 5.8 Socket.IO Event Handling

Socket.IO event handling is configured in the server entry point (`index.ts`) with additional handlers for police location updates, ambulance scanning, and journey management:

### 5.8.1 Police Location Update Handler

```typescript
socket.on('updatePoliceLocation', async (payload) => {
  const { lat, lng } = payload;
  const userId = (socket as any).userId || payload.userId;

  if (userId && lat && lng) {
    await redisClient.geoAdd(POLICE_GEO_KEY, {
      longitude: lng, latitude: lat, member: userId,
    });
  }
});
```

This handler allows police officers to update their geospatial position independently of the initial `join` event. The officer's user ID is obtained from either the authenticated socket (set during the JWT middleware) or the event payload, providing flexibility in authentication approaches.

### 5.8.2 Ambulance Scan Handler

```typescript
socket.on('scanAmbulances', async (payload, callback) => {
  const ambulanceGeoKey = 'ambulance_locations';
  const ambulances = await redisClient.geoSearch(ambulanceGeoKey,
    { longitude: 77.7796, latitude: 20.9374 }, // Center point (Amravati)
    { radius: 100, unit: 'km' }
  );

  const ambulanceData = [];
  for (const ambId of ambulances) {
    const pos = await redisClient.geoPos(ambulanceGeoKey, ambId);
    if (pos && pos[0]) {
      ambulanceData.push({
        ambulanceId: ambId,
        lat: pos[0].latitude,
        lng: pos[0].longitude,
      });
    }
  }

  if (typeof callback === 'function') {
    callback({ success: true, ambulances: ambulanceData });
  } else {
    socket.emit('scanResult', { success: true, ambulances: ambulanceData });
  }
});
```

The scan handler provides police officers with a snapshot of all active ambulances. It uses `GEOSEARCH` with a large radius (100 km) to find all ambulances near the configured center point, then retrieves each ambulance's exact position using `GEOPOS`. The handler supports both Socket.IO callbacks and event-based responses for flexibility.

## 5.9 Frontend Implementation

The Flutter frontend is organized following the Screen-Service pattern, with clear separation between UI presentation (screens) and business logic (services).

### 5.9.1 Project Structure

```
frontend/lib/
├── main.dart                          # App entry point (31 lines)
├── services/
│   ├── socket_io_service.dart         # Socket.IO client (326 lines)
│   ├── auth_service.dart              # Authentication API (180 lines)
│   ├── map_api_service.dart           # Map routing service
│   └── osm_search_service.dart        # Place search service
└── presentation/
    └── screens/
        ├── home_screen.dart           # Landing page
        ├── login_screen.dart          # Login form
        ├── signup_screen.dart         # Registration form
        ├── driver_screen.dart         # Driver map interface (465 lines)
        └── police_screen.dart         # Police monitoring (914 lines)
```

## 5.10 Flutter Application Entry Point

The `main.dart` file configures the application with Provider-based state management:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/socket_io_service.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SocketService(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ambulance Tracking System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
```

The `ChangeNotifierProvider` wraps the entire application, making the `SocketService` instance available to all screens via Provider's dependency injection. This ensures a single, shared socket connection across the application lifecycle.

## 5.11 Socket Service Implementation

The `SocketService` class (`socket_io_service.dart`) is the central communication service that manages the Socket.IO connection and provides reactive data streams.

### 5.11.1 Data Models

```dart
class AmbulancePosition {
  final String ambulanceId;
  final double lat;
  final double lng;
  final double? heading;

  factory AmbulancePosition.fromJson(Map<String, dynamic> json) {
    return AmbulancePosition(
      ambulanceId: json['ambulanceId'] ?? json['driverId'] ?? 'unknown',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
    );
  }
}

class ProximityAlert {
  final String ambulanceId;
  final String message;

  factory ProximityAlert.fromJson(Map<String, dynamic> json) {
    return ProximityAlert(
      ambulanceId: json['ambulanceId'] ?? 'unknown',
      message: json['message'] ?? 'Ambulance is approaching!',
    );
  }
}
```

### 5.11.2 Connection Management

The `SocketService` extends `ChangeNotifier` to provide reactive updates to the UI:

```dart
class SocketService with ChangeNotifier {
  IO.Socket? _socket;
  static const String _defaultSocketUrl = 'https://final-year-app.onrender.com';
  String _currentSocketUrl = _defaultSocketUrl;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;

  // Broadcast streams for reactive UI updates
  final StreamController<AmbulancePosition> _positionUpdateController = StreamController.broadcast();
  final StreamController<ProximityAlert> _alertController = StreamController.broadcast();
}
```

Key features of the connection management:
- **Configurable URL:** The socket URL is stored in `SharedPreferences`, allowing users to configure the server address during login
- **Connection Status Tracking:** A `ConnectionStatus` enum (`disconnected`, `connecting`, `connected`, `error`) provides UI feedback
- **Automatic Reconnection:** Socket.IO is configured with automatic reconnection (5 attempts, 2-second delay)
- **Broadcast Streams:** `StreamController.broadcast()` enables multiple listeners (multiple screens) on the same data stream

### 5.11.3 Socket Initialization

```dart
void _initSocket() {
  _socket = IO.io(_currentSocketUrl, <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
    'reconnection': true,
    'reconnectionAttempts': 5,
    'reconnectionDelay': 2000,
  });

  _socket!.onConnect((_) {
    _updateConnectionStatus(ConnectionStatus.connected);
    // Re-send join event on reconnect
    if (_currentUserId != null && _currentRole != null) {
      _socket!.emit('join', {
        'userId': _currentUserId!,
        'role': _currentRole!,
        'location': _currentLocation != null ? {
          'lat': _currentLocation!.latitude,
          'lng': _currentLocation!.longitude
        } : null,
      });
    }
  });
}
```

The socket is configured to use WebSocket transport exclusively (no fallback to polling) for optimal performance. Upon connection or reconnection, the service automatically re-sends the `join` event with stored credentials, ensuring seamless recovery from network interruptions.

## 5.12 Authentication Service

The `AuthService` class provides HTTP-based authentication through static and instance methods:

```dart
class AuthService {
  static const String _baseUrl = "https://final-year-app.onrender.com/api/v1/user";

  Future<bool> signUp({required String username, required String password, required String role}) async {
    final String apiRole = role == 'Ambulance Driver' ? 'driver' : 'police';
    final response = await http.post(
      Uri.parse('$_baseUrl/signup'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password, 'role': apiRole}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', responseBody['token']);
      await prefs.setString('user_role', responseBody['role']);
      await prefs.setString('user_id', responseBody['id'].toString());
      return true;
    }
    // ... error handling
  }
}
```

The service handles role name translation between user-friendly labels (`'Ambulance Driver'`, `'Traffic Police'`) and API-level identifiers (`'driver'`, `'police'`). Upon successful authentication, the JWT token, role, and user ID are persisted in `SharedPreferences` for session management.

## 5.13 Map and Geolocation Services

### 5.13.1 Map Integration

The ATS uses `flutter_map` with OpenStreetMap tiles for map rendering. The map configuration includes:

```dart
FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: _currentPosition,
    initialZoom: 17.0,
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      subdomains: const ['a', 'b', 'c'],
      userAgentPackageName: 'com.ats.ambulancetracker',
    ),
  ],
)
```

OpenStreetMap was chosen over Google Maps for several reasons:
- No API key required, eliminating setup friction
- Free and open-source with no usage limits
- Comprehensive global map coverage
- Strong community support and regular updates

### 5.13.2 GPS Location Access

The `geolocator` package provides access to the device's GPS hardware:

```dart
void _startRealTracking() {
  _gpsSub = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3,
    ),
  ).listen((p) {
    setState(() => _currentSpeed = p.speed * 3.6); // m/s to km/h
    final gpsHeading = (p.speed > 1.0 && p.heading >= 0) ? p.heading : null;
    _onLocationNew(LatLng(p.latitude, p.longitude), gpsHeading: gpsHeading);
  });
}
```

Key configuration decisions:
- **`accuracy: LocationAccuracy.high`** — Requests the best available GPS accuracy
- **`distanceFilter: 3`** — Only generates updates when the device moves at least 3 meters, reducing unnecessary network traffic
- **Speed calculation:** GPS speed (in m/s) is converted to km/h for display
- **Heading filtering:** GPS heading is only used when speed exceeds 1 m/s, as heading values are unreliable at very low speeds

## 5.14 Home Screen Implementation

The home screen serves as the application's landing page, featuring a navigation bar with login/signup buttons, a hero section with an emergency icon and call-to-action buttons, feature highlight cards (GPS Tracking, Proximity Alerts, Security), and a footer section. The screen uses Material Design 3 components with a professional color scheme of navy blue headings, accent blue buttons, and white backgrounds.

## 5.15 Login and Signup Screens

### 5.15.1 Login Screen

The login screen provides username and password input fields with a configurable server URL feature:

- Users enter their credentials in styled text fields
- A server URL configuration option allows connecting to different backend instances (useful for development and testing)
- Upon successful login, the screen extracts the user's role from the response and navigates to the appropriate screen (DriverScreen for drivers, PoliceScreen for police officers)
- The Socket.IO connection is established immediately after successful authentication

### 5.15.2 Signup Screen

The signup screen extends the login screen with role selection:

- Users select their role from a dropdown: "Ambulance Driver" or "Traffic Police"
- The role selection determines which screen the user is navigated to after registration
- Password field includes a visibility toggle for user convenience
- Client-side validation ensures all fields are filled before submission

## 5.16 Driver Screen Implementation

The driver screen (`driver_screen.dart`, 465 lines) is the primary interface for ambulance personnel, featuring a full-screen map with real-time vehicle tracking.

### 5.16.1 Map Display and Vehicle Marker

The driver screen displays a full-screen `FlutterMap` with the current vehicle position indicated by a custom directional marker:

```dart
MarkerLayer(markers: [
  Marker(
    point: _currentPosition,
    width: 80, height: 80,
    child: Transform.rotate(
      angle: _currentHeading * (math.pi / 180),
      child: _buildVehicleMarker(),
    ),
  ),
]),
```

The vehicle marker is implemented using a custom `CustomPainter` (`_DirectionArrowPainter`) that draws a navigation-style arrow with:
- A circular body with gradient shadow
- A white border ring
- An upward-pointing directional chevron
- Color coding: red when live, grey when offline
- A pulsing glow animation when the ambulance is in live mode

### 5.16.2 Smooth Marker Animation

Rather than teleporting the marker from one GPS position to the next, the driver screen implements smooth interpolation animation:

```dart
void _glideTo(LatLng end, double heading) {
  _moveAnim?.dispose();
  _moveAnim = AnimationController(
    duration: const Duration(milliseconds: 1200), vsync: this);
  final latT = Tween<double>(begin: _currentPosition.latitude, end: end.latitude);
  final lngT = Tween<double>(begin: _currentPosition.longitude, end: end.longitude);
  _moveAnim!.addListener(() {
    setState(() {
      _currentPosition = LatLng(
        latT.evaluate(CurvedAnimation(parent: _moveAnim!, curve: Curves.easeOut)),
        lngT.evaluate(CurvedAnimation(parent: _moveAnim!, curve: Curves.easeOut)),
      );
      _currentHeading = heading;
    });
    if (_autoFollow) _mapController.move(_currentPosition, 17.5);
  });
  _moveAnim!.forward();
}
```

This animation uses latitude and longitude tweens with an `easeOut` curve to create a smooth, deceleration-like movement that mimics natural vehicle motion.

### 5.16.3 Heading Calculation

The bearing (heading) between two geographic points is calculated using the forward azimuth formula:

```dart
double _calculateAngle(LatLng a, LatLng b) {
  double lat1 = a.latitude * (math.pi / 180);
  double lat2 = b.latitude * (math.pi / 180);
  double dLon = (b.longitude - a.longitude) * (math.pi / 180);
  double y = math.sin(dLon) * math.cos(lat2);
  double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}
```

This formula computes the great-circle bearing from point A to point B, which is used to rotate the vehicle marker in the correct direction of travel. The GPS-reported heading is preferred when the vehicle speed exceeds 1 m/s, with this calculated heading used as a fallback.

### 5.16.4 UI Components

The driver screen includes several UI overlay components:

1. **Navigation Header (live mode):** A dark floating card at the top showing "NAVIGATING LIVE" status and a color-coded speed indicator (green < 40 km/h, orange 40-60 km/h, red > 60 km/h)

2. **Route Trail:** A polyline layer showing the last 30 GPS positions as a route trail, colored red during live mode and grey when offline

3. **Bottom Action Card:** Displays the mission status ("ON DUTY" / "OFFLINE") with a GPS status indicator and a large action button ("GO LIVE" / "END MISSION")

4. **Re-center Button:** Appears when the user manually pans the map, allowing them to re-center on their current position

## 5.17 Police Screen Implementation

The police screen (`police_screen.dart`, 914 lines) is the most complex UI component, providing a comprehensive monitoring dashboard for traffic police officers.

### 5.17.1 Real-Time Ambulance Monitoring

The screen maintains a map of active ambulances and subscribes to the `SocketService` streams:

```dart
_socketService.positionUpdateStream.listen((pos) {
  if (mounted) {
    setState(() => _activeAmbulances[pos.ambulanceId] = pos);
    _updateDistanceToNearest();
  }
});

_socketService.alertStream.listen((alert) {
  _triggerAlert(alert);
});
```

Each ambulance is displayed on the map with a color-coded distance label:
- **Red:** < 0.5 km (immediate vicinity)
- **Orange:** 0.5-1.0 km (approaching)
- **Yellow:** 1.0-2.0 km (nearby)
- **Green:** > 2.0 km (distant)

### 5.17.2 Proximity Alert System

When a proximity alert is received, the police screen triggers a multi-sensory notification:

```dart
void _triggerAlert(ProximityAlert alert) async {
  _alertCount++;

  // 1. Haptic feedback - strong vibration pattern
  await Vibration.vibrate(
    pattern: [0, 800, 200, 800, 200, 800],
    intensities: [0, 255, 0, 255, 0, 255]
  );

  // 2. Audio feedback - siren sound
  await _audioPlayer.play(AssetSource('sounds/siren.mp3'));

  // 3. Visual feedback - animated alert banner
  setState(() => _currentAlert = alert);
  _alertAnimController.forward(from: 0.0);

  // 4. Map focus - centers on approaching ambulance
  final pos = _activeAmbulances[alert.ambulanceId];
  if (pos != null) _mapController.move(LatLng(pos.lat, pos.lng), 15.0);

  // 5. Auto-dismiss after 12 seconds
  _alertTimer = Timer(const Duration(seconds: 12), () {
    if (mounted) { _alertAnimController.reverse(); _audioPlayer.stop(); }
  });
}
```

### 5.17.3 Statistics Dashboard

The police screen features a glassmorphism statistics dashboard showing:
- **Active Ambulances Count:** Number of ambulances currently being tracked
- **Alert Count:** Total proximity alerts received during the session
- **Nearest Distance:** Distance to the closest ambulance in kilometers
- **Detection Radius:** The configured alert radius (2.5 km)
- **Connection Status:** Real-time Socket.IO connection status indicator
- **Duty Duration:** Timer showing how long the officer has been on duty

### 5.17.4 Ambulance List Sheet

A draggable bottom sheet lists all active ambulances with:
- Color-coded status icons based on distance
- Distance calculations using the Haversine formula (via `latlong2` package)
- A "focus" button to center the map on a specific ambulance
- Unit count badge showing total active ambulances

### 5.17.5 Map Controls

Floating action buttons provide additional functionality:
- **Scan Button:** Triggers the `scanAmbulances` Socket.IO event to discover all active ambulances
- **Zoom Controls:** Manual zoom in/out buttons
- **Re-center Button:** Returns the map to the officer's base location

## 5.18 Custom Map Markers and Animations

### 5.18.1 Vehicle Marker (Driver)

The vehicle marker uses a `CustomPainter` implementation for pixel-perfect rendering:

```dart
class _DirectionArrowPainter extends CustomPainter {
  final bool isLive;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow shadow
    final shadowPaint = Paint()
      ..color = (isLive ? Colors.red : Colors.grey).withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius * 0.7, shadowPaint);

    // Main body circle
    canvas.drawCircle(center, radius * 0.55, Paint()..color = isLive ? Colors.red : Colors.grey[700]!);

    // White border
    canvas.drawCircle(center, radius * 0.55, Paint()
      ..color = Colors.white ..style = PaintingStyle.stroke ..strokeWidth = 2.5);

    // Upward-pointing direction arrow
    final arrowPath = Path();
    arrowPath.moveTo(center.dx, center.dy - radius * 0.85);
    arrowPath.lineTo(center.dx - radius * 0.25, center.dy - radius * 0.45);
    arrowPath.lineTo(center.dx + radius * 0.25, center.dy - radius * 0.45);
    arrowPath.close();
    canvas.drawPath(arrowPath, Paint()..color = Colors.white);
  }
}
```

### 5.18.2 Police Station Marker

The police station is represented with a styled container widget:

```dart
Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.blue[900],
    boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 15)]
  ),
  child: const Icon(Icons.security, color: Colors.white, size: 35),
)
```

### 5.18.3 Radar Pulse Animation

The police screen features an animated pulse zone around the officer's location, implemented using `AnimationController` and `CircleLayer`:

```dart
_pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
_pulseAnimation = Tween<double>(begin: 1.0, end: 3.5).animate(
  CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut)
);
_pulseController.repeat(reverse: true);
```

This creates a continuously pulsing circle overlay on the map that visually communicates the detection radius to the officer, with the border width oscillating between 1.0 and 3.5 pixels.

---

\newpage

