# 42Sports - Sports Event Management Platform

A Flutter-based mobile app for organizing sports events at 42 campuses with a token-based economy system.

---

## � Quick Start (Easiest Way)

### 1. Download APK
**[Download 42Sports APK](./releases/42Sports.apk)**

### 2. Install on Android Device
1. Transfer APK to your Android device
2. Enable "Install from Unknown Sources"
3. Install and open 42Sports

### 3. Start Backend Server
```bash
cd backend
npm install
node server.js
```

### 4. Configure API Keys
Edit `42Sports/lib/utils/constants.dart`:
```dart
static const String clientId = 'your_42_client_id';
static const String clientSecret = 'your_42_client_secret';
```

### 5. Use the App
- Sign in with your 42 account
- Take the Welcome Quiz (earn 3 tokens)
- Create events or join existing ones!

---

## 🛠️ Development Setup

### Prerequisites
- Flutter SDK
- Android Studio / Xcode
- Node.js

### Backend Setup
```bash
cd backend
npm install
node server.js
```

### App Setup
```bash
cd 42Sports
flutter pub get

# Add your 42 API credentials to lib/utils/constants.dart
flutter run  # For development
flutter build apk --release  # For production APK
```

---

## 📸 Screenshots

### Welcome & Authentication
<p align="center">
  <img src="42Sports/assets/screens/login_page.jpg" alt="Login Page" width="200"/>
  <br>
  <em>42 OAuth Authentication</em>
</p>

### Token System & Profile
<p align="center">
  <img src="42Sports/assets/screens/profile_page.jpg" alt="Profile Page" width="200"/>
  <br>
  <em>Profile Dashboard - Track tokens and history</em>
</p>

### Welcome Quiz
<p align="center">
  <img src="42Sports/assets/screens/quiz_page.jpg" alt="Quiz Page" width="200"/>
  <br>
  <em>Welcome Quiz - Earn your first 3 tokens</em>
</p>

### Event Discovery
<p align="center">
  <img src="42Sports/assets/screens/event_page.jpg" alt="Events Page" width="200"/>
  <br>
  <em>Events Feed - Browse and join sports events</em>
</p>

### Tournament Management
<p align="center">
  <img src="42Sports/assets/screens/tournaments_list_page.jpg" alt="Tournaments Page" width="200"/>
  <br>
  <em>Tournament Hub - View active tournaments</em>
</p>

### Event Creation
<p align="center">
  <img src="42Sports/assets/screens/create_tournament_page.jpg" alt="Create Tournament" width="200"/>
  <br>
  <em>Create Tournament - Advanced tournament setup</em>
</p>

---

## 🎯 Token Economy

- **Start**: 0 tokens → Take quiz → 3 tokens
- **Create Event**: 1 token
- **Create Tournament**: 3 tokens
- **Complete Event**: +1 token reward
- **Cancel Event**: Full refund (before start)
- **Maximum**: 5 tokens

---

## ✨ Features

- 🔐 42 OAuth authentication
- 🎫 Token-based event creation
- 🏆 Tournament bracket system
- 👥 Event management & participation
- 📱 Clean, modern UI
- 🔄 Real-time updates

---

## 🤝 Contributing

Want to contribute? Feel free to:
- Fork the project
- Create a pull request
- Or DM me on 42 Intra

Built for the 42 community! 🏆

## � Screenshots

### Welcome & Authentication
<p align="center">
  <img src="42Sports/assets/screens/login_page.jpg" alt="Login Page" width="200"/>
  <br>
  <em>42 OAuth Authentication - Secure login with your 42 account</em>
</p>

### Token System & Profile
<p align="center">
  <img src="42Sports/assets/screens/profile_page.jpg" alt="Profile Page" width="200"/>
  <br>
  <em>Profile Dashboard - Track your tokens and event history</em>
</p>

### Welcome Quiz
<p align="center">
  <img src="42Sports/assets/screens/quiz_page.jpg" alt="Quiz Page" width="200"/>
  <br>
  <em>Welcome Quiz - Answer 2 questions to earn your first 3 tokens</em>
</p>

