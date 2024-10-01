FROM alpine:latest

MAINTAINER palw3ey <palw3ey@gmail.com>
LABEL name="ye3cert" version="1.0.0" author="palw3ey" maintainer="palw3ey" email="palw3ey@gmail.com" website="https://github.com/palw3ey/ye3cert" license="MIT" create="20231203" update="20231203" description="A docker CA server based on Openssl and Alpine. Below 20 Mb. With CRL, OCSP and HTTP. GNS3 ready." usage="docker run -dt -e Y_HTTP_SHARE_CERT=yes palw3ey/ye3cert" tip="The folder /data is persistent"
LABEL org.opencontainers.image.source=https://github.com/palw3ey/ye3cert

# general
ENV TZ=Europe/Paris \
	Y_LANGUAGE=fr_FR \
	Y_IP=""

# http
ENV Y_HTTP=yes \
	Y_HTTP_SHARE_CERT=no \
	Y_HTTP_SHARE_FOLDER=/data/ssl/certs \
	Y_HTTP_PORT=80 \
	Y_HTTP_PORT_SECURE=443

# crl, frenquency is in seconde
ENV Y_CRL=yes \
	Y_CRL_FREQUENCY=15

# ocsp
ENV Y_OCSP=yes \
	Y_OCSP_PORT=8080

# default certificate
ENV Y_DAYS=3650 \
	Y_DNS=ye3cert.test.lan \
	Y_CN=ye3cert \
	Y_ORGANIZATION_NAME=Test \
	Y_EMAIL_ADDRESS=webmaster@test.lan \
	Y_COUNTRY_NAME=FR \
	Y_STATE_OR_PROVINCE_NAME=Ile-de-France \
	Y_LOCALITY_NAME=Paris \
	Y_ORGANIZATIONAL_UNIT_NAME=Web \
	Y_KEY_USAGE="nonRepudiation, digitalSignature, keyEncipherment" \
	Y_EXTENDED_KEY_USAGE="serverAuth, clientAuth" \
	Y_CA_PASS=ca

ADD entrypoint.sh mgmt.sh /
ADD i18n/ /i18n/
ADD bypass_docker_env.sh.dis /etc/profile.d/

RUN apk add --update --no-cache openssl tzdata lighttpd ; \
	cp /usr/share/zoneinfo/$TZ /etc/localtime ; \
	echo $TZ > /etc/timezone ; \
	mkdir -p /data/ssl/certs ; \
	chmod +x /entrypoint.sh ; \
	chmod +x /mgmt.sh ; \
	ln -sfn /mgmt.sh /usr/sbin/mgmt

EXPOSE $Y_HTTP_PORT/tcp $Y_HTTP_PORT_SECURE/tcp $Y_OCSP_PORT/tcp

VOLUME "/data"

ENTRYPOINT sh --login -c  "/entrypoint.sh"
