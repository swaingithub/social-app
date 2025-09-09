
# Instagram Clone Blueprint

## Overview

This document outlines the plan, features, and design of a Flutter-based Instagram clone.

## Features

### Backend

*   **User Authentication:** Users can register and log in using a MySQL database.
*   **Posts:** Users can create and view posts, which are stored in a MongoDB database.
*   **Database Integration:** The backend uses both MySQL and MongoDB.

### Frontend

*   **User Authentication:**
    *   Login screen
    *   Registration screen
*   **Posts:**
    *   View all posts
    *   Create a new post
*   **State Management:** The application uses the `provider` package for state management.
*   **API Communication:** The `http` package is used to communicate with the backend.
*   **Persistent Login:** The `shared_preferences` package is used to keep the user logged in.

## Design

The application has a clean and modern design, similar to the official Instagram app.

## Implemented Features

*   **Dependencies:** Added the `http`, `provider`, and `shared_preferences` packages.
*   **Project Structure:** Created the necessary directories for the application.
*   **API Service:** Created a service to handle API requests.
*   **Models:** Created the `user` and `post` models.
*   **Providers:** Created providers for authentication and posts.
*   **Screens:** Created screens for login, registration, home, and creating posts.
*   **Widgets:** Created a widget for displaying a single post.
*   **`main.dart`:** Updated the `main.dart` file to include the necessary providers and routes.
