# Looping Tool MVP

A Flutter application for creating and managing audio loops with precise marker and segment control.

## Overview

The Looping Tool is designed for musicians and audio professionals who need precise control over audio playback, with features for:
- Creating and managing audio markers
- Defining segments for loop playback
- Real-time waveform visualization
- Interactive timeline navigation
- Customizable playback settings

## Project Structure

```
lib/
├── core/
│   └── services/
│       └── audio_service.dart      # Audio playback and processing
├── features/
│   └── looping_tool/
│       ├── models/
│       │   ├── marker.dart         # Marker data model
│       │   └── segment.dart        # Segment data model
│       ├── screens/
│       │   └── main_screen.dart    # Main application screen
│       ├── viewmodels/
│       │   └── looping_tool_viewmodel.dart  # State management
│       └── widgets/
│           ├── timeline/           # Timeline visualization
│           │   ├── daw_timeline.dart
│           │   ├── timeline_painter.dart
│           │   └── timeline_constants.dart
│           └── looping_tool_header.dart
└── theme/
    └── app_colors.dart            # Application theming
```

## Key Components

### Timeline System
The timeline system consists of three main components:
1. `DAWTimeline`: Main interactive timeline widget
2. `TimelinePainter`: Handles the visual rendering
3. `TimelineConstants`: Configuration and styling

### State Management
- Uses Provider pattern for state management
- `LoopingToolViewModel` coordinates between UI and audio service
- `AudioService` handles audio playback and processing

### Theme System
- Dark theme optimized for audio work
- Consistent color palette defined in `AppColors`
- High contrast for better visibility

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Usage

### Adding Markers
1. Load an audio file
2. Use the timeline to navigate to desired position
3. Click to add markers at specific points

### Creating Segments
1. Add at least two markers
2. Segments are automatically created between markers
3. Adjust segment settings in the segment panel

### Playback Control
- Use the main timeline for navigation
- Control playback speed and loop count
- Use the segment selector for focused practice

## Development

### Architecture
The application follows a feature-first architecture:
- Core services handle fundamental functionality
- Features are organized by domain
- Widgets are grouped by feature
- Models represent data structures
- ViewModels manage state and business logic

### State Management
- Provider pattern for dependency injection
- ViewModel for business logic
- Services for external interactions

### Testing
- Unit tests for ViewModels and Services
- Widget tests for UI components
- Integration tests for feature workflows

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License
[Add your license information here]
