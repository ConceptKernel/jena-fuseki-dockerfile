# Apache Jena Fuseki Docker Image

[![Docker Pulls](https://img.shields.io/docker/pulls/conceptkernel/jena-fuseki)](https://hub.docker.com/r/conceptkernel/jena-fuseki)
[![Docker Image Size](https://img.shields.io/docker/image-size/conceptkernel/jena-fuseki/latest)](https://hub.docker.com/r/conceptkernel/jena-fuseki/tags)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

**The most optimized, lightweight, and efficient Apache Jena Fuseki Docker container available.**

## 🚀 Features

- ✅ **Multi-arch Support**: linux/amd64 and linux/arm64
- ✅ **Minimal Size**: Alpine Linux base with custom JDK via jlink
- ✅ **Latest Version**: Based on Apache Jena Fuseki 5.6.0
- ✅ **Security First**: Runs as non-root user, minimal attack surface
- ✅ **Production Ready**: Health checks, proper logging, configurable resources
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

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JAVA_OPTIONS` | `-Xmx2048m -Xms2048m` | JVM memory settings |
| `JENA_VERSION` | `5.6.0` | Apache Jena version (build-time) |
| `FUSEKI_DIR` | `/fuseki` | Fuseki installation directory |

### Volumes

| Path | Purpose |
|------|---------|
| `/fuseki/databases` | Persistent RDF databases |
| `/fuseki/backups` | Database backups |
| `/fuseki/configuration` | Fuseki configuration files |
| `/fuseki/logs` | Application logs |

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

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jena-fuseki
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
        image: conceptkernel/jena-fuseki:5.6.0
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
          claimName: fuseki-data-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: jena-fuseki
spec:
  selector:
    app: jena-fuseki
  ports:
  - port: 3030
    targetPort: 3030
  type: ClusterIP
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
