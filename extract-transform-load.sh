#!/usr/bin/env bash

today=$(date "+%F")
dir=$(dirname "$0")
current_year=$(date "+%Y")

racket -y ${dir}/extract.rkt -e "$2" -p "$3"
racket -y ${dir}/transform-load.rkt -p "$1"

7zr a /var/tmp/finviz/screener/${current_year}.7z /var/tmp/finviz/screener/${today}.csv
