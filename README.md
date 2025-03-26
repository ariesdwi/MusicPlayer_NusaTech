# MusicPlayer_NusaTech# Music Player Project

## Overview
This is a simple music player app built using Swift and following the MVVM architecture. It utilizes the iTunes Search API to fetch and play music. The project is structured to follow best practices in object-oriented programming, including unit testing and CI/CD integration.

## Features
- Search for songs using the iTunes API
- Play, pause, next, and previous song functionality
- Error handling and loading states
- Unit testing using XCTest and Combine
- CI/CD setup (currently up to GitHub, not yet integrated with AppCenter/TestFlight)
- Uses **XcodeGen** for project generation
- Includes a **Makefile** for simplified project management
- Unit testing implemented in the Core module

## Project Structure
```
MusicPlayerProject
├── app
│   ├── source
│   │   ├── Views
│   │   │   ├── Controller.swift
│   │   ├── ViewModel
│   │   │   ├── ViewModel.swift
├── core
│   ├── source
│   │   ├── networking
│   │   │   ├── APIClient.swift
│   │   │   ├── Endpoints.swift
│   │   │   ├── NetworkError.swift
│   │   │   ├── Models
│   │   │   │   ├── SongDTO.swift
│   ├── Test
│   │   ├── APIClientTests
│   │   ├── MockURLProtocol
├── domain
│   ├── source
│   │   ├── UseCase
│   │   │   ├── usecase.swift
```

## Setup Instructions
### Prerequisites
- Xcode
- Swift Package Manager
- XcodeGen
- Fastlane

### Install Dependencies
```sh
make project
```
This will generate the Xcode project using XcodeGen and open it.

### Running Unit Tests
```sh
fastlane test
```
This command will run the unit tests using Fastlane.

### CI/CD Setup
- The project is currently integrated with GitHub.
- Future work: CI/CD integration with AppCenter/TestFlight.

## How to Run the App
1. Clone the repository
2. Run `make project`
3. Open the generated `.xcodeproj` in Xcode
4. Build and run the app on a simulator or device

## Future Enhancements
- Complete CI/CD integration with AppCenter/TestFlight
- Improve UI/UX with custom animations
- Enhance offline support with caching

## License
This project is for personal/hiring use and should not be shared publicly.

