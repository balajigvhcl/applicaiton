# 🧾 Ansible Pipeline – Errors & Fixes Guide

---

## 🚫 1. Playbook Not Found

**❌ Error**
```
ERROR! the playbook: house.yml could not be found
```

**🔍 Cause**
- Playbook path not defined correctly in pipeline
- Pipeline agent doesn’t know file location

**✅ Fix**
- Use absolute path OR correct relative path
- Ensure repo is checked out in pipeline

**💡 Example**
```
ansible-playbook /root/book/house.yml
```

---

## 🚫 2. Playbook Skipped (No Hosts Matched)

**❌ Error**
```
[WARNING]: Could not match supplied host pattern
skipping: no hosts matched
```PLAY [Deploy and run var housekeeping script] **********************************
skipping: no hosts matched

**🔍 Cause**
- Inventory mismatch
- Hardcoded IP in YAML but not passed correctly

**✅ Fix**
- Ensure correct inventory or dynamic host input
- Use:
```
-i "192.168.0.104,"
```

---

## 🚫 3. Undefined Variable

**❌ Error**
```
'script_url' is undefined
```fatal: [clientnode]: FAILED! => {"msg": "The task includes an option with an undefined variable. The error was: 'script_url' is undefined. 'script_url' is undefined\n\nThe error appears to be in '/tmp/_work/1/s/playbooks/house.yml': line 12, column 7, but may\nbe elsewhere in the file depending on the exact syntax problem.\n\nThe offending line appears to be:\n\n  tasks:\n    - name: Download script from github repoistory\n      ^ here\n"}


**🔍 Cause**
- Variable name mismatch in YAML

**✅ Fix**
- Ensure consistency:
```
script_url: ...
```
OR
```
script_src: ...
```

---

## 🚫 4. Script Execution Format Error

**❌ Error**
```
Exec format error: /tmp/housekeep.sh
```fatal: [clientnode]: FAILED! => {"changed": false, "cmd": "/tmp/housekeep.sh dryrun", "msg": "[Errno 8] Exec format error: b'/tmp/housekeep.sh'", "rc": 8, "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}


**🔍 Cause**
- HTML downloaded instead of script
- Wrong GitHub URL (`blob` instead of `raw`)

**✅ Fix**
Use RAW URL:
```
https://raw.githubusercontent.com/balajigvhcl/application/feature-linuxvm-ansible-deploy/scripts/housekeep.sh
```

---

## 🚫 5. Sudo Password Error

**❌ Error**
```
Missing sudo password
```fatal: [clientnode]: FAILED! => {"msg": "Missing sudo password"}


**🔍 Cause**
- Pipeline user lacks sudo privileges

**✅ Fix**
Grant passwordless sudo:
```
devops ALL=(ALL) NOPASSWD: ALL
```

---

## 🚫 6. SSH Permission Denied

**❌ Error**
```
Permission denied (publickey)
```fatal: [clientnode]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: test-jenkins@192.168.0.104: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).", "unreachable": true}


**🔍 Cause**
- SSH key not configured

**✅ Fix**
Add public key to:
```
~/.ssh/authorized_keys
```

---

## 🚫 7. SSH Broken Pipe / Unreachable

**❌ Error**
```fatal: [clientnode]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: Warning: Permanently added '192.168.0.104' (ED25519) to the list of known hosts.\r\nssh_dispatch_run_fatal: Connection to 192.168.0.104 port 22: Broken pipe", "unreachable": true}

ssh_dispatch_run_fatal: Broken pipe
```

**🔍 Cause**
- No proper SSH trust setup

**✅ Fix**
Verify connection:
```
ssh user@host
```

---

# ✅ Prerequisites Before Running Pipeline

## 🔑 Access & Authentication
- SSH access from control node → target
- Public key configured
- No password prompts

## 🛠️ Environment Setup
- Ansible installed on pipeline agent
- Python available on target nodes
- SSH port (22) open

## 📁 Files & Repo
- `house.yml` present in repo
- Script path correct
- Pipeline includes:
```
- checkout: self
```

## 🔐 Permissions
- Script executable:
```
chmod +x housekeep.sh
```
- User has sudo access

---

# ⚙️ YAML & Pipeline Best Practices

## ✅ Keep Playbook Generic
```
hosts: all
```

## ✅ Use Dynamic Targeting
```
ansible-playbook house.yml -i "$(SERVER_IP)," -e "action=$(action)"
```

## ✅ Variable Syntax
| Wrong | Correct |
|------|--------|
| ${var} | $(var) |

## ✅ Debug Commands
```
pwd
ls -l
find . -name "house.yml"
```

## ✅ Validate Downloads
```
curl -s <url> | head
```

---

# 🚀 Suggestions & Improvements

## 🔥 Safety
- Run `dryrun` first

## 🔥 Reliability
- Use `bash script.sh`
- Validate script content

## 🔥 Maintainability
- Avoid hardcoded IPs

## 🔥 Pipeline Design
- Parameterize:
  - SERVER_IP
  - ACTION

---

# 🧠 Summary

✔ Common issues:
- Wrong paths
- Wrong GitHub URLs
- SSH / permission issues  

✔ Key concept:
- Pipeline → where to run  
- Ansible → what to run  

✔ Golden rules:
- Validate everything
- Use dryrun first
- Ensure SSH + sudo readiness
