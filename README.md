Modular Flutter App – Clean Architecture & Modern UI (shadcn-inspired)
🧱 Project Structure
bash
Copy
Edit
lib/
│
├── core/                    # Global app utilities
│   ├── theme/               # Colors, typography, spacing
│   ├── utils/               # Global helpers
│   ├── services/            # App-wide services (e.g., NavigationService, AuthService)
│   ├── widgets/             # Reusable UI components
│   └── config/              # Constants, environment configs
│
├── features/                # Feature-based modules
│   ├── auth/                # Authentication feature
│   │   ├── data/            # API, repositories, models
│   │   ├── domain/          # Entities & use cases
│   │   ├── presentation/    # UI, screens, state management
│   │   └── auth_module.dart # Entry point
│   ├── feature1/            # feature1
│   │   ├── data/            # API, repositories
│   │   ├── domain/          # Models & providers
│   │   ├── presentation/    # UI, screens
│   │   └── glaucoma_module.dart # Entry point
│   ├── feature2/            # feature2
│   │   ├── data/            # API, repositories
│   │   ├── domain/          # Models & providers
│   │   ├── presentation/    # UI, screens, widgets
│   │   └── medication_module.dart # Entry point
│   ├── profile/             # Profile feature
│   └── .../
│
├── routes/                  # App routes and navigation setup
├── main.dart                # App entry point
└── di.dart                  # Dependency injection setup
🧼 Clean Architecture Layers
1. Presentation
screens/, widgets/, controllers/

State management: Riverpod / Bloc

Dumb widgets + ViewModels/Controllers (MVVM-style)

2. Domain
Pure Dart (no Flutter imports)

Entities and use cases

Easily testable, business-logic only

3. Data
Handles APIs, local storage

Maps raw data (DTOs) to domain models

🧠 Rule: UI depends on domain, domain does not depend on data or presentation.

✨ UI Guidelines (Inspired by shadcn/ui)
🎨 Design Language
Minimalist, bold typography, flat design

Primary color + subtle backgrounds

Use elevation, shadow, blur sparingly

dart
Copy
Edit
// Example color scheme
final colorScheme = ColorScheme.light(
  primary: Color(0xFF6366F1),
  background: Color(0xFFF9FAFB),
  surface: Colors.white,
  onPrimary: Colors.white,
  onBackground: Color(0xFF111827),
);
📐 Layout
Use Padding / Gap / SizedBox consistently

Max width containers for large screens

Avoid deeply nested Column/Row

🔘 Components (Widgets)
Use a consistent style for components, similar to shadcn's:

<PrimaryButton />

<InputField />

<Card />

<Badge variant="success" />

All live in core/widgets/ or are grouped per feature in presentation/widgets/.

dart
Copy
Edit
PrimaryButton(
  onPressed: () {},
  text: 'Continue',
  icon: Icons.arrow_forward,
)
🕶️ Typography
Define consistent text styles:

dart
Copy
Edit
Text('Title', style: Theme.of(context).textTheme.headlineMedium);
In theme/text_theme.dart, include:

displayLarge

headlineMedium

titleSmall

bodyLarge

labelMedium

🧩 UI Components Inspired by shadcn
Modal: showModalBottomSheet

Tooltip: Tooltip

Card: Elevated Container with border and shadow

Tabs: TabBarView

Toast: Use fluttertoast or a custom Overlay

✅ Clean Code Guidelines
Use final and const wherever possible

Keep widget trees shallow with helpers or reusable widgets

One class = one file

Organize features and files by purpose, not widget type

Follow Dart naming conventions (camelCase, PascalCase)

## Glaucoma Feature

This app includes a feature for glaucoma patients to:

- Capture eye images using the device camera
- Save and organize eye scans with titles and descriptions
- View a history of all saved scans
- Track changes over time

The feature uses:
- Camera and image picker integration
- Secure storage of images
- Clean architecture pattern with proper separation of concerns

To use this feature:
1. Navigate to the Eye Scan screen from the home screen
2. Follow the on-screen instructions to capture or select an image
3. Add a title and optional description
4. Save the scan to view it later

## Medication Reminder Feature

This app includes a medication reminder feature for patients to:

- Create medication reminders with custom schedules
- Set multiple reminder times per day
- Select specific days of the week for each medication
- Add descriptions and notes for each medication
- Enable/disable reminders as needed
- View all medication reminders in one place

The feature uses:
- Riverpod for state management
- Clean architecture pattern
- Intuitive UI for managing complex schedules

To use this feature:
1. Navigate to the Medication Reminders screen from the home screen
2. Tap the "+" button to add a new reminder
3. Enter medication details, set times and days
4. Save the reminder
5. Edit or delete reminders as needed from the main list

## Location Selection Feature

The app includes a robust location selection system that allows users to:

