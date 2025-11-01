// Jest Setup File
// This file runs before each test file

// Set test environment variables
process.env.NODE_ENV = 'test';

// Mock console methods to reduce noise in tests
global.console = {
  ...console,
  // Uncomment to ignore specific console methods during tests
  // log: jest.fn(),
  // debug: jest.fn(),
  // info: jest.fn(),
  // warn: jest.fn(),
  // error: jest.fn(),
};

// Add global test utilities
global.testUtils = {
  // Helper to create mock file paths
  mockFilePath: (filename) => `/mock/path/${filename}`,

  // Helper to create mock audio metadata
  mockAudioMetadata: (overrides = {}) => ({
    title: 'Test Song',
    artist: 'Test Artist',
    album: 'Test Album',
    duration: 180,
    bitrate: 320,
    format: 'mp3',
    ...overrides,
  }),
};

// Set up test timeout
jest.setTimeout(10000);