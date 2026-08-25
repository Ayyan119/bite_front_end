# Flutter Architecture & Engineering Guidelines

Whenever creating, modifying, refactoring, or reviewing Flutter/Dart code in this project, you MUST adhere to the following architecture and engineering rules:

## 1. Architecture

Use:
* Feature-first architecture
* Lightweight Clean Architecture
* Riverpod for application/server state
* Repository pattern
* Dependency injection through Riverpod

Do NOT over-engineer the project.
Use the domain layer only when it provides real value. For simple features, `presentation + data` is acceptable.

Preferred structure:
```text
lib/
  core/
    constants/
    errors/
    network/
    router/
    theme/
    utils/

  features/
    <feature_name>/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
      presentation/
        providers/
        screens/
        widgets/

  app.dart
  main.dart
```

For simple features, this can be simplified to:
```text
features/
  <feature_name>/
    data/
    presentation/
```

Do not create unnecessary folders or abstractions.

## 2. State Management

Use Riverpod as the primary state-management and dependency-injection solution.

Use Riverpod for:
* API/server state
* authentication state
* shared application state
* asynchronous operations
* cached server data
* feature state
* dependency injection

Use local Flutter state (`setState`) for small widget-local state such as:
* temporary UI toggles
* expansion state
* simple visual state
* transient widget state

Do NOT create a Riverpod provider for every small UI variable.
Prefer modern Riverpod patterns and immutable state.

Always explicitly handle:
* loading
* success
* error
* empty states

## 3. Data Flow

Follow this dependency direction:
```text
UI → Riverpod Provider/Notifier → Repository → Data Source → API / Database / Firebase
```

Widgets must NOT directly call:
* HTTP APIs
* Dio
* Firebase
* database queries
* repositories containing business logic

UI should communicate with Riverpod providers/notifiers.

## 4. Repository Pattern

Use repositories to isolate data access from presentation.

Example:
```text
AuthScreen → authProvider → AuthRepository → AuthRemoteDataSource → FastAPI
```

Repositories should contain data-access orchestration.
Data sources should handle external systems such as REST APIs, Firebase, local databases, files, and external services.

## 5. Business Logic

Never put business logic inside widgets.

Widgets should primarily handle:
* layout
* presentation
* user interaction
* displaying state

Business logic belongs in Notifiers, Controllers, Services, or Use cases (when genuinely necessary). Do NOT create use-case classes simply to satisfy a textbook Clean Architecture pattern.

## 6. UI Rules

Build reusable, composable widgets.

Prefer:
* small widgets
* `const` constructors
* immutable widgets
* clear widget responsibilities
* responsive layouts
* theme-based styling

Avoid huge `build()` methods. If a widget becomes difficult to understand, extract meaningful sub-widgets. Do not create a separate widget file for trivial one-line widgets unless reuse or readability justifies it.

## 7. Responsive Design

Never assume a single screen size. Use Flutter's constraint-based layout system.

Avoid unnecessary:
* hardcoded widths
* hardcoded heights
* absolute positioning
* device-specific hacks

Prefer `Expanded`, `Flexible`, `LayoutBuilder`, `MediaQuery` (when appropriate), adaptive layouts, and constraints. The UI must work across phones, tablets, different orientations, and screen sizes.

## 8. Theme and Design System

Do not scatter colors, text styles, spacing, or dimensions throughout widgets. Use the project's centralized theme/design system (`ThemeData`, `ColorScheme`, `TextTheme`, `ThemeExtension`).

Create reusable design constants only when they provide real value. Do not hardcode arbitrary colors when a theme value exists.

## 9. Animations

Use Flutter's built-in animation APIs.

Prefer implicit animations for simple transitions (`AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher`, `TweenAnimationBuilder`).
Use explicit animations with `AnimationController` when precise control is required.
Use `Hero`/shared-element transitions where appropriate.

Animations should:
* serve a UX purpose
* be smooth
* avoid unnecessary complexity
* respect accessibility/reduced-motion considerations
* not block user interaction unnecessarily

