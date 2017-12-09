# fail2ban

[![Build Status](https://travis-ci.org/Oefenweb/ansible-fail2ban.svg?branch=master)](https://travis-ci.org/Oefenweb/ansible-fail2ban) [![Ansible Galaxy](http://img.shields.io/badge/ansible--galaxy-fail2ban-blue.svg)](https://galaxy.ansible.com/tersmitten/fail2ban)

Set up fail2ban in Debian-like systems.

## Requirements

None

## Variables

- `fail2ban_loglevel`: [default: `3`, or `INFO` in Ubuntu 16.04]: Sets the loglevel output (e.g. `1 = ERROR`, `2 = WARN`, `3 = INFO`, `4 = DEBUG`)
- `fail2ban_logtarget`: [default: `/var/log/fail2ban.log`]: Sets the log target. This could be a file, SYSLOG, STDERR or STDOUT
- `fail2ban_syslog_target`: [default: `/var/log/fail2ban.log`]:
- `fail2ban_syslog_facility`: [default: `1`]:
- `fail2ban_socket`: [default: `/var/run/fail2ban/fail2ban.sock`]: Sets the socket file, which is used to communicate with the daemon
- `fail2ban_pidfile`: [default: `/var/run/fail2ban/fail2ban.pid`]: Sets the pid file, which is used to to store the process ID of the daemon (Only works on `fail2ban >= 0.8.9`)

- `fail2ban_ignoreips`: [default: `[127.0.0.1/8]`]: Which IP address/CIDR mask/DNS host should be ignored from fail2ban's actions
- `fail2ban_bantime`: [default: `600`]: Sets the bantime
- `fail2ban_maxretry`: [default: `3`]: Maximum number of retries before the host is put into jail
- `fail2ban_findtime`: [default: `600`]: A host is banned if it has generated `fail2ban_maxretry` during the last `fail2ban_findtime`
- `fail2ban_backend`: [default: `auto`]: Specifies the backend used to get files modification
- `fail2ban_banaction`: [default: `iptables-multiport`]: Sets the global/default banaction
- `fail2ban_mta`: [default: `sendmail`]: Email action
- `fail2ban_protocol`: [default: `tcp`]: Sets the default protocol
- `fail2ban_chain`: [default: `INPUT`]: Specifies the chain where jumps would need to be added in iptables-* actions
- `fail2ban_action`: [default: `%(action_)s`]: Default action.  **Note that variables (including the actions defined elsewhere in the config files) must be wrapped in python-style `%(` and `)s` so they are expanded**
- `fail2ban_sendername`: [default: `Fail2ban`]: The 'from' name for emails sent by mta actions.  NB: Use `fail2ban_sender` to set the 'from' email address.
- `fail2ban_sender`: [optional]: The 'from' address for emails sent by mta actions.
- `fail2ban_filterd_path`: [optional]: Path to directory containing filters to copy (**note the trailing slash**)
- `fail2ban_actiond_path`: [optional]: Path to directory containing actions to copy (**note the trailing slash**)
- `fail2ban_jaild_path`: [optional]: Path to directory containing jails to copy (**note the trailing slash**)

- `fail2ban_services` [default see `defaults/main.yml`]: Service definitions
- `fail2ban_services.{n}.name` [required]: Service name (e.g. `ssh`)
- `fail2ban_services.{n}.enabled` [default: `true`]: Whether or not enabled
- `fail2ban_services.{n}.*` [optional]: Name of the option
- `fail2ban_services.{n}.*.*` [optional]: Value of the option

## Dependencies

None

## Example(s)

### Simple

```yaml
---
- hosts: all
  roles:
    - fail2ban
```

### Enable sshd filter (with non-default settings)

```yaml
---
- hosts: all
  roles:
    - fail2ban
  vars:
    fail2ban_services:
      # In Ubuntu 16.04 this is sshd
      - name: ssh
        port: 2222
        maxretry: 5
        bantime: -1
```

### Add custom filters (from outside the role)

```yaml
---
- hosts: all
  roles:
    - fail2ban
  vars:
    fail2ban_filterd_path: ../../../files/fail2ban/etc/fail2ban/filter.d/
    fail2ban_services:
      - name: apache-wordpress-logins
        port: http,https
        filter: apache-wordpress-logins
        logpath: /var/log/apache2/access.log
        maxretry: 5
        findtime: 120
```

## License

MIT

## Author Information

Mischa ter Smitten (based on work of [ANXS](https://github.com/ANXS))

## Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/Oefenweb/ansible-fail2ban/issues)!
