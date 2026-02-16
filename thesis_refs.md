

# REFERENCES

[1] World Health Organization, "Global Status Report on Road Safety 2023," WHO, Geneva, 2023.

[2] National Crime Records Bureau, "Accidental Deaths and Suicides in India 2022," Ministry of Home Affairs, Government of India, 2022.

[3] S. Faye, N. Louveton, and G. Gheorghe, "A Survey on Real-Time Vehicle Tracking Systems for Emergency Services," *IEEE Access*, vol. 10, pp. 78124–78142, 2022.

[4] A. K. Sharma and R. K. Singh, "GPS-based ambulance tracking and emergency management system: A comprehensive review," *International Journal of Computer Applications*, vol. 176, no. 12, pp. 1–7, 2020.

[5] Node.js Foundation, "Node.js Documentation," [Online]. Available: https://nodejs.org/docs/. [Accessed: Jan. 2026].

[6] Microsoft, "TypeScript Documentation," [Online]. Available: https://www.typescriptlang.org/docs/. [Accessed: Jan. 2026].

[7] Express.js, "Express - Node.js web application framework," [Online]. Available: https://expressjs.com/. [Accessed: Jan. 2026].

[8] Socket.IO, "Socket.IO Documentation," [Online]. Available: https://socket.io/docs/v4/. [Accessed: Jan. 2026].

[9] MongoDB, Inc., "MongoDB Documentation," [Online]. Available: https://docs.mongodb.com/. [Accessed: Jan. 2026].

[10] Redis Ltd., "Redis Documentation — Geospatial Commands," [Online]. Available: https://redis.io/docs/latest/commands/?group=geo. [Accessed: Jan. 2026].

[11] Google, "Flutter Documentation," [Online]. Available: https://docs.flutter.dev/. [Accessed: Jan. 2026].

[12] Dart Team, "Dart Programming Language," [Online]. Available: https://dart.dev/guides. [Accessed: Jan. 2026].

[13] OpenStreetMap Foundation, "OpenStreetMap Wiki," [Online]. Available: https://wiki.openstreetmap.org/. [Accessed: Jan. 2026].

[14] flutter_map contributors, "flutter_map — A Flutter map widget," [Online]. Available: https://pub.dev/packages/flutter_map. [Accessed: Jan. 2026].

[15] Baseflow, "Geolocator Plugin for Flutter," [Online]. Available: https://pub.dev/packages/geolocator. [Accessed: Jan. 2026].

[16] Auth0, "Introduction to JSON Web Tokens," [Online]. Available: https://jwt.io/introduction. [Accessed: Jan. 2026].

[17] OpenJS Foundation, "bcrypt - A library to hash passwords," [Online]. Available: https://www.npmjs.com/package/bcrypt. [Accessed: Jan. 2026].

[18] Mongoose, "Mongoose ODM Documentation," [Online]. Available: https://mongoosejs.com/docs/. [Accessed: Jan. 2026].

[19] Render, "Render Documentation — Deploying Node.js," [Online]. Available: https://render.com/docs. [Accessed: Jan. 2026].

[20] R. Fielding, "Architectural Styles and the Design of Network-based Software Architectures," Doctoral Dissertation, University of California, Irvine, 2000.

[21] I. Fette and A. Melnikov, "The WebSocket Protocol," IETF RFC 6455, Dec. 2011.

[22] V. Cerf et al., "Internet Protocol," IETF RFC 791, Sept. 1981.

[23] M. Fowler, "Patterns of Enterprise Application Architecture," Addison-Wesley Professional, 2002.

[24] S. Newman, "Building Microservices: Designing Fine-Grained Systems," 2nd ed., O'Reilly Media, 2021.

[25] C. Richardson, "Microservices Patterns: With Examples in Java," Manning Publications, 2018.

[26] P. K. Sahoo and S. K. Patra, "Smart Ambulance System Using IoT and Cloud Computing: A Review," *Journal of King Saud University - Computer and Information Sciences*, vol. 34, no. 6, pp. 3045–3058, 2022.

[27] A. Patel, B. Gupta, and C. Kumar, "Intelligent Traffic Management for Emergency Vehicles Using IoT: A Survey," *Sensors*, vol. 21, no. 16, p. 5600, 2021.

[28] Provider Package Contributors, "Provider — A wrapper around InheritedWidget," [Online]. Available: https://pub.dev/packages/provider. [Accessed: Jan. 2026].

[29] MongoDB Atlas, "MongoDB Atlas Documentation — Free Tier Clusters," [Online]. Available: https://www.mongodb.com/docs/atlas/. [Accessed: Jan. 2026].

[30] Redis Cloud, "Redis Cloud Documentation," [Online]. Available: https://redis.io/docs/latest/operate/rc/. [Accessed: Jan. 2026].

