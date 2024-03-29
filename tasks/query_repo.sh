#!/bin/bash

declare PT__installdir
source "$PT__installdir/facts/tasks/bash.sh" >/dev/null || {
  echo "The puppetlabs-facts module is required" >&2
  fail
}
source "$PT__installdir/repo_tasks/files/common.sh"

shopt -s nullglob nocasematch

[[ $name ]] || { echo "name is a required parameter" >&2; fail; }

case "$ID" in
  'redhat'|'rhel'|'centos'|'fedora')
    while IFS= read -r line; do
      line="$(echo "$line" | tr -s ' ')"
      repos+=(\""$line"\")
    done < <(yum -q repolist "*$name*" | sed 1d)
    ;;

  'debian'|'ubuntu')
    while IFS= read -r line; do
      repos+=("\"$line\"")
    done < <(grep -hvE '^[[:space:]]*(#|$)' /etc/apt/sources.list /etc/apt/sources.list.d/* | \
      grep -i "$name" | sort -u)
    ;;

  'sles'|'suse'|'opensuse')
    _tmp_sles="$(mktemp)"
    zypper -q lr | sed '/^\s*$/d' >"$_tmp_sles"
    repos+=("\"$(sed -n 1p $_tmp_sles)\"")
    repos+=("\"$(sed -n 2p $_tmp_sles)\"")

    while IFS= read -r line; do
      repos+=("\"$line\"")
    done < <(grep "$name" "$_tmp_sles")

    # Don't return the head if we didn't match
    (( ${#repos[@]} == 2 )) && repos=()
    ;;

  *)
    echo "Unsupported platform $ID" >&2
    fail
esac

success "$(IFS=,; printf '{"repos": [%s]}' "${repos[*]}")"
