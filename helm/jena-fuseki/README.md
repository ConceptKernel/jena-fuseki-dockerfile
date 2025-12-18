# Apache Jena Fuseki Helm Chart

Community Helm chart for deploying Apache Jena Fuseki SPARQL server on Kubernetes.

**Maintained by**: [ConceptKernel](https://github.com/ConceptKernel)
**Chart Version**: 1.1.0 | **App Version**: 5.6.0

🐳 **Docker Image**: [conceptkernel/jena-fuseki](https://hub.docker.com/r/conceptkernel/jena-fuseki)
📦 **Source**: [ConceptKernel/jena-fuseki-dockerfile](https://github.com/ConceptKernel/jena-fuseki-dockerfile)
📖 **Full Documentation**: [Main README](../../README.md)

## Quick Start

```bash
# Install from OCI registry (recommended)
helm install fuseki oci://ghcr.io/conceptkernel/charts/jena-fuseki --version 1.1.0

# Or install from local clone
git clone https://github.com/ConceptKernel/jena-fuseki-dockerfile.git
helm install fuseki ./jena-fuseki-dockerfile/helm/jena-fuseki

# Get admin password
kubectl get secret fuseki-jena-fuseki-admin -o jsonpath='{.data.password}' | base64 -d

# Access via port-forward
kubectl port-forward svc/fuseki-jena-fuseki 3030:3030
```

## Features

- ✅ **Latest**: Apache Jena Fuseki 5.6.0
- ✅ **Inference**: RDFS, OWL, OWL Micro, OWL Mini reasoners
- ✅ **Extensions**: Auto-download jena-text, jena-geosparql, jena-shacl, jena-shex
- ✅ **Web UI**: Optional Vue 3 admin interface
- ✅ **Security**: 4 modes (open, public-read, full-auth, localhost)
- ✅ **Storage**: Persistent volumes for TDB2 databases
- ✅ **Networking**: Gateway API HTTPRoute + traditional Ingress
- ✅ **Multi-arch**: linux/amd64, linux/arm64

## Common Configurations

**Headless SPARQL server (no UI)**:
```bash
helm install fuseki oci://ghcr.io/conceptkernel/charts/jena-fuseki \
  --version 1.1.0 \
  --set ui.enabled=false
```

**With RDFS inference**:
```bash
helm install fuseki oci://ghcr.io/conceptkernel/charts/jena-fuseki \
  --version 1.1.0 \
  --set inference.enabled=true \
  --set inference.preset=rdfs
```

**Production with full-text search**:
```bash
helm install fuseki oci://ghcr.io/conceptkernel/charts/jena-fuseki \
  --version 1.1.0 \
  --set security.password="SecurePass123" \
  --set extensions.text.enabled=true \
  --set persistence.size=50Gi \
  --set resources.limits.memory=8Gi
```

## Configuration

For complete configuration documentation including:
- All 40+ values.yaml options
- Security modes and authentication
- Inference and extensions configuration
- Gateway API and Ingress setup
- Resource management
- High availability options

**See the [Main README - Helm Section](../../README.md#using-helm-kubernetes)**

## Values Reference

Key configuration values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ui.enabled` | Enable web UI | `true` |
| `security.mode` | Auth mode (open/public-read/full-auth/localhost) | `full-auth` |
| `security.password` | Admin password (empty = auto-generate) | `""` |
| `inference.enabled` | Enable reasoning | `false` |
| `inference.preset` | Reasoner (rdfs/owl/owlmicro/owlmini) | `rdfs` |
| `extensions.text.enabled` | Enable full-text search | `false` |
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.size` | PVC size | `10Gi` |
| `resources.limits.memory` | Memory limit | `4Gi` |

For all values, see [values.yaml](values.yaml)

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8+
- PV provisioner (for persistence)
- Gateway API v1.0+ (optional, for HTTPRoute)

## Upgrading

```bash
# Upgrade to latest version
helm upgrade fuseki oci://ghcr.io/conceptkernel/charts/jena-fuseki \
  --version 1.1.0 \
  --reuse-values

# Upgrade with new values
helm upgrade fuseki oci://ghcr.io/conceptkernel/charts/jena-fuseki \
  --version 1.1.0 \
  --set image.tag=5.6.0-3
```

## Uninstalling

```bash
helm uninstall fuseki
```

**Note**: PersistentVolumeClaims are not automatically deleted. To remove data:
```bash
kubectl delete pvc fuseki-jena-fuseki-data
```

## Support

- 📖 **Documentation**: [Main README](../../README.md)
- 🐛 **Issues**: [GitHub Issues](https://github.com/ConceptKernel/jena-fuseki-dockerfile/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/ConceptKernel/jena-fuseki-dockerfile/discussions)

## License

Apache License 2.0 - Same as Apache Jena

---

**Built on Apache Jena** | **Maintained by ConceptKernel**
