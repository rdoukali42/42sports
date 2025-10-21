class AppConstants {class AppConstants {

  // 42 OAuth credentials  // 42 OAuth credentials

  static const String clientId = 'Your UID Here';  static const String clientId = 'Your UID Here';

  static const String clientSecret = 'Your Secret Here';  static const String clientSecret = 'Your Secret Here';

    

  // Redirect URIs  // Redirect URIs

  static const String redirectUriWeb = 'http://localhost:8080';  static const String redirectUriWeb = 'http://localhost:8080';

  static const String redirectUriMobile = 'com.sports42://oauth/callback';  static const String redirectUriMobile = 'com.sports42://oauth/callback';

    

  static const String authorizationEndpoint = 'https://api.intra.42.fr/oauth/authorize';  static const String authorizationEndpoint = 'https://api.intra.42.fr/oauth/authorize';

  static const String tokenEndpoint = 'https://api.intra.42.fr/oauth/token';  static const String tokenEndpoint = 'https://api.intra.42.fr/oauth/token';

  static const String apiBaseUrl = 'https://api.intra.42.fr/v2';  static const String apiBaseUrl = 'https://api.intra.42.fr/v2';



  // Backend API (change this to your local IP when testing on phone)  // Backend API (change this to your local IP when testing on phone)

  // When testing on phone connected to same WiFi, use: http://YOUR_LOCAL_IP:3000  // When testing on phone connected to same WiFi, use: http://YOUR_LOCAL_IP:3000

  // Example: http://192.168.178.82:3000  // Example: http://192.168.178.82:3000

  static const String backendUrl = 'http://172.17.250.156:3000/api';  static const String backendUrl = 'http://172.17.250.156:3000/api';

    

  // Set to true to use backend API, false to use local storage only  // Set to true to use backend API, false to use local storage only

  static const bool useBackend = true;  static const bool useBackend = true;



  // Token limits  // Token limits

  static const int minTokens = 0;  static const int minTokens = 0;

  static const int maxTokens = 5;  static const int maxTokens = 5;

  static const int initialTokens = 0; // No tokens on signup, must complete quiz  static const int initialTokens = 0; // No tokens on signup, must complete quiz

  static const int quizRewardTokens = 3; // Reward for completing the welcome quiz  static const int quizRewardTokens = 3;

    static const int eventTokenCost = 1;

  // Token costs for creating events/tournaments  static const int tournamentTokenCost = 3;

  static const int eventCreationCost = 1;

  static const int tournamentCreationCost = 3;  // Storage keys

    static const String keyAccessToken = 'access_token';

  // Event completion reward  static const String keyRefreshToken = 'refresh_token';

  static const int eventCompletionReward = 1;  static const String keyUser = 'user';

}  static const String keyEvents = 'events';

}
