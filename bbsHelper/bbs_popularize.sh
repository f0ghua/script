#!/bin/sh

arrayBBSList=(
	"http://www.55188.com/?fromuid=3533031"
#    "http://www.eshuzone.com/bbs/?fromuser=f0g"
#    "http://www.fkzww.net/?fromuser=f0g"
#    "http://bbs.mydoo.cn/?fromuser=f0g"
#    "http://www.by-smart.com/?fromuser=f0g"
#    "http://dakedakedu.com/?fromuid=8282"
#    "http://www.horou.com/thread-33056-1-1.html"
#    "http://www.horou.com/?fromuid=58881"
#    "http://www.likeu778.com/?fromuid=408760" # XXXabc
#    "http://www.haptog.com/?fromuid=184372"
#    "http://www.dushiqingyuan.info/?fromuid=2488"
#    "http://www.newkhl.info/?fromuid=330517"
## ebigear:
#    "http://www.ebigear.com/e-2496185.html"
#    "http://oral.ebigear.com/oralpractice-2496185.html"
#    "http://word.ebigear.com/rememberword-2496185.html"
#    "http://www.ebigear.com/resclick-2065-7777700121794-2496185.html"
#    "http://www.ebigear.com/resclick-1392-7777700049473-2496185.html"
#    "http://www.ebigear.com/resclick-665-7777700016117-2496185.html"
#    "http://www.ebigear.com/resclick-12-7777700000003-2496185.html"
#    "http://www.ebigear.com/resclick-1234-7777700010619-2496185.html"
#    "http://www.ebigear.com/resclick-1674-7777700123507-2496185.html"
#    "http://www.ebigear.com/resclick-79-7777700001469-2496185.html"
#    "http://www.ebigear.com/resclick-882-7777700022109-2496185.html"
#    "http://www.ebigear.com/resclick-277-7777700006279-2496185.html"
#    "http://www.ebigear.com/resclick-137-7777700078326-2496185.html"
#    "http://www.ebigear.com/newsclick-481-71100-2496185.html"
#    "http://www.ebigear.com/newsclick-25-62692-2496185.html"
#    "http://www.ebigear.com/newsclick-27-65238-2496185.html"
#    "http://www.ebigear.com/newsclick-54-66780-2496185.html"
#    "http://www.ebigear.com/newsclick-12-1-2496185.html"
#    "http://www.ebigear.com/newsclick-25-61067-2496185.html"
#    "http://www.ebigear.com/newsclick-25-43409-2496185.html"
#    "http://www.ebigear.com/newsclick-45-46527-2496185.html"
#    "http://www.ebigear.com/newsclick-52-36927-2496185.html"
#    "http://www.ebigear.com/newsclick-100-3458-2496185.html"
)

tmpFile="/tmp/http_content"
proxyFile="./proxy/latestProxy.lst"
workingProxyFile="./proxy/workingProxy.lst"
timeOut=10

numberOfElements=${#arrayBBSList[@]}

# Initialize success hit numbers
for (( i = 0; i < numberOfElements; i++));do
#    echo ${arrayBBSList[$i]}
    arraySHitNumber[$i]=0
done

proxyNumbers=$(wc -l $proxyFile | cut -f 1 -d " ")
exProxyNumber=0

:>$workingProxyFile

while IFS=@ read proxy left; do
    ((exProxyNumber++))
    echo "using proxy[$exProxyNumber/$proxyNumbers] $proxy ...";

#    if [ "$exProxyNumber" -lt "280" ];then
#        continue
#    fi

    logIt=0
    for (( i = 0; i < numberOfElements; i++));do

        case "${arrayBBSList[$i]}" in
            *ebigear*)
                :>$tmpFile
                curl -x ${proxy} -m $timeOut "${arrayBBSList[$i]}" -o $tmpFile
                hrefNext=`cat ${tmpFile} |sed 's/.*href="\([^;]*\)refer.*/\1/'`
                # break when href is wrong
                if [ "${#hrefNext}" -eq 0 ] || [ "${#hrefNext}" -gt 64 ];then
                    break;
                fi
                urlNext="http://www.ebigear.com"${hrefNext}"refer=QQ+or+Email"
                curl -x ${proxy} -m $timeOut "$urlNext" -o /dev/null
                ;;
            *)
	        wget -e http_proxy=$proxy --save-cookies=cookie --keep-session-cookies --cache=off -T $timeOut -t 1 -w 0 -O /dev/null ${arrayBBSList[$i]}
                ;;
        esac

        if [[ $? == "0" ]]; then
            ((arraySHitNumber[$i]++))
            logIt=1
        else
            break
        fi
    done

    if [[ $logIt == "1" ]]; then
        echo "$proxy" >> $workingProxyFile
	sleep 15
    fi
done < $proxyFile

for (( i = 0; i < numberOfElements; i++));do
    echo "Popularize [${arrayBBSList[$i]}] number: ${arraySHitNumber[$i]}"
done