### Event Discovery
<p align="center">
  <img src="42Sports/assets/screens/event_page.jpg" alt="Events Page" width="200"/>
  <br>
  <em>Events Feed - Browse and join sports events created by the community</em>
</p>

### Tournament Management
<p align="center">
  <img src="42Sports/assets/screens/tournaments_list_page.jpg" alt="Tournaments Page" width="200"/>
  <br>
  <em>Tournament Hub - View active tournaments and their brackets</em>
</p>

### Event Creation
<p align="center">
  <img src="42Sports/assets/screens/create_tournament_page.jpg" alt="Create Tournament" width="200"/>
  <br>
  <em>Create Tournament - Advanced tournament setup with bracket generation</em>
</p>

### App Flow Overview
```
📱 Login → 🎯 Quiz (3 tokens) → 🏆 Create Events → 👥 Join Activities → 🏅 Earn Rewards
```

---

## �🚀 Getting Started

### Prerequisites
- Android device (API level 21+) or iOS device
- 42 Network account (for authentication)
- Backend server running (see Backend Setup below)

### Backend Setup

The app requires a Node.js backend server for 42 OAuth authentication.

#### 1. Configure Environment
```bash
cd backend
```

Create `.env` file with your 42 API credentials:
```env
CLIENT_ID=your_42_api_client_id
CLIENT_SECRET=your_42_api_client_secret
REDIRECT_URI=http://localhost:3000/callback
PORT=3000
```

#### 2. Install Dependencies
```bash
npm install
```

#### 3. Start Backend Server
```bash
node server.js
```

You should see:
```
Server running on http://localhost:3000
```

#### 4. Keep Server Running
The backend must remain running while using the app. To run in background:
```bash
node server.js &
```

To stop background server:
```bash
ps aux | grep "node server.js" | grep -v grep | awk '{print $2}' | xargs kill -9
```

### Using the App

#### First Time Setup
1. **Launch App** - Open 42Sports on your device
2. **Sign In** - Authenticate with your 42 account
3. **Take Quiz** - Complete the Welcome Quiz to earn your first 3 tokens
4. **Start Creating** - Use tokens to create events or tournaments

#### Creating Events
1. Navigate to **Create** tab
2. Select **Event** type
3. Fill in details:
   - Event name and description
   - Date, time, and location
   - Sport/activity type
   - Participant limits
4. **Create Event** (costs 1 token)

#### Creating Tournaments
1. Navigate to **Create** tab
2. Select **Tournament** type
3. Configure:
   - Tournament name and details
   - Team size requirements (min/max)
   - Number of teams
   - Matchmaking type (Auto/Manual)
4. **Create Tournament** (costs 3 tokens)

#### Joining Events
1. Browse events in **Home** tab
2. Tap event card to view details
3. Click **Join Event**
4. View your joined events in **My Events** tab

#### Managing Your Events
- **View Details**: Tap any event/tournament card
- **Cancel Event**: As creator, use menu → Cancel (full token refund before start)
- **Start Tournament**: Begin when minimum teams registered
- **Update Bracket**: Manual matchmaking - set results as games complete

---

## 🎮 Features

### Event Management
- ✅ Create and manage sports events
- ✅ Multiple sport types (Football, Basketball, Volleyball, etc.)
- ✅ Flexible participant limits
- ✅ Real-time participant tracking
- ✅ Event cancellation with refunds

### Tournament System
- ✅ Bracket-style tournaments
- ✅ Auto and Manual matchmaking
- ✅ Team creation and management
- ✅ Team size configuration (1v1, 2v2, 5v5, etc.)
- ✅ Dynamic bracket generation
- ✅ Live tournament progress tracking

### Token Economy
- ✅ Welcome Quiz (earn 3 tokens)
- ✅ Event creation (spend 1 token)
- ✅ Tournament creation (spend 3 tokens)
- ✅ Event completion rewards (+1 token)
- ✅ Cancellation refunds (full refund before start)
- ✅ 5 token maximum cap

### User Experience
- ✅ 42 OAuth authentication
- ✅ Profile management
- ✅ Event history tracking
- ✅ Clean, modern UI with neon green accents
- ✅ Intuitive navigation
- ✅ Creator attribution on all events

