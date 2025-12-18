# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to a modified semantic versioning scheme where the first three numbers match the Apache Jena Fuseki version, and the build number after the dash is incremented for repository-specific changes.

## [Unreleased]

### Added

#### Inference and Reasoning Support
- **Built-in Reasoners**: Support for RDFS, OWL, OWL Micro, and OWL Mini reasoners
- **Preset Configurations**: Four ready-to-use assembler configurations (rdfs, owl, owlmicro, owlmini)
- **Custom Assembler Support**: Ability to provide custom Turtle-format assembler configurations
- **Automatic Configuration**: Helm chart conditionally creates assembler ConfigMap and passes --config flag when inference.enabled=true
- **Documentation**: Comprehensive documentation in both main and Helm README files

#### Extensions Support
- **Auto-Download System**: Init container automatically downloads extension JARs from Maven Central
- **Dynamic Classpath**: Entrypoint script detects and loads extension JARs at startup
- **Four Official Extensions**:
  - **jena-text**: Lucene-based full-text search for SPARQL queries
  - **jena-fuseki-geosparql**: GeoSPARQL 1.0 support for geospatial queries
  - **jena-shacl**: SHACL validation for RDF data quality constraints
  - **jena-shex**: ShEx validation for RDF schema validation
- **Version Alignment**: Extension versions automatically match Jena version (5.6.0)
- **Zero-Config**: Extensions are automatically managed - no manual JAR handling required
- **EmptyDir Caching**: Extensions cached in ephemeral storage, no image bloat

#### Helm Chart Enhancements
- Added `inference.enabled`, `inference.preset`, `inference.customConfig` configuration options
- Added `extensions.text.enabled`, `extensions.geosparql.enabled`, `extensions.shacl.enabled`, `extensions.shex.enabled`
- Added init container for extension downloads (conditional on extension flags)
- Added extensions emptyDir volume with read-only mount to main container
- Added assembler-config ConfigMap for inference support
- Updated deployment to conditionally pass --config flag when inference enabled

### Changed
- **entrypoint.sh**: Enhanced to build dynamic classpath including extension JARs
- **deployment.yaml**: Added init container, volumes, and mounts for extensions and inference
- **values.yaml**: Added comprehensive configuration sections for inference and extensions
- **README.md**: Added "Advanced Features" section documenting inference and extensions
- **Helm README.md**: Added "Inference and Reasoning" and "Extensions" sections with examples

### Documentation
- Added inference preset documentation with use cases and performance characteristics
- Added extension documentation with features, use cases, and links to Apache Jena docs
- Updated Features list to highlight inference and extensions support
- Added Values Reference table entries for all new configuration options

## [v5.6.0-1] - 2025-12-17

### Added

#### Docker Image
- **Web UI Support**: Full Vue 3 admin interface automatically extracted from JAR on container startup
- **Multi-architecture**: Support for both linux/amd64 and linux/arm64
- **Optimized Image**: ~150MB Alpine Linux base with custom JDK built via jlink
- **Enhanced Entrypoint**: Automatic UI extraction to `$FUSEKI_BASE/webapp` on first run
- **Health Checks**: Built-in `/$/ping` endpoint for container orchestration
- **Security**: Runs as non-root user (fuseki:fuseki UID/GID 1000)

#### Helm Chart (v1.0.0)
- **Production-Ready Deployment**: Complete Kubernetes Helm chart in `helm/jena-fuseki/`
- **Multiple Security Modes**:
  - Open Access Mode (for private networks): `security.adminPassword=disabled`
  - Public Read Mode: UI and queries public, writes protected
  - Full Authentication Mode: Everything requires auth
  - Localhost-Only Mode: Admin endpoints restricted to localhost
- **Gateway API Support**: Native HTTPRoute configuration for modern Kubernetes ingress
- **Traditional Ingress Support**: Compatible with Nginx, Traefik, etc.
- **Persistent Storage**: Configurable PVC for TDB2 databases
- **Flexible Configuration**:
  - `ui.enabled`: Toggle between UI mode and headless SPARQL server
  - `security.localhostOnly`: Control admin endpoint access
  - `security.publicRead`: Enable public read access to datasets
  - `security.privateDatasets`: List datasets requiring full authentication
