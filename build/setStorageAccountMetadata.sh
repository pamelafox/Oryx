#!/bin/bash

storageAccount="https://oryxsdksdev.blob.core.windows.net"
container="dotnet"

xml=$(curl -k --silent "$storageAccount/$container?restype=container&comp=list")

nonStretchRegex="$container-(focal-scm|bullseye|buster)-(.*?).tar.gz"
stretchRegex="$container-(.*?).tar.gz"
grep -oPm1 "(?<=<Name>)[^<]+" <<< "$xml" | while read -r line ; do
    ostype=$(echo $line | awk "{match(\$0,/$nonStretchRegex/,a);print a[1]}" )
    version=$(echo $line | awk "{match(\$0,/$nonStretchRegex/,a);print a[2]}")
    if [[ -z $ostype ]] || [[ -z $version ]] ; then
        version=$(echo $line | awk "{match(\$0,/$stretchRegex/,a);print a[1]}")
        if [[ ! -z $version ]] ; then
            ostype="stretch"
        fi
    fi
    if [[ -z $ostype ]] || [[ -z $version ]] ; then
        echo "No match found for $line"
    else
        echo "ostype: $ostype     version: $version"
    fi
done