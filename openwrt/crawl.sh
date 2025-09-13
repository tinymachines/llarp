#!/bin/bash

ROOT="/home/bisenbek/projects/tinymachines/llarp/openwrt"
START="https://openwrt.org/docs/"

function wait_for_processes() {
	while (( $(ps aux | grep -E "lynx" | wc -l) >= 10 )); do
		echo "Waiting ..."
		sleep 1
	done
}

function clean_links() {
		while read -ra ROW; do echo "${ROW[1]}"; done \
		| while IFS=\?\# read -ra ROW2; do echo "${ROW2[0]}"; done \
		| sort \
		| uniq \
		| grep "${START}"
}

function get_links() {
	lynx --dump --listonly "${1}?do=export_xhtmlbody" \
		| while read -ra ROW; do echo "${ROW[1]}"; done \
		| while IFS=\?\# read -ra ROW2; do echo "${ROW2[0]}"; done \
		| sort \
		| uniq \
		| grep "${START}"
}

function fetch_page() {
	lynx --source "${1}?do=export_xhtmlbody"
	
}

function crawl_page() {

	local DIRECTORY="$(dirname ${1#*//})"
	local FILEPATH="${ROOT}/${DIRECTORY}"
	local FILENAME="${FILEPATH}/$(basename "${1}").html"

	echo "${1}" >/dev/stderr

	[[ -d ${FILEPATH} ]] || mkdir -p ${FILEPATH}
	[[ -f ${FILENAME} ]] || fetch_page "${1}" | tee >(lynx --dump --listonly --stdin | clean_links >${FILENAME}.lnk) >${FILENAME}

}

function crawl() {
	while read -r ROW; do
		wait_for_processes
		crawl_page "${ROW}" &
	done
}

function collect_links() {
	while read -r ROW; do
		cat "${ROW}"
	done<<<$(find . -type f -name *.lnk) | sort | uniq
}

function make_markdown() {
	while read -r ROW; do
		cat "${ROW}" | html2markdown >${ROW}.md
	done<<<$(find . -type f -name *.html) | sort | uniq
}

function move_markdown() {
	while read -r ROW; do

		local DIRNAME="$(dirname ${ROW})"
		local FILENAME="$(basename ${ROW})"
		local CLEAN="${FILENAME%.*.*}"

		local NEWDIR="./openwrt.org.md${DIRNAME#./openwrt.org}"

		local FILEPATH="${NEWDIR}"
		local FILENAME="${NEWDIR}/${CLEAN}.md"

		
		[[ -d ${FILEPATH} ]] || mkdir -p "${FILEPATH}"
		[[ -f ${FILENAME} ]] || cp "${ROW}" "${FILENAME}"

		echo "${FILENAME}"
		#echo "${DIRNAME}	${FILENAME}	${CLEAN}"
		#echo "${FILEPATH}	${FILENAME}"
	done<<<$(find . -type f -name *.md) | sort | uniq
}

function main() {

	get_links "${START}" | crawl
	wait

	collect_links | crawl
	wait

	make_markdown

}

#main
move_markdown
