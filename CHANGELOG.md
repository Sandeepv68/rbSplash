# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-07-22

### Added
- Initial release of RbSplash
- Unsplash API wrapper with promise-based (futures) responses
- Bearer token and Client-ID authentication
- Full Users API support (profile, photos, liked photos, collections, statistics)
- Full Photos API support (list, get, random, statistics, download link, update, like, unlike)
- Full Search API support (photos, collections, users)
- Current User API support (get profile, update profile)
- Stats API support (totals, monthly)
- Full Collections API support (list, get, CRUD, photos, related, add/remove photos)
- OAuth2 bearer token generation
- Configurable timeout, retries, and retry delay
- Transient error retry with exponential backoff
- Custom error class (`WrapSplashError`) with status code and message
- RSpec test suite with WebMock HTTP stubbing
- Convenience method aliases (`get_photo`, `get_random_photo`, `create_collection`, `update_collection`)

### Fixed
- Replaced `OpenStruct` with dedicated `Response` value class
- Credentials cleared from memory after `generate_bearer_token`
- Only transient network errors are retried (not HTTP 4xx/5xx)
- Error messages now include response body for debugging
- Fixed default timeout from 10ms to 10,000ms
- OAuth token request sends credentials in POST body instead of query params
