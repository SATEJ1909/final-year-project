# AMBULANCE TRACKING SYSTEM (ATS)

## A Real-Time Emergency Vehicle Tracking and Proximity Alert Platform

---

### A Thesis Submitted in Partial Fulfillment of the Requirements for the Degree of

## Bachelor of Engineering / Bachelor of Technology

### In

## Computer Science and Engineering

---

**Submitted By:**
**Satej** (Student)

**Under the Guidance of:**
**[Guide Name]** (Project Guide)

---

**Department of Computer Science and Engineering**
**[College Name]**
**[University Name]**
**Academic Year: 2025–2026**

---

\newpage

---

## CERTIFICATE

This is to certify that the project titled **"Ambulance Tracking System (ATS) — A Real-Time Emergency Vehicle Tracking and Proximity Alert Platform"** is a bonafide work carried out by **Satej** in partial fulfillment for the award of the degree of **Bachelor of Engineering / Bachelor of Technology in Computer Science and Engineering** from **[University Name]** during the academic year **2025–2026**.

The project has been completed under the guidance and supervision of **[Guide Name]**, Department of Computer Science and Engineering.

| | |
|---|---|
| **Project Guide** | **Head of Department** |
| [Guide Name] | [HOD Name] |
| Date: ____________ | Date: ____________ |

**External Examiner:**
Name: ____________
Date: ____________

---

\newpage

---

## DECLARATION

I hereby declare that the project titled **"Ambulance Tracking System (ATS) — A Real-Time Emergency Vehicle Tracking and Proximity Alert Platform"** submitted to **[University Name]** in partial fulfillment for the award of the degree of **Bachelor of Engineering / Bachelor of Technology in Computer Science and Engineering** is a record of original work done by me under the guidance of **[Guide Name]**, Department of Computer Science and Engineering, **[College Name]**.

I further declare that this work has not been submitted to any other university or institution for the award of any degree or diploma.

**Date:** February 2026
**Place:** [City Name]

**Signature of Student**
Satej

---

\newpage

---

## ACKNOWLEDGEMENT

I would like to express my sincere gratitude to all those who contributed to the successful completion of this project.

First and foremost, I wish to express my deepest gratitude to my project guide, **[Guide Name]**, for providing invaluable guidance, continuous support, and constructive feedback throughout the development of this project. Their expertise in the domain of real-time systems and software engineering was instrumental in shaping the direction of this work.

I am deeply thankful to **[HOD Name]**, Head of the Department of Computer Science and Engineering, for providing the necessary infrastructure, laboratory facilities, and academic resources that made this project possible.

I extend my sincere thanks to **[Principal Name]**, Principal of **[College Name]**, for providing an environment conducive to academic excellence and research.

I would also like to acknowledge the contributions of the open-source community. The technologies and frameworks used in this project — including Node.js, TypeScript, Flutter, Socket.IO, MongoDB, Redis, and OpenStreetMap — are products of collaborative open-source efforts that have made modern software development accessible and powerful.

I am grateful to my classmates and peers who participated in testing the system, provided valuable feedback, and offered suggestions that helped improve the overall quality of the application.

Finally, I owe a deep debt of gratitude to my family and friends for their unwavering encouragement, patience, and moral support throughout the duration of this project.

**Satej**
**[College Name]**
**February 2026**

---

\newpage

---

## ABSTRACT

Emergency medical services (EMS) play a critical role in saving lives during medical emergencies. The timely arrival of ambulances at the scene of an emergency and the swift transportation of patients to medical facilities are decisive factors in patient survival rates. However, in urban environments, ambulance response times are significantly impacted by traffic congestion, inefficient route management, and poor coordination between emergency vehicles and traffic control personnel.

This thesis presents the design, development, and implementation of the **Ambulance Tracking System (ATS)** — a comprehensive real-time emergency vehicle tracking and proximity alert platform. The system addresses the critical need for improved coordination between ambulance drivers and traffic police officers by providing real-time GPS-based location tracking, geospatial proximity alerting, and an interactive map-based user interface.

