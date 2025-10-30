# 🤝 Contributing to AudioDUPER

Thank you for your interest in contributing to AudioDUPER! This document provides guidelines and information for contributors. Please read it carefully before submitting any changes.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Guidelines](#development-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Release Process](#release-process)

## 🤝 Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors. Please read our [Code of Conduct](.github/CODE_OF_CONDUCT.md) and adhere to these guidelines in all interactions.

### Expected Behavior

- **Resful**: Treat all contributors with respect and kindness
- **Inclusive**: Welcome contributors from all backgrounds and experience levels
- **Constructive**: Provide helpful, specific feedback
- **Collaborative**: Work together to find the best solutions
- **Patient**: Understand that contributors have different schedules and availability

### Unacceptable Behavior

- Harassment or discriminatory language
- Personal attacks or insults
- Spam or irrelevant content
- Disruptive behavior
- Sharing private information without consent

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Node.js** 16+ installed
- **Git** configured and set up
- **GitHub** account with two-factor authentication
- **Code editor** (VS Code recommended)
- **Time and patience** for the review process

### Initial Setup

1. **Fork the Repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/audiodupe.git
   cd audiodupe
   ```

2. **Add Upstream Remote**
   ```bash
   git remote add upstream https://github.com/audiodupe/audiodupe.git
   ```

3. **Install Dependencies**
   ```bash
   npm install
   ```

4. **Verify Setup**
   ```bash
   npm test
   npm run build
   ```

5. **Start Development**
   ```bash
   npm run dev
   ```

## 📝 How to Contribute

### Types of Contributions

We welcome the following types of contributions:

#### 🐛 Bug Fixes
- Fix existing issues
- Improve error handling
- Resolve crashes or unexpected behavior

#### ✨ New Features
- Add new functionality
- Enhance existing features
- Improve user experience

#### 📚 Documentation
- Improve README.md
- Add technical documentation
- Fix typos or clarify instructions

#### 🧪 Testing
- Write new tests
- Improve test coverage
- Fix broken tests

#### 🎨 Design/UX
- Improve user interface
- Enhance user experience
- Add visual elements

#### ⚡ Performance
- Optimize existing code
- Improve memory usage
- Speed up operations

#### 🔧 Build/Infrastructure
- Improve build process
- Add new build targets
- Enhance CI/CD pipeline

### Finding Issues to Work On

1. **Good First Issues**: Look for issues labeled `good first issue`
2. **Help Wanted**: Check for `help wanted` label
3. **Bugs**: Review issues with `bug` label
4. **Enhancements**: Check `enhancement` label
5. **Discussions**: Participate in GitHub Discussions

### Claiming Issues

To avoid duplicate work:

1. **Check for existing work**: Look for open PRs
2. **Comment your intent**: Add a comment to the issue
3. **Wait for assignment**: Maintainers will assign the issue
4. **Create an issue**: If you have a new idea, create an issue first

## 🛠️ Development Guidelines

### Code Style

We follow these coding standards:

#### JavaScript/Node.js
```javascript
// Use async/await instead of callbacks
async function processFile(filePath) {
  try {
    const result = await audioProcessor.analyze(filePath);
    return result;
  } catch (error) {
    console.error(`Failed to process ${filePath}:`, error);
    throw error;
  }
}

// Use descriptive variable names
const duplicateFileGroups = findDuplicateGroups(audioFiles);
const highestQualityFiles = selectHighestQuality(duplicateFileGroups);

// Add JSDoc comments for public functions
/**
 * Finds duplicate audio files using acoustic fingerprinting
 * @param {string[]} filePaths - Array of file paths to analyze
 * @param {Object} options - Processing options
 * @returns {Promise<DuplicateGroup[]>} Array of duplicate groups
 */
async function findDuplicates(filePaths, options = {}) {
  // Implementation
}
```

#### File Organization
```
src/
├── main.js              # Main Electron process
├── preload.js           # Secure bridge
├── index.html           # UI
├── components/          # UI components
│   ├── file-list.js
│   └── progress-bar.js
├── services/            # Business logic
│   ├── audio-processor.js
│   └── file-manager.js
└── utils/               # Utility functions
    ├── format-helper.js
    └── path-validator.js
```

### Git Workflow

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/description-of-change
   ```

2. **Make Changes**
   - Follow existing code patterns
   - Add appropriate tests
   - Update documentation
   - Keep changes focused and atomic

3. **Commit Changes**
   ```bash
   # Stage changes
   git add .

   # Commit with conventional commit format
   git commit -m "feat: add audio format validation"
   ```

4. **Branch Naming Convention**
   ```
   feature/description
   fix/issue-number-description
   docs/update-documentation
   test/add-test-coverage
   build/enhance-build-process
   ```

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `build`: Build system changes
- `ci`: CI/CD changes
- `perf`: Performance improvements
- `chore`: Maintenance tasks

**Examples:**
```
feat(audio): add FLAC format support
fix: resolve crash when processing corrupted files
docs: update installation instructions for Windows
test: add unit tests for audio processor
perf: improve memory usage for large file sets
```

## 🔄 Pull Request Process

### Before Submitting

1. **Create Proper Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Quality Changes**
   - Code follows project style guidelines
   - Includes appropriate tests
   - Updates documentation
   - Builds successfully

3. **Test Thoroughly**
   ```bash
   npm test
   npm run build
   npm run lint
   ```

4. **Sync with Main**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

### Submitting Pull Request

1. **Create Pull Request**
   - Use descriptive title
   - Fill out PR template completely
   - Link relevant issues
   - Add screenshots if UI changes

2. **PR Template**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] All tests pass
   - [ ] Added new tests
   - [ ] Manual testing completed

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Documentation updated
   - [ ] Build tested on [platforms]
   ```

3. **Review Process**
   - Address reviewer feedback promptly
   - Update PR based on suggestions
   - Keep PR description current
   - Respond to all comments

### Merge Requirements

PR must meet these criteria before merging:

- ✅ All tests pass
- ✅ Code builds successfully on all platforms
- ✅ Documentation updated
- ✅ No merge conflicts
- ✅ At least one approval from maintainer
- ✅ CI/CD checks pass

## 🐛 Issue Reporting

### Bug Reports

Use the bug report template:

```markdown
**Describe the bug**
Clear description of what happened

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
What you expected to happen

