#! /bin/sh

test -d "build" || mkdir "build"

printf "<!DOCTYPE html>\
<html>\
<head>\
<meta charset=\"utf-8\">\
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\
<title>Articles</title>\
</head>\
<body>" > "build/index.html"

build()
{
    for i in ${@} ; do
        base="$(basename ${i} .md)"

        if test -d "${i}" ; then
            test -d "build/${i}" || mkdir -p "build/${i}"
            printf "<b>${base}/</b><ul>" >> "build/index.html"
            build ${i}/*
            printf "</ul>" >> "build/index.html"
        else
            dir="$(dirname ${i})"
            printf "building ${i}...\n"
            pandoc -f markdown -t html5 -s -o "build/${dir}/${base}.html" "${i}"
            printf "<li><a href=\"${dir}/${base}.html\">${base}.html</a></li>" >> "build/index.html"
        fi
    done
}

build article/????

printf "</body></html>" >> "build/index.html"
