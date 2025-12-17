# Jena Fuseki Helm Chart

This directory contains the official Helm chart for Apache Jena Fuseki 5.6.0.

## Quick Start

```bash
# Install with UI enabled (default)
helm install fuseki ./jena-fuseki

# Get admin credentials
kubectl get secret fuseki-jena-fuseki-admin -o jsonpath='{.data.password}' | base64 -d
```

See [jena-fuseki/README.md](jena-fuseki/README.md) for full documentation.
