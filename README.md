WIP

# repo_tasks

A set of Bolt Tasks to install and query repositories.  Currently supported platforms are

*  Debian/Ubuntu
*  SLES/OpenSuSe
*  EL (RedHat, CentOS, Fedora)

## Usage

### install_repo

```
bolt task run --targets <node-name> repo_tasks::install_repo repo_url=<value> name=<value> extra_args=<value>

PARAMETERS:
- repo_url: Any
    URL of the repo to install
- name: Optional[String[1]]
    Optional name for repository managers that support it
- extra_args: Any
    Extra arguments to pass to the underlying package manager
```

```
$ bolt task run repo_tasks::install_repo --targets tired-saloon.delivery.puppetlabs.net repo_url=https://yum.puppetlabs.com/puppet-release-el-7.noarch.rpm

Started on tired-saloon.delivery.puppetlabs.net...
Finished on tired-saloon.delivery.puppetlabs.net:
  {
    "result": "Installed repo https://yum.puppetlabs.com/puppet-release-el-7.noarch.rpm"
  }
Successful on 1 node: tired-saloon.delivery.puppetlabs.net
Ran on 1 node in 1.9 sec
```

### query_repo

```
bolt task run --targets <node-name> repo_tasks::query_repo name=<value>

PARAMETERS:
- name: Any
    Name of the repo to query for
```

```
$ bolt task run repo_tasks::query_repo --targets tired-saloon.delivery.puppetlabs.
net name=puppet
Started on tired-saloon.delivery.puppetlabs.net...
Finished on tired-saloon.delivery.puppetlabs.net:
  {
    "repos": [
      "puppet/x86_64 Puppet Repository el 7 - x86_64 159"
    ]
  }
Successful on 1 node: tired-saloon.delivery.puppetlabs.net
Ran on 1 node in 4.21 sec
```

### install_gpg_key
```
bolt task run --targets <node-name> repo_tasks::install_gpg_key gpg_url=<value>

PARAMETERS:
- gpg_url: Any
    URL of the key to install
```

```
$ bolt task run repo_tasks::install_gpg_key --targets tired-saloon.delivery.puppet
labs.net gpg_url=https://apt.puppetlabs.com/pubkey.gpg
Started on tired-saloon.delivery.puppetlabs.net...
Finished on tired-saloon.delivery.puppetlabs.net:
  {
    "result": "Installed key https://apt.puppetlabs.com/pubkey.gpg"
  }
Successful on 1 node: tired-saloon.delivery.puppetlabs.net
Ran on 1 node in 1.15 sec
```
