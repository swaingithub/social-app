# Social Media App Blueprint

## Overview

This document outlines the design, features, and development plan for a social media application built with Flutter and Firebase. The goal is to create a unique and modern user experience with a "Claymorphic" design.

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

## Claymorphic Design

The application will feature a "Claymorphic" design, which is characterized by soft shadows, rounded corners, and a vibrant color palette. This design creates a friendly and tactile user experience.

- **Color Palette:** The color palette will be based on a vibrant primary color, with a range of lighter and darker shades for depth and emphasis.
- **Typography:** The typography will be clean and modern, with a focus on readability and visual hierarchy.
- **Component Styling:** The UI components will have a soft, "clay-like" appearance, with rounded corners and subtle shadows to create a sense of depth.

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
2.  **Visual Design Overhaul (Claymorphic):** Update the theme, add custom fonts, and redesign the UI components to create a unique and modern "Claymorphic" look and feel. (In Progress)
3.  **Authentication:** Implement the authentication flow, including the login and sign up screens. (Completed)
4.  **Image Posts:** Implement the ability to create posts with images, including image selection from the device and uploading to Firebase Storage. (Completed)
5.  **Liking Posts:** Implement the ability to like and unlike posts, and update the UI to reflect the like count.
6.  **Home Screen:** Implement the home screen, including the ability to view posts from followed users.
7.  **Comments Screen:** Implement the comments screen, including the ability to view and add comments to a post.
8.  **User Profiles:** Implement user profiles, including the ability to view a user's profile picture, bio, and a grid of their posts.
9.  **Followers/Following:** Implement the ability to follow and unfollow other users.
