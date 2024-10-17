#!/bin/sh

# Entrypoint for container

# ============ [ global variable ] ============

# script name
vg_name=ye3cert

# ============ [ function ] ============

# echo information for docker logs
function f_log(){
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') $(hostname) $vg_name: $@"
}

# ============ [ internationalisation ] ============

if [[ -f /i18n/$Y_LANGUAGE.sh ]]; then
	f_log "i18n $Y_LANGUAGE"
	source /i18n/$Y_LANGUAGE.sh
else
	f_log "i18n fr_FR"
	source /i18n/fr_FR.sh
fi

# ============ [ config ] ============

f_log "$i_update_timezone"
/yee.sh --action=timezone --tz=$TZ

# check ca file presence
if [ -f "/data/ssl/cacert.pem" ]; then

	f_log "$i_start HTTP"
	if [[ $Y_HTTP == "yes" ]]; then /yee.sh --action=restart_http; fi
	
	f_log "$i_start CRL"
	if [[ $Y_CRL == "yes" ]]; then /yee.sh --action=restart_crl; fi
	
	f_log "$i_start OCSP"
	if [[ $Y_OCSP == "yes" ]]; then /yee.sh --action=restart_ocsp; fi
	
else
	
	f_log "$i_run_initial_setup"
	/yee.sh --action=init

fi

# create/update symbolic link for bypass_container_env.sh
 
ln -sfn /data/bypass_container_env.sh /etc/profile.d/bypass_container_env.sh

f_log ":: $i_ready ::"

# keep the server running
tail -f /dev/null
