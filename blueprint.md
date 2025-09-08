# Social Media App Blueprint

## Overview

This document outlines the design, features, and development plan for a social media application built with Flutter and Firebase, with the goal of creating an experience similar to Instagram.

## Project Structure

The project is organized into the following directories:

- `lib`: Contains the main application code.
  - `main.dart`: The entry point of the application.
  - `router.dart`: Defines the application's routes using `go_router`.
  - `screens`: Contains the different screens of the application.
    - `home_screen.dart`: The main feed where users can see posts.
    - `login_screen.dart`: The screen where users can log in or sign up.
    - `create_post_screen.dart`: A screen for creating new posts with images and captions.
    - `comments_screen.dart`: A screen for viewing and adding comments to a post.
    - `profile_screen.dart`: The user's profile screen.
  - `models`: Contains the data models for the application.
    - `post.dart`: The model for a post.
  - `theme`: Contains the theme provider for managing the application's theme.
    - `theme_provider.dart`: The `ChangeNotifier` for managing the theme.
  - `widgets`: Contains reusable widgets used throughout the application.
    - `post_card.dart`: A widget for displaying a single post.
    - `scaffold_with_nav_bar.dart`: A scaffold with a bottom navigation bar.
    - `stories_bar.dart`: A widget to display stories.
    - `post_placeholder.dart`: A placeholder for posts while they are loading.
- `test`: Contains the tests for the application.
  - `widget_test.dart`: An example widget test.
- `assets`: Contains the application's assets.
  - `images`: Contains the images used in the application.

## Design and Style

The application will follow the Material Design 3 guidelines, with a modern and vibrant aesthetic inspired by Instagram.

- **Theme:** The application has a light and dark theme, with a new color scheme and custom fonts to create a unique look and feel.
- **Typography:** The application uses custom fonts from `google_fonts` to enhance the visual hierarchy and readability.
- **Iconography:** The application uses a combination of Material Design icons and custom icons to create a more intuitive and engaging user experience.

## Features

The application will have the following features:

- **Authentication:** Users can sign up and log in with their email and password. A skip login option is also available.
- **Image Posts:** Users can create posts with images and captions. Implemented by adding `image_picker` and `firebase_storage`. A new `CreatePostScreen` allows image selection and caption input, which are then uploaded and stored in Firestore.
- **Liking Posts:** Users can like and unlike posts.
- **Comments:** Users can comment on posts.
- **User Profiles:** Users can view their own and other users' profiles, which will include a profile picture, bio, and a grid of their posts.
- **Followers/Following:** Users can follow and unfollow other users.
- **Theme:** Users can switch between the light and dark theme.

## Development Plan

The development of the application is divided into the following milestones:

1.  **Project Setup:** Set up the project, including the folder structure, dependencies, and Firebase integration. (Completed)
2.  **Visual Design Overhaul:** Update the theme, add custom fonts, and redesign the UI components to create a more modern and visually appealing look. (Completed)
3.  **Authentication:** Implement the authentication flow, including the login and sign up screens. (Completed)
4.  **Image Posts:** Implement the ability to create posts with images, including image selection from the device and uploading to Firebase Storage. (Completed)
5.  **Liking Posts:** Implement the ability to like and unlike posts, and update the UI to reflect the like count.
6.  **Home Screen:** Implement the home screen, including the ability to view posts from followed users.
7.  **Comments Screen:** Implement the comments screen, including the ability to view and add comments to a post.
8.  **User Profiles:** Implement user profiles, including the ability to view a user's profile picture, bio, and a grid of their posts.
9.  **Followers/Following:** Implement the ability to follow and unfollow other users.
