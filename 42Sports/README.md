# 42Sports - Flutter App# 42Sports - Mobile Application



Sports event management platform for 42 campuses with token-based economy system.## ✅ Project Status: FULLY IMPLEMENTED



## Quick StartA Flutter mobile application that integrates with 42Intra authentication to enable students to organize and participate in sports events and gaming activities within the 42 community.



### Install Dependencies**📦 Ready to Run** - All features implemented, modular structure, minimal code, no tests (as requested)

```bash

flutter pub get## Quick Start

```

### Prerequisites

### Run Development- Flutter SDK (>=3.0.0) - [Install Guide](https://docs.flutter.dev/get-started/install)

```bash- Android Studio or VS Code

flutter run- 42 API credentials

```

### Setup Steps

### Build Release APK

```bash1. **Install Dependencies**

# Standard APK   ```bash

flutter build apk --release   cd /home/reda/Desktop/hackathon/42Sports

   flutter pub get

# Split by ABI (recommended - smaller files)   ```

flutter build apk --split-per-abi

```2. **Configure 42 API**

   - Create an app in your 42 Intra settings

The APK will be generated in: `build/app/outputs/flutter-apk/`   - Set redirect URI to: `com.sports42://oauth/callback`

   - Update credentials in `lib/utils/constants.dart`

## Configuration

3. **Run the App**

### Update Backend URL   ```bash

If your backend is not on localhost, update the API URL in:   flutter run

`lib/services/auth_service.dart`   ```



```dartFor detailed setup instructions, see [SETUP.md](SETUP.md)

static const String _baseUrl = 'http://YOUR_IP:3000';

```---



## Project Structure## Project Overview

- Implement 42Intra OAuth authentication

```- Users must authenticate with their 42 credentials to access the application

lib/- Refer to `42_API_DOCS.md` for API integration details

├── models/          # Data models

├── screens/         # UI screens  ## User Profile

├── services/        # Business logicFetch and display user information from 42Intra API:

├── widgets/         # Reusable widgets- Profile picture

└── utils/           # Constants, theme- Intra username

```- Full name

- Additional relevant information from 42 API

## Key Features

- 42 OAuth authentication## Core Features

- Token-based event creation

- Tournament bracket system### 1. Create Event

- Event managementUsers can create sports/gaming events with the following fields:

- User profiles- **Event Name** (required)

- **Event Description** (optional)

For complete documentation, see [main README](../README.md)- **Date** (required)

- **Location** (required)
- **Minimum Number of Participants** (required)
- **Maximum Number of Participants** (optional)
  - If max reached: stop accepting new participants
  - If left empty: event remains open without limit
- **Event Logo** (optional)

**Event Types:**
- Futsal
- Football (11 vs 11)
- Volleyball
- Handball
- Basketball
- Video Game
- Mona's Games

### 2. Join Events
- Display list of all open events
- Users can view event details
- Users can join available events
- Events show current participant count and capacity

### 3. Token System
**Token Rules:**
- Each user starts with **1 Token**
- Creating an event costs **1 Token**
- **Token Recovery & Rewards:**
  - If created event reaches max capacity before start date AND is confirmed as held: user receives original token + 1 bonus token (total: 2 tokens)
  - If created event is cancelled: user receives original token back (total: 1 token)
- **Token Limits:**
  - Minimum: 1 Token or 0 tokens (only if user has an open event)
  - Maximum: 3 tokens
  - Users can create up to 3 concurrent events if they have 3 tokens

**Token Constraints:**
- User must always have at least 1 token OR 0 tokens with an active open event
- Maximum tokens allowed: 3

### 4. Event History
Users can view:
- **Events Attended:** List of past events the user participated in
- **Events Cancelled:** List of events that were cancelled

## Technical Requirements
- **Framework:** Flutter
- **Authentication:** 42Intra OAuth
- **API Integration:** 42 API for user data and authentication
- **Backend:** Design appropriate backend architecture for event management and token system
- **Database:** Structured storage for events, participants, and user tokens

## Design Guidelines
- Use 42 School's official color scheme
- Match 42 School's typography and font styles
- Follow 42 School's design language and UI patterns
- Ensure consistent branding throughout the application

## Development Principles
- Write minimal, clean code
- Focus on maintainable code structure
- Implement features in the specified order
- Ensure data privacy and security
- Create responsive and user-friendly interface
- Handle errors gracefully
- Avoid adding extra features beyond specifications

## Implementation Order
1. 42Intra authentication integration
2. User profile fetching and display
3. Event creation functionality
4. Event listing and joining functionality
5. Token system implementation
6. Event history tracking
7. UI/UX refinement with 42 branding

## API Reference
See `42_API_DOCS.md` in the parent directory for complete 42Intra API documentation.

## Key API Endpoints to Use
- `/v2/oauth/token` - Authentication
- `/v2/me` - Current user information
- `/v2/users/:id` - User details including profile picture

## Notes
- No mockup creation required
- No test files until specifically needed
- No additional documentation beyond this README
- Implementation should follow user specifications exactly
- If better implementation approaches exist, inform before implementing for user decision
