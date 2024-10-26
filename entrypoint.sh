#!/bin/sh

# Entrypoint for container

# ============ [ global variable ] ============

# default language
vg_default_language="fr_FR"

# ============ [ function ] ============

# echo information for logs
function f_log(){

	# extra info in logs, if debug on
	vl_log=""
	if [[ $Y_DEBUG == "yes" ]]; then
		vl_log="$(date '+%Y-%m-%d %H:%M:%S') $(hostname) $vg_name:"
	fi

	echo -e "$vl_log $@"
}

# ============ [ internationalisation ] ============

# load default language
source /i18n/$vg_default_language.sh

# override with choosen language
if [[ $Y_LANGUAGE != $vg_default_language ]] && [[ -f /i18n/$Y_LANGUAGE.sh ]] ; then
	source /i18n/$Y_LANGUAGE.sh
fi

f_log "i18n : $Y_LANGUAGE"

# ============ [ config ] ============

# debug
if [[ $Y_DEBUG == "yes" ]] ; then
	sed 's|> /dev/null 2>&1||g' /yee.sh > /yee-debug.sh
	chmod +x /yee-debug.sh
	yee_command=/yee-debug.sh
else
	yee_command=/yee.sh
fi

# create/update symbolic link for bypass_container_env.sh 
ln -sfn /data/bypass_container_env.sh /etc/profile.d/bypass_container_env.sh

# timezone
f_log "$i_update_timezone"
$yee_command --action=timezone --tz=$TZ

# check ca file presence
if [ -f "/data/ssl/cacert.pem" ]; then

	if [[ $Y_HTTP == "yes" ]]; then $yee_command --action=start_http; fi
	
	if [[ $Y_CRL == "yes" ]]; then $yee_command --action=start_crl; fi
	
	if [[ $Y_OCSP == "yes" ]]; then $yee_command --action=start_ocsp; fi
	
else
	
	f_log "$i_run_initial_setup"
	$yee_command --action=init

fi

f_log ":: $i_ready ::"

# keep the server running
tail -f /dev/null
