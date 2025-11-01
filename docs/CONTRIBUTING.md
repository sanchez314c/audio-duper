# Contributing to AudioDUPER

Thank you for your interest in contributing to AudioDUPER! This guide provides comprehensive information on how to contribute effectively to this cross-platform audio duplicate detection application.

## 🤝 How to Contribute

### Ways to Contribute

- **Code Contributions**: Fix bugs, add features, improve performance
- **Documentation**: Improve docs, add examples, fix typos
- **Testing**: Write tests, report bugs, improve test coverage
- **Design**: UI/UX improvements, icon design, theming
- **Community**: Help users, share ideas, provide feedback

### Getting Started

1. **Fork the Repository**

   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/your-username/audio-duper.git
   cd audio-duper
   ```

2. **Set Up Development Environment**

   ```bash
   # Install dependencies
   npm install

   # Run in development mode
   npm run dev
   ```

3. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 🏗️ Development Workflow

### Code Standards

#### JavaScript/Node.js Standards

- Use modern ES6+ features
- Follow ESLint configuration (`.eslintrc.json`)
- Use async/await for asynchronous operations
- Implement proper error handling
- Add JSDoc comments for functions

#### Code Style Example

```javascript
/**
 * Generates audio fingerprint for a file
 * @param {string} filePath - Path to audio file
 * @returns {Promise<string|null>} Fingerprint hash or null if failed
 */
async function generateFingerprint(filePath) {
  try {
    const metadata = await getAudioMetadata(filePath);
    const fingerprint = await calculateFingerprint(filePath);
    return fingerprint;
  } catch (error) {
    console.error(`Failed to process ${filePath}:`, error);
    return null;
  }
}
```

### Testing Requirements

#### Test Structure

```
tests/
├── unit/                   # Unit tests
│   ├── main.test.js       # Main process tests
│   ├── audio.test.js      # Audio processing tests
│   └── utils.test.js      # Utility function tests
├── integration/            # Integration tests
│   ├── file-ops.test.js   # File operation tests
│   └── ui.test.js         # UI interaction tests
└── fixtures/              # Test data
    ├── samples/           # Sample audio files
    └── configs/           # Test configurations
```

#### Writing Tests

```javascript
// Example test using Jest
describe('Audio Processing', () => {
  test('should generate fingerprint for valid audio file', async () => {
    const testFile = 'tests/fixtures/sample.mp3';
    const fingerprint = await generateFingerprint(testFile);

    expect(fingerprint).toBeTruthy();
    expect(typeof fingerprint).toBe('string');
    expect(fingerprint.length).toBeGreaterThan(0);
  });

  test('should handle invalid file gracefully', async () => {
    const invalidFile = 'nonexistent.mp3';
    const fingerprint = await generateFingerprint(invalidFile);

    expect(fingerprint).toBeNull();
  });
});
```

### Commit Guidelines

#### Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Commit Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting (no functional change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build process or dependency changes
- `perf`: Performance improvements

#### Examples

```bash
git commit -m "feat(audio): add support for FLAC format"
git commit -m "fix(ui): resolve memory leak in file scanner"
git commit -m "docs: update installation instructions"
```

## 🐛 Bug Reports

### Reporting Bugs

1. **Search Existing Issues**: Check if the bug is already reported
2. **Use Bug Report Template**: Fill out all required sections
3. **Provide Detailed Information**: Include steps to reproduce, expected vs actual behavior
4. **Include Environment Info**: OS, Node.js version, app version
5. **Add Screenshots**: If applicable, include screenshots or screen recordings

### Bug Report Template

```markdown
**Bug Description**
Brief description of the bug

**Steps to Reproduce**

1. Go to...
2. Click on...
3. See error

**Expected Behavior**
What you expected to happen

**Actual Behavior**
What actually happened

**Environment**

- OS: [e.g., macOS 14.0]
- Node.js: [e.g., 18.17.0]
- AudioDUPER: [e.g., v1.2.0]

**Additional Context**
Any other relevant information
```

## ✨ Feature Requests

### Requesting Features

1. **Check Roadmap**: Review if feature is already planned
2. **Search Existing Requests**: Avoid duplicates
3. **Use Feature Request Template**: Provide detailed proposal
4. **Explain Use Case**: Why is this feature needed?
5. **Consider Implementation**: Any technical constraints or suggestions?

### Feature Request Template

```markdown
**Feature Description**
Clear description of the proposed feature

**Problem Statement**
What problem does this solve?

**Proposed Solution**
How should the feature work?

**Alternatives Considered**
Other approaches you've thought about

**Additional Context**
Any relevant information or examples
```

## 🔧 Development Setup

### Prerequisites

- Node.js 16+
- npm or yarn
- Git
- Platform-specific build tools (see installation guide)

### Local Development

```bash
# Clone repository
git clone https://github.com/your-username/audio-duper.git
cd audio-duper

# Install dependencies
npm install

# Start development server
npm run dev

# Run tests
npm test

