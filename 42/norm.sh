#!/bin/bash
TMPFILE=$(mktemp)
ERRLOG=$(mktemp)
exec 2>$ERRLOG

for f in $@
do
    if ! [ -e "$f" ]
    then
        printf "Path '%s' does not exist\n" $f
    else
        f=$(realpath $f)
        if [ -d "$f" ]
        then
            find $f -name '*.[ch]' >>$TMPFILE
        else
            echo $f >>$TMPFILE
        fi
    fi
done

sort -u -o $TMPFILE $TMPFILE
sed -e "s:^$PWD/::" -i'' $TMPFILE

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

function diff_output() {
    sed -n -e 1p $2
    printf $'\x1b[33m'
    printf '!'
    printf $'\x1b[0m'
    printf " Diff compared to '"
    printf "$(sed -n -e '1{s/\x1b\[[0-9;]*m//g;p}' $1)"
    echo "'"
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
RED = '\x1b[31m'
GREEN = '\x1b[32m'
RESET = '\x1b[0m'

def structext(lines):
    lines = lines[1:]
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

lines1 = structext(open(sys.argv[1]).readlines())
lines2 = structext(open(sys.argv[2]).readlines())
for line1, line2 in zip(lines1, lines2):
    assert PAT in line2[0], (
        "Norminett's output does not start with 'Norme: ' signature")
    assert line1[0] == line2[0], (
        "Cannot compare different file lists")
    sys.stdout.write(line2[0].rstrip())
    i1 = i2 = 0
    ls1, ls2 = line1[1], line2[1]
    diff = False
    while i1 < len(ls1) or i2 < len(ls2):
        if i1 >= len(ls1):
            if not diff:
                sys.stdout.write('\n')
                diff = True
            line = '{}+{}{}'.format(RED, RESET, ls2[i2][1:])
            sys.stdout.write(line)
            i2 += 1
            continue
        if i2 >= len(ls2):
            if not diff:
                sys.stdout.write('\n')
                diff = True
            line = '{}-{}{}'.format(RED, RESET, ls1[i1][1:])
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
            if not diff:
                sys.stdout.write('\n')
                diff = True
            line = '{}-{}{}'.format(RED, RESET, ls1[i1][1:])
            sys.stdout.write(line)
            i1 += 1
        else:
            if not diff:
                sys.stdout.write('\n')
                diff = True
            for line in ls2[i2:ix]:
                line = '{}+{}{}'.format(RED, RESET, line[1:])
                sys.stdout.write(line)
            i1 += 1
            i2 = ix + 1
    if not diff:
        sys.stdout.write(' {}={}\n'.format(GREEN, RESET))
EOF
}

echo
cat $TMPFILE
echo
show_errors norminette -R CheckForbiddenSourceHeader | py_sort | tee .norm0
show_errors norminette -R CheckDefine | py_sort >.norm1
show_errors norminette | py_sort >.norm2
show_if .norm0 .norm1 .norm2

echo $'\x1b[31;1m'stderr:$'\x1b[0m\x1b[31m'
cat $ERRLOG
echo $'\x1b[0m'

rm -f $TMPFILE $ERRLOG .norm{0..2}
