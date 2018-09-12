#!/bin/bash
inFile=./config_recommended.sh
miniFile=./config_minimum.sh
fullFile=./config_full.sh

grepF=.testscan
if [ ! -e ${grepF} ]; then
	grep "Version=" ${inFile} > ${grepF}
fi

sed 's/=0/=1/g' ${inFile}  > ${fullFile}
sed 's/=1/=0/g' ${inFile}  > ${miniFile}

cat ${grepF} | while read -r word; do

    aa=`echo $word | cut -d= -f1`
    
    # now restore all old values
    sed -i "s/${aa}=.*/$word/g" ${inFile}
	sed -i "s/${aa}=.*/$word/g" ${miniFile}
	sed -i "s/${aa}=.*/$word/g" ${fullFile}
done

# delete temp file
rm ${grepF}