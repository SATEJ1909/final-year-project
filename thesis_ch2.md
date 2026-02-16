
# CHAPTER 2: LITERATURE REVIEW

## 2.1 Introduction to Emergency Medical Services

Emergency Medical Services (EMS) constitute a critical component of the public healthcare infrastructure in every nation. The EMS system encompasses the complete chain of response from the moment an emergency call is placed to the delivery of the patient to a definitive care facility. According to Tintinalli et al. (2016), modern EMS systems are built upon four fundamental pillars: rapid recognition of emergencies, prompt dispatch of trained personnel, efficient transportation to appropriate facilities, and pre-hospital medical care during transit.

The historical development of organized EMS systems can be traced back to the establishment of hospital-based ambulance services in major cities during the late 19th and early 20th centuries. However, the modern concept of a coordinated, nationwide EMS system was largely catalyzed by the publication of the landmark report "Accidental Death and Disability: The Neglected Disease of Modern Society" by the National Academy of Sciences in 1966. This report highlighted the deficiencies in emergency medical care and led to the passage of the Highway Safety Act of 1966 and the Emergency Medical Services Systems Act of 1973 in the United States, which established the framework for organized EMS systems.

In the Indian context, emergency medical services have undergone significant transformation over the past two decades. The launch of the 108 Emergency Response Service by the Emergency Management and Research Institute (EMRI) in 2005, beginning with the state of Andhra Pradesh, marked a pivotal moment in Indian EMS history. This service, which provides free emergency ambulance transportation to the nearest hospital, has since expanded to cover multiple states across India. According to EMRI's operational data, the average emergency response time in covered areas ranges from 15 to 30 minutes, depending on urban or rural classification. However, these response times are significantly higher than the recommended standards of 8-10 minutes set by international EMS organizations.

The critical factor that determines the effectiveness of an EMS system is the response time — the duration between the receipt of an emergency call and the arrival of the ambulance at the scene. Research by Blackwell and Kaufman (2002) demonstrated a statistically significant relationship between ambulance response times and patient survival rates for time-sensitive emergencies such as cardiac arrests, strokes, and severe trauma. Their study found that each additional minute of delay in ambulance response reduced the probability of survival by approximately 7% for out-of-hospital cardiac arrests.

The challenge of minimizing ambulance response times is multi-faceted. While factors such as ambulance deployment strategies, dispatch algorithms, and pre-hospital care protocols play important roles, the physical transportation of the ambulance through urban traffic represents a significant and often underappreciated bottleneck. A study by Gonzalez et al. (2009) found that in urban areas with moderate to heavy traffic, the actual travel time of an ambulance constituted 60-75% of the total response time, with the remaining time spent on dispatch processing and crew mobilization. This finding underscores the importance of traffic management as a lever for improving ambulance response times.

The intersection between technology and EMS has been a fertile area of research and development. The emergence of GPS-based vehicle tracking, real-time communication protocols, geographic information systems (GIS), and mobile computing has opened new possibilities for improving every aspect of the EMS chain. The Ambulance Tracking System (ATS) presented in this thesis contributes to this intersection by addressing the specific challenge of real-time coordination between ambulance drivers and traffic police officers.

## 2.2 Evolution of Vehicle Tracking Systems

Vehicle tracking systems have evolved significantly over the past several decades, progressing from basic radio-based position reporting to sophisticated GPS-enabled real-time tracking platforms. Understanding this evolution provides context for the technological choices made in the ATS.

**First Generation — Radio-Based Tracking (1960s-1980s):**
The earliest vehicle tracking systems relied on radio communication between vehicles and dispatch centers. Operators at central dispatch facilities would periodically request position reports from vehicle operators, who would verbally report their approximate locations based on known landmarks. This approach was highly imprecise, labor-intensive, and provided no continuous tracking capability.

**Second Generation — Cellular Network-Based Tracking (1990s):**
With the proliferation of cellular networks, vehicle tracking systems began to leverage cell tower triangulation to estimate vehicle positions. While this approach provided automated position updates without manual reporting, the accuracy was limited (typically 100-300 meters in urban areas) and was heavily dependent on cell tower density.

