# ye3cert

A docker certificate authority server based on Openssl and Alpine, for creating and managing certificates. Light server, below 20 Mb. Including CRL, OCSP and HTTP server. GNS3 ready.  

The /data folder is persistent.

# Quickstart

```bash
docker run -dt --name mycert -e Y_HTTP_SHARE_CERT=yes palw3ey/ye3cert
docker exec -it mycert sh --login -c "mgmt"
```

# GNS3

To run through GNS3, download and import the appliance : [ye3cert.gns3a](https://raw.githubusercontent.com/palw3ey/ye3cert/master/ye3cert.gns3a)

# Environment Variables

These are the env variables and their default values.  

| variables | format | default |
| :- |:- |:- |
|TZ | text | Europe/Paris |
|Y_LANGUAGE | text | fr_FR |
|Y_IP | IP address | |
|Y_HTTP | yes/no | yes |
|Y_HTTP_SHARE_CERT | yes/no | no |
|Y_HTTP_SHARE_FOLDER | folder path | /data/ssl/certs |
|Y_HTTP_PORT | port number | 80 |
|Y_HTTP_PORT_SECURE | port number | 443 |
|Y_CRL | yes/no | yes |
|Y_CRL_FREQUENCY | number of second | 15 |
|Y_OCSP | yes/no | yes |
|Y_OCSP_PORT | port number | 8080 |
|Y_DAYS | number | 3650 |
|Y_DNS | url address | ye3cert.test.lan |
|Y_CN | text | ye3cert |
|Y_ORGANIZATION_NAME | text | Test |
|Y_EMAIL_ADDRESS | email address | webmaster@test.lan |
|Y_COUNTRY_NAME | Two letter country code | FR |
|Y_STATE_OR_PROVINCE_NAME | text | Ile-de-France |
|Y_LOCALITY_NAME | text | Paris |
|Y_ORGANIZATIONAL_UNIT_NAME | text | Web |
|Y_KEY_USAGE | text | "nonRepudiation, digitalSignature, keyEncipherment" |
|Y_EXTENDED_KEY_USAGE | text | "serverAuth, clientAuth" |
|Y_CA_PASS | password | ca |

# Build

To customize and create your own images.

```bash
git clone https://github.com/palw3ey/ye3cert.git
cd ye3cert
# Make all your modifications, then :
docker build --no-cache --network=host -t ye3cert .
docker run -dt --name my_customized_cert ye3cert
```

# License

MIT  
author: palw3ey  
maintainer: palw3ey  
email: palw3ey@gmail.com  
website: https://github.com/palw3ey/ye3cert  
docker hub: https://hub.docker.com/r/palw3ey/ye3cert
