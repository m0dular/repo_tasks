#!/usr/bin/env bash

# Source scripts under the root of the module.  Works regardless of where we are called from
base_dir="${BASH_SOURCE[0]%/*}"

source "$base_dir/../files/common.sh"
source "$base_dir/../puppetlabs-facts/tasks/bash.sh" >/dev/null || {
  echo "The puppetlabs-facts module is required" >&2
  echo "Please clone this repo with --recurse-submodules"
  fail
}

while getopts ":r:" opt; do
  case "$opt" in
    r)
      repo_url="$OPTARG"
      ;;
    :)
      echo "Option -$OPTARG requires a table as an argument." >&2
      fail
      ;;
    esac
  done

shift $((OPTIND-1))

[[ $repo_url ]] || { echo "repo_url is required" >&2; fail; }

case "$ID" in
  'redhat'|'rhel'|'centos'|'fedora')
    # rpm exits 1 if the package is already installed
    rpm $extra_args -i "$repo_url" || {
      grep -q "already installed" "$_tmp" || {
        echo "Error installing $repo_url" >&2
        fail
      }
    }
    ;;
  'debian'|'ubuntu')
    type add-apt-repository &>/dev/null || {
      # On a fresh box we may need to run an update first.  If it fails we won't be able install anything anyway.
      apt-get update || fail
      DEBIAN_FRONTEND=noninteractive apt-get install -y $extra_args software-properties-common >/dev/null
    }

    # This may result in a duplicate src line in sources.list, but should be ok
    sudo add-apt-repository "$repo_url" &>"$_tmp" || { echo "Error installing repo" >&2; fail; }
    # Not all versions of add-apt-repository have the --update flag
    apt-get update >/dev/null
    ;;
  'sles'|'suse'|'opensuse')
    zypper -nqt $extra_args ar "$repo_url" "$name" >/dev/null || { echo "Error installing repo" >&2; fail; }
    ;;
  *)
    echo "Unsupported platform $ID" >&2
    fail
esac

success "{ \"result\": \"Installed repo $repo_url\" }"
