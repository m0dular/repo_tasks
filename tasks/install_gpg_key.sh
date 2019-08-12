#!/bin/bash

declare PT__installdir
source "$PT__installdir/facts/tasks/bash.sh" >/dev/null || {
  echo "The puppetlabs-facts module is required" >&2
  fail
}
source "$PT__installdir/repo_tasks/files/common.sh"

[[ $gpg_url ]] || { echo "gpg_url is required" >&2; fail; }

case "${ID,,}" in
  'redhat'|'rhel'|'sles'|'fedora')
    rpm --import "$gpg_url" || fail "Error installing $gpg_url"
    ;;
  'debian'|'ubuntu')
    # Required by gnupg
    type dirmngr &>/dev/null || {
        DEBIAN_FRONTEND=noninteractive apt-get install -y dirmngr >/dev/null || {
        fail "Error installing dirmngr"
      }
    }
    apt-key adv --fetch-keys "$gpg_url" >/dev/null || {
      fail "Error installing $gpg_url"
    }
  ;;
  *)
    echo "Unsupported platform $ID" >&2
    fail
esac

success "{ \"result\": \"Installed key $gpg_url\" }"
