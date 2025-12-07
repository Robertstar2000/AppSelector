# AppSelector
Tool to select a app from a list of apps to allow one url to service a group of apps

## Run Locally

**Prerequisites:** Node.js

1. Install dependencies:
   `npm install`
2. Run the app:
   `npm run dev`

This will start both the frontend (port 3110) and backend (port 3001) simultaneously.

## Features

- Application launcher with customizable cards
- Admin mode for editing and reordering apps
- Drag and drop to reorder apps in admin mode
- Persistent storage using SQLite database
- Backup functionality to download all app data as JSON
- Reduced card sizes for better layout

## Admin Mode

- Click the version number in the footer 5 times to toggle admin mode
- Edit apps by clicking on them in admin mode
- Add new apps with the "+" button
- Drag and drop cards to reorder
- Download backup by clicking the download icon in the header

## Backup

Access the backup feature in admin mode via the download button in the top right of the header. This downloads a JSON file with all app data and a timestamp.