---

\newpage

# APPENDICES

## Appendix A: API Documentation

### A.1 REST API Endpoints

**Base URL:** `https://final-year-app.onrender.com/api/v1/user`

#### POST /signup
Creates a new user account.

**Request Body:**
```json
{
  "username": "string (required, unique)",
  "password": "string (required)",
  "role": "string (required, 'driver' | 'police')"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "User created successfully",
  "token": "JWT token string",
  "role": "driver | police",
  "id": "MongoDB ObjectId"
}
```

**Error Responses:**
- `400` — User already exists
- `500` — Server error

#### POST /login
Authenticates an existing user.

**Request Body:**
```json
{
  "username": "string (required)",
  "password": "string (required)"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User logged in successfully",
  "token": "JWT token string",
  "role": "driver | police",
  "id": "MongoDB ObjectId"
}
```

**Error Responses:**
- `404` — User not found
- `401` — Invalid credentials
- `500` — Server error

### A.2 Socket.IO Events

**Connection URL:** `wss://final-year-app.onrender.com`

#### Client → Server Events

| Event | Payload | Description |
|-------|---------|-------------|
| `join` | `{ userId, role, location?: { lat, lng } }` | Register user identity and optional location |
| `updateLocation` | `{ ambulanceId, lat, lng, heading? }` | Send ambulance position update |
| `updatePoliceLocation` | `{ userId, lat, lng }` | Update police officer position |
| `scanAmbulances` | `{}` | Request list of all active ambulances |
| `journey_end` | `{ ambulanceId }` | Signal end of emergency mission |

#### Server → Client Events

| Event | Payload | Description |
|-------|---------|-------------|
| `ambulancePositionUpdate` | `{ ambulanceId, lat, lng, heading }` | Broadcast ambulance position to all police |
| `ambulanceProximityAlert` | `{ ambulanceId, message }` | Targeted alert to nearby police officer |
| `scanResult` | `{ success, ambulances: [{ ambulanceId, lat, lng }] }` | Response to scan request |

## Appendix B: Dependency List

### B.1 Backend Dependencies (package.json)

| Package | Version | Purpose |
|---------|---------|---------|
| express | ^4.21.2 | HTTP server framework |
| socket.io | ^4.8.1 | WebSocket server |
| mongoose | ^8.12.1 | MongoDB ODM |
| redis | ^5.8.3 | Redis client |
| jsonwebtoken | ^9.0.2 | JWT token generation and verification |
| bcrypt | ^5.1.1 | Password hashing |
| cors | ^2.8.5 | Cross-Origin Resource Sharing |
| dotenv | ^16.4.7 | Environment variable management |
| zod | ^3.24.1 | Schema validation |
| typescript | ^5.x | TypeScript compiler (devDependency) |

### B.2 Frontend Dependencies (pubspec.yaml)

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_map | ^7.0.2 | OpenStreetMap map widget |
| latlong2 | ^0.9.1 | Geographic coordinate operations |
| geolocator | ^13.0.2 | GPS location access |
| socket_io_client | ^3.0.2 | Socket.IO client |
| provider | ^6.1.2 | State management |
| http | ^1.2.2 | HTTP client for REST API |
| shared_preferences | ^2.3.4 | Local storage |
| audioplayers | ^6.1.0 | Alert sound playback |
| vibration | ^2.0.0 | Haptic feedback |
| lottie | ^3.3.1 | Lottie animation rendering |
| flutter_svg | ^2.0.16 | SVG image rendering |
| geolocator_android | ^4.6.1 | Android geolocation plugin |
| geolocator_apple | ^2.3.7 | iOS geolocation plugin |

## Appendix C: Environment Configuration

### C.1 Backend Environment Variables (.env)

```
DATABASE_URL=mongodb+srv://<username>:<password>@cluster.mongodb.net/<dbname>
REDIS_URL=redis://default:<password>@<host>:<port>
JWT_SECRET=<random-secret-key>
PORT=3000
```

### C.2 Android Permissions (AndroidManifest.xml)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.VIBRATE" />
```

## Appendix D: Deployment Instructions

### D.1 Backend Deployment (Render.com)

1. Push the backend code to a GitHub repository
2. Create a new Web Service on Render.com
3. Connect the GitHub repository
4. Set the build command: `npm install && npm run build`
5. Set the start command: `npm run start`
6. Configure environment variables (DATABASE_URL, REDIS_URL, JWT_SECRET)
7. Deploy

### D.2 Frontend Build (Android APK)

1. Ensure Flutter SDK is installed and configured
2. Run `flutter pub get` to install dependencies
3. Run `flutter build apk --release` for release build
4. The APK is generated at `build/app/outputs/flutter-apk/app-release.apk`

---

