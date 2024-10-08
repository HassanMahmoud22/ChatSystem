# Chat Application Project Overview

This README provides an in-depth look at the chat application's architecture, key components, data flow, and how we handle concurrency, race conditions, and parallelism. The application leverages a microservices architecture, background jobs, Redis for caching, and Elasticsearch for search capabilities.

## Table of Contents

1. [Project Structure](#project-structure)
2. [Endpoints](#endpoints)
   - [ApplicationsController Endpoints](#applicationscontroller-endpoints)
   - [ChatsController Endpoints](#chatscontroller-endpoints)
   - [MessagesController Endpoints](#messagescontroller-endpoints)
3. [Data Flow](#data-flow)
4. [Race Conditions and Parallelism Handling](#handling-race-conditions-and-parallelism)
5. [Technologies Used](#technologies-used)
6. [Setup Instructions](#setup-instructions)
7. [Conclusion](#conclusion)

## Project Structure

The project is organized into controllers, services, background jobs, and data storage components. Each functionality is encapsulated in its service, promoting scalability and maintainability.

### Controllers

1. **ApplicationsController:** Manages application-related actions such as creating, retrieving, and updating applications.
2. **ChatsController:** Handles chat-related functionality like chat creation and retrieving all chats for an application.
3. **MessagesController:** Manages messages, including creating, retrieving, and searching within chats.

### Services

- **ApplicationsService:** Handles business logic for applications.
- **ChatsService:** Manages chat creation and retrieval, with logic for handling chat counts and numbers.
- **MessagesService:** Deals with message creation, retrieval, and search functionality.

### Background Jobs

- **ChatCreationJob:** Manages chat creation asynchronously to reduce main thread blocking.
- **MessageCreationJob:** Asynchronously processes message creation.

### Data Storage

- **Relational Database (MySQL or PostgreSQL):** Stores applications, chats, and messages.
- **Redis:** Caches frequently accessed data such as chat counts and application tokens.
- **Elasticsearch:** Enables fast search functionality for messages.

## Endpoints

### ApplicationsController Endpoints

1. **POST /api/v1/applications**
   - **Description:** Creates a new application.
   - **Request Body:** `{ "name": "application_name" }`
   - **Response:** `201 Created` with `{ "token": "application_token" }`
   - **Errors:** `400 Bad Request` for invalid input.

2. **GET /api/v1/applications/:token**
   - **Description:** Retrieves an application by token.
   - **Response:** `200 OK` with `{ "name": "application_name", "token": "application_token", "chat_count": "chatcount"  }`
   - **Errors:** `404 Not Found` if the application does not exist.

3. **PUT /api/v1/applications/:token**
   - **Description:** Updates the application name.
   - **Request Body:** `{ "name": "new_application_name" }`
   - **Response:** `200 OK` with the updated application data.
   - **Errors:** `404 Not Found`, `400 Bad Request`.

### ChatsController Endpoints

1. **POST /api/v1/applications/:token/chats**
   - **Description:** Creates a new chat within an application.
   - **Response:** `201 Created` with `{ "chat_number": "ChatNumber" }`
   - **Errors:** `404 Not Found`, `400 Bad Request`.

2. **GET /api/v1/applications/:token/chats**
   - **Description:** Retrieves all chats associated with an application.
   - **Response:** `200 OK` with chat list.
   - **Errors:** `404 Not Found`.

### MessagesController Endpoints

1. **POST /api/v1/applications/:token/chats/:chat_number/messages**
   - **Description:** Creates a new message within a chat.
   - **Request Body:** `{"body": "MessageContent"}`
   - **Response:** `201 Created` with `{ "message_number": "MessageNumber" }`
   - **Errors:** `404 Not Found`, `400 Bad Request`.

2. **GET api/v1/applications/:token/chats/:chat_number/messages**
   - **Description:** Retrieves messages for a specific chat.
   - **Response:** `200 OK` with message list.
   - **Errors:** `404 Not Found`.

3. **GET /api/v1/applications/:token/chats/1/messages/search?query=:SearchQuery**
   - **Description:** Searches messages in a chat.
   - **Query Params:** `query=searchQuery`
   - **Response:** `200 OK` with search results.
   - **Errors:** `404 Not Found`.

## Data Flow

### Application Creation Flow

1. Client sends a POST request to `/api/v1/applications` with the application name.
2. `ApplicationsController#create` validates and forwards the request to `ApplicationsService#create_application`.
3. The application is created in the database, and the application token is returned.

### Chat Creation Flow

1. Client sends a POST request to `/api/v1/chats` with the application token.
2. `ChatsController#create` invokes `ChatsService#create_chat`.
3. A `ChatCreationJob` is enqueued to handle chat creation asynchronously.
4. The response returns the newly created chat number.

### Message Creation Flow

1. Client sends a POST request to `/api/v1/messages` with the application token, chat number, and message body.
2. `MessagesController#create` calls `MessagesService#create`.
3. The `MessageCreationJob` processes the request in the background, ensuring message uniqueness and race condition prevention.

### Retrieving Chats and Messages

- Chats and messages are retrieved using the respective `GET` endpoints. The controllers interact with the services to fetch data from the database or cache, ensuring fast response times.

## Handling Race Conditions and Parallelism

Concurrency is managed using Redis for chat and message counts, background jobs for asynchronous processing, and unique constraints in the database for enforcing data integrity.

1. **Redis:** Chat and message counts are stored in Redis for fast access, reducing database load.
2. **Background Jobs:** All chat and message creations are processed asynchronously, preventing blocking of main threads.
3. **Locking Mechanisms:** Redis locks are implemented to ensure sequential access to shared resources like chat numbers and message counts.

## Technologies Used

- **Ruby on Rails:** Web framework for building the application.
- **MySQL:** Relational database for persistent data storage.
- **Redis:** In-memory data store for caching frequently accessed data.
- **Elasticsearch:** Search engine used for querying messages.
- **Sidekiq:** Background job processing system.

## Setup Instructions

1. Clone the repository.
2. Install the necessary gems:
   ```bash
   bundle install
3. build the Docker file:
   ```bash
   docker-compose build 
4. run the Docker file:
   ```bash
   docker-compose up      
