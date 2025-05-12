# Trading System Test Tools

This project provides testing tools for the Trading System API, including unit tests, stress tests, and simulations.

## Prerequisites

- .NET 6 SDK or later
- Access to the Trading System services (or local development environment)

## Configuration

The tool can be configured using:

1. `appsettings.json` file (included in the project)
2. Environment variables
3. Command-line arguments (highest priority)

### Environment Variables

Service URLs:
- `IDENTITY_HOST` - Identity Service URL
- `TRADING_HOST` - Trading Service URL
- `MARKET_DATA_HOST` - Market Data Service URL
- `ACCOUNT_HOST` - Account Service URL
- `RISK_HOST` - Risk Service URL 
- `NOTIFICATION_HOST` - Notification Service URL

Simulation settings:
- `SIMULATION_USERS` - Number of users to simulate
- `SIMULATION_ORDERS_PER_USER` - Number of orders per user
- `SIMULATION_CONCURRENCY` - Number of concurrent operations
- `SIMULATION_TIMEOUT` - HTTP request timeout in seconds
- `SIMULATION_VERBOSE` - Enable verbose output
- `SIMULATION_MODE` - Simulation mode (random, market)

Stress test settings:
- `STRESS_TARGET_SERVICE` - Target service for stress testing
- `STRESS_CONCURRENCY` - Number of concurrent requests
- `STRESS_DURATION` - Duration of stress test in seconds

## Usage

The tool supports three modes: unit testing, stress testing, and simulation.

### Unit Testing

Run unit tests for all services:

```bash
dotnet run --mode unit
```

Unit tests follow a specific workflow:
1. Test connectivity to all services
2. Create a test user
3. Test authentication (login)
4. Test API endpoints for each service

### Stress Testing

Run stress tests against a specific service:

```bash
dotnet run --mode stress --target identity --concurrency 50 --duration 60
```

This will run a stress test with 50 concurrent requests against the identity service for 60 seconds.

Valid targets: `identity`, `trading`, `market-data`, `account`, `risk`, `notification`, `match-making`

### Trading Simulation

Run a trading simulation:

```bash
dotnet run --mode simulation --users 20 --orders 100 --concurrency 10 --sim-mode random
```

This will simulate 20 users each placing 100 orders with 10 concurrent operations using the random mode.

Available simulation modes:
- `random` - Random order placement
- `market` - Market order placement

## Command Line Options

```
Options:
  -?|--help                      Show help information
  -m|--mode <MODE>               Test mode: 'unit' for unit tests, 'stress' for stress tests, 'simulation' for trading simulation
  
  --identity-host <URL>          URL for Identity Service
  --trading-host <URL>           URL for Trading Service
  --market-host <URL>            URL for Market Data Service
  --account-host <URL>           URL for Account Service
  --risk-host <URL>              URL for Risk Service
  --notification-host <URL>      URL for Notification Service
  
  -t|--target <SERVICE>          Target service for stress tests
  -c|--concurrency <NUMBER>      Number of concurrent requests/users
  -d|--duration <SECONDS>        Duration of stress test in seconds
  
  -u|--users <NUMBER>            Number of simulated users
  -o|--orders <NUMBER>           Number of orders per user
  -s|--sim-mode <MODE>           Simulation mode: 'random', 'market'
  -v|--verbose                   Enable verbose logging
  --timeout <SECONDS>            HTTP request timeout in seconds
```

## Running in Docker

You can run the test tools in Docker:

```bash
docker build -t trading-system-test .
docker run -e IDENTITY_HOST=http://identity-service:8080 -e TRADING_HOST=http://trading-service:8080 trading-system-test --mode unit
```

## Log Files

All test runs generate log files in the `logs` directory:

- Unit test logs: `unittest_log_TIMESTAMP.txt`
- Stress test logs: `stress_test_log_TIMESTAMP.txt`
- Simulation logs: `simulation_log_TIMESTAMP.txt`
- Detailed logs: `detailed_order_log_TIMESTAMP.txt`, `api_responses_TIMESTAMP.txt`

## Extending the Tool

To add new tests:
1. Create a new test class in the `Tests` directory
2. Inherit from `ApiTestBase`
3. Add methods with the `[ApiTest]` attribute
4. Implement test logic using the provided HTTP clients

## Troubleshooting

- Ensure all services are running and accessible
- Check logs for detailed error information
- Verify service URLs are correctly configured
- If tests fail with authentication errors, check user registration/login flow 