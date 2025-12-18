# Release Process

This document outlines the professional release process for the jena-fuseki-dockerfile project.

## Version Scheme

We use a modified semantic versioning format: `vX.Y.Z-N`

- `X.Y.Z` = Apache Jena Fuseki version (must match official release)
- `N` = Build number (incremental for our image builds)

Examples:
- `v5.6.0-1` → Apache Jena 5.6.0, first build
- `v5.6.0-2` → Apache Jena 5.6.0, second build (bug fix, feature addition)
- `v5.7.0-1` → Apache Jena 5.7.0, first build

## Pre-Release Checklist

Before creating a release, ensure:

1. **Verify Apache Jena version exists**
   ```bash
   JENA_VERSION="5.6.0"
   curl -I "https://repo1.maven.org/maven2/org/apache/jena/apache-jena/${JENA_VERSION}/apache-jena-${JENA_VERSION}.tar.gz"
   # Should return HTTP 200
   ```

2. **Update version references**
   - [ ] `CHANGELOG.md`: Convert Unreleased section to new version
   - [ ] `README.md`: Update current release badge
   - [ ] `helm/jena-fuseki/Chart.yaml`: Bump chart version
   - [ ] `helm/jena-fuseki/Chart.yaml`: Update appVersion if Jena version changed

3. **Local testing** (optional but recommended)
   ```bash
   # Test build locally
   podman build --build-arg JENA_VERSION=5.6.0 -t jena-fuseki:test .

   # Test run
   podman run -p 3030:3030 jena-fuseki:test

   # Verify UI accessible at http://localhost:3030
   ```

4. **Commit version updates**
   ```bash
   git add CHANGELOG.md README.md helm/jena-fuseki/Chart.yaml
   git commit -m "Prepare vX.Y.Z-N release"
   git push origin main
   ```

## Release Procedure

### 1. Create and Push Git Tag

```bash
# Create annotated tag with release notes
git tag -a vX.Y.Z-N -m "$(cat <<'EOF'
Brief release title

## What's Changed
- Feature 1
- Feature 2
- Bug fix 3

## Docker Images
- `conceptkernel/jena-fuseki:X.Y.Z-N`
- `conceptkernel/jena-fuseki:X.Y`
- `conceptkernel/jena-fuseki:X`
- `conceptkernel/jena-fuseki:latest`

**Full Changelog**: https://github.com/ConceptKernel/jena-fuseki-dockerfile/compare/vPREV...vX.Y.Z-N
EOF
)"

# Push tag to trigger GitHub Actions
git push origin vX.Y.Z-N
```

### 2. Monitor GitHub Actions Workflow

**CRITICAL**: Do not assume success. Actively monitor the workflow.

```bash
# Watch workflow status
gh run watch

# Or check workflow list
gh run list --limit 3
```

**Expected workflow steps:**
1. ✅ Validate Release Version (~10 seconds)
   - Extracts versions
   - Validates Jena version exists on Maven Central
2. ✅ Build Multi-arch Docker Image (~4-5 minutes)
   - Builds linux/amd64 and linux/arm64
   - Pushes to Docker Hub
   - Updates Docker Hub description

**If validation fails:**
- Delete the tag: `git push origin :refs/tags/vX.Y.Z-N`
- Fix the issue (wrong version, missing Jena release, etc.)
- Recreate and push the corrected tag

**If build fails:**
- Check logs: `gh run view --log-failed`
- Delete tag, fix issue, recreate tag

### 3. Verify Docker Hub Publication

**Do not skip this step.**

```bash
# Check Docker Hub API
curl -s "https://hub.docker.com/v2/repositories/conceptkernel/jena-fuseki/tags" | jq '.results[] | select(.name == "X.Y.Z-N")'

# Or manually verify at:
# https://hub.docker.com/r/conceptkernel/jena-fuseki/tags
```

Expected tags:
- `X.Y.Z-N` (specific build)
- `X.Y` (minor version)
- `X` (major version)
- `latest`

All tags should show:
- Updated timestamp matching workflow completion
- ~144 MB compressed size
- linux/amd64, linux/arm64 platforms

### 4. Create GitHub Release

```bash
# Create published release (NOT draft)
gh release create vX.Y.Z-N \
  --title "vX.Y.Z-N: Brief Title" \
  --notes-file /tmp/release-notes.md \
  --latest

# Release notes template: /tmp/release-notes.md
```

