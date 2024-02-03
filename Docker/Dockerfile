FROM nginx:latest
RUN apt-get -y update
RUN apt-get -y install curl
COPY index.html /usr/share/nginx/html/index.html
COPY page1.html /usr/share/nginx/html/page1.html
# COPY page-2.html /usr/share/nginx/html/page-2.html
# RUN rm /etc/nginx/conf.d/default.conf
# COPY default.conf /etc/nginx/conf.d/