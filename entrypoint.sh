#!/bin/sh

# LABEL name="ye3cert" version="1.0.0" author="palw3ey" maintainer="palw3ey" email="palw3ey@gmail.com" website="https://github.com/palw3ey/ye3cert" license="MIT" create="20231203" update="20240115"

# Entrypoint for docker

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
/mgmt.sh --action=timezone --tz=$TZ

# check ca file presence
if [ -f "/data/ssl/cacert.pem" ]; then

	f_log "$i_start HTTP"
	if [[ $Y_HTTP == "yes" ]]; then /mgmt.sh --action=restart_http; fi
	
	f_log "$i_start CRL"
	if [[ $Y_CRL == "yes" ]]; then /mgmt.sh --action=restart_crl; fi
	
	f_log "$i_start OCSP"
	if [[ $Y_OCSP == "yes" ]]; then /mgmt.sh --action=restart_ocsp; fi
	
else
	
	f_log "$i_run_initial_setup"
	/mgmt.sh --action=init

fi

f_log ":: $i_ready ::"

# keep the server running
tail -f /dev/null
