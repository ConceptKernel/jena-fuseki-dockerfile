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

### Inference and Reasoning

Apache Jena includes built-in reasoners for RDFS and OWL inference. When enabled, Fuseki uses an assembler configuration to apply reasoning over your data.

**No additional JARs required** - all reasoners are included in the base Apache Jena distribution.

#### Inference Presets

```yaml
inference:
  enabled: true
  preset: "rdfs"  # Options: rdfs, owl, owlmicro, owlmini, custom
```

**Available Presets**:

- **`rdfs`**: RDFS reasoning (subclass, subproperty, domain, range, type inference)
  - Fast and efficient for basic ontologies
  - Recommended for most knowledge graphs

- **`owl`**: Full OWL reasoning (OWL FB Rule Reasoner)
  - Complete OWL DL inference
  - Computationally expensive - use with caution on large datasets

- **`owlmicro`**: OWL Micro reasoning
  - Subset of OWL optimized for performance
  - Good balance between expressiveness and speed

- **`owlmini`**: OWL Mini reasoning
  - Minimal OWL subset
  - Fastest OWL-based reasoner

- **`custom`**: Use your own assembler configuration
  - Provide custom Turtle config via `inference.customConfig`

#### Custom Assembler Configuration

For advanced use cases, provide your own assembler configuration:

```yaml
inference:
  enabled: true
  preset: "custom"
  customConfig: |
    @prefix fuseki:  <http://jena.apache.org/fuseki#> .
    @prefix ja:      <http://jena.hpl.hp.com/2005/11/Assembler#> .
    @prefix tdb2:    <http://jena.apache.org/2016/tdb#> .

    :service a fuseki:Service ;
        fuseki:name "dataset" ;
        fuseki:endpoint [ fuseki:operation fuseki:query ] ;
        fuseki:dataset :dataset .

    :dataset a tdb2:DatasetTDB2 ;
        tdb2:location "/fuseki/databases" ;
        ja:defaultGraph :model .

    :model a ja:InfModel ;
        ja:baseModel :baseModel ;
        ja:reasoner [
            ja:reasonerURL <http://jena.hpl.hp.com/2003/RDFSRuleReasoner>
        ] .

    :baseModel a tdb2:GraphTDB2 ;
        tdb2:location "/fuseki/databases" .
```

See [Jena Assembler Documentation](https://jena.apache.org/documentation/assembler/) for details.

### Extensions

Apache Jena provides official extension modules for advanced functionality. These are **automatically downloaded** from Maven Central during pod initialization.

#### Available Extensions

##### 1. Full-Text Search (jena-text)

Adds Lucene-based full-text search to SPARQL queries:

```yaml
extensions:
  text:
    enabled: true
    indexDir: /fuseki/text-index
```

**Features**:
- Full-text search with `text:query` SPARQL predicate
- Lucene indexing for fast text searches
- Configurable analyzers and languages

**Documentation**: [Jena Text Query](https://jena.apache.org/documentation/query/text-query.html)

##### 2. GeoSPARQL (jena-fuseki-geosparql)

GeoSPARQL 1.0 support for geospatial queries:

```yaml
extensions:
  geosparql:
    enabled: true
    indexDir: /fuseki/spatial-index
```

**Features**:
- Geospatial queries (distance, containment, intersection)
- Well-Known Text (WKT) and GML support
- Spatial indexing for performance

**Documentation**: [Jena GeoSPARQL](https://jena.apache.org/documentation/geosparql/)

##### 3. SHACL Validation (jena-shacl)

Shape constraint validation for RDF data:

```yaml
extensions:
  shacl:
    enabled: true
```

**Features**:
- SHACL shape validation
- Data quality constraints
- Validation reports

**Documentation**: [Jena SHACL](https://jena.apache.org/documentation/shacl/)

##### 4. ShEx Validation (jena-shex)

Shape expressions for RDF validation:

```yaml
extensions:
  shex:
    enabled: true
```

**Features**:
- ShEx shape validation
- Alternative to SHACL with different syntax
- Schema validation

**Documentation**: [Jena ShEx](https://jena.apache.org/documentation/shex/)

#### Combining Extensions and Inference

You can enable multiple extensions and inference together:

```yaml
inference:
  enabled: true
  preset: "rdfs"

extensions:
  text:
    enabled: true
    indexDir: /fuseki/text-index
  geosparql:
    enabled: true
    indexDir: /fuseki/spatial-index
  shacl:
    enabled: true
```

**Note**: Inference and extensions work independently. However, when inference is enabled, you'll use assembler-based configuration for the dataset instead of the standard Fuseki UI-based dataset creation.

#### Extension JAR Management

Extensions are automatically managed:
- Downloaded from Maven Central at pod start
- Version matches the Jena version (e.g., 5.6.0)
- Cached in emptyDir volume (`/fuseki/extensions`)
- Added to classpath automatically
- No manual JAR management required

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
| `inference.enabled` | Enable inference/reasoning | `false` |
| `inference.preset` | Inference preset: `rdfs`, `owl`, `owlmicro`, `owlmini`, `custom` | `rdfs` |
| `inference.customConfig` | Custom assembler config (Turtle format, when preset=custom) | `""` |
| `extensions.text.enabled` | Enable jena-text (Lucene full-text search) | `false` |
| `extensions.text.indexDir` | Text index directory | `/fuseki/text-index` |
| `extensions.geosparql.enabled` | Enable jena-fuseki-geosparql (GeoSPARQL support) | `false` |
| `extensions.geosparql.indexDir` | Spatial index directory | `/fuseki/spatial-index` |
| `extensions.shacl.enabled` | Enable jena-shacl (SHACL validation) | `false` |
| `extensions.shex.enabled` | Enable jena-shex (ShEx validation) | `false` |
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
