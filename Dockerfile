FROM registry.example.com/nginxinc/nginx-unprivileged:1.20
# Use root user to copy dist folder and modify user access to specific folder
USER root
# RUN apk add --no-cache  gettext
# Copy application and custom NGINX configuration
RUN rm /usr/share/nginx/html/*
COPY html/ /usr/share/nginx/html/
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
# Setup unprivileged user 1001
RUN chown -R 1001 /usr/share/nginx/html
# Use user 1001
USER 1001
# Expose a port that is higher than 1024 due to unprivileged access
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]