**Screenshots**
Add screenshots if applicable

**Environment:**
 - OS: [e.g. macOS 13.0, Windows 11, Ubuntu 22.04]
 - AudioDUPER version: [e.g. 1.2.3]
 - Audio formats: [e.g. MP3, FLAC]

**Additional context**
Add any other context about the problem
```

### Feature Requests

Use the feature request template:

```markdown
**Is your feature request related to a problem?**
Clear description of the problem

**Describe the solution you'd like**
Detailed description of desired solution

**Describe alternatives you've considered**
Other solutions you've considered

**Additional context**
Additional information about the request
```

### Issue Labels

- `bug`: Bug reports
- `enhancement`: Feature requests
- `documentation`: Documentation issues
- `good first issue`: Good for new contributors
- `help wanted`: Needs community help
- `priority: high`: High priority issues
- `priority: low`: Low priority issues

## 🧪 Testing Guidelines

### Test Types

1. **Unit Tests**
   - Test individual functions
   - Mock external dependencies
   - Fast and focused tests

2. **Integration Tests**
   - Test component interactions
   - Test IPC communication
   - Test file operations

3. **End-to-End Tests**
   - Test complete workflows
   - Test user interactions
   - Test cross-platform compatibility

### Writing Tests

```javascript
// Example unit test
const assert = require('assert');
const { findDuplicates } = require('../src/services/audio-processor');