- Select a location using an interactive Google Maps interface
- Use their current location with automatic address lookup
- View and confirm selected locations with full address details
- Seamlessly integrate location data with other features like home visits

The location selection feature uses:
- Google Maps Flutter integration for map display and interaction
- Geolocator for current location access
- Geocoding for converting coordinates to human-readable addresses
- Clean architecture pattern for separation of concerns

To use this feature:
1. When a location is needed (e.g., in Home Visit booking):
   - Tap the map icon to open the map selector
   - OR tap the location icon to use current location
2. If using the map:
   - Pan and zoom to find your location
   - Tap to place a marker
   - The address will be automatically fetched
3. Confirm your selection to return to the previous screen

Key components:
- LocationSelectorScreen: Full-screen map interface for location selection
- LocationData: Data model containing address, coordinates, and LatLng
- Geocoding integration for address lookup
- Permission handling for location access

## Clinic Visit Booking Feature

The app includes a clinic visit booking feature that allows patients to:

- Select a clinic from available options
- Choose a doctor from the selected clinic
- Pick a date and time for the appointment
- Provide symptoms or reason for the visit
- Submit the booking request to the server

The clinic visit booking feature uses:
- Clean architecture pattern for separation of concerns
- API integration with backend services
- Form validation and error handling
- User-friendly UI for the booking process

API Integration:
- GET `/PatientApi/services?clinicId={id}&language={lang}` - Fetches doctors and services for a clinic
  ```json
  // Response format:
  {
    "status": "success",
    "services": [
        {
            "id": 4,
            "name": "كشف د/ طارق الخولي"
        },
        {
            "id": 7,
            "name": "رسم قلب بالمجهود د/طارق الخولي"
        },
        {
            "id": 188,
            "name": "كشف ( د/ محمد عبد العزيز ) قلب"
        }
    ],
    "doctors": [
        {
            "id": 9283,
            "name": "طارق محمد الخولي"
        },
        {
            "id": 9319,
            "name": "د / محمد عبد العزيز "
        }
    ],
    "availableStartDate": "2025/07/09",
    "availableEndDate": "2025/10/01"
  }
  ```
- POST `/PatientApi/book-appointment` - Books a clinic appointment with the following JSON structure:
  ```json
  // Request format:
  {
    "ClinicId": 8,
    "DoctorId": 9284,
    "ServiceId": 10,
    "PatientId": 3349,
    "availableDate": "2025-07-06",
    "availableTime": "18:00:00",
    "Symptoms": "Headache and fever"
  }
  ```

To use this feature:
1. Navigate to the Clinic Visit screen from the home screen
2. Select a clinic from the dropdown
3. Choose a doctor from the available doctors list
4. Select date and time for the appointment
5. Enter symptoms or reason for the visit
6. Submit the booking request
7. Receive confirmation or error message

Key components:
- ClinicVisitScreen: UI for booking appointments
- AppointmentService: Handles API calls for booking and fetching doctors
- AppointmentRepository: Repository pattern implementation
- Doctor: Entity representing doctor data
- AppointmentBookingRequest: Model for the booking request

📦 Packages Used
Purpose	Package
State Management	flutter_riverpod / bloc
UI Components	flutter_hooks, gap, heroicons
Routing	go_router
Dependency Injection	get_it, riverpod
Forms & Validation	reactive_forms, formz
HTTP / Data	dio, retrofit, json_serializable
Persistence	hive, shared_preferences
Animations	flutter_animate, motion

🧪 Testing Strategy
Use mockito or mocktail for mocking dependencies

test/ folder should mirror the lib/ structure

Write unit tests for:

Use cases (domain layer)

State notifiers/blocs (presentation)

Repositories with mocked APIs

🛠️ Dev Tools
Use very_good_analysis or lint for static analysis

Use melos for monorepo if multiple packages

Use flutter_gen for assets, fonts, and localization

🚀 CI/CD Suggestions
Use GitHub Actions for linting, testing, and building

Use Codemagic, Bitrise, or FlutterFlow CI for deployment

Export production builds with version control

💡 UI/UX Best Practices
Use clear CTAs (Call-To-Actions)

Always show loading states and feedback

Keep spacing and padding consistent (8pt grid recommended)

Use micro-interactions (AnimatedSwitcher, Fade, Hero)

Support dark mode if possible

Make forms accessible and clear

📘 Starter Ideas
Want to bootstrap faster?

Create your own widget library inspired by shadcn components (shad_ui/)

Use AppScaffold, AppButton, AppCard, AppInput to unify layout and interaction

Create a global ThemeExtension for custom tokens

🌐🌓 Flutter Guidelines – Localization (Arabic & English) + Dark/Light Mode in the entire application
🌍 Localization (Arabic 🇸🇦 & English 🇺🇸)
✅ Packages
Use the built-in Flutter localization and flutter_localizations package.

Optionally, you can use easy_localization 