# ye3cert

A container certificate authority server based on Openssl and Alpine, for creating and managing certificates. Light server, below 20 Mb. Including CRL, OCSP and HTTP server. GNS3 ready.  

The /data folder is persistent.

# Simple usage

```bash
docker run -dt -e Y_CREATE_TEST_CLIENT=yes -e Y_HTTP_SHARE_CERT=yes -p 8443:443 ghcr.io/palw3ey/ye3cert:latest

# To show the management actions :
docker exec -it mycert sh --login -c "yee"
```

# Test
```bash
# get container IP :
docker exec -it mycert sh --login -c "hostname -i"

# Open a web browser and paste the IP address,
# the certificate files will be displayed, and available for download.
```

# HOWTOs

- Show a base64 certificate in the terminal, eg: tux1 :
```bash
docker exec -it mycert sh --login -c "yee --action=pem --prefix=tux1"
```

- Browse the ssl folder from the host :
```bash
# sudo is required
ls $(docker inspect mycert -f '{{range .Mounts}}{{ if eq .Type "volume" }}{{println .Source }}{{ end }}{{end}}')/ssl
```

- Add a client certificate, with a filename prefix : tux2
```bash
# connect to the container
docker exec -it mycert sh --login -c sh

# use the management script
yee --action=add \
  --prefix=tux2 \
  --cn=pc2.test.lan \
  --password=1234 \
  --revo=yes \
  --san=DNS.1:pc2.test.lan,IP.1:12.168.9.32,IP.2:10.2.9.32

# To leave, type : exit, or use the escape sequence : Ctrl+P and next Ctrl+Q
```

- Use your host Let's Encrypt certificates for HTTPS on 8443 port
```bash
docker run -dt --name mycert \
  -e TZ=America/Montreal \
  -e Y_HTTP_SHARE_CERT=yes \
  -p 8443:443 \
  -v /etc/letsencrypt/live/{YOUR_DOMAIN}/fullchain.pem:/data/fullchain.pem \
  -v /etc/letsencrypt/live/{YOUR_DOMAIN}/privkey.pem:/data/privkey.pem \
  palw3ey/ye3cert
```

# GNS3

To run through GNS3, download and import the appliance : [ye3cert.gns3a](https://raw.githubusercontent.com/palw3ey/ye3cert/master/ye3cert.gns3a)

# Environment Variables

These are the env variables and their default values.  

| variables | format | default | description |
| :- |:- |:- |:- |
|TZ | text | Europe/Paris | Time zone. The list is in the folder /usr/share/zoneinfo |
|Y_LANGUAGE | text | fr_FR | Language. The list is in the folder /i18n/ |
|Y_IP | IP address | | Server IP address |
|Y_HTTP | yes/no | yes | yes, enable http/https server |
|Y_HTTP_SHARE_CERT | yes/no | no | yes, to show certs files in the http server directory listing |
|Y_HTTP_SHARE_FOLDER | folder path | /data/ssl/certs | http server directory listing path |
|Y_HTTP_PORT | port number | 80 | http port |
|Y_HTTP_PORT_SECURE | port number | 443 | https port |
|Y_CRL | yes/no | yes | yes, to enable CRL update service |
|Y_CRL_FREQUENCY | number of second | 15 | CRL update frequency |
|Y_OCSP | yes/no | yes | yes, to enable OCSP service |
|Y_OCSP_PORT | port number | 8080 | OCSP port |
|Y_DAYS | number | 3650 | How long to certify for |
|Y_DNS | url address | ye3cert.test.lan | The server address |
|Y_CN | text | ye3cert | The server common name |
|Y_ORGANIZATION_NAME | text | Test | The server Organization Name |
|Y_EMAIL_ADDRESS | email address | webmaster@test.lan | The server email address |
|Y_COUNTRY_NAME | Two letter country code | FR | The server country name, 2 letter code |
|Y_STATE_OR_PROVINCE_NAME | text | Ile-de-France | The server state or province name |
|Y_LOCALITY_NAME | text | Paris | The server locality name |
|Y_ORGANIZATIONAL_UNIT_NAME | text | Web | The server organizational unit name |
|Y_KEY_USAGE | text | "nonRepudiation, digitalSignature, keyEncipherment" | Key usage for a client certificate |
|Y_EXTENDED_KEY_USAGE | text | "serverAuth, clientAuth" | Extended key usage for a client certificate |
|Y_CA_PASS | password | ca | The password to use for the ca key |

# Compatibility

The docker image was compiled to work on these CPU architectures :

- linux/386
- linux/amd64
- linux/arm/v6
- linux/arm/v7
- linux/arm64
- linux/ppc64le
- linux/s390x

Work on most computers including Raspberry Pi

# Build

To customize and create your own images.

```bash
git clone https://github.com/palw3ey/ye3cert.git
cd ye3cert
# Make all your modifications, then :
docker build --no-cache --network=host -t ye3cert .
docker run -dt --name my_customized_cert ye3cert
```

# Documentation

[OpenSSL man page](https://linux.die.net/man/1/openssl)  
[lighttpd man page](https://linux.die.net/man/8/lighttpd)

# Version

| name | version |
| :- |:- |
|ye3cert | 1.0.0 |
|openssl | 3.3.2 |
|lighttpd | 1.4.76 |
|alpine | 3.20.3 |

# ToDo

- ~~need to document env variables~~ (2023-12-23)
- add more translation files in i18n folder. Contribute ! Send me your translations by mail ;)

Don't hesitate to send me your contributions, issues, improvements on github or by mail.

# License

MIT  
author: palw3ey  
maintainer: palw3ey  
email: palw3ey@gmail.com  
website: https://github.com/palw3ey/ye3cert  
docker hub: https://hub.docker.com/r/palw3ey/ye3cert
