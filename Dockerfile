FROM rust:alpine3.17 as build-rust
RUN apk add build-base musl-dev openssl-dev
RUN mkdir /srv/core_api
WORKDIR /srv/core_api

COPY . .
ENV RUSTFLAGS="-C target-feature=-crt-static"
WORKDIR /srv/core_api/NodeLibraries/dl-fast-load
RUN cargo build --release  --message-format=json-render-diagnostics  > build-output.txt


FROM node:18.14.1-alpine3.17 as production
# these settings are needed for the admin web gui build, these variables are all baked into the Vue application and thus
# are available to any end user that wants to dig deep enough in the webpage - as such we don't feel it a security risk
# to have these env variables available to anyone running the history commmand on the container/image
ENV VUE_APP_BUNDLED_BUILD="true"
ENV VUE_APP_DEEP_LYNX_API_URL="http://localhost:8090"
ENV VUE_APP_DEEP_LYNX_API_AUTH_METHOD="token"
ENV VUE_APP_TIME_SERIES_ENABLED="true"
# you must include the trailing /# - because the bundled admin web app will be in hash mode, not history
ENV VUE_APP_APP_URL="http://localhost:8090/#"
# this should be an alphanumeric random string of at least 15 characters
ENV VUE_APP_DEEP_LYNX_APP_ID="root"

# turn off jobs on the main thread as this spins up PM2 with the worker
ENV RUN_JOBS=false
# set the default db to the one we'd see in the docker compose
ENV CORE_DB_CONNECTION_STRING=postgresql://postgres:root@timescaledb:5432/deep_lynx_dev

# Create the base directory and set the rust version to use default stable
RUN mkdir /srv/core_api

WORKDIR /srv/core_api
COPY package*.json ./

RUN npm install npm@latest --location=global
RUN npm update --location=global
RUN npm install pm2 --location=global
RUN npm install cargo-cp-artifact --location=global

# Bundle app source
COPY . .
RUN rm -rf /srv/core_api/NodeLibraries/dl-fast-load
COPY --from=build-rust /srv/core_api/NodeLibraries/dl-fast-load /srv/core_api/NodeLibraries/dl-fast-load

RUN npm ci --include=dev
RUN npm run build:docker
RUN cd /srv/core_api/AdminWebApp && npm ci --include=dev && npm run build -- --dest /srv/core_api/dist/http_server/web_gui
RUN rm -rf /srv/core_api/AdminWebApp/node_modules
# Build the Viewer
RUN npm run build:web-gl
# catch any env file a user might have accidentally built into the container
RUN rm -rf .env


# Add docker-compose-wait tool ----------------------
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait /wait
RUN chmod +x /wait

EXPOSE 8090
CMD /wait && pm2-runtime ecosystem.config.js
