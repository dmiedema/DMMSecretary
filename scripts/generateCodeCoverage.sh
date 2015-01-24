#!/bin/bash

function __cmd_exists() {
  if command -v "$1" &> /dev/null; then
    return 1
  else
    return 0
  fi
}

# make sure java is installed
__cmd_exists java
JAVA_EXISTS=$?
if [[ "$JAVA_EXISTS" != 1 ]]; then
  echo "Error: I need Java to generate code coverage with 'groovy'"
  exit 1
fi

__cmd_exists brew
BREW_EXISTS=$?
if [[ "$BREW_EXISTS" != 1 ]]; then
  echo "I need homebrew."
  echo "http://brew.sh"
  exit 1
fi

__cmd_exists groovy
GROOVY_EXISTS=$?
if [[ "$GROOVY_EXISTS" != 1 ]]; then
  brew install groovy
fi

__cmd_exists lcov
LCOV_EXISTS=$?
if [[ "$LCOV_EXISTS" != 1 ]];  then
  brew install lcov
fi

BUILD_COMMAND="xcodebuild "

WORKSPACE=$(ls -Ad ./*.xcworkspace)
PROJECT=$(ls -Ad ./*.xcodeproj)
if [[ -z "$WORKSPACE" ]]; then
  BUILD_COMMAND="$BUILD_COMMAND -workspace $WORKSPACE -scheme ${WORKSPACE%%.*} "
else
  BUILD_COMMAND="$BUILD_COMMAND -project $PROJECT "
fi

BUILD_COMMAND="$BUILD_COMMAND clean build test "

__cmd_exists xcpretty
XCPRETTY=$?

if [[ "$XCPRETTY" == 1 ]]; then
  BUILD_COMMAND="$BUILD_COMMAND | xcpretty -c"
fi

eval "$BUILD_COMMAND"

groovy http://frankencover.it/with -source-dir "$1"
open build/reports/coverage/index.html

