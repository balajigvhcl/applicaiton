# Quick Start Guide - Docker Image Setup

## 📋 Files Created

✅ **Dockerfile** - Nginx image with custom message  
✅ **docker-compose.yml** - Docker Compose configuration  
✅ **azure-pipelines.yml** - Azure DevOps pipeline  
✅ **dockerimage-readme.md** - Complete documentation  

---

## ⚡ Quick Start Steps

### 1️⃣ Push Files to Repository

```bash
cd c:\Users\balaj\working
git add Dockerfile docker-compose.yml azure-pipelines.yml dockerimage-readme.md
git commit -m "Add Docker image build and Azure Pipeline configuration"
git push origin main
```

### 2️⃣ Create Docker Hub Service Connection (One-time Setup)

1. Go to: https://dev.azure.com/balajigv/App-Project
2. **Project Settings** → **Service connections**
3. **New service connection** → **Docker Registry**
4. Fill in:
   - **Connection name:** `DockerHubServiceConnection`
   - **Docker registry:** `https://index.docker.io/v1/`
   - **Docker ID:** `1601071`
   - **Docker password:** Your Docker Hub password
5. Check **Grant access permission to all pipelines**
6. Click **Save**

### 3️⃣ Create the Pipeline

1. Go to: https://dev.azure.com/balajigv/App-Project/_build
2. Click **New pipeline**
3. Select **Azure Repos Git** → **application** repository
4. Select **Existing Azure Pipelines YAML file** → `/azure-pipelines.yml`
5. Click **Save and run**

### 4️⃣ Monitor the Build

- Pipeline will automatically build the Docker image
- Push it to: `docker.io/1601071/balaji_hub`
- Check Docker Hub for the published image

### 5️⃣ Test the Image

```bash
# Pull image from Docker Hub
docker pull 1601071/balaji_hub:latest

# Run container
docker run -d -p 8080:80 1601071/balaji_hub:latest

# Test
curl http://localhost:8080
```

---

## 📊 What the Pipeline Does

| Stage | Action |
|-------|--------|
| **Build** | Builds Docker image from Dockerfile |
| **Login** | Authenticates with Docker Hub |
| **Push** | Pushes image with build ID and "latest" tags |
| **Logout** | Securely disconnects |
| **Verify** | Confirms successful push |

---

## 🐳 Docker Commands for Testing

```bash
# Build locally
docker build -t 1601071/balaji_hub:latest .

# Run locally
docker run -it -p 8080:80 1601071/balaji_hub:latest

# Test with curl
curl http://localhost:8080

# Stop container
docker stop <container_id>

# Using Docker Compose
docker-compose up -d
docker-compose logs -f
docker-compose down
```

---

## 🔒 Azure DevOps Security Settings (Recommended)

### Protect Main Branch
**Pipelines** → **Branch policies** (if using Git):
```
✓ Require pull request review
✓ Require minimum reviewers: 1
✓ Require work item linking
✓ Require comment resolution
```

### Service Connection Security
- Credentials are stored securely in Azure DevOps vault
- Limited to service connection access only
- Consider using Personal Access Token (PAT) instead of password for better security

### Pipeline Secrets
```yaml
# In azure-pipelines.yml (already configured)
- task: Docker@2
  inputs:
    containerRegistry: $(dockerRegistryServiceConnection)  # Secure reference
```

---

## ✅ Verification Checklist

- [ ] Files committed and pushed to `main` branch
- [ ] Docker Hub service connection created
- [ ] Pipeline created and named in Azure DevOps
- [ ] First build completed successfully
- [ ] Image visible on Docker Hub: `docker.io/1601071/balaji_hub`
- [ ] Can pull: `docker pull 1601071/balaji_hub:latest`
- [ ] Container runs: `docker run -d -p 8080:80 1601071/balaji_hub:latest`
- [ ] Custom message displays when accessing `http://localhost:8080`

---

## 🚀 Next Builds

Every time you push to `main` or `develop` branch, the pipeline will:
1. Automatically trigger
2. Build the image
3. Push to Docker Hub with new tag
4. Keep `latest` tag updated

---

## 📞 Troubleshooting

| Problem | Solution |
|---------|----------|
| Service connection not found | Create it in Project Settings |
| Build fails to push | Check Docker ID and password in service connection |
| Port 8080 already in use | Use different port: `docker run -p 9090:80 ...` |
| Image not on Docker Hub | Check Azure DevOps pipeline logs for errors |
| Cannot pull image | Ensure image was successfully pushed (check Docker Hub) |

---

## 📚 Full Documentation

See **dockerimage-readme.md** for:
- Complete step-by-step instructions
- All Docker commands reference
- Dockerfile breakdown
- Pipeline YAML explanation
- Comprehensive troubleshooting guide

---

**Ready to go!** 🎉  
Push the files and create the service connection to get started.
