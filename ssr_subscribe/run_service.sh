#!/bin/bash

gunicorn server:__hug_wsgi__ -k gevent --bind 0.0.0.0:8000