The ATS employs a modern full-stack architecture comprising a **Node.js/TypeScript backend** with **Express.js** for RESTful API services, **Socket.IO** for bidirectional real-time communication, **MongoDB** for persistent data storage, and **Redis** for high-performance geospatial indexing and in-memory caching. The mobile frontend is built using **Flutter (Dart)**, leveraging **OpenStreetMap** via the `flutter_map` library for map rendering, the `geolocator` package for device GPS integration, and the `socket_io_client` for seamless real-time communication with the backend.

The system supports two primary user roles: **Ambulance Drivers** who broadcast their real-time GPS locations during emergency missions, and **Traffic Police Officers** who receive visual map updates and targeted proximity alerts when an ambulance approaches within a configurable radius (default: 2.5 kilometers). The proximity detection mechanism utilizes Redis geospatial commands (`GEOADD`, `GEOSEARCH`) to perform efficient spatial queries, achieving sub-100-millisecond query latency.

Key results demonstrate that the system achieves an end-to-end location update latency of less than one second, proximity detection accuracy of 99.9%+ (leveraging the Haversine formula), and efficient network utilization averaging approximately 10 KB per minute per active user. The system has been successfully tested with multiple concurrent ambulances and police officers, demonstrating its viability as a real-world emergency coordination tool.

**Keywords:** Real-Time Tracking, GPS, WebSocket, Socket.IO, Geospatial Computing, Emergency Response, Flutter, Node.js, Redis, MongoDB, Proximity Alert, Ambulance Tracking

---

\newpage

---

## TABLE OF CONTENTS

| Chapter | Title | Page |
|---------|-------|------|
| | Certificate | ii |
| | Declaration | iii |
| | Acknowledgement | iv |
| | Abstract | v |
| | Table of Contents | vi |
| | List of Figures | ix |
| | List of Tables | xi |
| | List of Abbreviations | xii |
| **1** | **Introduction** | **1** |
| 1.1 | Background and Motivation | 1 |
| 1.2 | Problem Statement | 4 |
| 1.3 | Objectives of the Project | 6 |
| 1.4 | Scope of the Project | 7 |
| 1.5 | Significance and Real-World Impact | 8 |
| 1.6 | Organization of the Thesis | 10 |
| **2** | **Literature Review** | **12** |
| 2.1 | Introduction to Emergency Medical Services | 12 |
| 2.2 | Evolution of Vehicle Tracking Systems | 15 |
| 2.3 | GPS Technology and Location-Based Services | 18 |
| 2.4 | Real-Time Communication Protocols | 22 |
| 2.5 | WebSocket Protocol and Socket.IO | 25 |
| 2.6 | Geospatial Data Processing and Indexing | 28 |
| 2.7 | Existing Ambulance Tracking Systems | 31 |
| 2.8 | Mobile Application Frameworks | 35 |
| 2.9 | NoSQL Databases in Real-Time Applications | 38 |
| 2.10 | In-Memory Data Stores and Caching | 41 |
| 2.11 | Authentication and Security in Real-Time Systems | 43 |
| 2.12 | Summary of Literature Review | 45 |
| **3** | **System Analysis and Requirements** | **47** |
| 3.1 | Feasibility Study | 47 |
| 3.2 | Requirement Analysis | 50 |
| 3.3 | Functional Requirements | 52 |
| 3.4 | Non-Functional Requirements | 55 |
| 3.5 | User Roles and Use Cases | 57 |
| 3.6 | Use Case Diagrams | 60 |
| 3.7 | Data Flow Diagrams | 63 |
| 3.8 | Hardware and Software Requirements | 66 |
| **4** | **System Design** | **68** |
| 4.1 | System Architecture Overview | 68 |
| 4.2 | High-Level Architecture Diagram | 70 |
| 4.3 | Backend Architecture | 73 |
| 4.4 | Frontend Architecture | 77 |
| 4.5 | Database Design | 80 |
| 4.6 | Redis Data Structures | 83 |
| 4.7 | API Design | 85 |
| 4.8 | WebSocket Event Design | 88 |
| 4.9 | Authentication Flow Design | 91 |
| 4.10 | Geospatial Algorithm Design | 94 |
| 4.11 | User Interface Design | 97 |
| 4.12 | Sequence Diagrams | 100 |
| 4.13 | Class Diagrams | 103 |
| 4.14 | Component Diagrams | 105 |
| **5** | **Implementation** | **107** |
| 5.1 | Development Environment Setup | 107 |
| 5.2 | Backend Implementation | 110 |
| 5.3 | Server Entry Point and Configuration | 112 |
| 5.4 | Database Models and Schema | 115 |
| 5.5 | Authentication Module | 117 |
| 5.6 | Real-Time Location Controller | 120 |
| 5.7 | Redis Client and Geospatial Operations | 124 |
| 5.8 | Socket.IO Event Handling | 127 |
| 5.9 | Frontend Implementation | 130 |
| 5.10 | Flutter Application Entry Point | 132 |
| 5.11 | Socket Service Implementation | 134 |
| 5.12 | Authentication Service | 137 |
| 5.13 | Map and Geolocation Services | 139 |
| 5.14 | Home Screen Implementation | 141 |
| 5.15 | Login and Signup Screens | 143 |
| 5.16 | Driver Screen Implementation | 146 |
| 5.17 | Police Screen Implementation | 149 |
| 5.18 | Custom Map Markers and Animations | 152 |
| **6** | **Testing and Results** | **155** |
| 6.1 | Testing Methodology | 155 |
| 6.2 | Unit Testing | 157 |
| 6.3 | Integration Testing | 159 |
| 6.4 | System Testing | 161 |
| 6.5 | Performance Testing | 163 |
| 6.6 | Security Testing | 166 |
| 6.7 | Usability Testing | 168 |
| 6.8 | Test Results and Analysis | 170 |
| 6.9 | Performance Metrics and Benchmarks | 173 |
| 6.10 | Screenshots and Output Demonstration | 176 |
| **7** | **Conclusion and Future Work** | **180** |
| 7.1 | Summary of Achievements | 180 |
| 7.2 | Limitations | 182 |
| 7.3 | Future Enhancements | 184 |
| 7.4 | Conclusion | 187 |
| | **References** | **189** |
| | **Appendices** | **193** |
| A | Source Code Listings | 193 |
| B | API Documentation | 196 |
| C | WebSocket Event Reference | 198 |
| D | Database Schema Reference | 200 |

