#!/bin/bash
convert the basespace downloadlinks to api wget-able links

tokenid=""

sed 's/.*tree\/\/\(.*\)?id=\(.*\)/wget -O \1 https:\/\/api.basespace.illumina.com\/v1pre3\/files\/\2\/content?access_token='$tokenid'/g' 2007_1.txt