Do not add animations simply because they are technically possible.

## 10. Navigation

Use GoRouter for application navigation. Keep routing configuration centralized.
Do not navigate by scattering route strings throughout the application.
Prefer named/type-safe routing patterns where supported by the project's setup.

## 11. Networking

Use Dio for HTTP networking unless the project already has another established networking layer. Do not make HTTP requests directly from widgets.

Centralize: base URL, interceptors, authentication headers, timeout configuration, and error handling.
Never hardcode API secrets or credentials. Use environment configuration for sensitive values.

## 12. Models

Use immutable models. Prefer `Freezed` and `json_serializable` for projects that require substantial model serialization.
Keep API/data models separate from UI widgets. Do not put API response parsing inside widgets.

## 13. Error Handling

Do not silently swallow exceptions. Handle errors intentionally. Convert low-level errors into meaningful application-level errors where appropriate.
UI should show useful user-facing error states. Do not expose stack traces, API secrets, or internal server errors directly to users.

## 14. Testing

When implementing important business logic, add appropriate tests.
Prefer unit tests for repositories/services, provider/notifier tests for state logic, widget tests for UI behavior, and integration tests for critical user flows. Do not create meaningless tests merely to increase coverage.

## 15. Code Quality

Always:
* run Dart formatting (`dart format .`)
* run static analysis (`flutter analyze`)
* fix analyzer errors
* avoid unnecessary warnings
* use meaningful names
* keep functions focused
* avoid duplication when practical
* prefer composition over unnecessary inheritance

## 16. Existing Project Conventions

Before creating code:
1. Inspect the existing project structure.
2. Inspect related features.
3. Inspect existing providers, repositories, and models.
4. Inspect routing and theme/design system.
5. Reuse existing patterns when they are good.

Do NOT introduce a new architectural pattern if the project already has an established pattern that is compatible with these rules. When modifying existing code, preserve working behavior unless explicit behavior changes are requested.

## 17. Agent Behavior

Before implementing a feature:
1. Understand the requirement.
2. Inspect relevant existing code.
3. Determine feature ownership.
4. Decide if new files are necessary.
5. Follow the architecture above and implement the smallest clean solution.
6. Run formatting/analyzer/tests when appropriate and fix introduced issues.

When uncertain between a simple solution and a complex abstraction, choose the simpler solution.

Do NOT: create unnecessary services, use cases, interfaces, or providers; duplicate existing functionality; move files without a reason; or introduce new state-management libraries/architectures.

## 18. Mandatory Architecture Check

Before considering a coding task complete, verify:
* Is UI separated from business logic?
* Is API/database access outside widgets?
* Is Riverpod used appropriately?
* Is the repository pattern followed where data access exists?
* Is dependency injection handled through Riverpod?
* Is the feature located in the correct feature folder?
* Is the UI responsive?
* Is theme/design-system usage consistent?
* Are animations appropriate and maintainable?
* Are loading/error/empty states handled?
* Is the implementation unnecessarily complex?
* Does the code match existing project conventions?
* Does `flutter analyze` pass?

If any answer is "no", fix it before finishing the task.

## 19. Priority

When rules conflict, follow this priority:
1. Correctness
2. Existing project conventions
3. Simplicity
4. Maintainability
5. Testability
6. Performance
7. Abstraction

The objective is NOT to demonstrate architectural complexity.
The objective is to produce clean, maintainable, production-quality Flutter code.

## 20. Custom Command: /specs Workflow

When the user invokes `/specs` or asks to generate feature specifications:
1. **Git Status Check**: Execute `git status --porcelain`. If there are any uncommitted changes, abort immediately and notify the user to clean their git working tree first.
2. **Branch Creation**: If clean, create a dedicated feature branch using `git checkout -b feature/<task-slug>`.
3. **Spec File Generation**: Create a comprehensive specification file in `specs/<task_slug>.md` detailing API DTOs, layered architecture, Riverpod providers, UI layout specs, and test plans.