---

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Node.js + Express
- **Authentication**: 42 OAuth 2.0
- **Storage**: SharedPreferences (local)
- **State Management**: Provider + setState

### Project Structure
```
42Sports/
├── lib/
│   ├── models/          # Data models (User, Event, Tournament, Team)
│   ├── screens/         # UI screens
│   ├── services/        # Business logic (Auth, User, Event, Tournament)
│   ├── widgets/         # Reusable components
│   └── utils/           # Constants, theme, helpers
├── backend/
│   └── server.js        # OAuth server
└── README.md            # This file
```

---

## 🎨 Design Philosophy

### Color Scheme
- **Primary**: Neon Green (#00FF00) - 42 Brand color
- **Background**: Light Gray (#F5F5F5)
- **Surface**: Pure White (#FFFFFF)
- **Text**: Deep Black (#0A0A0A)

### UI Principles
- Minimalist and clean design
- High contrast for readability
- Intuitive navigation patterns
- Consistent component styling
- Responsive layouts

---

## 🔐 Security

- Secure token storage using FlutterSecureStorage
- OAuth 2.0 authentication flow
- No passwords stored locally
- API tokens encrypted at rest
- Input validation on all forms

---

## 📊 Token Economics Example

```
Day 1:  Complete Quiz        → 3 tokens
Day 2:  Create Tournament    → 0 tokens (spent 3)
Day 3:  Tournament succeeds  → 0 tokens (no reward for tournaments)

Alternative:
Day 1:  Complete Quiz        → 3 tokens
Day 2:  Create Event         → 2 tokens
Day 3:  Event succeeds       → 3 tokens (+1 reward)
Day 4:  Create Event         → 2 tokens
Day 5:  Event succeeds       → 3 tokens (+1 reward)
Day 6:  Create Tournament    → 0 tokens
```

---

## 🐛 Troubleshooting

### App won't connect to backend
- Ensure backend server is running (`node server.js`)
- Check backend logs for errors
- Verify `.env` file has correct 42 API credentials
- Ensure device can reach `localhost:3000` (use local network IP if needed)

### Can't create events/tournaments
- Check token balance in Profile tab
- Complete Welcome Quiz if you have 0 tokens
- Verify form validation (all required fields filled)

### Authentication fails
- Verify 42 API credentials in backend `.env`
- Check redirect URI matches 42 app settings
- Clear app data and try signing in again

### Backend won't start
- Ensure Node.js is installed (`node --version`)
- Run `npm install` in backend directory
- Check if port 3000 is already in use
- Verify `.env` file exists and is properly formatted

---

## 🛠️ Development

### Building from Source

#### Flutter App
```bash
cd 42Sports

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release

# Build release APK with split per ABI (recommended - smaller files)
flutter build apk --split-per-abi
```

#### Backend
```bash
cd backend
npm install
node server.js
```

### Environment Variables
Backend requires:
- `CLIENT_ID` - Your 42 API client ID
- `CLIENT_SECRET` - Your 42 API client secret
- `REDIRECT_URI` - OAuth callback URL
- `PORT` - Server port (default: 3000)

---

## 📄 License

This project is created for the 42 Network community.

---

## 👥 Support

For issues, questions, or suggestions:
- Create an issue in the repository
- Contact via 42 Intra
- Check existing documentation

---

## 🎯 Roadmap

Future enhancements under consideration:
- [ ] Push notifications for event updates
- [ ] In-app messaging between participants
- [ ] Photo sharing for completed events
- [ ] Advanced statistics and leaderboards
- [ ] Event search and filtering
- [ ] Calendar integration
- [ ] Multi-campus support

---

**Made with ❤️ for the 42 Community**



### Token System#### 1. Tailored Motivation Letter Generation

- **Starting Tokens**: 0 tokens (take the Welcome Quiz to get 3 tokens)- User pastes job description

- **Create Event**: Costs 1 token- AI generates personalized motivation letter using job requirements and user's profile data

- **Create Tournament**: Costs 3 tokens- Match the tone, style, and vibe of provided motivation examples

- **Earn Tokens**: Complete events successfully (+1 token per event)

- **Maximum**: 5 tokens total#### 2. Resume Scoring (ATS-Style)

- **Refund Policy**: Cancel before event starts = full token refund- Score existing resume against job description

- Allow resume upload if not previously provided

This system ensures:- Provide ATS-friendly scoring and feedback

- ✅ Only committed organizers create events

- ✅ Quality over quantity in event creation#### 3. Network Expansion

- ✅ Rewards for successful event management- Suggest relevant LinkedIn connections for professional growth

- ✅ Fair distribution of organization responsibilities- Recommend networking events and opportunities

- Use AI with web search capabilities to find relevant connections and events

---

#### 4. Job Discovery (Future Feature)

## 🚀 Getting Started- Find relevant job opportunities (to be implemented later)



### Prerequisites## Technical Requirements

- Android device (API level 21+) or iOS device- Frontend: Modern web application

- 42 Network account (for authentication)- Backend: Server-side application with AI integration

- Backend server running (see Backend Setup below)- Authentication: 42Intra OAuth

- AI: Gemini 2.5 Flash with parsing and web search tools

### Backend Setup- Data Storage: Structured storage for user profiles and AI-generated content



The app requires a Node.js backend server for 42 OAuth authentication.## API Documentation

42Intra API documentation will be provided in a separate markdown file.

#### 1. Configure Environment

```bash## Instructions for AI Agent

cd backend- Focus on clean, maintainable code structure

```- Implement features in the order specified

- Ensure data privacy and security

Create `.env` file with your 42 API credentials:- Create responsive and user-friendly interface

```env- Handle errors gracefully

CLIENT_ID=your_42_api_client_id- Test all features thoroughly before moving to next phase
CLIENT_SECRET=your_42_api_client_secret
REDIRECT_URI=http://localhost:3000/callback
PORT=3000
```

#### 2. Install Dependencies
```bash
npm install
```

#### 3. Start Backend Server
```bash
node server.js
```

You should see:
```
Server running on http://localhost:3000
```

#### 4. Keep Server Running
The backend must remain running while using the app. To run in background:
```bash
node server.js &
```

To stop background server:
```bash
ps aux | grep "node server.js" | grep -v grep | awk '{print $2}' | xargs kill -9
```

### Using the App

#### First Time Setup
1. **Launch App** - Open 42Sports on your device
2. **Sign In** - Authenticate with your 42 account
3. **Take Quiz** - Complete the Welcome Quiz to earn your first 3 tokens
4. **Start Creating** - Use tokens to create events or tournaments

#### Creating Events
1. Navigate to **Create** tab
2. Select **Event** type
3. Fill in details:
   - Event name and description
   - Date, time, and location
   - Sport/activity type
   - Participant limits
4. **Create Event** (costs 1 token)

#### Creating Tournaments
1. Navigate to **Create** tab
2. Select **Tournament** type
3. Configure:
   - Tournament name and details
   - Team size requirements (min/max)
   - Number of teams
   - Matchmaking type (Auto/Manual)
4. **Create Tournament** (costs 3 tokens)

#### Joining Events
1. Browse events in **Home** tab
2. Tap event card to view details
3. Click **Join Event**
4. View your joined events in **My Events** tab

#### Managing Your Events
- **View Details**: Tap any event/tournament card
- **Cancel Event**: As creator, use menu → Cancel (full token refund before start)
- **Start Tournament**: Begin when minimum teams registered
- **Update Bracket**: Manual matchmaking - set results as games complete

---

## 🎮 Features

### Event Management
- ✅ Create and manage sports events
- ✅ Multiple sport types (Football, Basketball, Volleyball, etc.)
- ✅ Flexible participant limits
- ✅ Real-time participant tracking
- ✅ Event cancellation with refunds

### Tournament System
- ✅ Bracket-style tournaments
- ✅ Auto and Manual matchmaking
- ✅ Team creation and management
- ✅ Team size configuration (1v1, 2v2, 5v5, etc.)
- ✅ Dynamic bracket generation
- ✅ Live tournament progress tracking

### Token Economy
- ✅ Welcome Quiz (earn 3 tokens)
- ✅ Event creation (spend 1 token)
- ✅ Tournament creation (spend 3 tokens)
- ✅ Event completion rewards (+1 token)
- ✅ Cancellation refunds (full refund before start)
- ✅ 5 token maximum cap

### User Experience
- ✅ 42 OAuth authentication
- ✅ Profile management
- ✅ Event history tracking
- ✅ Clean, modern UI with neon green accents
- ✅ Intuitive navigation
- ✅ Creator attribution on all events

---

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Node.js + Express
- **Authentication**: 42 OAuth 2.0
- **Storage**: SharedPreferences (local)
- **State Management**: Provider + setState

### Project Structure
```
42Sports/
├── lib/
│   ├── models/          # Data models (User, Event, Tournament, Team)
│   ├── screens/         # UI screens
│   ├── services/        # Business logic (Auth, User, Event, Tournament)
│   ├── widgets/         # Reusable components
│   └── utils/           # Constants, theme, helpers
├── backend/
│   └── server.js        # OAuth server
└── README.md            # This file
```

---

## 🎨 Design Philosophy

### Color Scheme
- **Primary**: Neon Green (#00FF00) - 42 Brand color
- **Background**: Light Gray (#F5F5F5)
- **Surface**: Pure White (#FFFFFF)
- **Text**: Deep Black (#0A0A0A)

### UI Principles
- Minimalist and clean design
- High contrast for readability
- Intuitive navigation patterns
- Consistent component styling
- Responsive layouts

---

## 🔐 Security

- Secure token storage using FlutterSecureStorage
- OAuth 2.0 authentication flow
- No passwords stored locally
- API tokens encrypted at rest
- Input validation on all forms

---

## 📊 Token Economics Example

```
Day 1:  Complete Quiz        → 3 tokens
Day 2:  Create Tournament    → 0 tokens (spent 3)
Day 3:  Tournament succeeds  → 0 tokens (no reward for tournaments)
Day 4:  Create Event         → -1 token (insufficient, can't create)
Day 5:  Take Welcome Quiz    → Already completed (one-time only)
        
Alternative:
Day 1:  Complete Quiz        → 3 tokens
Day 2:  Create Event         → 2 tokens
Day 3:  Event succeeds       → 3 tokens (+1 reward)
Day 4:  Create Event         → 2 tokens
Day 5:  Event succeeds       → 3 tokens (+1 reward)
Day 6:  Create Tournament    → 0 tokens
```

---

## 🐛 Troubleshooting

### App won't connect to backend
- Ensure backend server is running (`node server.js`)
- Check backend logs for errors
- Verify `.env` file has correct 42 API credentials
- Ensure device can reach `localhost:3000` (use local network IP if needed)

### Can't create events/tournaments
- Check token balance in Profile tab
- Complete Welcome Quiz if you have 0 tokens
- Verify form validation (all required fields filled)

### Authentication fails
- Verify 42 API credentials in backend `.env`
- Check redirect URI matches 42 app settings
- Clear app data and try signing in again

### Backend won't start
- Ensure Node.js is installed (`node --version`)
- Run `npm install` in backend directory
- Check if port 3000 is already in use
- Verify `.env` file exists and is properly formatted

---

## 🛠️ Development

### Building from Source

#### Flutter App
```bash
cd 42Sports

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release

# Build release APK with split per ABI (smaller files)
flutter build apk --split-per-abi
```

#### Backend
```bash
cd backend
npm install
node server.js
```

### Environment Variables
Backend requires:
- `CLIENT_ID` - Your 42 API client ID
- `CLIENT_SECRET` - Your 42 API client secret
- `REDIRECT_URI` - OAuth callback URL
- `PORT` - Server port (default: 3000)

---

## 📄 License

This project is created for the 42 Network community.

---

## 👥 Support

For issues, questions, or suggestions:
- Create an issue in the repository
- Contact via 42 Intra
- Check existing documentation

---

## 🎯 Roadmap

Future enhancements under consideration:
- [ ] Push notifications for event updates
- [ ] In-app messaging between participants
- [ ] Photo sharing for completed events
- [ ] Advanced statistics and leaderboards
- [ ] Event search and filtering
- [ ] Calendar integration
- [ ] Multi-campus support

---

**Made with ❤️ for the 42 Community**
