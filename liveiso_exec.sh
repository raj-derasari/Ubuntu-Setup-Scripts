#!/bin/bash
bash master.sh -x -f ./configs/liveiso_preset/liveiso_no_equalizer.sh > ./custom_iso_sh/set1_noeq.sh
bash master.sh -x -f ./configs/liveiso_preset/liveiso_with_equalizer.sh > ./custom_iso_sh/set1_weq.sh
bash master.sh -x -f ./configs/liveiso_preset/liveiso_global_setPy.sh > ./custom_iso_sh/set2.sh #bash set0.sh /etc/skel/.bashrc
#bash set1.sh 2>>set1_errlog.txt
#bash set2.sh 2>>set2_errlog.txt

if [[ -z `cat log_errors.log` ]]; then
	rm *.log
fi
