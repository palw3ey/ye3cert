#!/bin/sh

# This sh script help you to manage the certificate server

# env variables
source /etc/profile.d/bypass_container_env.sh > /dev/null 2>&1

# ============ [ global variable ] ============

# default language
vg_default_language="fr_FR"

# id and password parameters
vg_users_separator=":"
vg_username_char="a-z"
vg_username_length=12
vg_password_char="A-Za-z0-9"
vg_password_length=32

# ============ [ internationalisation ] ============

# load default language
source /i18n/$vg_default_language.sh

# override with choosen language
if [[ $Y_LANGUAGE != $vg_default_language ]] && [[ -f /i18n/$Y_LANGUAGE.sh ]] ; then
	source /i18n/$Y_LANGUAGE.sh
fi

# ============ [ function ] ============

# initial setup : create certificate authority server
f_init() {

	# ============ [ backup ] ============
	
	# stop http, crl and ocsp service
	f_stop_http
	f_stop_crl
	f_stop_ocsp

	# backup
	if [ -f "/data/ssl/cacert.pem" ]; then
		timestamp=$(date +%Y%m%d%H%M%S)
		mkdir -p /data/backup/$timestamp
		cp -R /data/ssl/* /data/backup/$timestamp
		rm -R /data/ssl/*
	fi
	
	# ============ [ preparation ] ============
	
	# if env variable Y_IP doesn't exist, then set to public ip or default route interface ip or first hostname ip
		
	if [[ -z "$Y_IP" ]]; then

		# get external ip
		if [[ $Y_IP_USE_PUBLIC == "yes" ]] ; then
			vl_ip_public=$(curl -m $Y_IP_CHECK_URL_TIMEOUT -s $Y_IP_CHECK_URL)
		else 
			vl_ip_public=""
		fi
		
		# get default interface ip
		vl_interface=$(route | awk '/^default/{print $NF}')
		vl_interface_ip=$(/sbin/ifconfig $vl_interface | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
	
		# choose
		if expr "$vl_ip_public" : '[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null; then
			Y_IP=$vl_ip_public
		elif [[ ! -z "vl_interface_ip" ]]; then
			Y_IP=$vl_interface_ip
		else
			Y_IP=$(hostname -i | cut -d ' ' -f1)
		fi
		echo "Y_IP : $Y_IP" 
	fi
	
	# if env variable Y_DNS doesn't exist, then set to external domain, or hostname
		
	if [[ -z "$Y_DNS" ]]; then
 
 		Y_DNS=$(nslookup $Y_IP | grep -m 1 'name = ' | sed 's/.*name = //')
   
		if [[ -z "$Y_DNS" ]]; then
  			Y_DNS=$(hostname -f)
  		fi
  	fi


	# create directories and files

	mkdir -p /data/ssl/private > /dev/null 2>&1
	mkdir /data/ssl/csr > /dev/null 2>&1
	mkdir /data/ssl/certs > /dev/null 2>&1
	mkdir /data/ssl/newcerts > /dev/null 2>&1
	mkdir $Y_HTTP_SHARE_FOLDER > /dev/null 2>&1
	touch /data/ssl/index.txt
	sh -c "echo 10 > /data/ssl/serial"
	sh -c "echo 10 > /data/ssl/crlnumber"

	# configure cnf file

	cp /etc/ssl/openssl.cnf /data/ssl/openssl.cnf
	sed -i "s/.\/demoCA/\/data\/ssl/" /data/ssl/openssl.cnf
	sed -i "s/default_days[[:blank:]]*=[[:blank:]]*365/default_days = $Y_DAYS/" /data/ssl/openssl.cnf
	sed -i "s/# copy_extensions = copy/copy_extensions = copy/" /data/ssl/openssl.cnf
	sed -i "/^\[ usr_cert \]/a\extendedKeyUsage = $Y_EXTENDED_KEY_USAGE" /data/ssl/openssl.cnf
	sed -i "s/# keyUsage = nonRepudiation, digitalSignature, keyEncipherment/keyUsage = $Y_KEY_USAGE/" /data/ssl/openssl.cnf
	echo "[ v3_OCSP ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = OCSPSigning
" >> /data/ssl/openssl.cnf
	echo "[ usr_cert_with_revocation ]
extendedKeyUsage = $Y_EXTENDED_KEY_USAGE
basicConstraints=CA:FALSE
keyUsage = $Y_KEY_USAGE
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer
crlDistributionPoints = URI:http://$Y_IP:$Y_HTTP_PORT/crl
authorityInfoAccess = OCSP;URI:http://$Y_IP:$Y_OCSP_PORT
" >> /data/ssl/openssl.cnf
	

	# ============ [ CA ] ============

	# create ca key and cert

	if [[ -z "$Y_CN" ]]; then
		Y_CN=$Y_IP
	fi
	echo "Y_CN : $Y_CN" 

	vl_subj=""
	if [[ ! -z "$Y_COUNTRY_NAME" ]]; then
 		vl_subj="${vl_subj}/C=${Y_COUNTRY_NAME}"
 	fi
 	if [[ ! -z "$Y_STATE_OR_PROVINCE_NAME" ]]; then
 		vl_subj="${vl_subj}/ST=${Y_STATE_OR_PROVINCE_NAME}"
 	fi
 	if [[ ! -z "$Y_LOCALITY_NAME" ]]; then
 		vl_subj="${vl_subj}/L=${Y_LOCALITY_NAME}"
 	fi
 	if [[ ! -z "$Y_ORGANIZATION_NAME" ]]; then
 		vl_subj="${vl_subj}/O=${Y_ORGANIZATION_NAME}"
 	fi
 	if [[ ! -z "$Y_ORGANIZATIONAL_UNIT_NAME" ]]; then
 		vl_subj="${vl_subj}/OU=${Y_ORGANIZATIONAL_UNIT_NAME}"
 	fi
 	if [[ ! -z "$Y_EMAIL_ADDRESS" ]]; then
 		vl_subj="${vl_subj}/emailAddress=${Y_EMAIL_ADDRESS}"
 	fi

   	vl_subj_ca="/CN=${Y_CN}${vl_subj}"
	openssl genrsa -aes256 -passout pass:$Y_CA_PASS -out /data/ssl/private/cakey.pem $Y_KEY_SIZE > /dev/null 2>&1

	openssl req -config /data/ssl/openssl.cnf -new -x509 -nodes -extensions v3_ca -subj "$vl_subj_ca" -days $Y_DAYS -key /data/ssl/private/cakey.pem -passin pass:$Y_CA_PASS -out /data/ssl/cacert.pem

	# publish pem
 	ln -sfn /data/ssl/cacert.pem /data/ssl/certs/cacert.pem
 	ln -sfn /data/ssl/cacert.pem /var/www/localhost/htdocs/cacert.pem
	ln -sfn /data/ssl/cacert.pem $Y_HTTP_SHARE_FOLDER/cacert.pem
 	# convert to crt and publish 
 	openssl x509 -outform der -in /data/ssl/cacert.pem -out /data/ssl/cacert.crt
 	ln -sfn /data/ssl/cacert.crt /data/ssl/certs/cacert.crt
 	ln -sfn /data/ssl/cacert.crt /var/www/localhost/htdocs/cacert.crt
	ln -sfn /data/ssl/cacert.crt $Y_HTTP_SHARE_FOLDER/cacert.crt
 
	# ============ [ OCSP ] ============

	# create ocsp key and cert

   	vl_subj_ocsp="/CN=OCSPServer${vl_subj}"
	openssl req -config /data/ssl/openssl.cnf -subj "$vl_subj_ocsp" -addext "subjectAltName=DNS:$Y_DNS,IP:$Y_IP" -newkey rsa:$Y_KEY_SIZE -nodes -keyout /data/ssl/private/server-keY_OCSP.pem -out /data/ssl/csr/server-req_ocsp.pem > /dev/null 2>&1

	openssl ca -config /data/ssl/openssl.cnf -policy policy_anything -extensions v3_OCSP -batch -notext -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -out /data/ssl/certs/server-cert_ocsp.pem -infiles /data/ssl/csr/server-req_ocsp.pem > /dev/null 2>&1 

	cat /data/ssl/private/server-keY_OCSP.pem /data/ssl/certs/server-cert_ocsp.pem > example.com.pem

	# ============ [ https ] ============

	# create https server key and cert
	
	f_add server $Y_CN server yes $Y_DAYS "DNS.1:$Y_DNS,IP.1:$Y_IP"
	
	# ============ [ client ] ============

	# create a test client key and cert
	
	if [[ $Y_TEST_CLIENT_CREATE == "yes" ]]; then 
		f_add $Y_TEST_CLIENT_PREFIX $Y_TEST_CLIENT_CN $Y_TEST_CLIENT_PASSWORD $Y_TEST_CLIENT_REVO $Y_TEST_CLIENT_DAYS $Y_TEST_CLIENT_SAN
	fi

 	# create random client key and cert

   	if [[ ! -z "$Y_RANDOM_CLIENT" ]]; then
 		f_add_random $Y_RANDOM_CLIENT $Y_RANDOM_CLIENT_REVO $Y_RANDOM_CLIENT_DAYS
   	fi
	
	# ============ [ finalization ] ============

	# ping gateway
	ping -c 3 $(route -n | grep 'UG[ \t]' | awk '{print $2}') > /dev/null 2>&1

	# start http server
	if [[ $Y_HTTP == "yes" ]]; then f_start_http; fi
	
	# start crl update service
	if [[ $Y_CRL == "yes" ]]; then f_start_crl; fi
	
	# start ocsp service
	if [[ $Y_OCSP == "yes" ]]; then f_start_ocsp; fi
	
	echo "$i_finished"

}

# stop http service
f_stop_http() {
	/bin/kill `/bin/ps aux | /bin/grep "/usr/sbin/lighttpd -f /data/lighttpd.conf" | /bin/grep -v grep | /usr/bin/awk '{ print $1 }'` > /dev/null 2>&1
}

# start http service
f_start_http() {

	# create a custom configuration file
	cp /etc/lighttpd/lighttpd.conf /data/lighttpd.conf
	
	# correct to actual mime-types.conf
	sed -i "s|.*include \"mime-types.conf\".*|include \"/etc/lighttpd/mime-types.conf\"|" /data/lighttpd.conf
	
	# set document root
	if [[ $Y_HTTP_SHARE_CERT == "yes" ]]; then
		sed -i "s|.*server.document-root.*|server.document-root = \"$Y_HTTP_SHARE_FOLDER\"|" /data/lighttpd.conf
		ln -sfn /data/ssl/certs $Y_HTTP_SHARE_FOLDER/certs
	else
		sed -i "s|.*server.document-root.*|server.document-root = \"/var/www/localhost/htdocs\"|" /data/lighttpd.conf
	fi
	
	# enable directory listing
	sed -i "s|.*dir-listing.activate.*|dir-listing.activate = \"enable\"|" /data/lighttpd.conf
	
	# http : set port
	sed -i "s|.*server.port.*|server.port = \"$Y_HTTP_PORT\"|" /data/lighttpd.conf
	
	# https : activate module
	sed -i '/^server.modules = (/a\"mod_openssl",' /data/lighttpd.conf
	
	# https : if external pem files are provided then used them, otherwise use selfsigned
	if [[ -f "/data/fullchain.pem" && -f "/data/privkey.pem" ]]; then
		https_key=/data/privkey.pem
		https_cert=/data/fullchain.pem
	else
		https_key=/data/ssl/private/server-key.pem
		https_cert=/data/ssl/certs/server-cert.pem
	fi
	
	# https : set port and pem files
	echo '$SERVER["socket"] == ":'$Y_HTTP_PORT_SECURE'" {
	ssl.engine = "enable"
	ssl.privkey = "'$https_key'"
	ssl.pemfile = "'$https_cert'"
	}' >> /data/lighttpd.conf
	
	# start service
	/usr/sbin/lighttpd -f /data/lighttpd.conf > /dev/null 2>&1 &
	
}

# stop crl update service
f_stop_crl() {
	/bin/kill `/bin/ps aux | /bin/grep "crond -c /data/crontabs -d 0 -l 0" | /bin/grep -v grep | /usr/bin/awk '{ print $1 }'` > /dev/null 2>&1
}

# start crl update service
f_start_crl() {

	# initial crl
	(/usr/bin/openssl ca -config /data/ssl/openssl.cnf -gencrl -crlsec $Y_CRL_SEC_NEXT -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -out /data/ssl/crl.pem ; /usr/bin/openssl crl -inform PEM -in /data/ssl/crl.pem -outform DER -out /data/ssl/certs/crl ; ln -sfn /data/ssl/certs/crl /var/www/localhost/htdocs/crl ; ln -sfn /data/ssl/certs/crl $Y_HTTP_SHARE_FOLDER/crl ) > /dev/null 2>&1
	
	# create cron folder
	mkdir /data/crontabs > /dev/null 2>&1
	
	# create cron file
	echo -e "$Y_CRL_CROND       (/usr/bin/openssl ca -config /data/ssl/openssl.cnf -gencrl -crlsec $Y_CRL_SEC_NEXT -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -out /data/ssl/crl.pem > /dev/null 2>&1 ; /usr/bin/openssl crl -inform PEM -in /data/ssl/crl.pem -outform DER -out /data/ssl/certs/crl)\n" > /data/crontabs/root
	chmod 600 /data/crontabs/root
 
	# start service
	crond -c /data/crontabs -d 0 -l 0 > /dev/null 2>&1 & 
}


# stop ocsp server
f_stop_ocsp() {
	/bin/kill `/bin/ps aux | /bin/grep "/usr/bin/openssl ocsp -resp_text -ignore_err -nmin 1 -port $Y_OCSP_PORT -index /data/ssl/index.txt -CA /data/ssl/cacert.pem -rkey /data/ssl/private/server-keY_OCSP.pem -rsigner /data/ssl/certs/server-cert_ocsp.pem -out /data/ssl/log.txt" | /bin/grep -v grep | /usr/bin/awk '{ print $1 }'` > /dev/null 2>&1
}

# start ocsp server
f_start_ocsp() {
	/usr/bin/openssl ocsp -resp_text -ignore_err -nmin 1 -port $Y_OCSP_PORT -index /data/ssl/index.txt -CA /data/ssl/cacert.pem -rkey /data/ssl/private/server-keY_OCSP.pem -rsigner /data/ssl/certs/server-cert_ocsp.pem -out /data/ssl/log.txt > /dev/null 2>&1 &
}

# create a certificate
f_add() {
	
	prefix=$1
	cn=$2
	password=$3
	
	# extension
	if [[ "$4" == "no" ]]; then
		usr_cert='usr_cert'
	else
		usr_cert='usr_cert_with_revocation'
	fi
	
	# days
	if [[ -z "$5" ]] || [[ "$5" == "-" ]] ; then
  		days=$Y_DAYS_CLIENT
	else
		days=$5
	fi
 
	# san
	if [[ -z "$6" ]] || [[ "$6" == "-" ]] ; then
		san=''
	else
		san='-addext subjectAltName='$6
	fi
	
	# create client key and cert
	
	openssl req -config /data/ssl/openssl.cnf -newkey rsa:$Y_KEY_SIZE -nodes -subj "/CN=$cn" $san -keyout /data/ssl/private/$prefix-key.pem -out /data/ssl/csr/$prefix-req.pem > /dev/null 2>&1

	openssl ca -config /data/ssl/openssl.cnf -policy policy_anything -extensions $usr_cert -days $days -batch -notext -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -out /data/ssl/certs/$prefix-cert.pem -infiles /data/ssl/csr/$prefix-req.pem > /dev/null 2>&1
	
	# export to other format
	
	f_export $prefix $password

 	# show and export credentials
  
  	vl_cred="$prefix $password"
  	echo "CRED : $vl_cred"
	echo "$vl_cred" >> $Y_CRED_EXPORT
	
}


# create random certificates
function f_add_random(){

	vl_count=$1
  
	if [[ -z "$2" ]] || [[ "$2" == "-" ]] ; then
 		vl_revo=$Y_RANDOM_CLIENT_REVO
 	else
 		vl_revo=$2
 	fi
  
	if [[ -z "$3" ]] || [[ "$3" == "-" ]] ; then
 		vl_days=$Y_RANDOM_CLIENT_DAYS
 	else
 		vl_days=$3
 	fi
 
	for i in $(seq $vl_count)
	do
 		# generate credentials
 		vl_user=$(tr -dc $vg_username_char </dev/urandom | head -c $vg_username_length; echo)
   		vl_password=$(tr -dc $vg_password_char </dev/urandom | head -c $vg_password_length; echo)
		vl_result="$vl_user $vl_password"

   		# create certificate
		f_add $vl_user $vl_user $vl_password $vl_revo $vl_days
  
	done
 
}

# export to p12
f_export() {

	prefix=$1
	password=$2

	# export to crt
 
	 openssl x509 -outform der -in /data/ssl/certs/$prefix-cert.pem -out /data/ssl/certs/$prefix-cert.crt
 
	# export to p12

	openssl pkcs12 -in /data/ssl/certs/$prefix-cert.pem -inkey /data/ssl/private/$prefix-key.pem -certfile /data/ssl/cacert.pem -export -out /data/ssl/certs/$prefix-cert.p12 -passout pass:$password 
	chmod 644 /data/ssl/certs/$prefix-cert.p12

	# export to p12 legacy

	openssl pkcs12 -legacy -in /data/ssl/certs/$prefix-cert.pem -inkey /data/ssl/private/$prefix-key.pem -certfile /data/ssl/cacert.pem -export -out /data/ssl/certs/$prefix-cert-legacy.p12 -passout pass:$password
	chmod 644 /data/ssl/certs/$prefix-cert-legacy.p12
	
	# export to p12 legacy pem

	openssl base64 -in /data/ssl/certs/$prefix-cert-legacy.p12 -out /data/ssl/certs/$prefix-cert-legacy.p12.pem
	
}

# show crl
f_crl() {
	openssl crl -inform DER -text -noout -in /data/ssl/certs/crl
}

# test certificate against OCSP server
f_test() {
	prefix=$1

 	# crl
  	echo "CRL:"
 	vl_serial=$(openssl x509 -in /data/ssl/certs/$prefix-cert.pem -noout -serial | cut -d= -f2)
	openssl crl -inform DER -text -in /data/ssl/certs/crl | grep -A 1 "Serial Number: $vl_serial"

 	# ocsp
  	echo "OCSP:"
	openssl ocsp -CAfile /data/ssl/cacert.pem -issuer /data/ssl/cacert.pem -cert /data/ssl/certs/$prefix-cert.pem -url 127.0.0.1:$Y_OCSP_PORT -resp_text 
}

# test certificate against OCSP server
f_update() {
	prefix=$1
 	# crl
 	openssl ca -config /data/ssl/openssl.cnf -gencrl -crlsec $Y_CRL_SEC_NEXT -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -out /data/ssl/crl.pem > /dev/null 2>&1 ; openssl crl -inform PEM -in /data/ssl/crl.pem -outform DER -out /data/ssl/certs/crl
 	# ocsp
  	openssl ocsp -CAfile /data/ssl/cacert.pem -issuer /data/ssl/cacert.pem -cert /data/ssl/certs/$prefix-cert.pem -url 127.0.0.1:$Y_OCSP_PORT -resp_text > /dev/null 2>&1
}

# revoke a certificate
f_revoke() {
	prefix=$1
	openssl ca -config /data/ssl/openssl.cnf -keyfile /data/ssl/private/cakey.pem -cert /data/ssl/cacert.pem -passin pass:$Y_CA_PASS -revoke /data/ssl/certs/$prefix-cert.pem
 	f_update $1
 }

# display ca
f_ca() {
	cat /data/ssl/cacert.pem
}

# display pem certificate 
f_pem() {
	prefix=$1
	cat /data/ssl/certs/$prefix-cert.pem
}

# display p12 legacy certificate in pem
f_p12() {
	prefix=$1
	cat /data/ssl/certs/$prefix-cert-legacy.pem
}

# get certificate info
f_info() {
	prefix=$1
	openssl x509 -text -noout -in /data/ssl/certs/$prefix-cert.pem
}

# get certificate sha1 fingerprint
f_sha1() {
	prefix=$1
	openssl x509 -fingerprint -noout -sha1 -in /data/ssl/certs/$prefix-cert.pem | cut -d "=" -f2 | sed 's/://g'
}

# change timezone
f_timezone(){
	timezone=$1
	cp /usr/share/zoneinfo/$timezone /etc/localtime
	echo $timezone > /etc/timezone
	export TZ=$timezone
	date
}

# shutdown the server
f_shutdown(){
	/bin/kill `/bin/ps aux | /bin/grep "tail -f /dev/null" | /bin/grep -v grep | /usr/bin/awk '{ print $1 }'`
}

# show help
f_arg() {
	echo -e "$(hostname -i)\n$i_HELP"
}

# optional argument
revo="-"
days="-"
san="-"

# get argument
while [ $# -gt 0 ]; do
	case "$1" in
		--action=*|-a=*)
			action="${1#*=}"
			;;
		--prefix=*|-p=*)
			prefix="${1#*=}"
			;;
		--cn=*)
			cn="${1#*=}"
			;;
		--password=*|-pw=*)
			password="${1#*=}"
			;;
		--revo=*|-r=*)
			revo="${1#*=}"
			;;
		--days=*|-d=*)
			days="${1#*=}"
			;;
		--san=*|-s=*)
			san="${1#*=}"
			;;
		--count=*|-c=*)
			count="${1#*=}"
			;;
		--tz=*|-t=*)
			tz="${1#*=}"
			;;
		"?")
			f_arg
			exit 0
			;;
		*)
			echo -e "\n$i_error: $i_missing_or_invalid_argument"
			f_arg
			exit 1
	esac
	shift
done

# switch
case "$action" in
	"init")
		f_init
	;;
	"add")
		if [[ ! -z "$prefix" && ! -z "$cn" && ! -z "$password" ]]; then
			f_add $prefix $cn $password $revo $days $san
		else 
			f_arg
		fi
	;;
 	"random")
		if [[ ! -z "$count" ]]; then
   			f_add_random $count $revo $days
		else 
			f_arg
		fi
	;;
	"crl")
		f_crl
	;;
	"test"|"revoke"|"pem"|"p12"|"info"|"sha1")
		if [[ ! -z "$prefix" ]]; then
			f_$action $prefix
		else 
			f_arg
		fi
	;;
	"ca")
		f_ca
	;;
	"stop_http")
		f_stop_http
	;;
	"stop_crl")
		f_stop_crl
	;;
	"stop_ocsp")
		f_stop_ocsp
	;;
	"start_http")
		f_start_http
	;;
	"start_crl")
		f_start_crl
	;;
	"start_ocsp")
		f_start_ocsp
	;;
	"restart_http")
		f_stop_http
		f_start_http
	;;
	"restart_crl")
		f_stop_crl
		f_start_crl
	;;
	"restart_ocsp")
		f_stop_ocsp
		f_start_ocsp
	;;
	"timezone")
		if [[ ! -z "$tz" ]]; then
			f_timezone $tz
		else 
			f_arg
		fi
	;;
	"shutdown")
		f_shutdown
	;;
	*)
		echo -e "\n$i_error: $i_missing_or_invalid_argument"
		f_arg
		exit 1
	;;
esac
