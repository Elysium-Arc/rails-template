#!/bin/bash
APP_NAME=$1
if [ -z "$APP_NAME" ]; then
  echo "Usage: ./setup.sh MyAppName"
  exit 1
fi

echo "Replacing __APP_NAME__ with $APP_NAME..."
find . -type f -exec sed -i "s/__APP_NAME__/$APP_NAME/g" {} +

rm -rf .git
git init
git add .
git commit -m "Initial commit for $APP_NAME"

echo "Setup complete for $APP_NAME."
