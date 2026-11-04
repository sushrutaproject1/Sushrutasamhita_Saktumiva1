#!/usr/bin/env bash
# Pre-render the TEI XML transcriptions in xml/0*/ to static HTML,
# so readers' browsers no longer have to run the XSLT themselves.
#
# Each foo.xml becomes foo.html in the same folder, so the stylesheet's
# relative links to ../lib/ (CSS, fonts, JS) keep working.
#
# Needs: xsltproc, and the xml/lib submodule checked out:
#   git submodule update --init xml/lib
#
# Usage: xml/build-html.sh            (all xml/0*/*.xml)
#        xml/build-html.sh FILE.xml…  (just those files)

set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
xsl="$here/tei-to-html.xsl"

if [ ! -f "$here/lib/xslt/tei-to-html.xsl" ]; then
    echo "xml/lib is empty: run 'git submodule update --init xml/lib' first" >&2
    exit 1
fi

if [ $# -gt 0 ]; then
    files=("$@")
else
    files=("$here"/0*/*.xml)
fi

for xml in "${files[@]}"; do
    html="${xml%.xml}.html"
    tmp="$(mktemp)"
    xsltproc "$xsl" "$xml" > "$tmp"
    {
        echo '<!DOCTYPE html>'
        # drop the <?xml-stylesheet ...?> instruction the XSLT copies through
        sed '1s/^<?xml-stylesheet[^>]*>//' "$tmp"
    } > "$html"
    rm -f "$tmp"
    echo "wrote ${html#$here/}"
done
