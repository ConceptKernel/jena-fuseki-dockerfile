# Apache Jena Fuseki - Optimized Docker Image

**The fastest, lightest, and most efficient Apache Jena Fuseki SPARQL server container.**

## 🚀 Quick Start

```bash
# Pull and run
docker pull conceptkernel/jena-fuseki:latest
docker run -p 3030:3030 conceptkernel/jena-fuseki:latest

# Access Fuseki UI
open http://localhost:3030
```

## ✨ Why This Image?

- ✅ **50% smaller** than alternatives (~150MB vs ~350MB)
- ✅ **Multi-arch** support (amd64 + arm64)
- ✅ **Latest** Apache Jena Fuseki 5.6.0
- ✅ **Inference** support (RDFS, OWL reasoners)
- ✅ **Extensions** auto-download (text search, GeoSPARQL, SHACL, ShEx)
- ✅ **Kubernetes** ready with Helm chart
- ✅ **Production-ready** with health checks
- ✅ **Secure** - runs as non-root user
- ✅ **Fast** - optimized with jlink minimal JDK

## 📦 Available Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest stable release |
| `5.6.0`, `5.6`, `5` | Specific version |
| `5.5.0`, `5.4.0` | Previous versions |

## 🔧 Usage

### Basic

```bash
docker run -p 3030:3030 conceptkernel/jena-fuseki:latest
```

### With Persistent Data

```bash
docker run -p 3030:3030 \
  -v fuseki-data:/fuseki/databases \
  conceptkernel/jena-fuseki:latest
```

### Custom Memory Settings

```bash
docker run -p 3030:3030 \
  -e JAVA_OPTIONS="-Xmx4g -Xms2g" \
  conceptkernel/jena-fuseki:latest
```

## 🐳 Docker Compose

```yaml
version: '3.8'
services:
  fuseki:
    image: conceptkernel/jena-fuseki:latest
    ports:
      - "3030:3030"
    volumes:
      - fuseki-data:/fuseki/databases
    environment:
      - JAVA_OPTIONS=-Xmx4g -Xms2g
    restart: unless-stopped

volumes:
  fuseki-data:
```

## 📊 SPARQL Endpoints

Once running, Fuseki provides:

- **UI**: `http://localhost:3030`
- **Query**: `http://localhost:3030/dataset/query`
- **Update**: `http://localhost:3030/dataset/update`
- **Data**: `http://localhost:3030/dataset/data`
- **Admin**: `http://localhost:3030/$/datasets`

## 🔍 Example Queries

### Query Data

```bash
curl -X POST http://localhost:3030/dataset/query \
  -H "Content-Type: application/sparql-query" \
  --data 'SELECT * WHERE { ?s ?p ?o } LIMIT 10'
```

### Insert Data

```bash
curl -X POST http://localhost:3030/dataset/update \
  -H "Content-Type: application/sparql-update" \
  --data 'INSERT DATA { <http://example.org/subject> <http://example.org/predicate> "object" }'
```

### Load RDF File

```bash
curl -X POST http://localhost:3030/dataset/data \
  -H "Content-Type: text/turtle" \
  --data-binary @data.ttl
```

## ⚙️ Configuration

### Environment Variables

- `JAVA_OPTIONS`: JVM settings (default: `-Xmx2048m -Xms2048m`)

### Volumes

- `/fuseki/databases` - Persistent RDF databases
- `/fuseki/backups` - Database backups
- `/fuseki/configuration` - Configuration files
- `/fuseki/logs` - Application logs

## ☸️ Kubernetes Deployment

Deploy to Kubernetes with the ConceptKernel Helm chart:

```bash
# Install from OCI registry
helm install fuseki oci://ghcr.io/conceptkernel/charts/jena-fuseki --version 1.1.0

# Or from source
git clone https://github.com/ConceptKernel/jena-fuseki-dockerfile.git
helm install fuseki ./jena-fuseki-dockerfile/helm/jena-fuseki
```

Features: Gateway API, Ingress, PersistentVolumes, inference, extensions, and more.

## 🏗️ Image Details

- **Base**: Alpine Linux 3.21
- **Java**: Custom JDK 21 (jlink optimized)
- **Jena Version**: 5.6.0
- **User**: fuseki:fuseki (UID/GID 1000)
- **Platforms**: linux/amd64, linux/arm64

## 📝 License

Apache License 2.0

## 🔗 Links

- **GitHub**: [ConceptKernel/jena-fuseki-dockerfile](https://github.com/ConceptKernel/jena-fuseki-dockerfile)
- **Documentation**: [Apache Jena Fuseki](https://jena.apache.org/documentation/fuseki2/)
- **Issues**: [Report a bug](https://github.com/ConceptKernel/jena-fuseki-dockerfile/issues)

---

**Maintained by [ConceptKernel](https://github.com/ConceptKernel) • Built with ❤️**
