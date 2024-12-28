#!/usr/bin/env bash

CURRENT_DIRECTORY=$(pwd)

ALL_WORKING_DIRECTORY=$(find "src" -maxdepth 2 -mindepth 2 -type d | sed 's/src\///')

for CURRENT_PATH in $ALL_WORKING_DIRECTORY; do
    FULL_PATH="$CURRENT_DIRECTORY/src/$CURRENT_PATH"

    cd $FULL_PATH

    cp -r "$CURRENT_DIRECTORY/_includes" "_includes" 
    cp -r "$CURRENT_DIRECTORY/_layouts" "_layouts" 
    cp -r "$CURRENT_DIRECTORY/_plugins" "_plugins" 
    cp -r "$CURRENT_DIRECTORY/_sass" "_sass" 
    cp -r "$CURRENT_DIRECTORY/assets" "assets"

    bundle exec jekyll build --destination "../../../_site/$CURRENT_PATH" --baseurl "/$CURRENT_PATH"
done

cd "$CURRENT_DIRECTORY"

cp -r "404.html" "_site/404.html"

if [ "$1" = "--serve" ]; then
  bundle exec jekyll serve --skip-initial-build --livereload-ignore "**/**"
fi