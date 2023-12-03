#!/bin/sh

# LABEL name="ye3cert" version="1.0.0" author="palw3ey" maintainer="palw3ey" email="palw3ey@gmail.com" website="https://github.com/palw3ey/ye3cert" license="MIT" create="20231203" update="20231203"

# Entrypoint for docker

# ============ [ function ] ============

# echo information for docker logs
function f_log(){
  echo -e "$(date '+%Y-%m-%d %H:%M:%S') $(hostname) ye3radius: $@"
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
	if [ $y_http == "yes" ]; then /mgmt.sh --action=restart_http; fi
	
	f_log "$i_start CRL"
	if [ $y_crl == "yes" ]; then /mgmt.sh --action=restart_crl; fi
	
	f_log "$i_start OCSP"
	if [ $y_ocsp == "yes" ]; then /mgmt.sh --action=restart_ocsp; fi
	
else
	
	f_log "$i_run_initial_setup"
	/mgmt.sh --action=init

fi

f_log ":: $i_ready ::"

# keep the server running
tail -f /dev/null
