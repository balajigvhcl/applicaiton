# Azure DevOps Settings Configuration Guide

## 🎯 Required ADO Configurations for Docker Pipeline

### 1. Service Connection Setup ⭐ (REQUIRED)

Navigate to: **Project Settings** → **Service connections**

#### Create Docker Registry Connection

1. Click **New service connection**
2. Select **Docker Registry**
3. Fill in the following:

```
Connection name: DockerHubServiceConnection
Docker registry: https://index.docker.io/v1/
Docker ID: 1601071
Docker password: <your_docker_hub_password_or_token>
```

4. **Check:** "Grant access permission to all pipelines"
5. Click **Save**

✅ **Why:** Enables secure authentication to Docker Hub from the pipeline

---

### 2. Repository Settings

Navigate to: **Repository** → **Settings** (within application repo)

#### Security Settings
```
☑ Allow contributors to create branches
☑ Automatically link work items mentioned in pull requests
☑ Notify pull request creators
☑ Enforce a merge strategy: Squash merge (Recommended)
```

#### Default Branch
```
Default branch: main
```

✅ **Why:** Ensures proper branching strategy and pull request workflow

---

### 3. Build Pipeline Settings

Navigate to: **Pipelines** → **Settings**

#### YAML Pipeline Settings
```
☑ Make secrets available to builds of forks: ☐ (Leave UNCHECKED)
☑ Make secrets available to builds of pull requests from forks: ☐ (Leave UNCHECKED)
☑ Enable resource validation for all YAML pipelines: ☑ (CHECK)
☑ Protect access to repositories in GitHub: Auto-injected (if using GitHub)
```

#### Queue and Timeline
```
Log lines to include: 1000
Verbosity: 1
```

✅ **Why:** Maintains security by not exposing secrets in forked builds

---

### 4. Retention Policy

Navigate to: **Pipelines** → **Settings** → **Retention**

#### Build Retention
```
Artifacts retention (days): 30
Pull request retention (days): 10
Branches retention (days): 30
```

✅ **Why:** Keeps storage costs low and maintains audit trail

---

### 5. Branch Policies (Optional but Recommended)

Navigate to: **Repos** → **Branches** → **main** → **Branch policies**

#### Policy Settings
```
☑ Require a minimum number of reviewers: 1
☑ Allow completion with active comments: ☐ (UNCHECKED)
☑ Require code reviews before completion: ☑ (CHECKED)
☑ Automatically include code reviewers
☑ Dismiss stale pull request reviews when new commits are pushed
☑ Require an associated work item
☑ Build validation: Enable (Select your pipeline)
☑ Status checks: Require (if using GitHub)
```

✅ **Why:** Ensures code quality and security before deployment

---

### 6. Agent Pool Configuration

Navigate to: **Project Settings** → **Agent pools**

#### For Public Projects
```
Pool: Azure Pipelines (Default)
Role: Hosted agents
OS: Linux (ubuntu-latest)
```

#### For Private Projects (if using self-hosted)
```
Pool: Default / Custom Pool Name
Agents: At least 2 agents for redundancy
Docker: Installed and configured
```

⚠️ **For Self-Hosted Agents:**
```bash
# Add Docker group permissions
sudo usermod -aG docker azpagent

# Add docker.sock permissions
sudo chmod 666 /var/run/docker.sock
```

✅ **Why:** Ensures pipeline has necessary Docker capabilities

---

### 7. Variable Groups (Optional)

Navigate to: **Pipelines** → **Library** → **Variable groups**

#### Create Variable Group: `DockerVariables`

```
Name: DockerVariables
Variables:
  - dockerRegistryServiceConnection = DockerHubServiceConnection
  - imageRepository = 1601071/balaji_hub
  - containerRegistry = docker.io
  - dockerfilePath = Dockerfile
```

Then in `azure-pipelines.yml`:
```yaml
variables:
  - group: DockerVariables
```

✅ **Why:** Centralizes configuration for reuse across multiple pipelines

---

### 8. Secrets Management

#### Using Azure Key Vault (Recommended for Production)

1. Navigate to: **Project Settings** → **Service connections**
2. Create **Azure Resource Manager** service connection
3. Store Docker credentials in Key Vault
4. Link in pipeline:

```yaml
variables:
  - group: 'KeyVaultVariables'

steps:
  - task: Docker@2
    inputs:
      containerRegistry: $(dockerRegistryServiceConnection)
      # Credentials pulled from Key Vault
```

