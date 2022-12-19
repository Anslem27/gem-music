#!/usr/bin/env bash
# The scipt below optimises a flutter project.

# Check for the existence of the Flutter binary
if ! [ -x "$(command -v flutter)" ]; then
  echo "Error: Flutter is not installed or is not in your PATH." >&2
  exit 1
fi

# Run Flutter's doctor command to check for any issues with the project
echo "Running Flutter doctor to check for any issues with the project..."
flutter doctor

# Run Flutter's analyze command to check for any code issues
echo "Running Flutter analyze to check for any code issues..."
flutter analyze

# Run Flutter's format command to ensure that the code is properly formatted
echo "Running Flutter format to ensure that the code is properly formatted..."
flutter format -n .

# Run Flutter's build command to build the project
echo "Running Flutter build to build the project..."
flutter build

# Run Flutter's test command to run the project's tests
echo "Running Flutter test to run the project's tests..."
flutter test
