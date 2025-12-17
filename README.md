# Apache Jena Fuseki Docker Image

[![Docker Pulls](https://img.shields.io/docker/pulls/conceptkernel/jena-fuseki)](https://hub.docker.com/r/conceptkernel/jena-fuseki)
[![Docker Image Size](https://img.shields.io/docker/image-size/conceptkernel/jena-fuseki/latest)](https://hub.docker.com/r/conceptkernel/jena-fuseki/tags)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

**The most optimized, lightweight, and efficient Apache Jena Fuseki Docker container available.**

## 🚀 Features

- ✅ **Web UI Included**: Full Vue 3 admin interface with SPARQL query editor
- ✅ **Multi-arch Support**: linux/amd64 and linux/arm64
- ✅ **Minimal Size**: ~150MB Alpine Linux base with custom JDK via jlink
- ✅ **Latest Version**: Based on Apache Jena Fuseki 5.6.0 (October 2025)
- ✅ **Security First**: Shiro authentication, runs as non-root user, minimal attack surface
- ✅ **Production Ready**: Health checks, proper logging, configurable resources
- ✅ **Helm Chart**: Official Helm chart for Kubernetes deployments
- ✅ **Fast Builds**: Optimized layer caching and multi-stage builds
- ✅ **Verified Downloads**: SHA1 checksum verification of all artifacts

## 📦 Quick Start

### Pull and Run

```bash
# Pull the latest image
docker pull conceptkernel/jena-fuseki:latest

# Run Fuseki server
docker run -p 3030:3030 conceptkernel/jena-fuseki:latest

# Access the UI
open http://localhost:3030
```

### Using Docker Compose

Create a `docker-compose.yml`:

```yaml
version: '3.8'

services:
  fuseki:
    image: conceptkernel/jena-fuseki:latest
    container_name: jena-fuseki
    ports:
      - "3030:3030"
    volumes:
      - fuseki-data:/fuseki/databases
      - fuseki-backups:/fuseki/backups
      - fuseki-config:/fuseki/configuration
    environment:
      - JAVA_OPTIONS=-Xmx4g -Xms2g
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:3030/$/ping"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 60s

volumes:
  fuseki-data:
  fuseki-backups:
  fuseki-config:
```

Run:

```bash
docker-compose up -d
```

### Using Helm (Kubernetes)

The official Helm chart provides a production-ready deployment with:
- Web UI with Shiro authentication
- Persistent storage for databases
- Gateway API HTTPRoute support
- Configurable security policies
- Resource limits and health checks

```bash
# Add the repository
git clone https://github.com/ConceptKernel/jena-fuseki-dockerfile.git
cd jena-fuseki-dockerfile/helm

# Install with default settings (UI enabled, authentication enabled)
helm install fuseki ./jena-fuseki

# Install with custom values
helm install fuseki ./jena-fuseki -f ./jena-fuseki/examples/production-values.yaml

# Get the admin password
kubectl get secret fuseki-jena-fuseki-admin -o jsonpath='{.data.password}' | base64 -d

# Port forward to access locally
kubectl port-forward svc/fuseki-jena-fuseki 3030:3030
```

For detailed Helm chart documentation, see [helm/jena-fuseki/README.md](helm/jena-fuseki/README.md).

## 🏗️ Building from Source

### Prerequisites

- Docker 20.10+ with BuildKit enabled
- Docker Buildx for multi-arch builds

### Build Locally

```bash
# Clone the repository
git clone https://github.com/ConceptKernel/jena-fuseki-dockerfile.git
cd jena-fuseki-dockerfile

# Build for your platform
docker build --build-arg JENA_VERSION=5.6.0 -t jena-fuseki:local .

# Build multi-arch (requires buildx)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg JENA_VERSION=5.6.0 \
  -t conceptkernel/jena-fuseki:5.6.0 \
  --push \
  .
```

## ⚙️ Configuration

### Web UI and Authentication

The container includes the full Fuseki web UI with:
- **Admin Interface**: Create/manage datasets, view server stats
- **SPARQL Query Editor**: YASGUI-powered query interface with syntax highlighting
- **Shiro Authentication**: Configurable user authentication and authorization
- **Default Credentials**: `admin` / `pw` (change via Shiro config or Helm chart)

The UI is automatically extracted from the JAR on first startup and served from `$FUSEKI_BASE/webapp`.

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JAVA_OPTIONS` | `-Xmx2048m -Xms2048m` | JVM memory settings |
| `JENA_VERSION` | `5.6.0` | Apache Jena version (build-time) |
| `FUSEKI_DIR` | `/fuseki` | Fuseki installation directory |
| `FUSEKI_BASE` | `/fuseki/run` | Runtime directory (config, logs, UI files) |

### Volumes

| Path | Purpose |
|------|---------|
| `/fuseki/databases` | Persistent RDF databases (recommended for production) |
| `/fuseki/run` | Runtime files (config, logs, UI, system state) |
| `/fuseki/backups` | Database backups |
| `/fuseki/configuration` | Fuseki configuration files |
| `/fuseki/logs` | Application logs |

**Note**: For production deployments with persistent data, mount `/fuseki/databases` to preserve your datasets across container restarts.

### Ports

| Port | Description |
|------|-------------|
| `3030` | Fuseki HTTP endpoint |

## 📊 Usage Examples

### Create a Dataset

```bash
# Using the Fuseki UI
open http://localhost:3030

# Using CLI
docker exec -it jena-fuseki /fuseki/fuseki-server \
  --update \
  --mem \
  /mydataset
```

### SPARQL Queries

```bash
# Query via curl
curl -X POST http://localhost:3030/mydataset/query \
  -H "Content-Type: application/sparql-query" \
  --data 'SELECT * WHERE { ?s ?p ?o } LIMIT 10'

# Update via curl
curl -X POST http://localhost:3030/mydataset/update \
  -H "Content-Type: application/sparql-update" \
  --data 'INSERT DATA { <http://example.org/subject> <http://example.org/predicate> "object" }'
```

### Load Data

```bash
# Load RDF file
curl -X POST http://localhost:3030/mydataset/data \
  -H "Content-Type: text/turtle" \
  --data-binary @data.ttl
```

## 🎯 Production Deployment

### Kubernetes with Helm (Recommended)

For production Kubernetes deployments, use the official Helm chart:

```bash
# Clone the repository
git clone https://github.com/ConceptKernel/jena-fuseki-dockerfile.git

# Install with production settings
helm install fuseki ./jena-fuseki-dockerfile/helm/jena-fuseki \
  -f ./jena-fuseki-dockerfile/helm/jena-fuseki/examples/production-values.yaml

# Or customize inline
helm install fuseki ./jena-fuseki-dockerfile/helm/jena-fuseki \
  --set persistence.size=50Gi \
  --set resources.limits.memory=8Gi \
  --set security.adminPassword=your-secure-password
```

The Helm chart includes:
- 🔐 Shiro authentication with auto-generated passwords
- 💾 Persistent volume claims for data
- 🌐 Gateway API HTTPRoute support
- 📊 Health checks and monitoring
- ⚙️ Configurable resources and security policies

See [helm/jena-fuseki/README.md](helm/jena-fuseki/README.md) for complete documentation.

### Kubernetes with kubectl (Manual)

For manual deployments without Helm:

```bash
# Create namespace
kubectl create namespace fuseki

# Create PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fuseki-data
  namespace: fuseki
spec:
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 20Gi
EOF

# Deploy Fuseki
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jena-fuseki
  namespace: fuseki
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jena-fuseki
  template:
    metadata:
      labels:
        app: jena-fuseki
    spec:
      containers:
      - name: fuseki
        image: conceptkernel/jena-fuseki:latest
        ports:
        - containerPort: 3030
        env:
        - name: JAVA_OPTIONS
          value: "-Xmx4g -Xms2g"
        volumeMounts:
        - name: data
          mountPath: /fuseki/databases
        livenessProbe:
          httpGet:
            path: /$/ping
            port: 3030
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /$/ping
            port: 3030
          initialDelaySeconds: 30
          periodSeconds: 10
        resources:
          requests:
            memory: "2Gi"
            cpu: "500m"
          limits:
            memory: "6Gi"
            cpu: "2000m"
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: fuseki-data
---
apiVersion: v1
kind: Service
metadata:
  name: jena-fuseki
  namespace: fuseki
spec:
  selector:
    app: jena-fuseki
  ports:
  - port: 3030
    targetPort: 3030
  type: ClusterIP
EOF
```

## 🔍 Image Details

### Architecture

```
┌─────────────────────────────────┐
│  Stage 1: Builder               │
│  - eclipse-temurin:21-alpine    │
│  - Download Fuseki JAR          │
│  - Verify SHA1 checksum         │
│  - Create minimal JDK (jlink)   │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│  Stage 2: Runtime               │
│  - alpine:3.21                  │
│  - Minimal JDK only             │
│  - Fuseki JAR + config          │
│  - Non-root user (UID 1000)     │
│  - Health check enabled         │
└─────────────────────────────────┘
```

### Size Comparison

| Image | Size | Notes |
|-------|------|-------|
| **conceptkernel/jena-fuseki** | **~150MB** | This image - optimized |
| stain/jena-fuseki | ~350MB | Community image |
| Official WAR | N/A | No official Docker image |

### Security

- ✅ Runs as non-root user (`fuseki:fuseki` UID/GID 1000)
- ✅ No unnecessary packages installed
- ✅ Minimal attack surface (Alpine + jlink JDK)
- ✅ SHA1 checksum verification of downloads
- ✅ Regular security updates via automated builds

## 📚 Documentation

- [Apache Jena Documentation](https://jena.apache.org/documentation/)
- [Fuseki Server Documentation](https://jena.apache.org/documentation/fuseki2/)
- [SPARQL 1.1 Specification](https://www.w3.org/TR/sparql11-query/)
- [Helm Chart Documentation](helm/jena-fuseki/README.md)

## 🔧 Technical Notes

### Web UI Implementation

This container uses `jena-fuseki-server-5.6.0.jar` (55.9MB fat JAR) which includes:
- The full Fuseki server with UI and admin functionality
- Apache Shiro security framework
- Prometheus metrics endpoint
- YASGUI SPARQL query editor (Vue 3 application)

The UI files are embedded in the JAR at `/webapp/*`. On first startup, the entrypoint script extracts them to `$FUSEKI_BASE/webapp` where Fuseki's `FMod_UI` module can serve them.

**Main Class**: `org.apache.jena.fuseki.main.cmds.FusekiServerCmd`
**UI Module**: `org.apache.jena.fuseki.mod.ui.FMod_UI`

For headless deployments without UI, the alternative main class `org.apache.jena.fuseki.main.cmds.FusekiMainCmd` can be used.

### JAR Selection

There are two Fuseki JARs available:
- `jena-fuseki-server-*.jar` (55.9MB) - Full server with UI, admin, metrics (this image)
- `jena-fuseki-main-*.jar` (183KB) - Library JAR, not executable

This image uses the server JAR for complete functionality.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

Apache Jena Fuseki is licensed under the Apache License 2.0 by the Apache Software Foundation.

## 🙏 Acknowledgments

- Apache Software Foundation for Apache Jena and Fuseki
- The Jena community for their excellent work
- ConceptKernel team for optimization and maintenance

## 📞 Support

- 🐛 [Issues](https://github.com/ConceptKernel/jena-fuseki-dockerfile/issues)
- 💬 [Discussions](https://github.com/ConceptKernel/jena-fuseki-dockerfile/discussions)
- 🐳 [Docker Hub](https://hub.docker.com/r/conceptkernel/jena-fuseki)

---

**Built with ❤️ by [ConceptKernel](https://github.com/ConceptKernel)**
