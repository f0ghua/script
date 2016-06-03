#!/bin/sh

export LC_CTYPE=en_US.UTF-8

TOPDIR=`pwd`

E_WRONG_ARGS=65

timeStamp=$(date +%Y%m%d%H%M)
tmpOutputFile="output${timeStamp}.zip"

if [ $# -lt 1 ]
then
    echo "Usage: `basename $0` <url_link> [output_file]"
      # `basename $0` is the script's filename.
    exit $E_WRONG_ARGS
fi

#urlLink="http://page2.dix3.com/fs/7wyd7y1a0c18e5/"

urlLink="$1"
if [ ! -z $2 ]
then
    tmpOutputFile="$2"
fi

echo "output file is $tmpOutputFile"
imgLink="http://page2.dix3.com/verifyimg/getPcv.html"

urlGetLink=
urlGetHost="page2.dix3.com"
uriGetPart1="/file/down/"

urlPostHost="dl31.dix3.com"
uriPostPart1="/view?action=downfile&fid="

proxyParameter="-x 192.168.0.242:7777"
timeOut=10

gzipFile="./tmp.gzip"
tmpHtmlFile="tmp.html"
tmpImageFile="tmp.png"


:>cookie.txt
:>cookie_tmp.txt

#lineS="<a id=\"premium_link\" href=\"javascript:void(0)\" onclick=\"openAddress(this,1,'user/','premium','Membership/','wydy1/','77a0c18e',1,1)\"></a>"
#addr=`echo $lineS | sed "s/.*onclick=[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,'\([^']*\)','\([^']*\)'.*/\1\2/g"`
#echo $addr
#exit

url="${urlLink}"
curl ${proxyParameter} -b cookie.txt -D cookie_tmp.txt\
    -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Keep-Alive: 115" \
    -H "Proxy-Connection: keep-alive" \
    "${url}" -o $tmpHtmlFile
cat cookie_tmp.txt >> cookie.txt

uriGetPart2=`grep '^<a id="premium_link"' $tmpHtmlFile | sed "s/.*onclick=[^,]*,[^,]*,[^,]*,[^,]*,[^,]*,'\([^']*\)','\([^']*\)'.*/\1\2/g"`

echo $uriGetPart2

url="${imgLink}"
curl ${proxyParameter} -b cookie.txt -D cookie_tmp.txt\
    -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Keep-Alive: 115" \
    -H "Proxy-Connection: keep-alive" \
    --referer "${urlLink}" \
    "${url}" -o $tmpImageFile
cat cookie_tmp.txt >> cookie.txt
#addrPart3=number from the image file

read imageNumber

urlGetUri="$uriGetPart1$uriGetPart2/$imageNumber.html"

sleep 30

urlGetLink="${urlGetHost}${urlGetUri}"
echo "$urlGetLink"
curl ${proxyParameter} -b cookie.txt -D cookie_tmp.txt \
    -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Keep-Alive: 115" \
    -H "Proxy-Connection: keep-alive" \
    --referer "${urlLink}" \
    "${urlGetLink}" -o $tmpHtmlFile
cat cookie_tmp.txt >> cookie.txt

#    <input type="hidden" name="module" value="fileService" />
#    <input type="hidden" name="userId" value="wydy1" />
#    <input type="hidden" name="fileId" value="" />
#    <input type="hidden" name="vid" value="" />
#    <input type="hidden" name="vid1" value="a8a9ed59dddeb586" />
#    <input type="hidden" name="md5" value="626d68c95f488c4c18b7abad8237fd4c" />

paramFid=$(grep 'fid' $tmpHtmlFile|grep 'form.action'|sed 's/.*fid=\([^"]*\)".*/\1/')

paramUserId=$(grep '"userId"' $tmpHtmlFile|sed 's/.*value="\([^"]*\)".*/\1/')
paramFileId=$(grep 'form.fileId.value' $tmpHtmlFile|sed 's/.* = "\([^""]*\)".*/\1/')
paramVid=$(grep 'var vericode' $tmpHtmlFile|sed 's/.* = "\([^"]*\)".*/\1/')
paramVid1=$(grep 'vid1' $tmpHtmlFile|sed 's/.*value="\([^"]*\)".*/\1/')
paramMd5=$(grep 'md5' $tmpHtmlFile|sed 's/.*value="\([^"]*\)".*/\1/')
#echo $paramModule $paramUserId $paramFileId $paramVid $paramVid1 $paramMd5

#"module=fileService&userId=wydy1&fileId=77a0c18e&vid=cf5aefa4&vid1=a8a9ed5906ed640a&md5=626d68c95f488c4c18b7abad8237fd4c"

postData="module=fileService&userId=${paramUserId}&fileId=${paramFileId}&vid=${paramVid}&vid1=${paramVid1}&md5=${paramMd5}"

urlPostLink="${urlPostHost}${uriPostPart1}${paramFid}"
echo "urlPostLink=${urlPostLink}"
curl ${proxyParameter} -C - -b cookie.txt -D cookie_tmp.txt \
    -H "User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.3) Gecko/20100423 Ubuntu/10.04 (lucid) Firefox/3.6.3" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Keep-Alive: 115" \
    -H "Proxy-Connection: keep-alive" \
    --referer "${urlGetLink}" \
    -d "${postData}" \
    "${urlPostLink}" -o $tmpOutputFile
