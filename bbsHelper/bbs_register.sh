#!/bin/sh

userName="白雪公猪的小JJ"
userId=2488

urlSite="http://www.dushiqingyuan.info"
urlFirst=${urlSite}"/forum.php?fromuid=$userId"
urlRegister=${urlSite}"/member.php?mod=register.php"
urlRegPost=${urlSite}"/member.php?mod=register.php&inajax=1"

proxyFile="./proxy/latestProxy.lst"
processFile="./bbs_register_process.tmp"
nameListFile="./genNameList/nameList"
tmpFile1="/tmp/http_content1"
tmpFile2="/tmp/http_content2.gz"
timeOut=10
successHit=0

proxyCount=1
nameCount=1

if [ -f $processFile ];then
    read proxyCount nameCount < $processFile
fi

proxyCntMax=$(wc -l $proxyFile |cut -f 1 -d " ")
nameCntMax=$(wc -l $nameListFile |cut -f 1 -d " ")

echo "proxy: $proxyCount/$proxyCntMax, name: $nameCount/$nameCntMax"

#while IFS=@ read proxy left; do
while ((proxyCount < proxyCntMax && nameCount <= nameCntMax));do
        proxy=`sed -n "${proxyCount},1p" $proxyFile|cut -f 1 -d @`
        proxyParameter="-x $proxy"
        regUserName=`sed -n "${nameCount},1p" $nameListFile`

	echo "[$proxyCount/$proxyCntMax] using proxy $proxy, name $regUserName ...";
        
        :>cookie.txt
        curl ${proxyParameter} -m $timeOut -D cookie_tmp.txt \
            -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3" \
            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
            -H "Accept-Language: en-us,en;q=0.5" \
            -H "Accept-Encoding: gzip,deflate" \
            -H "Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7" \
            -H "Keep-Alive: 115" \
            -H "Proxy-Connection: keep-alive" \
            "${urlFirst}" -o $tmpFile1
        cat cookie_tmp.txt >> cookie.txt

        curl ${proxyParameter} -m $timeOut -b cookie.txt -D cookie_tmp.txt \
            -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3" \
            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
            -H "Accept-Language: en-us,en;q=0.5" \
            -H "Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7" \
            -H "Keep-Alive: 115" \
            -H "Proxy-Connection: keep-alive" \
            --referer "${urlFirst}" \
            "${urlRegister}" -o $tmpFile1
        cat cookie_tmp.txt >> cookie.txt

        formHash=`grep 'formhash' ${tmpFile1} |sed 's/.*"formhash" value="\([^"]*\)".*/\1/g'`
        agreeBbRule=`grep 'agreebbrule" value' ${tmpFile1}|sed 's/.*"agreebbrule" value="\([^"]*\)".*/\1/g'`
#        urlMailTmp=`grep 'sendmail' ${tmpFile1}|sed 's/.*src="\([^"]*\)".*/\1/'`
#        urlMail=${urlSite}"/"${urlMailTmp}

        echo "formhash=${formHash} agreebbrule=${agreeBbRule}"


#        curl ${proxyParameter} -m $timeOut -b cookie.txt -D cookie_tmp.txt \
#            -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3" \
#            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
#            -H "Accept-Language: en-us,en;q=0.5" \
#            -H "Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7" \
#            -H "Keep-Alive: 115" \
#            -H "Proxy-Connection: keep-alive" \
#            --referer "${urlFirst}" \
#            ${urlMail} -o /dev/null
#        cat cookie_tmp.txt >> cookie.txt

#        curl ${proxyParameter} -m $timeOut -b cookie.txt -D cookie_tmp.txt \
#            -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3" \
#            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
#            -H "Accept-Language: en-us,en;q=0.5" \
#            -H "Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7" \
#            -H "Keep-Alive: 115" \
#            -H "Proxy-Connection: keep-alive" \
#            --referer "${urlFirst}" \
#            "http://www.dushiqingyuan.info/forum.php?mod=ajax&infloat=register&handlekey=register&action=checkemail&email=${regUserName}@gmail.com&inajax=1&ajaxtarget=returnmessage4" -o /dev/null
#        cat cookie_tmp.txt >> cookie.txt


        curl ${proxyParameter} -m $timeOut -b cookie.txt \
            -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3" \
            -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
            -H "Accept-Language: en-us,en;q=0.5" \
            -H "Accept-Encoding: gzip,deflate" \
            -H "Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7" \
            -H "Keep-Alive: 115" \
            -H "Proxy-Connection: keep-alive" \
            -H "Expect:" \
            --referer "${urlFirst}" \
            -F "regsubmit=yes" \
            -F "formhash=${formHash}" \
            -F "referer=${urlFirst}" \
            -F "activationauth=" \
            -F "username=${regUserName}" \
            -F "password=123456" \
            -F "password2=123456" \
            -F "email=${regUserName}@gmail.com" \
            -F "agreebbrule=${agreeBbRule}" \
            "${urlRegPost}" -o $tmpFile2

        if [[ $? == "0" ]]; then
            ((nameCount++));
            ((successHit++));
        fi
        ((proxyCount++));
        echo "$proxyCount $nameCount" > $processFile
done
#done < proxy/proxylist

echo "Success hit ${successHit} times."


