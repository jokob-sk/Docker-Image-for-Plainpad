#!/bin/sh

npm start --prefix plainpad/
service cron start && tail -f /dev/null