---

\newpage

---

## LIST OF FIGURES

| Figure No. | Title | Page |
|------------|-------|------|
| 1.1 | Emergency Response Time Impact on Survival Rates | 3 |
| 1.2 | Traffic Congestion Impact on Ambulance Response | 5 |
| 2.1 | Evolution of Vehicle Tracking Technologies | 16 |
| 2.2 | GPS Satellite Constellation and Trilateration | 19 |
| 2.3 | WebSocket vs HTTP Polling Comparison | 24 |
| 2.4 | Socket.IO Architecture Overview | 26 |
| 2.5 | Geospatial Indexing Methods Comparison | 29 |
| 2.6 | Haversine Formula for Distance Calculation | 30 |
| 3.1 | Use Case Diagram — Driver Role | 60 |
| 3.2 | Use Case Diagram — Police Role | 61 |
| 3.3 | Use Case Diagram — Complete System | 62 |
| 3.4 | Level-0 Data Flow Diagram | 63 |
| 3.5 | Level-1 Data Flow Diagram | 64 |
| 3.6 | Level-2 Data Flow Diagram — Location Update | 65 |
| 4.1 | High-Level System Architecture | 70 |
| 4.2 | Three-Tier Architecture Model | 71 |
| 4.3 | Backend Component Architecture | 73 |
| 4.4 | MVC Pattern in Backend | 74 |
| 4.5 | Frontend Screen-Service Architecture | 77 |
| 4.6 | Provider State Management Flow | 78 |
| 4.7 | MongoDB User Collection Schema | 80 |
| 4.8 | Redis Geospatial Data Structure | 83 |
| 4.9 | REST API Endpoint Design | 85 |
| 4.10 | WebSocket Event Flow Diagram | 88 |
| 4.11 | JWT Authentication Flow | 91 |
| 4.12 | Proximity Detection Algorithm Flowchart | 94 |
| 4.13 | Home Screen UI Wireframe | 97 |
| 4.14 | Driver Screen UI Wireframe | 98 |
| 4.15 | Police Screen UI Wireframe | 99 |
| 4.16 | Sequence Diagram — User Authentication | 100 |
| 4.17 | Sequence Diagram — Location Update and Alert | 101 |
| 4.18 | Sequence Diagram — Proximity Alert | 102 |
| 4.19 | Class Diagram — Backend | 103 |
| 4.20 | Class Diagram — Frontend Services | 104 |
| 4.21 | Component Diagram | 105 |
| 5.1 | Development Environment Architecture | 108 |
| 5.2 | Project Directory Structure | 109 |
| 6.1 | Location Tracking Latency Distribution | 173 |
| 6.2 | Alert System Response Time Graph | 174 |
| 6.3 | Network Bandwidth Utilization | 175 |
| 6.4 | Screenshot — Home Screen | 176 |
| 6.5 | Screenshot — Login Screen | 176 |
| 6.6 | Screenshot — Signup Screen | 177 |
| 6.7 | Screenshot — Driver Screen (Offline) | 177 |
| 6.8 | Screenshot — Driver Screen (Live Tracking) | 178 |
| 6.9 | Screenshot — Police Screen (Monitoring) | 178 |
| 6.10 | Screenshot — Proximity Alert Banner | 179 |

