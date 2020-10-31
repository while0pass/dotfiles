#!/bin/bash
TMPFILE=$(mktemp)
if [ $# == 0 ] || [ $# == 1 ] && [ -d "$1" ]
then
    if [ $# == 1 ] && [ -d "$1" ]
    then
        DIR=$1
    else
        DIR=./
    fi
    find $DIR -name '*.[ch]' | sort >$TMPFILE
else
    echo $@ >$TMPFILE
fi
for f in $(xargs -a $TMPFILE echo)
do
    if ! [ -e "$f" ]
    then
        echo Path "'"$f"'" does not exist
        exit 1
    fi
done
if [ $(cat $TMPFILE | wc -m) == 0 ] && [ $# -ge 1 ]
then
    echo No files found
    exit 1
fi

function show_errors() {
    echo $'\x1b[1m'$*$'\x1b[0m'
    xargs -a $TMPFILE $@ | sed -e '
        /^Norme:/{
            s/^\(Norme: \)\(.*\)$/  \1\x1b[33m\2\x1b[0m/;
        };
        /^Error/{
            s/^\(Error: \)\(.*\)$/    \1\x1b[31m\2\x1b[0m/g;
            s/^\(Error ([^)]\+): \)\(.*\)$/    \1\x1b[31m\2\x1b[0m/g;
        };
        /^Warning/{
            s/^\(Warning: \)\(.*\)$/    \1\x1b[34m\2\x1b[0m/g;
        };
        '
    echo
}

function same_output() {
    sed -n -e 1p $2
    printf $'\x1b[33m'
    printf "="
    printf $'\x1b[0m'
    printf " Same output as for '"
    printf "$(sed -n -e '1{s/\x1b\[[0-9;]*m//g;p}' $1)"
    echo "'"
}

function __py_sort() {
    cat << EOF

import sys
import re

PAT = 'Norme: '

def structext(lines):
    x = []
    for i, line in enumerate(lines):
        if not line.strip():
            continue
        if i == 0 or PAT in line:
            filepath = line
            errors = []
            x.append((filepath, errors))
            continue
        errors.append(line)
    x.sort()
    return x

def sort_key(line):
    result = re.findall(
        '^\s*(Error|Warning)\s*(?:\(line\s*(\d+)(?:,\s*col\s*(\d+))?\))?\:\s*(.*)$',
        line)
    if len(result) > 0:
        kind, y, x, text = result[0]
        y = int(y or 0)
        x = int(x or 0)
        return (kind, y, x, text)

lines = structext(sys.stdin.readlines())
for filepath, errors in lines:
    sys.stdout.write(filepath)
    errors.sort(key=sort_key)
    for error in errors:
        sys.stdout.write(error)

EOF
}

function __py_diff() {
    cat << EOF

import sys

PAT = 'Norme: '
COLOR = '\x1b[31m'
RESET = '\x1b[0m'

def structext(lines):
    lines = lines[1:]
    x = []
    for line in lines:
        if not line.strip():
            continue
        if PAT in line:
            filepath = line
            errors = []
            x.append((filepath, errors))
            continue
        errors.append(line)
    x.sort()
    return x

lines1 = structext(open(sys.argv[1]).readlines())
lines2 = structext(open(sys.argv[2]).readlines())
for line1, line2 in zip(lines1, lines2):
    assert line1[0] == line2[0]
    sys.stdout.write(line2[0])
    i1 = i2 = 0
    ls1, ls2 = line1[1], line2[1]
    while i1 < len(ls1) or i2 < len(ls2):
        if i1 >= len(ls1):
            line = '{}+{}{}'.format(COLOR, RESET, ls2[i2][1:])
            sys.stdout.write(line)
            i2 += 1
            continue
        if i2 >= len(ls2):
            line = '{}-{}{}'.format(COLOR, RESET, ls1[i1][1:])
            sys.stdout.write(line)
            i1 += 1
            continue
        if ls1[i1] == ls2[i2]:
            i1 += 1
            i2 += 1
            continue
        try:
            ix = ls2.index(ls1[i1])
        except ValueError:
            line = '{}-{}{}'.format(COLOR, RESET, ls1[i1][1:])
            sys.stdout.write(line)
            i1 += 1
        else:
            for line in ls2[i2:ix]:
                line = '{}+{}{}'.format(COLOR, RESET, line[1:])
                sys.stdout.write(line)
            i1 += 1
            i2 = ix + 1
EOF
}

function diff_output() {
    sed -n -e 1p $2
    python <(__py_diff) $1 $2
}

function py_sort() {
    python <(__py_sort)
}

function show_if() {
    echo
    if [ -z "$(diff <(sed -n -e '1!p' $1) <(sed -n -e '1!p' $2))" ]
    then
        same_output $1 $2
    else
        diff_output $1 $2
    fi
    echo
    if [ -z "$(diff <(sed -n -e '1!p' $1) <(sed -n -e '1!p' $3))" ]
    then
        same_output $1 $3
    elif [ -z "$(diff <(sed -n -e '1!p' $2) <(sed -n -e '1!p' $3))" ]
    then
        same_output $2 $3
    else
        diff_output $2 $3
    fi
    echo
}

echo
cat $TMPFILE
echo
show_errors norminette -R CheckForbiddenSourceHeader | py_sort | tee .norm0
show_errors norminette -R CheckDefine | py_sort >.norm1
show_errors norminette | py_sort >.norm2
show_if .norm0 .norm1 .norm2

rm -f $TMPFILE .norm{0..2}