**Third Generation — GPS-Based Tracking (2000s):**
The selective availability of GPS signals to civilian users (following the removal of intentional signal degradation by the US government in May 2000) revolutionized vehicle tracking. GPS receivers could now provide position accuracy of 5-15 meters, enabling precise vehicle tracking for the first time. Early GPS-based fleet tracking systems combined GPS receivers with GSM modems to transmit position data to centralized servers. Companies like Fleet Complete, Trimble, and Geotab developed commercial fleet management solutions during this period.

**Fourth Generation — Smartphone-Based Tracking (2010s-Present):**
The widespread adoption of GPS-enabled smartphones has democratized vehicle tracking, eliminating the need for dedicated hardware. Modern smartphones contain highly accurate GPS chipsets (often augmented by A-GPS, Wi-Fi positioning, and cellular triangulation) and always-on internet connectivity, making them ideal platforms for real-time location tracking applications. This is the paradigm leveraged by the ATS, which uses the `geolocator` package in Flutter to access the smartphone's GPS hardware.

| Generation | Technology | Accuracy | Update Frequency | Cost |
|---|---|---|---|---|
| 1st | Radio reporting | ~500m-1km | Minutes (manual) | Low |
| 2nd | Cell tower triangulation | 100-300m | 30-60 seconds | Medium |
| 3rd | Dedicated GPS + GSM | 5-15m | 10-30 seconds | High |
| 4th | Smartphone GPS | 5-20m | 1-5 seconds | Very Low |

**Table 2.1: Comparison of Vehicle Tracking Technologies**

The ATS utilizes fourth-generation smartphone-based tracking, which offers the best combination of accuracy, update frequency, and cost-effectiveness. The `geolocator` package used in the Flutter frontend accesses the device's GPS hardware and can provide position updates at configurable intervals, with a distance filter of 3 meters ensuring that updates are sent only when meaningful movement has occurred.

## 2.3 GPS Technology and Location-Based Services

The Global Positioning System (GPS) is a satellite-based navigation system maintained by the United States government. It consists of a constellation of at least 24 satellites orbiting the Earth at an altitude of approximately 20,200 kilometers. The system enables GPS receivers to determine their three-dimensional position (latitude, longitude, and altitude) with high accuracy by measuring the time delay of signals received from multiple satellites.

**Principles of GPS Positioning:**
GPS positioning relies on the principle of trilateration — determining a point's position by measuring its distance from three or more known reference points (satellites). Each GPS satellite continuously broadcasts a signal that encodes the satellite's precise position and the exact time of signal transmission. The GPS receiver measures the time taken for each signal to arrive and calculates the distance to each satellite using the speed of light. With distances from at least three satellites, the receiver can compute its two-dimensional position (latitude and longitude). A fourth satellite is required to resolve clock synchronization errors and determine altitude.

**GPS Accuracy Factors:**
The accuracy of GPS positioning is influenced by several factors:

1. **Satellite Geometry (DOP):** The geometric arrangement of visible satellites affects accuracy. When satellites are spread across the sky, accuracy is higher (low DOP — Dilution of Precision). When satellites are clustered together, accuracy degrades (high DOP).

2. **Atmospheric Effects:** GPS signals pass through the ionosphere and troposphere, where they are delayed and refracted. Dual-frequency GPS receivers can mitigate ionospheric delays, but consumer-grade receivers typically use mathematical models for correction.

3. **Multipath Effects:** In urban environments, GPS signals may bounce off buildings, creating multiple signal paths (multipath). This can introduce errors of several meters, particularly in urban canyons with tall buildings.

