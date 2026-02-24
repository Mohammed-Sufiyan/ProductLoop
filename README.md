# ProductLoop
**Discover smarter with every tap.**

## 1. Overview
ProductLoop is a Flutter application built as a technical evaluation submission. It provides a seamless product discovery experience by integrating with the FakeStoreAPI (and DummyJSON API), allowing users to browse a dynamic feed of products, view details via an in-app browser, and manage their preferences. The app organizes product history, user likes/dislikes, category filtering, and offline support into a premium, cohesive interface.

## 2. Approach
The application adheres to a clean, feature-based architecture to ensure maintainability and strict separation of concerns. 
- **Structure:** The codebase is divided into clear feature domains (`products`, `browser`, `preferences`, `splash`, `dashboard`) rather than technical layers, making it easier to scale and locate logic.
- **Data Flow & Repository Pattern:** A Repository pattern is used to abstract the data layer (Dio for network requests and Hive for local caching). The UI never communicates directly with the API; it observes state exposed by Riverpod providers, which internally coordinate with the repositories. This ensures that offline fallbacks and data mapping are handled invisibly to the presentation layer.

## 3. State Management Choice
I chose **Riverpod** for state management because of its compile-time safety and predictable asynchronous data handling.
- **Predictability:** Riverpod eliminates the `ProviderNotFoundException` common in traditional Provider setups and ensures providers are always available when requested.
- **Separation from UI:** State logic lives entirely outside the widget tree, keeping the UI declarative and clean.
- **Scalability & Testability:** By providing a structured way to manage global state, dependency injection, and async operations, Riverpod scales effortlessly and simplifies unit testing by allowing straightforward overriding of providers.

## 4. Data Persistence Method
For local data persistence, I opted for **Hive**.
- **Lightweight & Fast:** Hive is a NoSQL, synchronous key-value database written purely in Dart. It completely avoids the overhead and asynchronous boilerplate of SQLite/sqflite.
- **Simplicity:** It fits the app's persistence needs perfectly. Global settings (dark mode), user "likes/dislikes", and application onboarding flags are stored natively as simple key-value pairs. 
- **History Tracking:** The browsing history is serialized into JSON payloads and stored chronologically in a dedicated Hive box, ensuring that past viewed products load instantly, even offline, across app restarts.

## 5. Handling Loading and Errors
A robust user experience demands graceful degradation during network failures or loading states.
- **AsyncValue:** Riverpod's `AsyncValue` is used heavily to declaratively transition the UI between `.data`, `.loading` (showing skeleton shimmer loaders), and `.error` states.
- **Defensive API Handling:** The `ApiClient` (powered by Dio) catches specific `DioException` types (timeouts, bad responses, connection errors) and translates them into readable, user-friendly exception messages.
- **Offline Fallback:** If the API fails entirely, the repositories automatically fall back to serving cached JSON payloads from Hive, preventing hard crashes and keeping the core feed functional.

## 6. Folder Structure
The app uses a modular, feature-first folder structure:

```text
lib/
├── core/
│   ├── api/           # Dio client configurations and interceptors
│   ├── providers/     # Global structural providers (theme, bottom nav)
│   └── storage/       # Hive local storage service implementation
├── features/
│   ├── browser/       # In-App WebView and History tracking
│   ├── dashboard/     # Main bottom navigation shell frame
│   ├── favorites/     # Filtered list of persistent liked products
│   ├── intro/         # First-time user onboarding experience
│   ├── preferences/   # Like/Dislike state logic
│   ├── products/      # Feed, Repositories, Models, Filtering logic
│   └── splash/        # Animated initial load screen
└── main.dart          # Entry point and thematic setup
```
This division ensures that each feature is self-contained with its own models, repositories, and UI components.

## 7. What I Would Improve With More Time
Given more time, I would focus on the following engineering and UX refinements:
- **Better Caching Strategy & Offline-first Support:** Implement a robust offline-first synchronization strategy using a local SQLite database (via Drift or Isar) to properly handle paginated data caching, rather than raw JSON blob caching.
- **Unit & Widget Tests:** Write comprehensive unit tests for the repositories/providers, and widget tests for the core UI flows (like the product feed and simulated history navigation).
- **Search Optimization:** Currently, search is performed locally on the fetched list. Adding a debouncer for the search input and moving search logic to a paginated backend query would improve performance on larger datasets.
- **Architecture Refinement:** Extract standard spacing, typography, and color tokens into a strictly enforced `AppTheme` class to remove inline styling throughout widgets.
- **Improved Animations:** Add `Hero` transitions between the product feed and the detail view for a more fluid navigational feel.

## 8. Approximate Time Spent
The development of this project took approximately 12.5 hours in total, broken down as follows:
- **Setup, Architecture Planning & Theming:** 1.5 hours
- **API Integration & Repositories (Dio):** 2.5 hours
- **State Management (Riverpod):** 2.0 hours
- **Persistence & Offline Caching (Hive):** 2.0 hours
- **Internal WebView & History Routing:** 2.5 hours
- **UI Polishing, Animations, & Testing:** 2.0 hours
