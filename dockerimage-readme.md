# Docker Image Creation, Build, and Push Guide

## Overview
This document provides complete instructions for creating a customized nginx Docker image, building it, and publishing it to Docker Hub (artifactory).

**Project:** app-project  
**Repository:** 1601071/balaji_hub  
**Base Image:** nginx:latest  
**Custom Message:** "This is nginx server image customized by balajigv, under app-project"

---

## Table of Contents
1. [Local Setup and Manual Build](#local-setup-and-manual-build)
2. [Azure DevOps Pipeline Setup](#azure-devops-pipeline-setup)
3. [Running the Pipeline](#running-the-pipeline)
4. [Verification and Testing](#verification-and-testing)
5. [Troubleshooting](#troubleshooting)

---

## Local Setup and Manual Build

### Prerequisites
- Docker installed and running
- Docker Hub account (1601071)
- Azure DevOps access
- Git configured

### Step 1: Clone the Repository

```bash
# Clone the application repository
git clone https://dev.azure.com/balajigv/App-Project/_git/application
cd application
```

### Step 2: Verify Dockerfile

The `Dockerfile` contains:
```dockerfile
FROM nginx:latest
WORKDIR /usr/share/nginx/html
RUN echo "<h1>This is nginx server image customized by balajigv, under app-project</h1>" > index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Step 3: Pull the Base Nginx Image

```bash
# Pull the official nginx image
docker pull nginx:latest
```

### Step 4: Build the Docker Image Locally

```bash
# Build the image with tag
docker build -t 1601071/balaji_hub:latest -f Dockerfile .

# Or with specific version tag
docker build -t 1601071/balaji_hub:v1.0 -f Dockerfile .
```

### Step 5: Verify the Image

```bash
# List local images
docker images | grep balaji_hub

# Check image details
docker image inspect 1601071/balaji_hub:latest
```

### Step 6: Test the Image Locally

```bash
# Run the container
docker run -d -p 8080:80 --name test-nginx 1601071/balaji_hub:latest

# Check if container is running
docker ps

# Test the nginx server
curl http://localhost:8080

# Stop the container
docker stop test-nginx
docker rm test-nginx
```

### Step 7: Login to Docker Hub

```bash
# Authenticate with Docker Hub
docker login

# When prompted, enter:
# Username: 1601071
# Password: <your_docker_hub_password>
```

### Step 8: Push Image to Docker Hub

```bash
# Push the image
docker push 1601071/balaji_hub:latest

# Or push specific version
docker push 1601071/balaji_hub:v1.0
```

### Step 9: Verify Published Image

```bash
# Verify image in Docker Hub
# Visit: https://hub.docker.com/r/1601071/balaji_hub

# Pull from Docker Hub to test
docker pull 1601071/balaji_hub:latest

# Run and verify
docker run -d -p 8080:80 1601071/balaji_hub:latest
curl http://localhost:8080
```

---

## Azure DevOps Pipeline Setup

### Step 1: Create Docker Hub Service Connection in Azure DevOps

1. Navigate to your Azure DevOps project:
   ```
   https://dev.azure.com/balajigv/App-Project
   ```

2. Go to **Project Settings** → **Service connections**

3. Click **New service connection** and select **Docker Registry**

4. Fill in the details:
   - **Registry type:** Docker Hub
   - **Connection name:** `DockerHubServiceConnection`
   - **Docker registry:** `https://index.docker.io/v1/`
   - **Docker ID:** `1601071`
   - **Docker password:** `<your_docker_hub_password>`
   - **Check:** "Grant access permission to all pipelines"

5. Click **Save**

### Step 2: Add Pipeline Files to Repository

Ensure the following files are in your repository root:

```
application/
├── Dockerfile
├── docker-compose.yml
├── azure-pipelines.yml
├── dockerimage-readme.md (this file)
└── ... (other project files)
```

### Step 3: Create/Update Pipeline in Azure DevOps

1. Navigate to **Pipelines** → **Create New Pipeline**

2. Select:
   - **Where is your code?** → Azure Repos Git
   - **Repository:** application
   - **Configuration:** Existing Azure Pipelines YAML file
   - **Path:** `/azure-pipelines.yml`

3. Click **Continue**

4. Review the pipeline YAML and click **Save and run**

---

## Running the Pipeline

### Automatic Trigger

The pipeline runs automatically when:
- Code is pushed to `main` branch
- Code is pushed to `develop` branch
- Pull requests are created on `main` branch

### Manual Trigger

1. Go to **Pipelines** in your Azure DevOps project
2. Select the pipeline you created
3. Click **Run pipeline**
4. Select the branch and click **Run**

### Pipeline Stages

1. **Build_and_Push Stage:**
   - Builds the Docker image
   - Logs into Docker Hub
   - Pushes image with tags:
     - `$(Build.BuildId)` (unique build ID)
     - `latest` (always updated)
   - Logs out from Docker Hub

2. **Verify Stage:**
   - Verifies the image was published successfully
   - Displays image details and pull command

---

## Verification and Testing

### Monitor Pipeline Execution

```bash
# View pipeline status in Azure DevOps
https://dev.azure.com/balajigv/App-Project/_build
```

### Check Image on Docker Hub

```bash
# Visit your repository
https://hub.docker.com/r/1601071/balaji_hub

# You should see:
# - latest tag
# - Build ID tags (e.g., 120, 121, etc.)
# - Pull history
```

### Pull and Test Published Image

```bash
# Pull the latest image
docker pull 1601071/balaji_hub:latest

# Run a container
docker run -it --rm -p 8080:80 1601071/balaji_hub:latest

# In another terminal, test
curl http://localhost:8080

# Expected output:
# <h1>This is nginx server image customized by balajigv, under app-project</h1>
```

### Docker Compose Testing

```bash
# Start service using docker-compose
docker-compose up -d

# Check service
docker-compose ps

# View logs
docker-compose logs -f

# Stop service
docker-compose down
```

---

## Azure DevOps Settings Configuration

### Required Settings and Configurations

#### 1. **Repository Settings**
- Ensure the `application` repository has the following files:
  - `Dockerfile`
  - `docker-compose.yml`
  - `azure-pipelines.yml`
  - `dockerimage-readme.md`

#### 2. **Service Connection Settings**
- Service connection name must be: `DockerHubServiceConnection`
- Keep credentials securely in Azure DevOps vault

#### 3. **Pipeline Settings**
```
✓ YAML pipeline is enabled
✓ Make secrets available to builds of forks: Disabled (security)
✓ Make secrets available to builds of pull requests from forks: Disabled (security)
✓ Enable resource validation for all YAML pipelines: Enabled
```

#### 4. **Recommended Security Settings**

In **Project Settings** → **Policies**:
```
✓ Require a minimum number of reviewers: 1
✓ Allow completion with active comments: Disabled
✓ Require code reviews before completion: Enabled
✓ Enforce a merge strategy: Squash merge
```

#### 5. **Variable Settings**

If using variable groups, create one named `DockerVariables`:

```
dockerRegistryServiceConnection = DockerHubServiceConnection
imageRepository = 1601071/balaji_hub
containerRegistry = docker.io
```

#### 6. **Build Pipeline Retention Policy**

In **Pipelines** → **Retention**:
```
Artifacts retention (days): 30
Pull request retention (days): 10
Branches retention (days): 30
```

#### 7. **Agent Pool Settings**

Ensure you're using the right agent pool:
- **For public projects:** `Azure Pipelines` (Hosted)
- **For private projects:** Use same if available, or self-hosted agent

---

## Dockerfile Breakdown

```dockerfile
# Use official nginx image as base
FROM nginx:latest

# Set working directory for web content
WORKDIR /usr/share/nginx/html

# Create custom index.html with your message
RUN echo "<h1>This is nginx server image customized by balajigv, under app-project</h1>" > index.html

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
```

---

## Docker Compose Breakdown

```yaml
version: '3.8'

services:
  nginx-custom:
    build:          # Build from Dockerfile
      context: .
      dockerfile: Dockerfile
    container_name: balaji-nginx-custom
    ports:
      - "8080:80"   # Map port 8080 to container's port 80
    environment:
      - APP_NAME=balaji_hub
      - PROJECT=app-project
    volumes:
      - ./html:/usr/share/nginx/html  # Mount local html directory
    networks:
      - app-network
    restart: unless-stopped
```

---

## Azure Pipeline YAML Breakdown

### Triggers
```yaml
trigger:
  - main
  - develop
```
Pipeline runs on changes to main and develop branches.

### Pool
```yaml
pool:
  vmImage: 'ubuntu-latest'
```
Uses Microsoft-hosted Ubuntu agent.

### Variables
- `dockerRegistryServiceConnection`: Name of service connection for authentication
- `imageRepository`: Docker Hub repository path
- `containerRegistry`: Docker Hub registry URL
- `tag`: Uses Build ID for unique tagging
- `latestTag`: Always updated to latest

### Build Stage
1. **Build Image**: Creates Docker image with specified tags
2. **Login**: Authenticates with Docker Hub using service connection
3. **Push**: Uploads image to Docker Hub repository
4. **Logout**: Securely disconnects from Docker Hub

### Verify Stage
- Confirms image was pushed successfully
- Displays pull command for users

---

## Useful Commands Reference

### Docker Commands

```bash
# Pull image
docker pull 1601071/balaji_hub:latest

# Run container
docker run -d -p 8080:80 1601071/balaji_hub:latest

# View logs
docker logs <container_id>

# Stop container
docker stop <container_id>

# Remove image
docker rmi 1601071/balaji_hub:latest

# List all images
docker images

# Build locally
docker build -t 1601071/balaji_hub:latest .

# Push to registry
docker push 1601071/balaji_hub:latest
```

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# View status
docker-compose ps

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild image
docker-compose build --no-cache
```

### Git Commands

```bash
# Clone repository
git clone https://dev.azure.com/balajigv/App-Project/_git/application

# Add files
git add .

# Commit changes
git commit -m "Add Docker files and pipeline"

# Push to repository
git push origin main
```

---

## Troubleshooting Guide

### Issue: "Authentication required. Forgotten password or token?"

**Solution:**
```bash
# Clear Docker credentials
docker logout

# Re-authenticate
docker login
# Enter username: 1601071
# Enter password: <your_token_or_password>
```

### Issue: "Error response from daemon: manifest unknown"

**Solution:**
- Ensure image was successfully pushed
- Check Docker Hub repository for the image
- Verify the correct image name and tag

### Issue: Pipeline fails with "permission denied while trying to connect to Docker daemon"

**Solution:**
- Ensure the Azure DevOps build agent has Docker permissions
- For self-hosted agents, add user to docker group:
  ```bash
  sudo usermod -aG docker $USER
  ```

### Issue: "Service connection not found"

**Solution:**
1. Go to Project Settings → Service connections
2. Verify `DockerHubServiceConnection` exists
3. Update `azure-pipelines.yml` with correct service connection name

### Issue: Container doesn't start or PORT already in use

**Solution:**
```bash
# Check running containers
docker ps

# Stop conflicting container
docker stop <container_id>

# Run on different port
docker run -d -p 9090:80 1601071/balaji_hub:latest

# Test on new port
curl http://localhost:9090
```

---

## Next Steps

1. ✅ Push all files to `application` repository
2. ✅ Create Docker Hub service connection in Azure DevOps
3. ✅ Create pipeline using `azure-pipelines.yml`
4. ✅ Trigger pipeline and monitor build
5. ✅ Verify image on Docker Hub
6. ✅ Pull and test the published image locally
7. ✅ Share image with team: `docker pull 1601071/balaji_hub:latest`

---

## Support and Questions

For issues or questions:
- Check **Azure DevOps Logs**: Pipeline → Select run → View logs
- Check **Docker Hub**: Repository → Tags and pull history
- Check **Local Docker**: `docker logs` command
- Refer to official docs:
  - Docker: https://docs.docker.com
  - Azure Pipelines: https://docs.microsoft.com/azure/devops/pipelines
  - Docker Hub: https://docs.docker.com/docker-hub

---

**Created for:** app-project  
**Docker Image:** 1601071/balaji_hub  
**Last Updated:** 2026-04-03
