#!/bin/sh

echo "Checking lint issues..."

bundle install >/dev/null
git diff --name-only --cached | xargs ls -1 2>/dev/null | grep '\.rb$' | xargs bundle exec standardrb --fix