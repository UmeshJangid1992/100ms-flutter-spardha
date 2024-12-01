#!/bin/bash

# Exit the script on any command with a non-zero exit code
set -e

# Variables 
UPSTREAM_REPO="https://github.com/100mslive/100ms-flutter.git"
FORK_REPO="https://github.com/UmeshJangid1992/100ms-flutter-spardha.git"
MOBILE_REPO="https://github.com/UmeshJangid1992/mobilesdk-100ms-music-mode.git"
BRANCH="spardha-music-mode"
TEMP_DIR="temp_sync_dir"

# Step 1: Clone the forked 100ms-flutter-spardha repository
echo "Cloning forked 100ms-flutter-spardha repository..."
rm -rf $TEMP_DIR
git clone $FORK_REPO $TEMP_DIR
cd $TEMP_DIR

# Step 2: Add the upstream repository and fetch the latest changes
echo "Adding upstream repository..."
git remote add upstream $UPSTREAM_REPO
echo "Fetching updates from upstream..."
git fetch upstream

# Step 3: Checkout the target branch and merge updates from upstream
echo "Switching to $BRANCH branch..."
git fetch upstream
git checkout -b $BRANCH upstream/$BRANCH
echo "Merging updates from upstream/$BRANCH..."
git merge upstream/$BRANCH --no-edit

# Step 4: Push updates to the forked repository
echo "Pushing updates to the forked repository..."
git push origin $BRANCH

# Step 5: Clone the mobilesdk-100ms-music-mode (our branch which to be added in mobile app repo.) repository
echo "Cloning mobilesdk-100ms-music-mode repository..."
cd ..
rm -rf mobile_repo
git clone $MOBILE_REPO mobile_repo
cd mobile_repo

# Step 6: Fetch and merge the updated spardha-music-mode branch into mobilesdk-100ms-music-mode (our branch which to be added in mobile app repo.)
echo "Fetching and merging $BRANCH branch from forked repository..."
git remote add 100ms-flutter-spardha $FORK_REPO
git fetch 100ms-flutter-spardha
git checkout main
git merge 100ms-flutter-spardha/$BRANCH --allow-unrelated-histories --no-edit

# Step 7: Push changes to the mobilesdk-100ms-music-mode repository
echo "Pushing updates to the mobilesdk-100ms-music-mode repository..."
git push origin main

# Clean up
cd ..
rm -rf $TEMP_DIR mobile_repo

echo "Sync process completed successfully!"
