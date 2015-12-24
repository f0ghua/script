#!/bin/bash
# 
# This script is used to download books from yunshenwuji
#
# @param URL The index page url of the book
#

export LC_CTYPE=en_US.UTF-8

F_IPAGE="index_page"     # index page
F_BPAGE="book_pages"     # book pages

TOPDIR=`pwd`

E_WRONG_ARGS=65

if [ $# -ne 2 ]
then
    echo "Usage: `basename $0` <url_link_index> <output_file>"
      # `basename $0` is the script's filename.
    exit $E_WRONG_ARGS
fi


URL="$1"
OFILE="$2"
echo "" > $OFILE

#
#echo URL=$URL
#


# if you the index page have same format with links, we parser auto
#wget --no-parent -O $F_IPAGE "$URL"
#./parse_link $F_IPAGE > $F_BPAGE

#
#URL_prefix=${URL%/*}
#echo $URL_prefix
#
# get book page links from index page
#
#cat ${F_IPAGE}|grep -E "<div class=\"dccss\"><a\ href=\"[0-9]+"|LC_ALL=zh_CN.GBK sed -e 's/.*href="\([0-9]\+\).*/\1\.html/g' > $F_BPAGE


# get all pages from the website
# wget -k -p ${URL_prefix}/index.html

KEY="yswj"
while read i;do
    echo "processing $i ..."
#    w3m -dump ${URL_prefix}/$i >> ${OFILE}
#    w3m -dump $i >> ${OFILE}
    isBackupSpace=$i
    # check if it is a backup space
    matchStr=${isBackupSpace/${KEY}*/}
    isBackupSpace=${isBackupSpace##${matchStr}}

    w3m -dump $i >> ${OFILE}
#    if [ "${isBackupSpace}" != "" ];then
#        w3m -dump $i|sed -n '/ 恶魔法则/,/回备用空间目录/p' >> ${OFILE}
#    else
#        w3m -dump $i|sed -n '/ 恶魔法则/,/回目录观看下载更多章节/p' >> ${OFILE}
#    fi
done < $F_BPAGE
