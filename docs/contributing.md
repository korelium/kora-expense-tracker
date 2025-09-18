# Contributing to Kora Expense Tracker

## 🤝 Welcome Contributors!

Thank you for your interest in contributing to Kora Expense Tracker! We welcome contributions from developers of all skill levels.

## 🎯 How to Contribute

### 1. Fork the Repository
```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/kora-expense-tracker.git
cd kora-expense-tracker

# Add upstream remote
git remote add upstream https://github.com/korelium/kora-expense-tracker.git
```

### 2. Create a Branch
```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Or bugfix branch
git checkout -b bugfix/issue-description
```

### 3. Make Changes
- Follow our coding standards
- Write tests for new features
- Update documentation as needed
- Ensure all tests pass

### 4. Commit Changes
```bash
# Stage your changes
git add .

# Commit with descriptive message
git commit -m "feat: add new feature description"

# Push to your fork
git push origin feature/your-feature-name
```

### 5. Create Pull Request
- Go to GitHub and create a pull request
- Fill out the PR template
- Link any related issues
- Request review from maintainers

## 📋 Development Setup

### Prerequisites
- Flutter 3.16.0+
- Dart 3.2.0+
- Git
- IDE (VS Code, Android Studio, or IntelliJ)

### Setup Steps
```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/kora-expense-tracker.git
cd kora-expense-tracker

# Install dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build

# Run tests
flutter test

# Analyze code
flutter analyze
```

## 📝 Coding Standards

### Dart/Flutter Standards
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### Code Formatting
```bash
# Format code before committing
dart format .

# Analyze code
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### File Organization
```
lib/
├── core/              # Shared utilities and constants
├── data/              # Data layer (models, providers, services)
├── presentation/      # UI layer (screens, widgets)
└── main.dart         # App entry point
```

### Naming Conventions
- **Files**: Use snake_case (e.g., `user_profile_screen.dart`)
- **Classes**: Use PascalCase (e.g., `UserProfileScreen`)
- **Variables**: Use camelCase (e.g., `userName`)
- **Constants**: Use SCREAMING_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)

## 🧪 Testing Guidelines

### Test Structure
```bash
test/
├── unit/              # Unit tests
├── widget/            # Widget tests
└── integration/       # Integration tests
```

### Writing Tests
```dart
// Example unit test
group('TransactionProvider', () {
  test('should add transaction successfully', () async {
    // Arrange
    final provider = TransactionProviderHive();
    final transaction = Transaction(...);
    
    // Act
    await provider.addTransaction(transaction);
    
    // Assert
    expect(provider.transactions.length, 1);
  });
});
```

### Test Coverage
- Aim for 80%+ test coverage
- Test critical business logic
- Test edge cases and error conditions
- Mock external dependencies

## 🐛 Bug Reports

### Before Reporting
1. Check existing issues
2. Update to latest version
3. Try to reproduce the bug
4. Check logs for error messages

### Bug Report Template
```markdown
**Bug Description**
A clear description of the bug.

**Steps to Reproduce**
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Environment**
- OS: [e.g., Android 12, iOS 15]
- Device: [e.g., Pixel 6, iPhone 13]
- App Version: [e.g., 1.0.0]
- Flutter Version: [e.g., 3.16.0]

**Additional Context**
Any other context about the problem.
```

## ✨ Feature Requests

### Before Requesting
1. Check existing feature requests
2. Consider if it aligns with app goals
3. Think about implementation complexity
4. Consider user impact

### Feature Request Template
```markdown
**Feature Description**
A clear description of the feature.

**Problem Statement**
What problem does this solve?

**Proposed Solution**
How should this work?

**Alternatives Considered**
Other solutions you've considered.

**Additional Context**
Any other context or screenshots.
```

## 📋 Pull Request Guidelines

### PR Template
```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

### Review Process
1. **Automated Checks**: CI/CD pipeline runs tests
2. **Code Review**: Maintainers review code
3. **Testing**: Manual testing on multiple platforms
4. **Approval**: At least one maintainer approval required

## 🏷️ Issue Labels

### Bug Labels
- `bug` - Something isn't working
- `critical` - Critical bug affecting core functionality
- `platform:android` - Android-specific issue
- `platform:ios` - iOS-specific issue
- `platform:desktop` - Desktop-specific issue

### Feature Labels
- `enhancement` - New feature or request
- `ui/ux` - User interface or experience
- `performance` - Performance improvement
- `accessibility` - Accessibility improvement

### Other Labels
- `documentation` - Documentation needs improvement
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention needed
- `wontfix` - Will not be fixed

## 🎉 Recognition

### Contributors
- All contributors are listed in CONTRIBUTORS.md
- Significant contributors get maintainer status
- Regular contributors get special recognition

### Contribution Types
- **Code**: Bug fixes, new features, refactoring
- **Documentation**: Guides, API docs, examples
- **Testing**: Unit tests, integration tests, bug reports
- **Design**: UI/UX improvements, mockups
- **Community**: Helping other contributors, answering questions

## 📞 Getting Help

### Communication Channels
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and discussions
- **Email**: support@korelium.com for private matters

### Response Time
- **Critical Bugs**: Within 24 hours
- **Feature Requests**: Within 1 week
- **General Questions**: Within 3 days
- **Code Reviews**: Within 2 days

## 📜 Code of Conduct

### Our Pledge
We are committed to providing a welcoming and inclusive environment for all contributors.

### Expected Behavior
- Use welcoming and inclusive language
- Be respectful of differing viewpoints
- Accept constructive criticism gracefully
- Focus on what's best for the community

### Unacceptable Behavior
- Harassment, discrimination, or trolling
- Personal attacks or political discussions
- Publishing private information
- Any unprofessional conduct

## 📄 License

By contributing to Kora Expense Tracker, you agree that your contributions will be licensed under the MIT License.

---

*Thank you for contributing to Kora Expense Tracker! Together, we're building something amazing.*
