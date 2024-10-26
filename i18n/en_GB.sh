# localisation file for ye3cert
# website : https://github.com/palw3ey/ye3cert
# language : en_GB
# translation by : palw3ey <palw3ey@gmail.com>
# create : 20231203
# update : 20241025

i_error="error"
i_finished="finished"
i_missing_or_invalid_argument="missing or invalid argument"
i_ready="ready"
i_run_initial_setup="run initial setup"
i_start="start"
i_update_timezone="update timezone"
i_HELP="
--action=text
  init           : Recreate certificate authority server. This will backup 
                   the folder /data/ssl to /data/backup/YYYYmmddHHMMSS.
                   All services will be restarted
  add            : Create a certificate (ARG: prefix cn password revo[opt] days[opt] san[opt])
  crl            : Show the CRL
  test           : Verify a certificate via the OCSP service (ARG: prefix)
  revoke         : Revoke a certificate (ARG: prefix)
  ca             : Show the CA certificate in base64 pem
  pem            : Show a pem certificate (ARG: prefix)
  p12            : Show a p12 'legacy' certificate in base64 pem (ARG: prefix)
  info           : Show the certificate informations (ARG: prefix)
  sha1           : Show the certificate fingerprint in SHA1 (ARG: prefix)
  stop_http      : Stop the HTTP service
  stop_crl       : Stop the CRL update service
  stop_ocsp      : Stop the OCSP service
  start_http     : Start the HTTP service
  start_crl      : Start the CRL update service
  start_ocsp     : Start the OCSP service
  restart_http   : Restart the HTTP service
  restart_crl    : Restart the CRL update service
  restart_ocsp   : Restart the OCSP service
  timezone       : Change timezone (ARG: tz) list : /usr/share/zoneinfo
  shutdown       : Shutdown the server
  
--prefix=text    : Filename prefix (ex: mycert, will produce: mycert-cert.pem)
--cn=text        : Common Name (ex: laptop1.test.lan)
--password=text  : Password (ex: mypassword)
--revo=yes/no    : Include revocation URL, by default : yes
--days=integer   : Certificate validity period
--san=text       : Include SAN (ex: DNS.1:laptop1.test.lan)
--tz=text        : Timezone (ex: Europe/Paris)

Example :
yee --action=add --prefix=tux2 --cn=pc2.test.lan --password=1234 --revo=yes --san=DNS.1:pc2.test.lan,IP.1:192.168.9.32,IP.2:10.2.9.32 
"