---

\newpage

---

## LIST OF TABLES

| Table No. | Title | Page |
|-----------|-------|------|
| 2.1 | Comparison of Vehicle Tracking Technologies | 17 |
| 2.2 | Comparison of Real-Time Communication Protocols | 23 |
| 2.3 | Comparison of Existing Ambulance Tracking Systems | 33 |
| 2.4 | Comparison of Mobile Application Frameworks | 36 |
| 2.5 | Comparison of NoSQL Database Systems | 39 |
| 3.1 | Functional Requirements Specification | 53 |
| 3.2 | Non-Functional Requirements Specification | 55 |
| 3.3 | Hardware Requirements | 66 |
| 3.4 | Software Requirements — Development | 67 |
| 3.5 | Software Requirements — Runtime | 67 |
| 4.1 | Backend Technology Stack | 73 |
| 4.2 | Frontend Technology Stack | 77 |
| 4.3 | REST API Endpoints | 86 |
| 4.4 | WebSocket Client-to-Server Events | 89 |
| 4.5 | WebSocket Server-to-Client Events | 90 |
| 4.6 | Redis Key Design | 84 |
| 5.1 | Backend npm Dependencies | 111 |
| 5.2 | Frontend Flutter Dependencies | 131 |
| 6.1 | Manual Test Scenarios and Results | 161 |
| 6.2 | Location Tracking Performance Metrics | 163 |
| 6.3 | Alert System Performance Metrics | 164 |
| 6.4 | Backend Latency Benchmarks | 165 |
| 6.5 | Frontend Performance Metrics | 165 |
| 6.6 | Network Performance Metrics | 166 |
| 6.7 | Security Assessment Summary | 167 |
| 6.8 | Code Quality Metrics | 170 |
| 6.9 | System Scalability Estimates | 171 |
| 6.10 | Overall Project Evaluation Scores | 172 |

---

\newpage

---

## LIST OF ABBREVIATIONS

| Abbreviation | Full Form |
|---|---|
| ATS | Ambulance Tracking System |
| API | Application Programming Interface |
| CORS | Cross-Origin Resource Sharing |
| CSS | Cascading Style Sheets |
| CRUD | Create, Read, Update, Delete |
| DFD | Data Flow Diagram |
| EMS | Emergency Medical Services |
| FPS | Frames Per Second |
| GIS | Geographic Information System |
| GPS | Global Positioning System |
| HTTP | Hypertext Transfer Protocol |
| HTTPS | Hypertext Transfer Protocol Secure |
| I/O | Input/Output |
| ISC | Internet Systems Consortium |
| JSON | JavaScript Object Notation |
| JWT | JSON Web Token |
| MVC | Model-View-Controller |
| NoSQL | Not Only SQL |
| ORM | Object-Relational Mapping |
| OSM | OpenStreetMap |
| OSRM | Open Source Routing Machine |
| REST | Representational State Transfer |
| SDK | Software Development Kit |
| SQL | Structured Query Language |
| SSL | Secure Sockets Layer |
| TLS | Transport Layer Security |
| TCP | Transmission Control Protocol |
| UI | User Interface |
| UML | Unified Modeling Language |
| URL | Uniform Resource Locator |
| UUID | Universally Unique Identifier |
| WGS | World Geodetic System |
| XSS | Cross-Site Scripting |

---

\newpage
