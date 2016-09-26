#!/bin/bash

# Copyright (c) 2016, Ilya Arefiev
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of f1porn nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

if [ -z "$DST_DIR" ]; then
    DST_DIR="images/"
fi;

RSS_LINK="https://www.reddit.com/r/f1porn/.rss"
RSS="/tmp/f1porn.xml"
DLIST="/tmp/f1porn.links"
TODAY=$(date +%F);

if [ ! -d "$DST_DIR" ];
then
    mkdir -p "$DST_DIR";
fi;
    
check_and_download()
{
    echo "check '$1'";
    local dst=$(echo "$1" | md5sum | sed -r -e "s/\ .*//");
    ls -1 "$DST_DIR" | sed -r -e 's/.*_//' -e 's/\.jpg//' | grep -q "$dst";

    if [ $? -eq 1 ];
    then
        dst="${DST_DIR}/${TODAY}_${dst}.jpg";
        echo "downloading to '$dst'";
        curl -# "$1" > $dst;
    fi;
}

echo "grab images links"
curl -A "Mozilla/5.0" -# "$RSS_LINK" | xmllint --format - > "$RSS";
grep -P "href" "$RSS" | sed -re 's/\ /\n/g' | grep -P "href.*\.jpg" | sed -r -e "s/href\=\"//" -e "s/\.jpg\".*$/\.jpg/" > "$DLIST";
cat "$DLIST" | while read line;
               do
                   check_and_download "$line";
               done;

rm "$RSS" "$DLIST";
