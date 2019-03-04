#!/bin/sh

#  release.sh
#  VideoLibrary
#
#  Created by Alexander Bozhko on 13/11/2018.
#  Copyright © 2018 CocoaPods. All rights reserved.

echo Release $1...

pod lib lint &&

git add -A;
git commit -m "release $1" &&
git push &&
git tag $1 &&
git push --tags &&

pod repo push kinoapp-ios-podspec VideoLibrary.podspec
