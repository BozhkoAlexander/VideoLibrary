#!/bin/sh

#  release.sh
#  VideoLibrary
#
#  Created by Alexander Bozhko on 13/11/2018.
#  Copyright © 2018 CocoaPods. All rights reserved.

# pod lib lint
echo Release VideoLibrary v.$1
git add -A
git commit -m "release `$1`"
git tag $1
git push
