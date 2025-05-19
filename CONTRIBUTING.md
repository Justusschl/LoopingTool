# Contributing to Looping Tool

Thank you for your interest in contributing to the Looping Tool project! This document provides guidelines and instructions for contributing.

## Development Setup

1. Fork and clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add documentation comments for all public APIs
- Keep functions small and focused
- Write unit tests for new features

## Project Structure

### Core Components
- `audio_service.dart`: Handles audio playback
- `looping_tool_viewmodel.dart`: Manages application state
- `main_screen.dart`: Main application screen

### Timeline System
The timeline system is organized into three main components:
1. `daw_timeline.dart`: Main interactive timeline
2. `timeline_painter.dart`: Visual rendering
3. `timeline_constants.dart`: Configuration

### Adding New Features

1. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Implement your changes:
   - Add new files in appropriate directories
   - Update existing files as needed
   - Add tests for new functionality
   - Update documentation

3. Test your changes:
   ```bash
   flutter test
   ```

4. Submit a pull request:
   - Describe your changes
   - Reference any related issues
   - Include screenshots if UI changes

## Testing

### Unit Tests
- Test ViewModels and Services
- Mock dependencies
- Test edge cases

### Widget Tests
- Test UI components
- Verify user interactions
- Test state changes

### Integration Tests
- Test feature workflows
- Verify component interactions
- Test real audio playback

## Documentation

### Code Documentation
- Add documentation comments for all public APIs
- Explain complex logic
- Document assumptions and limitations

### User Documentation
- Update README.md for new features
- Add usage examples
- Document configuration options

## Pull Request Process

1. Update documentation
2. Add tests for new features
3. Ensure all tests pass
4. Update the changelog
5. Submit the pull request

## Code Review

- Review for code style
- Check test coverage
- Verify documentation
- Test functionality
- Review performance impact

## Questions?

Feel free to open an issue for any questions or concerns. 