**Release notes template:**
```markdown
## 🚀 Features / 🐛 Fixes / 🔧 Changes

- Feature 1 description
- Bug fix description
- Configuration change

## 📦 Docker Images

All images available on Docker Hub:

- `conceptkernel/jena-fuseki:X.Y.Z-N` (specific release)
- `conceptkernel/jena-fuseki:X.Y` (minor version track)
- `conceptkernel/jena-fuseki:X` (major version track)
- `conceptkernel/jena-fuseki:latest`

**Multi-architecture support:**
- linux/amd64
- linux/arm64

**Quick Start:**
```bash
docker pull conceptkernel/jena-fuseki:X.Y.Z-N
docker run -p 3030:3030 conceptkernel/jena-fuseki:X.Y.Z-N
```

**Apache Jena Fuseki Version:** X.Y.Z

## 📚 Documentation

- [Docker Hub](https://hub.docker.com/r/conceptkernel/jena-fuseki)
- [GitHub Repository](https://github.com/ConceptKernel/jena-fuseki-dockerfile)
- [Helm Chart README](helm/jena-fuseki/README.md)
- [CHANGELOG](CHANGELOG.md)

**Full Changelog**: https://github.com/ConceptKernel/jena-fuseki-dockerfile/compare/vPREV...vX.Y.Z-N
```

### 5. Verify GitHub Release

```bash
# Check release status
gh release list --limit 3

# Expected output:
# vX.Y.Z-N: Title    Latest    vX.Y.Z-N    YYYY-MM-DDTHH:MM:SSZ
```

Verify:
- [ ] Release is published (not Draft)
- [ ] Release is marked as "Latest"
- [ ] Release notes are complete and formatted correctly
- [ ] Links work

### 6. Post-Release Verification

**Final checklist:**

1. **Docker Hub**
   - [ ] All 4 tags visible and updated
   - [ ] README updated with latest version
   - [ ] Image size reasonable (~144 MB)

2. **GitHub**
   - [ ] Release published and marked Latest
   - [ ] Tag exists in repository
   - [ ] Actions workflow succeeded

3. **Functionality** (spot check)
   ```bash
   docker pull conceptkernel/jena-fuseki:X.Y.Z-N
   docker run -d -p 3030:3030 --name fuseki-test conceptkernel/jena-fuseki:X.Y.Z-N

   # Wait 10 seconds for startup
   curl http://localhost:3030/$/ping
   # Should return: {"status":"ok"}

   # Check UI accessible
   open http://localhost:3030

   # Cleanup
   docker stop fuseki-test && docker rm fuseki-test
   ```

## Troubleshooting

### Workflow fails validation

**Error:** `Apache Jena X.Y.Z not found on Maven Central`

**Solution:**
1. Verify Jena version exists: https://repo1.maven.org/maven2/org/apache/jena/apache-jena/
2. Check for typos in tag version
3. Ensure using official Jena version (not a pre-release)

### Build succeeds but images not on Docker Hub

**Possible causes:**
1. Docker Hub login failed (check secrets)
2. Push step timed out
3. Docker Hub experiencing issues

**Solution:**
1. Check workflow logs: `gh run view --log`
2. Verify DOCKER_PASSWORD secret is valid
3. Re-run workflow: `gh run rerun <run-id>`

### Release created as Draft

**Solution:**
```bash
gh release edit vX.Y.Z-N --draft=false --latest
```

### Wrong version published

**If caught immediately (within 1 hour):**
1. Delete Docker Hub tags manually via web UI
2. Delete GitHub release: `gh release delete vX.Y.Z-N`
3. Delete git tag: `git push origin :refs/tags/vX.Y.Z-N`
4. Fix issue and restart release process

**If published for >1 hour:**
1. DO NOT delete - users may have pulled the image
2. Create a new corrected release with incremented build number
3. Mark incorrect release as deprecated in release notes

## Automation Safeguards

The GitHub Actions workflow includes:

1. **Pre-build validation**
   - Verifies Jena version exists on Maven Central
   - Extracts and validates version format
   - Fails fast before expensive multi-arch build

2. **Version extraction**
   - Automatically strips build number for JENA_VERSION
   - Creates appropriate Docker tags
   - Prevents manual version mismatches

3. **Multi-arch build**
   - Uses GitHub Actions cache for faster builds
   - Provenance disabled for compatibility

## Release Cadence

- **Jena version updates**: Release when new Apache Jena versions are published
- **Feature additions**: Increment build number (e.g., v5.6.0-1 → v5.6.0-2)
- **Bug fixes**: Increment build number
- **Chart updates**: Bump chart version in Chart.yaml

## Communication

After successful release:
- Update any deployment documentation
- Notify users in relevant channels if breaking changes
- Update Helm chart repository if maintaining one
