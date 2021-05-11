#!/usr/bin/env bash

# Source scripts under the root of the module.  Works regardless of where we are called from
base_dir="${BASH_SOURCE[0]%/*}"

source "$base_dir/../files/common.sh"
source "$base_dir/../puppetlabs-facts/tasks/bash.sh" >/dev/null || {
  echo "The puppetlabs-facts module is required" >&2
  echo "Please clone this repo with --recurse-submodules"
  fail
}
while getopts ":g:" opt; do
  case "$opt" in
    g)
      gpg_url="$OPTARG"
      echo $gpg_url
      ;;
    :)
      echo "Option -$OPTARG requires a table as an argument." >&2
      fail
      ;;
    esac
  done

shift $((OPTIND-1))

[[ $gpg_url ]] || { echo "gpg_url is required" >&2; fail; }

#TODO: bash 3
case "${ID,,}" in
  'redhat'|'rhel'|'sles'|'fedora'|'centos')
    rpm --import "$gpg_url" || fail "Error installing $gpg_url"
    ;;
  'debian'|'ubuntu')
    # Required by gnupg
    type dirmngr &>/dev/null || {
        DEBIAN_FRONTEND=noninteractive apt-get install -y dirmngr >/dev/null || {
        fail "Error installing dirmngr"
      }
    }
    find /etc/apt/trusted.gpg.d/ -ls
    apt-key adv --fetch-keys "$gpg_url" >/dev/null || {
      fail "Error installing $gpg_url"
    }
  ;;
  *)
    echo "Unsupported platform $ID" >&2
    fail
esac

success "{ \"result\": \"Installed key $gpg_url\" }"
