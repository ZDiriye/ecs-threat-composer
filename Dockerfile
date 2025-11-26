#used multistage build (build and production stages) to reduce the size of the image

#build stage - installs the dependencies and bundles the whole app into a static file
FROM node:18-alpine as Build
WORKDIR /app

COPY app/package.json app/yarn.lock ./
RUN yarn install --frozen-lockfile

COPY app/ .
RUN yarn build


#production stage - copies the final build output and serves it on port 8080
FROM node:18-alpine
RUN adduser -S user

WORKDIR /app 

COPY --from=Build /app/build ./build
RUN yarn global add serve

USER user
EXPOSE 8080

CMD ["serve", "-s", "build", "-l", "8080"]