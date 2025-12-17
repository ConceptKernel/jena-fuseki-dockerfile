# Apache Jena Fuseki Helm Chart

Official Helm chart for deploying Apache Jena Fuseki 5.6.0 SPARQL server on Kubernetes.

🐳 **Docker Image**: [conceptkernel/jena-fuseki](https://hub.docker.com/r/conceptkernel/jena-fuseki)
📦 **Source Repository**: [ConceptKernel/jena-fuseki-dockerfile](https://github.com/ConceptKernel/jena-fuseki-dockerfile)
📖 **Main Documentation**: [README.md](../../README.md)

## Features

- ✅ **Latest Version**: Apache Jena Fuseki 5.6.0 (October 2025)
- ✅ **Optimized Container**: Multi-arch (amd64/arm64), ~150MB minimal Alpine-based image
- ✅ **Web UI Support**: Optional web-based administration interface
- ✅ **Secure by Default**: Built-in Shiro authentication with configurable access control
- ✅ **Persistent Storage**: Configurable PVC for dataset persistence
- ✅ **Gateway API**: Native HTTPRoute support for modern ingress
- ✅ **Flexible Configuration**: UI mode or headless SPARQL server mode

## TL;DR

```bash
# Install with default values (UI enabled)
helm install my-fuseki ./helm/jena-fuseki

# Install headless SPARQL server
helm install my-fuseki ./helm/jena-fuseki --set ui.enabled=false

# Install with custom admin password
helm install my-fuseki ./helm/jena-fuseki \
  --set security.adminPassword="mySecurePassword123"
```

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8+
- PV provisioner support in the cluster (for persistence)
- Gateway API v1.0+ (optional, for HTTPRoute)

## Installation

### Basic Installation

```bash
# Clone the repository
git clone https://github.com/ConceptKernel/jena-fuseki-dockerfile.git
cd jena-fuseki-dockerfile

# Install the chart
helm install fuseki ./helm/jena-fuseki
```

### With Custom Values

Create a `my-values.yaml` file:

```yaml
# Enable Web UI (default)
ui:
  enabled: true

# Configure security
security:
  enabled: true
  adminUser: "admin"
  adminPassword: "changeme"  # Leave empty to auto-generate
  localhostOnly: false  # Allow remote admin access

# Configure persistence
persistence:
  enabled: true
  size: 10Gi
  storageClass: "fast-ssd"

# Configure Gateway API
gatewayAPI:
  enabled: true
  parentRefs:
    - name: my-gateway
      namespace: gateway-system
      sectionName: https
  hostnames:
    - fuseki.example.com

# Resource limits
resources:
  requests:
    cpu: 1000m
    memory: 2Gi
  limits:
    cpu: 4000m
    memory: 8Gi
```

Install with custom values:

```bash
helm install fuseki ./helm/jena-fuseki -f my-values.yaml
```

## Configuration

### UI vs Headless Mode

#### UI Mode (Recommended for Getting Started)

When `ui.enabled=true`, Fuseki starts with the web administration interface:

- Access the UI at `https://your-domain/`
- Create and manage datasets through the browser
- Visual SPARQL query interface
- Server monitoring and statistics

```yaml
ui:
  enabled: true
```

#### Headless Mode (For Production)

When `ui.enabled=false`, Fuseki runs as a pure SPARQL server with a pre-configured dataset:

```yaml
ui:
  enabled: false
dataset:
  name: "mydata"
  type: "tdb2"  # or "mem" for in-memory
  allowUpdate: true
  location: "/fuseki/databases"
```

### Security Configuration

⚠️ **WARNING**: Authentication with Shiro has not been fully tested in production.

⚠️ **RECOMMENDATION**: Only use this deployment on private networks with proper network-level security.

For production use with authentication, additional testing and validation is required.

#### Security Modes

##### 1. Open Access Mode (Private Networks Only)

Complete open access with no authentication. **Use only on private networks!**

```yaml
security:
  enabled: true
  adminPassword: "disabled"  # Special value for open access
```

This mode:
- ✅ Allows access to all endpoints without authentication
- ✅ Bypasses Fuseki's localhost-only restrictions
- ❌ Provides NO security - suitable only for trusted private networks

##### 2. Public Read Access Mode

UI and SPARQL queries are public, writes require authentication:

```yaml
security:
  enabled: true
  adminPassword: "your-secure-password"
  publicRead: true
  localhostOnly: false  # Allow remote admin access
  privateDatasets:  # Mark these as fully private
    - "internal"
    - "confidential"
```

This mode:
- ✅ Public: UI, SPARQL queries (`/query`, `/sparql`)
- 🔒 Protected: Write operations, admin endpoints, private datasets

##### 3. Full Authentication Mode

Everything requires authentication (default when `security.enabled=true`):

```yaml
security:
  enabled: true
  adminUser: "admin"
  adminPassword: "secure-password"
  localhostOnly: false  # Allow remote admin access
```

##### 4. Localhost-Only Admin Access

Admin endpoints only accessible from localhost (default):

```yaml
security:
  enabled: true
  adminPassword: "secure-password"
  localhostOnly: true  # Restrict admin to localhost
```

##### 5. No Authentication (Not Recommended)

Disabling security leaves Fuseki with default localhost-only restrictions:

```yaml
security:
  enabled: false
```

⚠️ **Note**: With `enabled: false`, admin endpoints are still restricted to localhost by Fuseki itself.

### Persistence

Configure persistent storage for datasets:

```yaml
persistence:
  enabled: true
  storageClass: "default"  # Use cluster default
  accessMode: ReadWriteOnce
  size: 20Gi
  mountPath: /fuseki/databases
```

### Exposure Options

#### Option 1: Gateway API (Recommended)

```yaml
gatewayAPI:
  enabled: true
  parentRefs:
    - name: multi-domain-gateway
      namespace: gateway-system
      sectionName: conceptkernel-dev-https
  hostnames:
    - fuseki.conceptkernel.dev
```

#### Option 2: Traditional Ingress

```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: fuseki.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: fuseki-tls
      hosts:
        - fuseki.example.com
```

#### Option 3: Port Forward (Development)

```bash
kubectl port-forward svc/fuseki-jena-fuseki 3030:3030
```

## Upgrading

```bash
# Upgrade to new chart version
helm upgrade fuseki ./helm/jena-fuseki

# Upgrade with new image version
helm upgrade fuseki ./helm/jena-fuseki --set image.tag=5.7.0
```

## Uninstalling

```bash
helm uninstall fuseki

# Also delete PVC if desired
kubectl delete pvc fuseki-jena-fuseki-data
```

## Values Reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Docker image repository | `conceptkernel/jena-fuseki` |
| `image.tag` | Image tag | `5.6.0` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `replicaCount` | Number of replicas | `1` |
| `ui.enabled` | Enable web UI mode | `true` |
| `dataset.name` | Dataset name (headless mode) | `ds` |
| `dataset.type` | Dataset type: `mem` or `tdb2` | `tdb2` |
| `dataset.allowUpdate` | Allow SPARQL updates | `true` |
| `security.enabled` | Enable Shiro authentication | `true` |
| `security.adminUser` | Admin username | `admin` |
| `security.adminPassword` | Admin password (auto-generated if empty, use "disabled" for open access) | `""` |
| `security.localhostOnly` | Restrict admin endpoints to localhost | `true` |
| `security.publicRead` | Allow public read access (queries public, writes protected) | `false` |
| `security.privateDatasets` | List of dataset names requiring full authentication | `[]` |
| `persistence.enabled` | Enable persistence | `true` |
| `persistence.size` | PVC size | `5Gi` |
| `persistence.storageClass` | Storage class | `default` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `3030` |
| `gatewayAPI.enabled` | Enable HTTPRoute | `false` |
| `ingress.enabled` | Enable Ingress | `false` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `1Gi` |
| `resources.limits.cpu` | CPU limit | `2000m` |
| `resources.limits.memory` | Memory limit | `4Gi` |
| `javaOptions` | JVM options | `"-Xmx2g -Xms2g"` |

## Troubleshooting

### UI Returns 404

This was a known issue with earlier configurations. The chart now properly configures Fuseki to serve the UI when `ui.enabled=true`.

**Solution**: Make sure `ui.enabled=true` in your values and no dataset args are being passed.

### Pod Stuck in ContainerCreating

This usually indicates PVC mounting issues with ReadWriteOnce volumes.

**Solution**: Ensure only 1 replica when using RWO volumes:
```yaml
replicaCount: 1
```

### Cannot Create Datasets via UI

The admin endpoints are restricted to localhost by default.

**Solution**: Set `security.localhostOnly=false` to allow remote admin access:
```yaml
security:
  localhostOnly: false
```

### Memory Issues

Increase Java heap and container memory:
```yaml
javaOptions: "-Xmx4g -Xms4g"
resources:
  limits:
    memory: 8Gi
```

## Examples

### Example 1: Public SPARQL Server with UI

```yaml
ui:
  enabled: true

security:
  enabled: true
  adminPassword: "admin123"
  localhostOnly: false

gatewayAPI:
  enabled: true
  parentRefs:
    - name: public-gateway
      namespace: gateway-system
  hostnames:
    - sparql.mycompany.com
```

### Example 2: Private Dataset Server

```yaml
ui:
  enabled: false

dataset:
  name: "knowledge-graph"
  type: "tdb2"
  allowUpdate: false  # Read-only

security:
  localhostOnly: true

persistence:
  size: 100Gi
  storageClass: "premium-ssd"
```

### Example 3: Development Setup

```yaml
ui:
  enabled: true

persistence:
  enabled: false  # Ephemeral storage

security:
  enabled: false  # No authentication

service:
  type: LoadBalancer  # Direct external access
```

## Contributing

Issues and pull requests are welcome at:
https://github.com/ConceptKernel/jena-fuseki-dockerfile

## License

- Chart: Apache License 2.0
- Jena Fuseki: Apache License 2.0

## Sources

- [Apache Jena Fuseki Documentation](https://jena.apache.org/documentation/fuseki2/)
- [GitHub Issue #2902 - Fuseki Server UI Enhancement](https://github.com/apache/jena/issues/2902)
- [Apache Jena Docker Documentation](https://jena.apache.org/documentation/fuseki2/fuseki-docker)
- [Running Fuseki Server](https://jena.apache.org/documentation/fuseki2/fuseki-server.html)
