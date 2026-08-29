# Long Exam Discussion

### Models

Works with data types and data parsing. The data provided by the DummyJSON API is in the form of a raw JSON map, so I developed models, including: User, Post, Comment, CommentUser. Both have a factory method named fromJson that can be used to turn incoming data into a strongly typed Dart object, as well as a toJson method to turn the data back into a Dart object when saving its state to SharedPreferences.

### Services

Looks after external communications and business logic. Services like UserService, PostService or CommentService will be centralized and will handle our HTTP calls, inspect for errors/HTTP status code and read/write operations for local storage. The other parts of the app do not interact directly with the network – they only call a service method, and wait for clean model instances.

### Screens & Widgets

Renders and interacts with the UI. Other views like SplashScreen, LogInScreen, ProfileScreen, SettingsScreen, DetailScreen are only interested in layout changes or state changes (setState / Provider). The screen fetches and displays the contents of the service when the user calls a particular action, e.g. the user logs in or loads the comments.