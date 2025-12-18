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
- ✅ **Inference Support**: Built-in RDFS and OWL reasoners with preset configurations
- ✅ **Extensions**: Auto-download official Apache Jena modules (text search, GeoSPARQL, SHACL, ShEx)

## 📖 About This Project

This project provides optimized Docker images and Kubernetes Helm charts for **Apache Jena Fuseki**, the industry-standard SPARQL server and triple store.

### What is Apache Jena Fuseki?

[Apache Jena Fuseki](https://jena.apache.org/documentation/fuseki2/) is a SPARQL 1.1 server that provides:
- SPARQL query and update endpoints
- RESTful HTTP interface for RDF data management
- Web-based admin UI for dataset management
- Support for TDB2 persistent storage and in-memory datasets
- Integration with Apache Jena's semantic web toolkit

### This Repository (jena-fuseki-dockerfile)

**Repository**: [github.com/ConceptKernel/jena-fuseki-dockerfile](https://github.com/ConceptKernel/jena-fuseki-dockerfile)
**Docker Hub**: [hub.docker.com/r/conceptkernel/jena-fuseki](https://hub.docker.com/r/conceptkernel/jena-fuseki)
**License**: Apache License 2.0

This repository maintains:
- Optimized multi-stage Dockerfile for minimal image size
- Production-ready Kubernetes Helm chart
- Documentation and deployment examples
- Automated builds for both amd64 and arm64 architectures

### Versioning Scheme

**Current Release**: `v5.6.0-2`

We follow a modified semantic versioning scheme:

```
v5.6.0-1
  │││  └─ Build number (incremented for jena-fuseki-dockerfile changes)
  │││
  └┴┴─ Apache Jena Fuseki version (5.6.0)
```

- **First three numbers** (`5.6.0`): Match the upstream Apache Jena Fuseki release version
- **Build number after dash** (`-1`): Incremented for patches, documentation updates, or Helm chart changes in this repository
- This ensures version alignment with Apache Jena while allowing independent updates

**Example**:
- `v5.6.0-1`: Initial release based on Fuseki 5.6.0
- `v5.6.0-2`: Updated Helm chart for same Fuseki version
- `v5.7.0-1`: New Fuseki upstream release

### Official Apache Jena Resources

- **Apache Jena Homepage**: https://jena.apache.org/
- **Fuseki Documentation**: https://jena.apache.org/documentation/fuseki2/
- **Fuseki GitHub**: https://github.com/apache/jena (see `jena-fuseki2/` directory)
- **Fuseki Docker Guide**: https://jena.apache.org/documentation/fuseki2/fuseki-docker
- **SPARQL 1.1 Specification**: https://www.w3.org/TR/sparql11-query/
- **Apache Jena Releases**: https://jena.apache.org/download/

### Key Differences from Official Apache Jena

This image provides several optimizations over building from source:

| Feature | This Image | Official WAR |
|---------|-----------|-------------|
| Docker Image | ✅ Ready to use | ❌ DIY |
| Image Size | ~150MB | N/A |
| Multi-arch | ✅ amd64 + arm64 | Source only |
| Kubernetes Helm Chart | ✅ Included | ❌ Not provided |
| UI Extraction | ✅ Automatic | Manual setup |
| JDK Optimization | ✅ jlink minimal JDK | Full JRE required |

## 📦 Quick Start

### Basic Docker Run

The simplest way to get started:

```bash
# Pull the latest image
docker pull conceptkernel/jena-fuseki:5.6.0

# Run Fuseki server with UI
docker run -d \
  --name jena-fuseki \
  -p 3030:3030 \
  conceptkernel/jena-fuseki:5.6.0

# Access the UI in your browser
open http://localhost:3030
```

The UI will be immediately available at `http://localhost:3030` with full admin capabilities.

### Docker Run with Persistence

For persistent data across container restarts:

```bash
# Create a volume for persistent storage
docker volume create fuseki-data

# Run with mounted volume
docker run -d \
  --name jena-fuseki \
  -p 3030:3030 \
  -v fuseki-data:/fuseki/databases \
  -e JAVA_OPTIONS="-Xmx4g -Xms2g" \
  conceptkernel/jena-fuseki:5.6.0

# View logs
docker logs -f jena-fuseki

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

**Helm Chart Version**: `1.1.0` | **App Version**: `5.6.0`

The official Helm chart provides a production-ready, configurable deployment with extensive options for security, storage, networking, and advanced features.

#### Quick Start

```bash
# Clone the repository
git clone https://github.com/ConceptKernel/jena-fuseki-dockerfile.git
cd jena-fuseki-dockerfile/helm

# Install with default settings (UI enabled, authentication enabled)
helm install fuseki ./jena-fuseki

# Get the admin password
kubectl get secret fuseki-jena-fuseki-admin -o jsonpath='{.data.password}' | base64 -d

# Port forward to access locally
kubectl port-forward svc/fuseki-jena-fuseki 3030:3030
```

#### Local Development with Minikube (macOS/Linux)

```bash
# Install minikube
brew install minikube  # macOS
# Or follow: https://minikube.sigs.k8s.io/docs/start/

# Start minikube cluster
minikube start --cpus=4 --memory=8192

# Deploy Fuseki
cd jena-fuseki-dockerfile/helm
helm install fuseki ./jena-fuseki

# Access via port-forward
kubectl port-forward svc/fuseki-jena-fuseki 3030:3030
open http://localhost:3030
```

#### Local Development with Colima (macOS - Docker Desktop Alternative)

```bash
# Install colima (lightweight alternative to Docker Desktop)
brew install colima

# Start colima with Kubernetes enabled
colima start --cpu 4 --memory 8 --kubernetes

# Set kubectl context
kubectl config use-context colima

# Deploy Fuseki
cd jena-fuseki-dockerfile/helm
helm install fuseki ./jena-fuseki

# Access locally
kubectl port-forward svc/fuseki-jena-fuseki 3030:3030
```

#### Feature Matrix

The Helm chart supports extensive configuration options across multiple categories:

| Category | Feature | Supported | Configuration |
|----------|---------|-----------|---------------|
| **UI & Interface** | Web UI Enable/Disable | ✅ | `ui.enabled: true/false` |
| | SPARQL Query Editor | ✅ | Included with UI |
| | Dataset Management | ✅ | Included with UI |
| **Security** | No Authentication (Open) | ✅ | `security.mode: open` |
| | Public Read Only | ✅ | `security.mode: public-read` |
| | Full Authentication | ✅ | `security.mode: full-auth` (default) |
| | Localhost Only | ✅ | `security.mode: localhost` |
| | Custom Shiro Config | ✅ | `security.customShiroConfig` |
| **Storage** | Persistent Volume | ✅ | `persistence.enabled: true` |
| | Storage Size | ✅ | `persistence.size: "10Gi"` |
| | Storage Class | ✅ | `persistence.storageClass: "default"` |
| | Custom Mount Path | ✅ | `persistence.mountPath` |
| **Inference** | RDFS Reasoner | ✅ | `inference.preset: "rdfs"` |
| | OWL Reasoner | ✅ | `inference.preset: "owl"` |
| | OWL Micro | ✅ | `inference.preset: "owlmicro"` |
| | OWL Mini | ✅ | `inference.preset: "owlmini"` |
| | Custom Assembler | ✅ | `inference.customConfig` |
| **Extensions** | jena-text (Full-text) | ✅ | `extensions.text.enabled: true` |
| | jena-geosparql | ✅ | `extensions.geosparql.enabled: true` |
| | jena-shacl | ✅ | `extensions.shacl.enabled: true` |
| | jena-shex | ✅ | `extensions.shex.enabled: true` |
| | Auto-download | ✅ | Automatic from Maven Central |
| **Networking** | ClusterIP Service | ✅ | `service.type: ClusterIP` (default) |
| | LoadBalancer Service | ✅ | `service.type: LoadBalancer` |
| | NodePort Service | ✅ | `service.type: NodePort` |
| | Traditional Ingress | ✅ | `ingress.enabled: true` |
| | Gateway API HTTPRoute | ✅ | `gateway.enabled: true` |
| | Multi-domain Routing | ✅ | `gateway.listeners[].name` |
| | TLS/HTTPS | ✅ | Via Ingress/Gateway |
| **Resources** | CPU Requests/Limits | ✅ | `resources.requests/limits.cpu` |
| | Memory Requests/Limits | ✅ | `resources.requests/limits.memory` |
| | JVM Heap Size | ✅ | `javaOptions: "-Xmx4g"` |
| **High Availability** | Multiple Replicas | ⚠️ | `replicas: 2` (read-only replicas) |
| | Pod Disruption Budget | ❌ | Not yet implemented |
| | Auto-scaling (HPA) | ❌ | Not yet implemented |
| **Monitoring** | Liveness Probe | ✅ | `livenessProbe` |
| | Readiness Probe | ✅ | `readinessProbe` |
| | Health Endpoint | ✅ | `/$/ping` |
| | Prometheus Metrics | ⚠️ | Via `/$/stats` (basic) |
| **Deployment** | Rolling Updates | ✅ | Default strategy |
| | Pod Security Context | ✅ | Non-root UID 1000 |
| | Image Pull Policy | ✅ | `image.pullPolicy` |
| | Node Selector | ✅ | `nodeSelector` |
| | Tolerations | ✅ | `tolerations` |
| | Affinity Rules | ✅ | `affinity` |

**Legend:**
- ✅ **Fully Supported** - Production-ready feature
- ⚠️ **Partial Support** - Available with limitations
- ❌ **Not Available** - Planned for future release

#### Configuration Examples

**Open Access (No Authentication)**:
```yaml
security:
  mode: open
  enabled: false
```

**Production with Full-Text Search**:
```yaml
security:
  mode: full-auth
  username: admin
  password: "YourSecurePassword"

persistence:
  enabled: true
  size: "50Gi"
  storageClass: "premium-rwo"

extensions:
  text:
    enabled: true
    indexDir: /fuseki/text-index

resources:
  requests:
    cpu: "2000m"
    memory: "8Gi"
  limits:
    cpu: "4000m"
    memory: "16Gi"

javaOptions: "-Xmx12g -Xms4g"
```

**With RDFS Inference**:
```yaml
inference:
  enabled: true
  preset: rdfs
```

**Gateway API with Multi-Domain**:
```yaml
gateway:
  enabled: true
  className: "eg"  # Envoy Gateway
  listeners:
    - name: "https"
      namespace: "gateway-system"
      gateway: "main-gateway"
  hosts:
    - "sparql.example.com"
```

#### Advanced Deployment

```bash
# Production deployment with inference and extensions
helm install fuseki ./jena-fuseki \
  --set image.tag=5.6.0-2 \
  --set security.password="SecurePass123" \
  --set inference.enabled=true \
  --set inference.preset=rdfs \
  --set extensions.text.enabled=true \
  --set persistence.size=100Gi \
  --set resources.limits.memory=16Gi \
  --set javaOptions="-Xmx12g"

# Upgrade existing release
helm upgrade fuseki ./jena-fuseki \
  --reuse-values \
  --set image.tag=5.6.0-2

# Uninstall
helm uninstall fuseki
```

For complete Helm chart documentation, see [helm/jena-fuseki/README.md](helm/jena-fuseki/README.md).

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

## 🚀 Advanced Features

This image includes support for official Apache Jena extension modules that add powerful capabilities to your SPARQL server. All extensions are official Apache Jena Foundation components.

### Inference and Reasoning

Apache Jena includes built-in reasoners for RDFS and OWL inference. **No additional JARs required** - all reasoners are included in the base distribution.

When deploying with the Helm chart, enable inference via `values.yaml`:

```yaml
inference:
  enabled: true
  preset: "rdfs"  # Options: rdfs, owl, owlmicro, owlmini, custom
```

**Available Reasoners**:
- **RDFS**: Subclass, subproperty, domain, range inference - fast and efficient
- **OWL**: Full OWL DL reasoning - computationally expensive
- **OWL Micro**: Performance-optimized OWL subset
- **OWL Mini**: Minimal OWL subset - fastest

**Documentation**: [Jena Inference](https://jena.apache.org/documentation/inference/)

### Extensions

Official Apache Jena extension modules for advanced functionality. When using the Helm chart, extensions are **automatically downloaded** from Maven Central at pod initialization.

#### 1. Full-Text Search (jena-text)

Lucene-based full-text search for SPARQL queries:

```yaml
extensions:
  text:
    enabled: true
    indexDir: /fuseki/text-index
```

**Use cases**: Search large text corpora, multilingual search, fuzzy matching

**Documentation**: [Jena Text Query](https://jena.apache.org/documentation/query/text-query.html)

#### 2. GeoSPARQL (jena-fuseki-geosparql)

GeoSPARQL 1.0 support for geospatial queries:

```yaml
extensions:
  geosparql:
    enabled: true
    indexDir: /fuseki/spatial-index
```

**Use cases**: Location-based queries, spatial relationships, geographic data

**Documentation**: [Jena GeoSPARQL](https://jena.apache.org/documentation/geosparql/)

#### 3. SHACL Validation (jena-shacl)

Shape constraint validation for RDF data quality:

```yaml
extensions:
  shacl:
    enabled: true
```

**Use cases**: Data validation, quality constraints, schema enforcement

**Documentation**: [Jena SHACL](https://jena.apache.org/documentation/shacl/)

#### 4. ShEx Validation (jena-shex)

Shape expressions for RDF validation:

```yaml
extensions:
  shex:
    enabled: true
```

**Use cases**: Alternative to SHACL, schema validation, data quality

**Documentation**: [Jena ShEx](https://jena.apache.org/documentation/shex/)

### Extension Management

- ✅ **Zero Configuration**: Extensions auto-download from Maven Central
- ✅ **Version Aligned**: Extension versions match Jena version (e.g., 5.6.0)
- ✅ **Classpath Integration**: Automatically added to Java classpath
- ✅ **Container Optimized**: Cached in ephemeral storage, no image bloat

For detailed configuration, see the [Helm Chart README](helm/jena-fuseki/README.md).

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
