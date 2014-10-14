#!/bin/sh
rm ./dist/*.js
./node_modules/coffee-script/bin/coffee -c -o ./dist ./src
./node_modules/uglify-js/bin/uglifyjs ./dist/radioactive.js > ./dist/radioactive.min.js