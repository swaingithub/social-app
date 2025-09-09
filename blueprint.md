# Social Media App Blueprint

## Overview

This document outlines the design, features, and development plan for a social media application built with Flutter and Firebase. The goal is to create a unique and modern user experience with a "Claymorphic" design.

## Project Structure

The project is organized into the following directories:

- `lib`: Contains the main application code.
  - `main.dart`: The entry point of the application.
  - `routing`: Defines the application's routes using `go_router`.
    - `app_router.dart`: The main router configuration.
  - `screens`: Contains the different screens of the application.
    - `home_screen.dart`: The main feed where users can see posts.
    - `login_screen.dart`: The screen where users can log in or sign up.
    - `add_post_screen.dart`: A screen for creating new posts with images and captions.
    - `comments_screen.dart`: A screen for viewing and adding comments to a post.
    - `profile_screen.dart`: The user's profile screen.
    - `full_screen_post_screen.dart`: A screen for displaying a single post in a full-screen, immersive view.
    - `explore_screen.dart`: A screen for discovering new content.
    - `stories_screen.dart`: A screen for displaying stories and a news feed.
    - `root_screen.dart`: The root screen that contains the bottom navigation bar.
  - `models`: Contains the data models for the application.
    - `post.dart`: The model for a post.
    - `user.dart`: The model for a user.
    - `comment.dart`: The model for a comment.
  - `providers`: Contains the change notifiers for managing the application's state.
    - `theme_provider.dart`: The `ChangeNotifier` for managing the theme.
    - `feed_provider.dart`: The `ChangeNotifier` for managing the feed.
    - `comment_provider.dart`: The `ChangeNotifier` for managing comments.
  - `services`: Contains the services for interacting with Firebase.
    - `api_service.dart`: The service for interacting with Firestore and Firebase Storage.
  - `theme`: Contains the theme provider for managing the application's theme.
    - `theme_provider.dart`: The `ChangeNotifier` for managing the theme.
  - `widgets`: Contains reusable widgets used throughout the application.
    - `post_card.dart`: A widget for displaying a single post.
    - `comment_card.dart`: A widget for displaying a single comment.
- `test`: Contains the tests for the application.
  - `widget_test.dart`: An example widget test.
- `assets`: Contains the application's assets.
  - `images`: Contains the images used in the application.

## Claymorphic Design

The application will feature a "Claymorphic" design, which is characterized by soft shadows, rounded corners, and a vibrant color palette. This design creates a friendly and tactile user experience.

- **Color Palette:** The color palette will be based on a vibrant primary color, with a range of lighter and darker shades for depth and emphasis.
- **Typography:** The typography will be clean and modern, with a focus on readability and visual hierarchy.
- **Component Styling:** The UI components will have a soft, "clay-like" appearance, with rounded corners and subtle shadows to create a sense of depth.
- **Layout:** The home feed will be a traditional scrollable feed, but with a unique and modern "Claymorphic" `PostCard` design. A full-screen, immersive view of each post will be accessible by tapping on the post.

## Features

- **Authentication:** Users can sign up and log in with their email and password. A skip login option is also available.
- **Navigation:** A bottom navigation bar with four main sections: Home, Stories/News, Explore, and Profile.
- **Image Posts:** Users can create posts with images and captions using a floating action button on the home screen.
- **Liking Posts:** Users can like and unlike posts.
- **Double-Tap to Like:** Users can double-tap on a post to like it.
- **Comments:** Users can comment on posts.
- **User Profiles:** Users can view their own and other users' profiles, which will include a profile picture, bio, and a grid of their posts.
- **Followers/Following:** Users can follow and unfollow other users.
- **Theme:** Users can switch between the light and dark theme.
- **Full-Screen Post View:** Users can tap on a post to view it in an immersive, full-screen mode.
- **Stories & News:** A dedicated screen for viewing stories and a news feed.

## Development Plan

The development of the application is divided into the following milestones:

1.  **Project Setup:** Set up the project, including the folder structure, dependencies, and Firebase integration. (Completed)
2.  **Visual Design Overhaul (Claymorphic):** Update the theme, add custom fonts, and redesign the UI components to create a unique and modern "Claymorphic" look and feel. (Completed)
3.  **Home Screen Redesign (Claymorphic Feed):** Redesign the home screen to feature a scrollable feed with a unique and modern "Claymorphic" `PostCard` design. (Completed)
4.  **Authentication:** Implement the authentication flow, including the login and sign up screens. (Completed)
5.  **Image Posts:** Implement the ability to create posts with images, including image selection from the device and uploading to Firebase Storage. (Completed)
6.  **Liking Posts:** Implement the ability to like and unlike posts, and update the UI to reflect the like count. (Completed)
7.  **Double-Tap to Like:** Implement the double-tap to like gesture on posts. (Completed)
8.  **Comments Screen:** Implement the comments screen, including the ability to view and add comments to a post. (Completed)
9.  **UI and Navigation Redesign:** Redesign the bottom navigation, remove stories from the home screen, and create a new screen for stories and news. (Completed)
10. **User Profiles:** Implement user profiles, including the ability to view a user's profile picture, bio, and a grid of their posts.
11. **Followers/Following:** Implement the ability to follow and unfollow other users.
12. **Full-Screen Post View:** Implement a full-screen view for posts, accessible by tapping on a post in the feed. (Completed)
