# Contributing to RbSplash

Thank you for considering contributing to RbSplash! This document provides guidelines and information for contributors.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

### Reporting Bugs

1. Check the [existing issues](https://github.com/SandeepVattapparambil/rb_splash/issues) to avoid duplicates.
2. Open a new issue with a clear title and description.
3. Include steps to reproduce, expected behavior, and actual behavior.
4. Include your Ruby version and OS.

### Suggesting Features

1. Open an issue with the `enhancement` label.
2. Describe the feature, why it's needed, and how it should work.

### Submitting Pull Requests

1. Fork the repository.
2. Create a feature branch from `main`:
   ```sh
   git checkout -b feature/my-feature
   ```
3. Make your changes with tests.
4. Ensure all tests pass:
   ```sh
   bundle exec rspec
   ```
5. Commit with a clear message.
6. Push and open a pull request.

## Development Setup

```sh
git clone https://github.com/SandeepVattapparambil/rb_splash.git
cd rb_splash
bundle install
bundle exec rspec
```

## Pull Request Guidelines

- Write tests for new features and bug fixes.
- Follow existing code style (frozen string literals, 2-space indent).
- Update documentation if needed.
- Keep PRs focused on a single change.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