4. **Receiver Quality:** The quality of the GPS chipset in the receiving device affects accuracy. Modern smartphone GPS chipsets (such as Qualcomm's series) achieve typical accuracies of 3-5 meters under ideal conditions.

5. **Assisted GPS (A-GPS):** Modern smartphones use A-GPS, which supplements GPS satellite signals with data from cellular networks to achieve faster initial position fixes and improved accuracy in challenging environments.

In the context of the ATS, the Flutter frontend uses the `geolocator` package (version 10.1.0) to interface with the device's GPS hardware. The package supports multiple location accuracy levels (low, medium, high, best) and provides additional metadata such as speed, heading, and accuracy estimates. The ATS configures the geolocator for high accuracy with a distance filter of 3 meters, ensuring that location updates are generated whenever the device moves at least 3 meters from its last reported position.

**Location-Based Services (LBS):**
The availability of accurate, real-time positioning data has spawned a broad category of applications known as Location-Based Services (LBS). These services leverage the user's current position to provide contextually relevant information, services, or actions. LBS can be categorized into:

- **Reactive LBS:** Services that respond to user requests with location-aware information (e.g., searching for nearby restaurants).
- **Proactive LBS:** Services that automatically trigger actions based on the user's location without explicit requests (e.g., geofencing alerts, proximity notifications).

The ATS falls into the category of proactive LBS, as it automatically triggers proximity alerts to nearby police officers based on the ambulance's real-time position without requiring any explicit action from the officers. This proactive nature is a key differentiator of the ATS from passive tracking systems that merely display vehicle positions on a map.

## 2.4 Real-Time Communication Protocols

Real-time communication is fundamental to the operation of the ATS, as it must transmit location updates from ambulance drivers to police officers with minimal latency. Several communication protocols have been developed for real-time data exchange in web and mobile applications:

**HTTP Polling:**
The simplest approach to receiving server-side updates involves the client periodically sending HTTP requests to the server to check for new data. While straightforward to implement, this approach suffers from high latency (limited by the polling interval), unnecessary network traffic (requests are sent even when no new data is available), and poor scalability (each poll requires a full HTTP request-response cycle).

**HTTP Long Polling:**
An improvement over standard polling, long polling involves the client sending an HTTP request that is held open by the server until new data is available or a timeout occurs. When data arrives, the server responds and the client immediately sends a new request. While reducing latency compared to standard polling, long polling still incurs the overhead of repeated HTTP connections and is not truly bidirectional.

**Server-Sent Events (SSE):**
SSE provides a unidirectional channel from server to client over a single, long-lived HTTP connection. The server can push data to the client at any time without the client needing to poll. However, SSE is limited to server-to-client communication; the client cannot send data back to the server over the same connection. Additionally, SSE does not support binary data and has limited browser support for certain features.

**WebSocket Protocol:**
WebSocket (RFC 6455) provides full-duplex, bidirectional communication over a single TCP connection. After an initial HTTP handshake that upgrades the connection to WebSocket, both the client and server can send data frames to each other at any time with minimal overhead. WebSocket is the protocol best suited for real-time applications that require low-latency, bidirectional communication — making it the natural choice for the ATS.

| Feature | HTTP Polling | Long Polling | SSE | WebSocket |
|---|---|---|---|---|
| Direction | Client → Server | Client → Server | Server → Client | Bidirectional |
| Latency | High (polling interval) | Medium | Low | Very Low |
| Connection | New per request | New per timeout | Single persistent | Single persistent |
| Overhead | High | Medium | Low | Very Low |
| Server Push | No | Partial | Yes | Yes |
| Binary Support | Yes | Yes | No | Yes |
| Scalability | Poor | Fair | Good | Excellent |

**Table 2.2: Comparison of Real-Time Communication Protocols**

The ATS uses the WebSocket protocol via Socket.IO, which provides automatic fallback to other transport mechanisms (such as HTTP long polling) when WebSocket connections cannot be established. This ensures compatibility across a wide range of network environments while defaulting to the highest-performance option when available.

## 2.5 WebSocket Protocol and Socket.IO

**WebSocket Protocol (RFC 6455):**
The WebSocket protocol was standardized by the IETF as RFC 6455 in 2011. It provides a full-duplex communication channel over a single TCP connection, enabling real-time data exchange between clients and servers with minimal overhead. The protocol begins with an HTTP upgrade handshake, after which the connection is promoted to a WebSocket connection that remains open for the duration of the session.

Key characteristics of the WebSocket protocol include:

1. **Low Overhead:** After the initial handshake, WebSocket frames have a minimal header (2-14 bytes), compared to the hundreds of bytes required for HTTP headers. This makes WebSocket highly efficient for frequent, small data transmissions — such as the location updates in the ATS.

2. **Full-Duplex Communication:** Both the client and server can independently send data at any time without waiting for a request or response. This enables truly real-time, event-driven communication.

3. **Persistent Connection:** The WebSocket connection remains open until explicitly closed by either party, eliminating the need for repeated connection establishment.

4. **Protocol-Level Ping/Pong:** WebSocket includes built-in keep-alive mechanisms through ping/pong control frames, enabling connection health monitoring.

**Socket.IO:**
Socket.IO is a JavaScript library that provides a higher-level abstraction over the WebSocket protocol, adding several features that are essential for building robust real-time applications:

1. **Automatic Transport Negotiation:** Socket.IO automatically selects the best available transport mechanism, starting with WebSocket and falling back to HTTP long polling if necessary. This ensures connectivity across a wide range of network environments, including those with restrictive proxies or firewalls.

2. **Rooms and Namespaces:** Socket.IO supports the concept of "rooms" — logical groupings of connected clients that can be targeted with broadcasts. In the ATS, police officers are grouped into a "police" room, allowing the server to broadcast ambulance position updates to all police clients with a single operation.

3. **Acknowledgements:** Socket.IO supports message acknowledgements, allowing the sender to confirm that a message was received and processed by the recipient.

4. **Automatic Reconnection:** Socket.IO includes built-in reconnection logic with configurable parameters (attempts, delays, backoff), ensuring that temporary network disruptions do not permanently disconnect clients.

5. **Binary Support:** Socket.IO supports the transmission of binary data alongside JSON messages.

In the ATS, Socket.IO (version 4.8.1) is used on the backend (Node.js) and `socket_io_client` (version 2.0.3+1) is used on the Flutter frontend. The system defines several custom events for communication:

- `join` — Client identifies itself with userId, role, and optional location
- `updateLocation` — Ambulance sends its current GPS position
- `updatePoliceLocation` — Police officer updates their position
- `ambulancePositionUpdate` — Server broadcasts ambulance position to police room
- `ambulanceProximityAlert` — Server sends targeted alert to nearby police
- `scanAmbulances` — Police requests list of all active ambulances
- `journey_end` — Driver signals end of emergency mission

## 2.6 Geospatial Data Processing and Indexing

Geospatial data processing is at the heart of the ATS's proximity detection mechanism. The system must efficiently answer the question: "Which police officers are within 2.5 km of this ambulance's current position?" This is a spatial query that requires specialized data structures and algorithms.

**The Haversine Formula:**
The distance between two points on the Earth's surface, specified by their latitude and longitude coordinates, is calculated using the Haversine formula. This formula accounts for the curvature of the Earth and provides accurate great-circle distances:

```
a = sin²(Δlat/2) + cos(lat1) × cos(lat2) × sin²(Δlon/2)
d = 2R × atan2(√a, √(1-a))
```

Where:
- `lat1`, `lat2` are the latitudes of the two points (in radians)
- `Δlat` = lat2 - lat1
- `Δlon` = lon2 - lon1
- `R` = Earth's mean radius (6,371 km)
- `d` = great-circle distance between the two points

The Haversine formula provides accuracy better than 0.5% for distances up to 100 km, making it highly suitable for proximity detection applications. In the ATS, the Haversine formula is used by Redis's built-in geospatial commands, which implement this formula internally for distance calculations.

**Geospatial Indexing with Redis:**
Redis, an in-memory data store, provides native support for geospatial data through its GEO commands. Redis's geospatial functionality is built on top of sorted sets, using a geohash encoding scheme that maps two-dimensional coordinates (latitude, longitude) to a one-dimensional sorted set score. This enables efficient spatial queries using the sorted set's underlying skip list data structure.

Key Redis GEO commands used in the ATS include:

1. **GEOADD:** Adds one or more geospatial entries (longitude, latitude, member) to a key. Used to store police officer positions.
   
2. **GEOSEARCH:** Returns members within a specified radius of a given point. Used to find police officers near an ambulance's position.

3. **GEOPOS:** Returns the longitude and latitude of specified members. Used to retrieve stored positions for display.

4. **ZREM:** Removes members from the geospatial index (since it's backed by a sorted set). Used for cleanup when users disconnect.

The advantage of using Redis for geospatial indexing in the ATS is threefold:
- **Performance:** Redis operates entirely in memory, achieving sub-millisecond latency for geospatial queries.
- **Simplicity:** Redis's GEO commands provide a high-level API that abstracts away the complexity of geospatial indexing.
- **Scalability:** Redis can handle millions of geospatial entries with consistent performance.

## 2.7 Existing Ambulance Tracking Systems

Several ambulance tracking and emergency response systems have been developed and deployed in various parts of the world. A review of these systems provides context for the ATS and highlights both commonalities and differentiators.

**1. GVK EMRI 108 Ambulance Service (India):**
The GVK EMRI 108 service is India's largest emergency ambulance service, operating across 15 states. The system uses GPS-based vehicle tracking, computer-aided dispatch (CAD), and an integrated communication system to manage ambulance operations. The 108 service includes an Emergency Response Centre (ERC) that receives calls, dispatches the nearest available ambulance, and tracks its progress. However, the system does not include a mechanism for alerting traffic police officers about approaching ambulances.

**2. RapidSOS (United States):**
RapidSOS is a technology platform that connects emergency callers with 911 dispatchers, providing precise location data and additional context to improve emergency response. The platform integrates with existing 911 infrastructure and leverages smartphone sensor data for improved positioning accuracy. While RapidSOS focuses on the dispatch and caller-dispatcher communication aspects, it does not address the traffic management challenge.

**3. Waze Beacon for Emergency Vehicles:**
Waze, the crowd-sourced navigation application owned by Google, introduced a feature that alerts Waze users about approaching emergency vehicles. This system relies on integration with emergency dispatch systems and uses the Waze app's push notification system to alert nearby drivers. While innovative, this approach targets civilian drivers rather than traffic police officers and requires widespread Waze adoption among the driving population.

**4. EMS Vehicle Preemption Systems:**
Traffic signal preemption systems, such as those marketed by Opticom (by Global Traffic Technologies) and Virchow Krause, use emitter-detector pairs to detect approaching emergency vehicles and automatically change traffic signals to provide a green corridor. While highly effective, these systems require significant hardware infrastructure investment at each intersection and are primarily deployed in developed countries.

**5. Academic Research Systems:**
Several academic studies have proposed ambulance tracking systems with varying levels of sophistication. Khatri et al. (2019) proposed a system using IoT sensors and cloud computing for ambulance tracking. Patel and Shah (2020) developed a system using Firebase real-time database for location synchronization. Kumar and Singh (2021) proposed a system using MQTT protocol for lightweight real-time communication.

| System | Tracking | Police Alerts | Traffic Signal | Cost | Open Source |
|---|---|---|---|---|---|
| GVK EMRI 108 | GPS + CAD | No | No | High | No |
| RapidSOS | Smartphone sensors | No | No | Medium | No |
| Waze Beacon | Crowd-sourced | Civilian alerts | No | Low | No |
| Opticom/EVP | Emitter-detector | Indirect | Yes | Very High | No |
| **ATS (This Project)** | **Smartphone GPS** | **Yes (Proximity)** | **No** | **Very Low** | **Yes** |

**Table 2.3: Comparison of Existing Ambulance Tracking Systems**

The ATS differentiates itself from existing systems through its combination of real-time ambulance tracking with targeted, proximity-based alerts specifically to traffic police officers. This unique focus on the ambulance-police coordination gap, combined with the system's low-cost, smartphone-based architecture, positions the ATS as a complementary solution that can be deployed alongside existing emergency response infrastructure.

## 2.8 Mobile Application Frameworks

The choice of mobile application framework significantly impacts development efficiency, application performance, and deployment reach. Several frameworks were evaluated for the ATS frontend:

**Native Development (Java/Kotlin for Android, Swift for iOS):**
Native development provides the best performance and full access to platform-specific APIs. However, it requires maintaining separate codebases for each platform, doubling development effort and time.

**React Native:**
React Native, developed by Facebook (now Meta), enables cross-platform mobile development using JavaScript and React. It uses a bridge architecture to communicate between JavaScript logic and native UI components. While widely adopted, React Native has been criticized for bridge-related performance bottlenecks, particularly in applications with complex animations or high-frequency data updates.

**Flutter:**
Flutter, developed by Google, uses the Dart programming language and a custom rendering engine (Skia) that draws UI directly on a canvas, bypassing native UI components entirely. This approach provides consistent UI across platforms, smooth 60 FPS animations, and excellent performance for graphically intensive applications. Flutter's widget-based architecture and hot reload feature significantly accelerate development.

**Xamarin:**
Xamarin, owned by Microsoft, enables cross-platform development using C# and .NET. While providing good native API access, Xamarin has a smaller community and fewer third-party packages compared to React Native and Flutter.

| Feature | Native | React Native | Flutter | Xamarin |
|---|---|---|---|---|
| Language | Java/Kotlin/Swift | JavaScript | Dart | C# |
| Performance | Excellent | Good | Excellent | Good |
| UI Consistency | Platform-specific | Near-native | Pixel-perfect | Near-native |
| Community | Large | Very Large | Growing rapidly | Medium |
| Hot Reload | Limited | Yes | Yes | Limited |
| Map Support | Native Maps | React Native Maps | flutter_map | Xamarin.Forms.Maps |
| Real-time (Socket.IO) | Good | Good | Good | Fair |
| Learning Curve | Medium | Low | Medium | Medium |

**Table 2.4: Comparison of Mobile Application Frameworks**

Flutter was selected for the ATS frontend for several reasons:
1. Excellent performance for map rendering and real-time marker animations
2. Cross-platform deployment from a single codebase
3. Rich ecosystem of packages including `flutter_map`, `geolocator`, `socket_io_client`, and `provider`
4. Dart's strong type system provides compile-time safety
5. Hot reload accelerates the development-test cycle

## 2.9 NoSQL Databases in Real-Time Applications

The ATS uses MongoDB, a document-oriented NoSQL database, for persistent data storage. The choice of a NoSQL database over a traditional relational database (RDBMS) was driven by several factors relevant to real-time applications:

**Document-Oriented Design:**
MongoDB stores data as JSON-like documents (BSON format), which map naturally to the objects used in JavaScript/TypeScript applications. In the ATS, user records containing username, password hash, and role can be stored as documents without the schema constraints of relational tables.

**Schema Flexibility:**
NoSQL databases offer schema flexibility that is advantageous during rapid development. As the ATS evolved, the user schema could be modified without requiring database migration scripts or downtime.

**Horizontal Scalability:**
MongoDB supports horizontal scaling through sharding, where data is distributed across multiple servers. This capability is important for applications that may need to scale to handle large numbers of users across multiple regions.

**Integration with Node.js:**
MongoDB integrates seamlessly with Node.js through the Mongoose ODM (Object Document Mapper), which provides schema validation, type casting, query building, and business logic hooks. The ATS uses Mongoose (version 8.19.1) to define user schemas with validation rules, unique constraints, and automatic timestamping.

The ATS uses MongoDB for storing user authentication data (usernames, hashed passwords, and roles), while Redis handles all real-time geospatial data. This separation of concerns — persistent data in MongoDB, ephemeral real-time data in Redis — follows the polyglot persistence pattern recommended for modern applications with diverse data access patterns.

## 2.10 In-Memory Data Stores and Caching

Redis (Remote Dictionary Server) serves as the in-memory data store in the ATS, handling two critical functions: geospatial indexing of police officer locations and mapping user IDs to socket IDs for targeted messaging.

**Redis Architecture:**
Redis is a single-threaded, in-memory data structure store that supports various data types including strings, hashes, lists, sets, sorted sets, and geospatial indexes. Its single-threaded architecture avoids the overhead of context switching and lock contention, enabling it to handle hundreds of thousands of operations per second on a single core.

**In-Memory Performance:**
Since all data resides in RAM, Redis achieves sub-millisecond latency for most operations. This is critical for the ATS's proximity detection mechanism, which must execute geospatial queries on every ambulance location update (every 3 seconds per ambulance) and deliver results before the next update arrives.

**Data Structures Used in the ATS:**
1. **Geospatial Set (`police_locations`):** Stores the positions of all connected police officers using Redis's GEO commands. Each entry consists of a longitude, latitude, and member identifier (userId).
2. **Geospatial Set (`ambulance_locations`):** Stores the last known positions of active ambulances for the scan feature.
3. **Hash (`user_sockets`):** Maps user IDs to their Socket.IO socket IDs, enabling the server to send targeted messages to specific users.

**Persistence Options:**
Redis offers two persistence mechanisms — RDB (Redis Database Backup) snapshots and AOF (Append-Only File) logging. For the ATS, persistence is not critical since geospatial data is ephemeral and is naturally repopulated when clients reconnect. However, Redis persistence can be enabled for recovery from server restarts.

## 2.11 Authentication and Security in Real-Time Systems

Security is a critical concern in the ATS, as the system handles sensitive location data and must prevent unauthorized access. The ATS implements authentication using JSON Web Tokens (JWT), a widely adopted standard for securing web and mobile applications.

**JSON Web Tokens (JWT):**
JWT (RFC 7519) is an open standard for creating access tokens that assert claims about a subject. A JWT consists of three parts: a header (specifying the signing algorithm), a payload (containing claims such as user ID and role), and a signature (ensuring token integrity). JWTs are compact, URL-safe, and self-contained — meaning the server can verify a token's authenticity without querying a database.

In the ATS, JWTs are generated upon successful login or signup and include the user's ID and role as payload claims. The token is signed using the HMAC-SHA256 algorithm with a server-side secret (configured via the `JWT_SECRET` environment variable). The Flutter frontend stores the JWT using SharedPreferences and includes it in Socket.IO connection handshakes for authentication.

**Password Security:**
The ATS uses bcrypt for password hashing, with a salt round factor of 10. Bcrypt is an adaptive hashing function based on the Blowfish cipher, designed specifically for password storage. Its key strength is that the computational cost of hashing can be increased over time (by increasing the salt rounds) to keep pace with hardware improvements, ensuring that brute-force attacks remain impractical.

**CORS (Cross-Origin Resource Sharing):**
The ATS backend configures CORS to allow requests from all origins (`origin: "*"`). While this is acceptable for development and demonstration purposes, production deployments should restrict CORS to specific, trusted origins to prevent cross-site request forgery (CSRF) and other cross-origin attacks.

## 2.12 Summary of Literature Review

This literature review has examined the key technologies, concepts, and existing systems relevant to the Ambulance Tracking System:

1. **Emergency Medical Services** face significant challenges in urban environments, where traffic congestion is a major contributor to delayed ambulance response times.

2. **Vehicle tracking systems** have evolved from radio-based manual reporting to GPS-enabled smartphone-based tracking, with modern smartphones providing 5-20 meter accuracy at minimal cost.

3. **GPS technology** provides the positioning foundation for the ATS, with the `geolocator` package enabling high-accuracy location tracking on Flutter-based mobile applications.

4. **WebSocket and Socket.IO** provide the low-latency, bidirectional communication channel essential for real-time location updates and proximity alerts.

5. **Redis geospatial indexing** enables efficient proximity detection using the Haversine formula, with sub-millisecond query latency for finding nearby police officers.

6. **Existing ambulance tracking systems** address various aspects of emergency response but do not specifically target the ambulance-police coordination gap that the ATS addresses.

7. **Flutter** provides an excellent cross-platform framework for building the ATS mobile frontend, with strong support for maps, geolocation, and real-time communication.

8. **MongoDB and Redis** together implement a polyglot persistence strategy that separates persistent authentication data from ephemeral real-time location data.

9. **JWT and bcrypt** provide secure authentication and password storage for the system.

The ATS builds upon these technologies and concepts to create a novel system that specifically addresses the coordination gap between ambulance drivers and traffic police officers — a gap that has been largely overlooked by existing solutions.

---

\newpage

