FROM alpine:latest

LABEL org.opencontainers.image.title="ye3cert"
LABEL org.opencontainers.image.version="2.0.0"
LABEL org.opencontainers.image.created="2024-10-28T15:00:00-03:00"
LABEL org.opencontainers.image.revision="20241028"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.authors="palw3ey"
LABEL org.opencontainers.image.vendor="palw3ey"
LABEL org.opencontainers.image.maintainer="palw3ey"
LABEL org.opencontainers.image.email="palw3ey@gmail.com"
LABEL org.opencontainers.image.url="https://github.com/palw3ey/ye3cert"
LABEL org.opencontainers.image.documentation="https://github.com/palw3ey/ye3cert/blob/main/README.md"
LABEL org.opencontainers.image.source="https://github.com/palw3ey/ye3cert"
LABEL org.opencontainers.image.base.name="ghcr.io/palw3ey/ye3cert:2.0.0"
LABEL org.opencontainers.image.description="An image CA server based on Openssl and Alpine. Below 20 Mb. With CRL, OCSP and HTTP. GNS3 ready."
LABEL org.opencontainers.image.usage="docker run -dt --name mycert -e TZ=America/Cayenne -e Y_IP_USE_PUBLIC=yes -e Y_RANDOM_CLIENT=4 -e Y_TEST_CLIENT_CREATE=yes -e Y_HTTP_SHARE_CERT=yes -e Y_HTTP_PORT=8091 -e Y_HTTP_PORT_SECURE=8092 -e Y_OCSP_PORT=8093 -p 8091-8093:8091-8093 ghcr.io/palw3ey/ye3cert:latest"
LABEL org.opencontainers.image.tip="The folder /data is persistent"
LABEL org.opencontainers.image.premiere="20231203"

MAINTAINER palw3ey <palw3ey@gmail.com>

ENV TZ=Europe/Paris \
	Y_LANGUAGE=fr_FR \
	Y_DEBUG=no \
	Y_IP= \
	Y_IP_CHECK_PUBLIC=no \
	Y_IP_CHECK_URL=http://whatismyip.akamai.com \
  	Y_IP_CHECK_URL_TIMEOUT=5 \
   	Y_CRED_EXPORT=/data/ssl/cred \
	\
	# http
	Y_HTTP=yes \
	Y_HTTP_SHARE_CERT=no \
	Y_HTTP_SHARE_FOLDER=/data/ssl/www \
	Y_HTTP_PORT=80 \
	Y_HTTP_PORT_SECURE=443 \
	\
	# crl
	Y_CRL=yes \
	Y_CRL_CROND="*/15       *       *       *       *" \
 	Y_CRL_SEC_NEXT=2678400 \
	\
	# ocsp
	Y_OCSP=yes \
	Y_OCSP_PORT=8080 \
	\
	# default certificate
	Y_KEY_SIZE=2048 \
	Y_DAYS=3650 \
	Y_DAYS_CLIENT=365 \
	Y_KEY_USAGE="nonRepudiation, digitalSignature, keyEncipherment" \
	Y_EXTENDED_KEY_USAGE="serverAuth, clientAuth" \
	\
	# Server
	Y_CA_PASS=ca \
	Y_DNS= \
	Y_CN= \
	Y_COUNTRY_NAME=FR \
	Y_STATE_OR_PROVINCE_NAME=Ile-de-France \
	Y_LOCALITY_NAME=Paris \
	Y_ORGANIZATION_NAME=Test \
	Y_ORGANIZATIONAL_UNIT_NAME=Web \
	Y_EMAIL_ADDRESS=webmaster@test.lan \
	\
	 # random client
	Y_RANDOM_CLIENT= \
	Y_RANDOM_CLIENT_REVO=yes \
	Y_RANDOM_CLIENT_DAYS=731 \
	\
	# test client
	Y_TEST_CLIENT_CREATE=no \
	Y_TEST_CLIENT_PREFIX=tux1 \
	Y_TEST_CLIENT_CN=pc1.test.lan \
	Y_TEST_CLIENT_PASSWORD=1234 \
	Y_TEST_CLIENT_REVO=yes \
	Y_TEST_CLIENT_DAYS=31 \
	Y_TEST_CLIENT_SAN=DNS.1:pc1.my.net,IP.1:192.168.1.10


ADD entrypoint.sh yee.sh /
ADD i18n/ /i18n/

RUN apk add --update --no-cache openssl tzdata lighttpd curl ; \
	cp /usr/share/zoneinfo/$TZ /etc/localtime ; \
	echo $TZ > /etc/timezone ; \
	mkdir -p /data/ssl/certs ; \
	chmod +x /entrypoint.sh ; \
	chmod +x /yee.sh ; \
	ln -sfn /yee.sh /usr/sbin/yee

ADD bypass_container_env.sh /data/

EXPOSE $Y_HTTP_PORT/tcp $Y_HTTP_PORT_SECURE/tcp $Y_OCSP_PORT/tcp

VOLUME "/data"

ENTRYPOINT sh --login -c  "/entrypoint.sh"