- **Resource Management**: Configurable CPU/memory requests and limits
- **Pod Security**: Non-root, read-only filesystem where possible

#### Documentation
- **Comprehensive README**: Enhanced with project information, versioning scheme, official Apache Jena links
- **Helm Chart README**: Complete guide with 5 security configuration modes
- **Production Examples**: Sample values files for different deployment scenarios
- **Docker Examples**: Basic run, persistent storage, and Docker Compose configurations
- **Security Warnings**: Clear documentation that authentication has not been production-tested

#### Features
- **Automatic UI Extraction**: Extracts Vue 3 UI from JAR to filesystem on startup
- **Shiro Integration**: Apache Shiro security framework with configurable access control
- **TDB2 Support**: Persistent triple store with configurable storage location
- **SPARQL 1.1**: Full SPARQL query and update endpoint support
- **Monitoring Endpoints**: `/$/ping`, `/$/stats`, `/$/metrics`, `/$/server`

### Changed
- **Versioning Scheme**: Adopted `vX.Y.Z-N` format where X.Y.Z matches Apache Jena Fuseki version and N is the build number
- **Base Image**: Upgraded to Alpine 3.21
- **JDK**: Custom minimal JDK built with jlink for reduced image size
- **FUSEKI_BASE**: Now defaults to `/fuseki/run` for runtime files, separate from `/fuseki/databases`

### Fixed
- **UI 404 Errors**: Properly extracts and serves UI files from JAR
- **Authentication Issues**: Configured Shiro BasicHttpAuthenticationFilter (note: requires production testing)
- **Localhost Restrictions**: Added open access mode to bypass Fuseki's default localhost-only admin restrictions
- **Volume Mounts**: Separated runtime files (`/fuseki/run`) from persistent data (`/fuseki/databases`)

### Security
- **⚠️ IMPORTANT**: Authentication with Shiro has not been fully tested in production
- **⚠️ RECOMMENDATION**: Only use this deployment on private networks with proper network-level security
- For production use with authentication, additional testing and validation is required

### Testing
- ✅ Docker run tests: UI loads correctly at localhost:3030
- ✅ Endpoint tests: `/$/server`, `/$/ping` working
- ✅ Security tests: `/$/datasets` correctly restricted with default config
- ✅ Kubernetes deployment: Tested on AKS with Gateway API
- ✅ Internal domain deployment: Successfully deployed to `jena.int.tech.games`

### Known Issues
- **HTTP Basic Auth**: API endpoint authentication returns 401 even with correct credentials (UI login form may work differently)
- **Pod Naming**: Pods are named `fuseki-jena-fuseki-*` instead of `jena-fuseki-*` (fix pending)
- **RWO Volume Multi-Attach**: Rolling updates require manual old pod scaling due to ReadWriteOnce PVC limitations

### Infrastructure
- **Docker Hub**: Automated multi-arch builds at `conceptkernel/jena-fuseki`
- **GitHub**: Source repository at `github.com/ConceptKernel/jena-fuseki-dockerfile`
- **Base Version**: Apache Jena Fuseki 5.6.0 (October 2025)

### Upstream
- Based on Apache Jena Fuseki 5.6.0
- SHA1 checksum verification of downloaded artifacts
- No modifications to Fuseki JAR itself

---

## Version Format

```
v5.6.0-1
  │││  └─ Build number (incremented for jena-fuseki-dockerfile changes)
  │││
  └┴┴─ Apache Jena Fuseki version (5.6.0)
```

**Examples**:
- `v5.6.0-1`: Initial release based on Fuseki 5.6.0
- `v5.6.0-2`: Updated Helm chart for same Fuseki version
- `v5.7.0-1`: New Fuseki upstream release

---

[v5.6.0-1]: https://github.com/ConceptKernel/jena-fuseki-dockerfile/releases/tag/v5.6.0-1
