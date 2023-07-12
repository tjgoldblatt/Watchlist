#!/bin/sh

#  Script.sh
#  Watchlist
#
#  Created by TJ Goldblatt on 6/4/23.
#

defaults write com.apple.dt.Xcode IDESkipPackagePluginFingerprintValidatation -bool YES

buildNumber=$CI_BUILD_NUMBER
target_plist="$TARGET_BUILD_DIR/$INFOPLIST_PATH"
dsym_plist="$DWARF_DSYM_FOLDER_PATH/$DWARF_DSYM_FILE_NAME/Contents/Info.plist"

for plist in "$target_plist" "$dsym_plist"; do
    if [ -f "$plist" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$plist"
    fi
done