# Run linting
npm run lint

# Build for testing
npm run build
```

### Debugging

```bash
# Start with debugging
npm run dev:debug

# Enable verbose logging
DEBUG=* npm start

# Test specific functionality
npm test -- --grep "audio processing"
```

## 📝 Documentation Contributions

### Improving Documentation

1. **Identify Area**: What documentation needs improvement?
2. **Check Style**: Follow existing documentation style
3. **Be Specific**: Provide clear, actionable information
4. **Include Examples**: Code examples, screenshots, step-by-step guides
5. **Test Instructions**: Verify your instructions work

### Documentation Types

#### User Documentation

- README.md
- User guides
- FAQ entries
- Tutorial content

#### Developer Documentation

- API documentation
- Architecture guides
- Development setup
- Contributing guidelines

#### Technical Documentation

- Build instructions
- Deployment guides
- Security considerations
- Performance optimization

## 🎨 Design Contributions

### UI/UX Improvements

1. **Understand Users**: Consider user needs and workflows
2. **Follow Design Patterns**: Maintain consistency with existing UI
3. **Test Changes**: Verify improvements work across platforms
4. **Document Changes**: Explain design decisions and implementation

### Icon and Asset Contributions

1. **Check Guidelines**: Review existing icon style and requirements
2. **Multiple Sizes**: Provide assets in all required sizes
3. **Format Requirements**: Use appropriate formats (PNG, ICO, ICNS)
4. **Test Integration**: Verify assets work in the application

## 🧪 Testing Contributions

### Test Coverage

1. **Unit Tests**: Test individual functions and methods
2. **Integration Tests**: Test component interactions
3. **End-to-End Tests**: Test complete user workflows
4. **Performance Tests**: Test with large file sets

### Test Data

1. **Use Fixtures**: Place test files in `tests/fixtures/`
2. **Variety**: Include different audio formats and edge cases
3. **Size Considerations**: Include both small and large files
4. **Legal**: Ensure test files are legally usable

## 🚀 Release Process

### Version Management

1. **Semantic Versioning**: Follow MAJOR.MINOR.PATCH format
2. **Changelog Updates**: Document all changes in CHANGELOG.md
3. **Tag Releases**: Create Git tags for releases
4. **Build Verification**: Test builds on all target platforms

### Release Checklist

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version number updated
- [ ] Build tested on all platforms
- [ ] Release notes prepared

## 🏆 Recognition

### Contributor Recognition

1. **Credits**: Contributors are credited in releases
2. **Contributor List**: Maintained in README.md
3. **Special Thanks**: Notable contributions highlighted
4. **Community**: Active contributors invited to maintainers team

### Types of Contributions Recognized

- Code contributions (features, fixes, optimizations)
- Documentation improvements
- Bug reports and testing
- Community support and user assistance
- Design and UX improvements
- Translation and localization

## 📞 Getting Help

### Support Channels

1. **GitHub Issues**: For bug reports and feature requests
2. **Discussions**: For general questions and community discussion
3. **Documentation**: Check existing docs first
4. **Existing Issues**: Search before creating new issues

### Contact Information

- **Project Maintainers**: Listed in README.md
- **Community Forum**: GitHub Discussions
- **Bug Reports**: GitHub Issues
- **Security Issues**: See SECURITY.md

## 📋 Code Review Process

### Review Guidelines

1. **Thorough Review**: Review all changes carefully
2. **Constructive Feedback**: Provide helpful, specific feedback
3. **Test Changes**: Verify changes work as expected
4. **Documentation**: Ensure documentation is updated
5. **Performance**: Consider performance implications

### Review Checklist

- [ ] Code follows project standards
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No breaking changes (or clearly documented)
- [ ] Security considerations addressed
- [ ] Performance impact considered
- [ ] Cross-platform compatibility verified

## 🔄 Continuous Integration

### CI/CD Pipeline

1. **Automated Testing**: Tests run on all pull requests
2. **Linting**: Code style checks
3. **Build Verification**: Ensure application builds successfully
4. **Security Scanning**: Check for vulnerabilities
5. **Multi-Platform**: Test on different operating systems

### CI Requirements

- All tests must pass
- Code coverage thresholds met
- No linting errors
- Successful builds on all platforms
- Security scan clean

## 📊 Contribution Metrics

### What We Track

1. **Code Contributions**: Commits, pull requests, lines of code
2. **Documentation**: Docs improvements, tutorials
3. **Community**: Issues resolved, discussions participated
4. **Quality**: Test coverage, bug fixes, performance improvements

### Recognition System

1. **Top Contributors**: Monthly and annual recognition
2. **Special Badges**: For specific types of contributions
3. **Release Credits**: Named in release notes
4. **Community Awards**: For outstanding community support

---

Thank you for contributing to AudioDUPER! Your contributions help make this project better for everyone. 🎵

If you have any questions about contributing, don't hesitate to ask in GitHub Discussions or contact the maintainers.
