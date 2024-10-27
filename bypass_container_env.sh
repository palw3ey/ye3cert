
## These values will override container env variables, and used by entrypoint.sh on every restart. To activate and customize the configurations wanted, remove one or more # sign.

## general
# export TZ=Europe/Paris
# export Y_LANGUAGE=fr_FR
# export Y_DEBUG=no
# export Y_IP=
# export Y_IP_USE_PUBLIC=no
# export Y_IP_CHECK_URL=http://whatismyip.akamai.com
# export Y_IP_CHECK_URL_TIMEOUT=5
# export Y_CRED_EXPORT=/data/ssl/cred

## http
# export Y_HTTP=yes
# export Y_HTTP_SHARE_CERT=no
# export Y_HTTP_SHARE_FOLDER=/data/ssl/www
# export Y_HTTP_PORT=80
# export Y_HTTP_PORT_SECURE=443

## crl, frequency is in seconde
# export Y_CRL=yes
# export Y_CRL_FREQUENCY="*/15       *       *       *       *"
# export Y_CRL_SEC_NEXT=300

## ocsp
# export Y_OCSP=yes
# export Y_OCSP_PORT=8080

## default certificate
# export Y_KEY_SIZE=2048
# export Y_DAYS=3650
# export Y_DAYS_CLIENT=365
# export Y_KEY_USAGE="nonRepudiation, digitalSignature, keyEncipherment"
# export Y_EXTENDED_KEY_USAGE="serverAuth, clientAuth"

## Server
# export Y_CA_PASS=ca
# export Y_DNS=
# export Y_CN=
# export Y_COUNTRY_NAME=FR
# export Y_STATE_OR_PROVINCE_NAME=Ile-de-France
# export Y_LOCALITY_NAME=Paris
# export Y_ORGANIZATION_NAME=Test
# export Y_ORGANIZATIONAL_UNIT_NAME=Web
# export Y_EMAIL_ADDRESS=webmaster@test.lan

## random client
# export Y_RANDOM_CLIENT=
# export Y_RANDOM_CLIENT_REVO=yes
# export Y_RANDOM_CLIENT_DAYS=731

## test client
# export Y_TEST_CLIENT_CREATE=no
# export Y_TEST_CLIENT_PREFIX=tux1
# export Y_TEST_CLIENT_CN=pc1.test.lan
# export Y_TEST_CLIENT_PASSWORD=1234
# export Y_TEST_CLIENT_REVO=yes
# export Y_TEST_CLIENT_DAYS=31
# export Y_TEST_CLIENT_SAN=DNS.1:pc1.my.net,IP.1:192.168.1.10
