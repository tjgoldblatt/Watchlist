#!/bin/sh

#  Script.sh
#  Watchlist
#
#  Created by TJ Goldblatt on 6/4/23.
#  
defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES
echo "Starting build number"
buildNumber=$(CI_BUILD_NUMBER)
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$plist"
