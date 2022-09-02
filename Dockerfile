FROM timbru31/ruby-node:2.7 as builder

RUN mkdir /usr/src/app
WORKDIR /usr/src/app
ENV PATH /usr/src/app/node_modules/.bin:$PATH
COPY package.json /usr/src/app/package.json

RUN npm install -g bower
RUN npm install -g grunt-cli
COPY . /usr/src/app
RUN bower --allow-root install
RUN npm install
RUN bundle install
RUN grunt prod

# FROM nginxinc/nginx-unprivileged
# COPY nginx.conf /etc/nginx/nginx.conf
# COPY --from=builder /usr/src/app/dist/community-app /usr/share/nginx/html
# EXPOSE 8080



FROM nginx:1.13.3-alpine
## Copy our nginx config
COPY nginx/ /etc/nginx/conf.d/
## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/* && chmod -R 777 /var/log/nginx /var/cache/nginx/ && chmod -R 777 /etc/nginx/* && chmod -R 777 /var/run/ && chmod -R 777 /usr/share/nginx/
## copy over the artifacts in dist folder to default nginx public folder
COPY --from=builder /usr/src/app/dist/community-app /usr/share/nginx/html
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
