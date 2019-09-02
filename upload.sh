#!/bin/bash
# based on https://stackoverflow.com/a/40906709/1952991
set -eu -o pipefail
safe_source () { [[ ! -z ${1:-} ]] && source $1; _dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; _sdir=$(dirname "$(readlink -f "$0")"); }; safe_source

show_help(){
    cat <<HELP
    Usage:

        $(basename $0) path/to/file shared-link [password]

HELP
    exit
}

if [[ ${1:-} == "--help" ]]; then
    show_help
fi

file=${1:-}
if [[ ! -f $file ]]; then
    [[ -z $file ]] || echo "Error: No such file found: $file"
    show_help
fi

shared_link=${2:-}
if [[ -z $shared_link ]]; then
    echo "Shared link is required."
    show_help
fi

url=$(echo $shared_link | awk -F'/s/' '{print $1}')
url=${url%index.php}
token=$(echo $shared_link | awk -F'/s/' '{print $2}')
[[ -z $token ]] && { echo "Can not determine token."; exit 5; }
filename=$(basename $file)
password=${3:-}

curl -u $token:$password \
	-T $file \
	"$url/public.php/webdav/$filename" \
	--progress-bar | tee /dev/null

