#!/bin/sh
set -e
git checkout gh-pages
git merge master -m "merging with master for doc creation"
ldoc .
git add .
git status
git commit -a -m "updated docs"
git push origin gh-pages
git checkout master
