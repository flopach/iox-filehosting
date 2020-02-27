#
# Dockerfile for file hosting IOx Cisco platforms
#

# ARM or x86
#FROM alpine:latest
FROM arm64v8/alpine:latest

# Install
RUN apk update
RUN apk add --no-cache samba
RUN apk add --no-cache nginx

# Nginx configuration
RUN mkdir -p /run/nginx
RUN mkdir /www
RUN adduser -D -g 'www' www
RUN chown -R www:www /var/lib/nginx
RUN chown -R www:www /www

# samba configuration
RUN mkdir /samba && chmod 777 /samba
RUN adduser smbuser -SHD
RUN (echo "samba123!"; sleep 2; echo "samba123!" ) | passwd smbuser
RUN (echo "samba123!"; sleep 2; echo "samba123!" ) | smbpasswd -a smbuser
RUN smbpasswd -e smbuser

# copy files
COPY smb.conf /etc/samba/smb.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /www/index.html
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# open ports
EXPOSE 137/UDP 138/UDP 139/TCP 445/TCP 5000/TCP

ENTRYPOINT "/entrypoint.sh"
