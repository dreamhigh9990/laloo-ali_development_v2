#!/bin/bash

#########################
# Clear iOS working/development environment
#
# Requirements (packages): bash, fluttersdk
# Run (command line): cd <TALKILA_ROOT_DIR> && ./clear_ios_environment.sh
# NOTE: script is tested using mac
#########################

# exit when any command fails
set -e

echo "Clear iOS working/development environment (CLOSE XCODE FIRST!!!)"

echo -ne "Delete project's temp files located at ~/Library/Developer/Xcode/DerivedData... "
rm -rf ~/Library/Developer/Xcode/DerivedData
echo "finished."

echo -ne "Delete project file..."
rm -rf ios/Runner.xcworkspace
echo "finished."

echo -ne "Delete Podfile.lock and Pods..."
rm -rf ios/Podfile.lock ios/Pods
echo "finished."

echo "Flutter clean..."
flutter clean
echo "finished."

echo "Flutter pub get..."
flutter pub get
echo "finished."

echo "Installing Pods..."
cd ios/ && pod install
echo "finished."

echo "Process finished with exit code 0"
exit 0