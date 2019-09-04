#!/bin/bash

declare PT__installdir
source "$PT__installdir/facts/tasks/bash.sh" >/dev/null || {
  echo "The puppetlabs-facts module is required" >&2
  fail
}
source "$PT__installdir/repo_tasks/files/common.sh"

shopt -s nocasematch

[[ $repo_url ]] || { echo "repo_url is required" >&2; fail; }

case "$ID" in
  'redhat'|'rhel')
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
      DEBIAN_FRONTEND=noninteractive apt-get install -y $extra_args software-properties-common >/dev/null
    }

    # This may result in a duplicate src line in sources.list, but should be ok
    add-apt-repository "$repo_url" &>"$_tmp" || { echo "Error installing repo" >&2; fail; }
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
