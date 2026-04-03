# 🚀 QUICK REFERENCE - Docker Build Pipeline Setup

## Files Created (8 total)

```
✅ Dockerfile              - Nginx with custom message
✅ docker-compose.yml      - Docker Compose config
✅ azure-pipelines.yml     - Azure DevOps CI/CD pipeline
✅ dockerimage-readme.md   - Complete 25-section guide
✅ ADO-SETTINGS-GUIDE.md   - Azure DevOps setup & security
✅ QUICKSTART.md          - 1-page quick start
✅ SETUP-SUMMARY.md       - Overview & architecture
✅ .dockerignore/.gitignore - Git & Docker exclusions
```

---

## ⏱️ 5-Step Quick Start (15 minutes)

### 1️⃣ Setup Service Connection (5 min)
```
https://dev.azure.com/balajigv/App-Project
→ Project Settings → Service connections → New → Docker Registry

Name: DockerHubServiceConnection
ID: 1601071
Password: <docker_hub_password>
✓ Grant access to all pipelines
```

### 2️⃣ Push to Repository (2 min)
```powershell
cd c:\Users\balaj\working
git add .
git commit -m "Add Docker pipeline setup"
git push origin main
```

### 3️⃣ Create Pipeline (3 min)
```
https://dev.azure.com/balajigv/App-Project/_build
→ New pipeline → Azure Repos Git → application 
→ Existing YAML → /azure-pipelines.yml → Save and run
```

### 4️⃣ Monitor Build (2-3 min)
```
Watch pipeline run → All stages turn green ✅
Check Docker Hub: https://hub.docker.com/r/1601071/balaji_hub
```

### 5️⃣ Test Image (3 min)
```bash
docker pull 1601071/balaji_hub:latest
docker run -d -p 8080:80 1601071/balaji_hub:latest
curl http://localhost:8080  # See custom message! ✅
```

---

## 📖 Documentation Map

| Need | Read This | Time |
|------|-----------|------|
| Get started ASAP | **QUICKSTART.md** | 5 min |
| Understand everything | **SETUP-SUMMARY.md** | 10 min |
| Configure Azure DevOps | **ADO-SETTINGS-GUIDE.md** | 15 min |
| Complete reference | **dockerimage-readme.md** | 30 min |
| See how it works | **azure-pipelines.yml** | 10 min |

---

## 🎯 What Happens When You Push Code

```
You: git push origin main
         ↓
Azure DevOps: Detects changes
         ↓
Pipeline Triggers: Automatically
         ↓
Build Stage:
  1. Pull nginx:latest
  2. Add custom message
  3. Build Docker image
  4. Login to Docker Hub
  5. Push image → 1601071/balaji_hub
  6. Tag: build ID + latest
  7. Logout
         ↓
Verify Stage:
  1. Confirm push successful
  2. Display image info
         ↓
Result: Image available on Docker Hub ✅
```

---

## 🛠️ Essential Commands

### Build Locally
```bash
docker build -t 1601071/balaji_hub:latest .
```

### Run Container
```bash
docker run -d -p 8080:80 1601071/balaji_hub:latest
```

### Test
```bash
curl http://localhost:8080
```

### Push to Registry
```bash
docker login
docker push 1601071/balaji_hub:latest
```

### Using Docker Compose
```bash
docker-compose up -d
docker-compose ps
docker-compose logs -f
docker-compose down
```

---

## ✅ Success Indicators

- [ ] Service connection shows "Test connection successful"
- [ ] Pipeline shows all green checkmarks
- [ ] Image appears on Docker Hub with tags
- [ ] Can pull: `docker pull 1601071/balaji_hub:latest`
- [ ] Container serves custom nginx page on port 8080
- [ ] Message shows: "This is nginx server image customized by balajigv"

---

## 🔧 Configuration Details

```
Image Base:        nginx:latest
Custom Message:    "nginx server image customized by balajigv"
Port:              80 (internal) → 8080 (external)
Repository:        docker.io/1601071/balaji_hub
Tags:              latest, <build_id>
Registry:          Docker Hub
Credentials:       ADO Service Connection (SecureVault)
Pipeline Level:    All branches (main, develop)
```

---

## ❓ Quick Troubleshooting

```
Service connection fails?
→ Verify Docker ID and password at Docker Hub

Build fails?
→ Check azure-pipelines.yml logs for errors
→ See dockerimage-readme.md Troubleshooting section

Cannot pull image?
→ Check if image pushed successfully
→ Verify credentials
→ Ensure image is public on Docker Hub

Port 8080 in use?
→ Use different port: docker run -p 9090:80 ...
```

---

## 📋 Status Tracking

**Current State:**
- ✅ Dockerfile created
- ✅ docker-compose.yml created
- ✅ azure-pipelines.yml created
- ✅ Documentation complete
- ⏳ **Next: Create Service Connection**
- ⏳ **Next: Push files and create pipeline**
- ⏳ **Next: Run first build**

---

## 🚀 After Setup Complete

1. Every push to `main`/`develop` auto builds & pushes
2. Share image: `docker pull 1601071/balaji_hub:latest`
3. Find improvements in SETUP-SUMMARY.md section "Next Level Improvements"
4. Monitor builds at: https://dev.azure.com/balajigv/App-Project/_build

---

**Time to First Success: ~15 minutes** ⏱️

Start with **Step 1: Setup Service Connection** above!
