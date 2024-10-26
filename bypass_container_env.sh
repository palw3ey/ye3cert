
## These values will override container env variables, and used by entrypoint.sh on every restart. To activate and customize the configurations wanted, remove one or more # sign.

## general
# export TZ=Europe/Paris
# export Y_LANGUAGE=fr_FR
# export Y_DEBUG=no
# export Y_IP=
# export Y_IP_CHECK_EXTERNAL=yes
# export Y_URL_IP_CHECK=http://whatismyip.akamai.com
# export Y_URL_IP_CHECK_TIMEOUT=5
# export Y_DEBUG=no

## http
# export Y_HTTP=yes
# export Y_HTTP_SHARE_CERT=no
# export Y_HTTP_SHARE_FOLDER=/data/ssl/www
# export Y_HTTP_PORT=80
# export Y_HTTP_PORT_SECURE=443

## crl, frenquency is in seconde
# export Y_CRL=yes
# export Y_CRL_FREQUENCY=15

## ocsp
# export Y_OCSP=yes
# export Y_OCSP_PORT=8080

## default certificate
# export Y_DAYS=3650
# export Y_DNS=
# export Y_CN=
# export Y_ORGANIZATION_NAME=
# export Y_EMAIL_ADDRESS=
# export Y_COUNTRY_NAME=
# export Y_STATE_OR_PROVINCE_NAME=
# export Y_LOCALITY_NAME=
# export Y_ORGANIZATIONAL_UNIT_NAME=
# export Y_KEY_USAGE="nonRepudiation, digitalSignature, keyEncipherment"
# export Y_EXTENDED_KEY_USAGE="serverAuth, clientAuth"
# export Y_CA_PASS=ca
# export Y_KEY_SIZE=2048
# export Y_CREATE_TEST_CLIENT=no
