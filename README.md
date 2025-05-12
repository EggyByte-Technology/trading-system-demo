# Trading System Demo

<div align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-green.svg" alt="Version 1.0.0">
  <img src="https://img.shields.io/badge/license-Proprietary-blue.svg" alt="License">
  <img src="https://img.shields.io/badge/.NET-9.0-purple.svg" alt=".NET 9.0">
  <img src="https://img.shields.io/badge/Flutter-3.19+-blue.svg" alt="Flutter 3.19+">
</div>

## 📋 Overview

A comprehensive trading platform with a microservices backend architecture and a responsive Flutter frontend. This system demonstrates a complete trading ecosystem, including account management, order execution, risk assessment, market data, and real-time notifications.

## 🏗️ System Architecture

The Trading System Demo consists of:

- **Backend**: .NET 9.0 microservices architecture
- **Frontend**: Flutter-based responsive UI for web and mobile platforms
- **Infrastructure**: Docker containers, Kubernetes deployment, CI/CD pipeline

### 🔌 Microservices

- **Identity Service**: User authentication and authorization
- **Account Service**: User account and balance management
- **Market Data Service**: Real-time and historical market data
- **Trading Service**: Order management and execution
- **Risk Service**: Risk assessment and limits management
- **Notification Service**: Real-time alerts and user notifications
- **Match Making Service**: Order matching engine

## 🚀 Getting Started

### 📋 Prerequisites

| Requirement | Version | Purpose |
|-------------|---------|---------|
| .NET SDK | 9.0+ | Backend development |
| Flutter | 3.19+ (with Dart 3.3+) | Frontend development |
| Docker | Latest | Containerization |
| Docker Compose | Latest | Multi-container deployment |
| Kubernetes | Latest | Production deployment (optional) |
| MongoDB | Latest | Database |

### 🔧 Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/eggybyte/trading-system-demo.git
   cd trading-system-demo
   ```

2. Set up the backend:
   ```bash
   cd backend
   dotnet restore
   dotnet build
   ```

3. Set up the frontend:
   ```bash
   cd frontend/trading_system_frontend
   flutter pub get
   ```

4. Run the development environment:
   ```bash
   # From the root directory
   docker-compose up -d
   ```

### 💻 Development Mode

- **Backend Services**: Each service can be run individually
  ```bash
  cd backend/ServiceName
  dotnet run
  ```

- **Frontend**: Run in development mode
  ```bash
  cd frontend/trading_system_frontend
  flutter run -d chrome  # For web
  flutter run            # For default device
  ```

## 🚢 Deployment

### 🐳 Docker Deployment

```bash
# Build and run all services
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### ☸️ Kubernetes Deployment

```poweshell
# Apply Kubernetes configurations
.\scripts\helm\helm-install.ps1
```

## 📚 API Documentation

The API documentation is available at:
- Swagger UI: `/` endpoint on each service

## 📁 Project Structure

```
trading-system-demo/
├── backend/                # .NET microservices
│   ├── AccountService/     # Account management service
│   ├── CommonLib/          # Shared library and models
│   ├── IdentityService/    # User authentication service
│   ├── MarketDataService/  # Market data service
│   ├── MatchMakingService/ # Order matching engine
│   ├── NotificationService/# Real-time notifications
│   ├── RiskService/        # Risk management service
│   ├── SimulationTest/     # Testing and simulation tools
│   └── TradingService/     # Trading and order service
├── frontend/               # Flutter application
│   └── trading_system_frontend/
│       ├── lib/            # Application source code
│       └── ...             # Flutter project structure
├── logs/                   # System logs
├── scripts/                # Deployment and utility scripts
│   ├── docker/             # Docker deployment files
│   └── istio/              # Service mesh configuration
└── ...
```

## 📜 License

Copyright © 2024-2025 EggyByte Technology. All rights reserved.

This project is proprietary software. No part of this project may be copied, modified, or distributed without the express written permission of EggyByte Technology.

---

<div align="center">
  <p>Developed by EggyByte Technology • 2024-2025</p>
</div> 