describe('Audio Processor', () => {
  it('should identify duplicate files', async () => {
    const files = [
      'test/fixtures/song.mp3',
      'test/fixtures/song-copy.mp3'
    ];

    const duplicates = await findDuplicates(files);

    assert.strictEqual(duplicates.length, 1);
    assert.strictEqual(duplicates[0].files.length, 2);
  });

  it('should handle invalid file paths', async () => {
    const files = ['nonexistent.mp3'];

    await assert.rejects(
      () => findDuplicates(files),
      /File not found/
    );
  });
});
```

### Test Commands

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Run tests with coverage
npm run test:coverage

# Run specific test file
npm test -- tests/unit/audio-processor.test.js
```

### Test Coverage

- Aim for 80%+ code coverage
- Focus on critical paths
- Test error conditions
- Test edge cases

## 📚 Documentation Standards

### Required Documentation

1. **README.md**: User documentation
2. **DEVELOPMENT.md**: Development setup and guide
3. **API Documentation**: For public APIs
4. **Inline Comments**: For complex logic
5. **CHANGELOG.md**: Version history

### Documentation Style

- Use clear, concise language
- Provide code examples
- Include screenshots for UI changes
- Link to related documentation
- Keep documentation up to date

### API Documentation

```javascript
/**
 * Processes audio files to find duplicates
 * @param {string[]} filePaths - Array of file paths to process
 * @param {Object} options - Processing options
 * @param {boolean} options.includeSubdirs - Include subdirectories
 * @param {string[]} options.formats - Audio formats to include
 * @returns {Promise<DuplicateGroup[]>} Array of duplicate groups
 * @throws {Error} When file processing fails
 * @example
 * const duplicates = await findDuplicates(
 *   ['/music/artist'],
 *   { includeSubdirs: true, formats: ['mp3', 'flac'] }
 * );
 */
async function findDuplicates(filePaths, options = {}) {
  // Implementation
}
```

## 🚀 Release Process

### Version Management

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Steps

1. **Update Version**
   ```bash
   npm version patch  # or minor/major
   ```

2. **Update Changelog**
   ```bash
   npm run changelog
   ```

3. **Create Release Build**
   ```bash
   npm run dist:maximum
   ```

4. **Create GitHub Release**
   - Tag with version number
   - Add release notes
   - Attach build artifacts

5. **Update Documentation**
   - Update version in README
   - Add new features to documentation
   - Update compatibility information

### Changelog Format

```markdown
## [1.2.3] - 2024-01-15

### Added
- Support for Opus audio format
- Progress indicators for long operations
- Dark mode theme option

### Fixed
- Crash when processing corrupted audio files
- Memory leak during large file scans
- Incorrect file size display on Windows

### Changed
- Improved duplicate detection algorithm
- Updated Electron to version 28.0.0
- Enhanced error messages

### Deprecated
- Support for Windows 7 (will be removed in v2.0.0)

### Removed
- Legacy settings panel
- Support for 32-bit macOS builds
```

## 🎯 Recognition

### Contributor Recognition

- All contributors listed in README
- Special thanks in release notes
- Contributor badges on GitHub
- Annual contributor spotlight

### Ways to Contribute

- Code contributions
- Bug reports and feature requests
- Documentation improvements
- Testing and quality assurance
- Community support and discussions
- Translation and localization

## 📞 Getting Help

### Resources

- **GitHub Issues**: Report bugs and request features
- **GitHub Discussions**: Community discussions and questions
- **Documentation**: Comprehensive guides and API docs
- **Wiki**: Additional tutorials and guides

### Contact

- **Maintainers**: @maintainer1, @maintainer2
- **Community**: GitHub Discussions
- **Security**: security@audiodupe.com

## 🙏 Thank You

Thank you for contributing to AudioDUPER! Your contributions help make this project better for everyone. We appreciate your time, effort, and expertise.

---

**Happy coding! 🎵**

*AudioDUPER Team*