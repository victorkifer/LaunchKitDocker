#!/usr/bin/env bash

VERSION=1.0.0
# Docker gives by default 2gb of RAM for Docker containers
# But building lxml library takes more memory and causes OOM,
# This option helps speed up the build and avoid OOM
MEMORY_LIMIT=4g

docker build -f docker/Dockerfile.base -t launchkit-base -m ${MEMORY_LIMIT} .
docker build -f docker/Dockerfile.backend -t viktorkifer/launchkit-app:${VERSION} -m ${MEMORY_LIMIT} .
docker build -f docker/Dockerfile.gae -t viktorkifer/launchkit-gae:${VERSION} -m ${MEMORY_LIMIT} .
docker build -f docker/Dockerfile.reviews -t viktorkifer/launchkit-reviews:${VERSION} -m ${MEMORY_LIMIT} .
docker build -f docker/Dockerfile.skit -t viktorkifer/launchkit-skit:${VERSION} -m ${MEMORY_LIMIT} .
docker build -f docker/Dockerfile.postgres -t viktorkifer/viktorkifer/postgres-hstore:${VERSION} -m ${MEMORY_LIMIT} .
docker rmi -f launchkit-base