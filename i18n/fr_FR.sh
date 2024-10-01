# localisation file for ye3cert
# website : https://github.com/palw3ey/ye3cert
# language : fr_FR
# translation by : palw3ey <palw3ey@gmail.com>
# create : 20231203
# update : 20231203

i_error="erreur"
i_finished="terminé"
i_missing_or_invalid_argument="argument invalid ou manquant"
i_ready="prêt"
i_run_initial_setup="éxecuter la configuration initial"
i_start="démarrer"
i_update_timezone="actualisation du fuseau horaire"
i_HELP="
--action=text
  init           : Recréer le serveur d'autorité de certification. Cela sauvegardera
                   le dossier /data/ssl dans /data/backup/YYYYmmddHHMMSS
                   Tous les services seront redémarrés
  add            : Créer un certificat (ARG: prefix cn password revo[opt] san[opt])
  crl            : Afficher la CRL
  test           : Vérifier un certificat via le service OCSP (ARG: prefix)
  revoke         : Révoquer un certificat (ARG: prefix)
  ca             : Afficher le certificat CA en base64 pem
  pem            : Afficher un certificat pem (ARG: prefix)
  p12            : Afficher un certificat p12 'legacy' en pem base64 (ARG: prefix)
  info           : Affiher les informations du certificat (ARG: prefix)
  sha1           : Affiher l'empreinte digitale du certificat en SHA1 (ARG: prefix)
  stop_http      : Arrêter le service HTTP
  stop_crl       : Arrêter le service d'actualisation CRL
  stop_ocsp      : Arrêter le service OCSP
  restart_http   : Redémarrer le service HTTP
  restart_crl    : Redémarrer le service d'actualisation CRL
  restart_ocsp   : Redémarrer le service OCSP
  timezone       : Changer le fuseau horaire (ARG: tz) liste : /usr/share/zoneinfo
  shutdown       : Arrêter le serveur
  
--prefix=text    : Préfixe du nom de fichier (ex: mycert, produira: mycert-cert.pem)
--cn=text        : Nom commun (ex: laptop1.test.lan)
--password=text  : Mot de passe (ex: mypassword)
--san=text       : Inclure le SAN (ex: DNS.1:laptop1.test.lan)
--revo=yes/no    : Inclure l'URL de révocation, par default: yes
--tz=text        : Fuseau horaire  (ex: Europe/Paris)

Exemple :
mgmt --action=add --prefix=tux2 --cn=pc2.test.lan --password=1234 --revo=yes --san=DNS.1:pc2.test.lan,IP.1:192.168.9.32,IP.2:10.2.9.32 
"