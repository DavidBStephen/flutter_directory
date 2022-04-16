# To use this code you need to create a Firebase application

# flutter_directory

Phone & email directory application
# Summary
This is a Flutter based application to run on iOS or Android.
It will likely also run on the other supported environments for Flutter such as Windows, MacOS and Web but without any phone functionality and is currently untested.

The application attempts to represent some basic concepts in mobile development.
# Bloc Pattern
Flutter Bloc (https://pub.dev/packages/flutter_bloc) was chosen over the lighter alternatives such as the Flutter setState functionality or other State Management tools such as Provider or RiverPod.
The Bloc Pattern (https://bloclibrary.dev/) has a number of advantages:
- Functionality is encapsulated in the Bloc or Cubit instead of the user interface.
- Functionality can be tested against the Bloc or Cubit through automation.
- The validation of data for the interface and the data is done inside the Bloc or Cubit.
- Validation can be applied at the field leven and the entire data of the Bloc or Cubit.
- Well used pattern with a good support online.

# Logging
Logging is done through logger package instead of simple print statements.
This will allow memory storage of the logs to be retrieved in case of error.

# Dependency Injection
To support automated testing, Dependency Injection using Get_it (https://pub.dev/packages/get_it) has been implemented. These dependnecies are configured at the start of the application and mocked at the start of automated tests.

# Automated Testing
Flutter supports
- Unit Tests
- Widget Tests
- Integration Tests

Mockito (https://pub.dev/packages/mockito) was used to mock the services.

# Firebase authentication
Authentication to the application is provided by Firebase.
This allows for Email/Password and Google authentication.
Other athentication mechanisms are easily supported.
Email authentication also allows for registration and resetting passwords as provided by Firebase.
The application may be extended to only allow particular domains to have access and not anyone with a Google account.

# Firebase datastore
Firebase datastore is used to store the data.
The datastore only will let users retrieve, add or delete if they are authenticated against Firebase as part of the datastore custom rules.

# Internet Connectivity
The state of internet connectivity via WiFi or Mobile data is monitored with connectivity_plus (https://pub.dev/packages/connectivity_plus) that is wrapped in a Cubit to send events if the connectivity changes.
When the device has internet connectivity the use can login and perform normal actions otherwise the login screen is disabled.
If logged in and the connection is dropped, then features will be disabled.
Once the data is loaded from Firebase with an internet connection, it is serialised and saved to disk to be used if the connection is lost.

# Secure Storage
If the user logs in with their email and password, it is stored with secure storage to be used for next login.

# Spash Screen and Application Icon
Mobile phones require an Application Icon and Name.
It also requires a spash screen whilst loading.
This is supported.

# State Restoration
When a mobile app is put in the background it can be effectively shut down.
State Restoration has been applied to restore the application to the screen it was previously on before swapping applications.

# Call, Text, Email
Clicking on the icons for a phone, SMS or email will open the approiate phone function enabling communication.

# Multi Language
Added ability to support multiple languages.
Currently French and English based on the default language of the device.
Can add more languages.
The framework allows for string interpolation and plural options, but so far not needed.

# Theming
Enabled switching between dark and light themes.

# File Structure
Directories have been used to separate features and core functionality enabling the application to support a scalable codebase

# Future
Some functions to include
- Crashlitics
- App Check
- Introduction Page

# Wish List
Additional functionality to add
- GPS to identify location of work or other - background updates to server
- Permission check - Contacts or GPS or Camera
- Phone contact update - update contacts on phone from Servian directory
- Google Chat
- Push messages
- Working times/time zones