#### Current Setup (Basic)
```
Service Connection: DockerHubServiceConnection
Credentials stored in: ADO Secrets vault
Accessible to: Linked pipeline only
```

✅ **Why:** Encrypts credentials at rest and in transit

---

### 9. Pipeline Naming and Folders

Navigate to: **Pipelines**

#### Organize Pipelines
```
Create folder: Docker
Created pipeline: docker-build-push

Naming convention:
- Format: <service>-<action>
- Example: nginx-build-push
```

✅ **Why:** Makes it easy to find and manage related pipelines

---

### 10. Notifications (Optional)

Navigate to: **Project Settings** → **Notifications**

#### Setup Build Alerts

1. Click **New subscription**
2. Select **Build completion** 
3. Set filters:
   - Pipeline: Your Docker pipeline
   - Branch: main
   - Status: Failed
4. Click **Finish**

✅ **Why:** Alerts you when builds fail

---

### 11. Required Permissions

Ensure your user account has:

```
✑ Project: Contributor (minimum)
✑ Service connections: Creator, Administrator
✑ Build: Edit, Queue
✑ Release: Create, Manage
```

View permissions: **Project Settings** → **Security** → **Users**

---

### 12. Personal Access Token (For CLI Use)

If using Azure DevOps CLI or local authentication:

1. Click **User profile** → **Personal access tokens**
2. Click **New Token**
3. Set:
   - Name: `docker-build-token`
   - Scopes: Build (Read & Execute), Release (Read, Create & Manage)
   - Expiration: 90 days (recommended)
4. Copy token (shown only once)

```bash
# Use token in CLI
az pipelines build queue --project App-Project --token <PAT>
```

✅ **Why:** Required for authenticated CLI operations

---

## 🔄 Verification Checklist

After configuring ADO, verify:

- [ ] Service connection `DockerHubServiceConnection` exists and is tested
- [ ] Pipeline `azure-pipelines.yml` is created
- [ ] Pipeline triggers on `main` and `develop` branches
- [ ] Branch policy for `main` is configured (if needed)
- [ ] Agent pool has Docker installed
- [ ] First build ran successfully
- [ ] Image pushed to Docker Hub
- [ ] Retention policy is set to reasonable values
- [ ] Notifications are configured for build failures

---

## 🚀 Recommended ADO Settings Summary

### For Development Team
```yaml
Branching Strategy: Git Flow (main/develop/feature branches)
Build Validation: Enabled on main
Review Policy: 1 minimum reviewer
Build Retention: 30 days
Agent Pool: Azure Pipelines (ubuntu-latest)
Secrets: ADO Service Connections
Notifications: Build failures only
```

### For Production
```yaml
Branching Strategy: Git Flow with release branches
Build Validation: Enabled on all protected branches
Review Policy: 2 minimum reviewers
Deployment Gates: Manual approval required
Build Retention: 90 days
Agent Pool: Self-hosted (secured network)
Secrets: Azure Key Vault
Notifications: All pipeline events
Audit: Enable and review regularly
```

---

## ⚠️ Security Best Practices

### DO ✅
- Use service connections for all authentication
- Store passwords/tokens in ADO secrets, not in YAML
- Use least-privilege access for agents
- Enable branch protection on main
- Rotate tokens every 90 days
- Use PAT instead of passwords
- Enable audit logging

### DON'T ❌
- Hardcode credentials in YAML files
- Use personal passwords in service connections
- Store secrets in variables without encryption
- Allow public builds to access secrets
- Share PAT tokens across users
- Disable branch policies

---

## 📞 Quick Support

| Issue | Solution |
|-------|----------|
| Service connection fails | Test connection, verify credentials, check Docker Hub login |
| Build agent offline | Check agent pool health, restart agent service |
| Pipeline not triggering | Check branch policy YAML path, verify branch trigger |
| Permission denied | Check user role in Project Settings → Security |
| Docker auth fails | Recreate service connection, verify Docker ID/password |

---

## 📚 Links

- **Azure DevOps Docs:** https://docs.microsoft.com/azure/devops/
- **Pipelines Documentation:** https://docs.microsoft.com/azure/devops/pipelines/
- **Docker Task:** https://docs.microsoft.com/azure/devops/pipelines/tasks/build/docker
- **Service Connections:** https://docs.microsoft.com/azure/devops/pipelines/library/service-endpoints

---

**Last Updated:** 2026-04-03  
**Project:** app-project  
**Configuration Status:** Ready
