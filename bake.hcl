variable "environment" {
  default = "testing"
  validation {
    condition = contains(["testing", "production"], environment)
    error_message = "environment must be either testing or production"
  }
}

variable "registry" {
  default = "localhost:5000"
}

fullname = ( environment == "testing") ? "${registry}/postgresql-testing" : "{registry}/postgresql"
now = timestamp()

target "postgresql" {
  matrix = {
    tgt = ["minimal", "standard"]
    pgVersion = [
//      "13.18",
//      "14.15",
//      "15.10",
      "16.6",
      "17.2"
    ]
    distroVersion = [
 //     "bookworm-20241223-slim",
      "bullseye-20241223-slim"
    ]
  }
  dockerfile = "Dockerfile"
  name = "postgresql-${index(split(".",pgVersion),0)}-${index(split("-",distroVersion),0)}-${tgt}"
  tags = [
    "${fullname}:${index(split(".",pgVersion),0)}-${index(split("-",distroVersion),0)}-${tgt}",
    "${fullname}:${pgVersion}-${index(split("-",distroVersion),0)}-${tgt}",
    "${fullname}:${pgVersion}-${formatdate("YYYYMMDDhhmm", now)}-${index(split("-",distroVersion),0)}-${tgt}"
  ]
  context = "."
  target = "${tgt}"
  args = {
    PG_VERSION = "${pgVersion}"
    DISTRO  = "debian:${distroVersion}"
    BUILDTIME = "${now}"
    REVISION = "${formatdate("YYYYMMDDhhmm", now)}"
  }
  attest = [
    "type=provenance,mode=max",
    "type=sbom"
  ]
  annotations = [
    "index,manifest:org.opencontainers.image.created=${now}",
    "index,manifest:org.opencontainers.image.url=https://github.com/cloudnative-pg/postgres-containers",
    "index,manifest:org.opencontainers.image.source=https://github.com/cloudnative-pg/postgres-containers",
    "index,manifest:org.opencontainers.image.version=${pgVersion}",
    "index,manifest:org.opencontainers.image.revision=${formatdate("YYYYMMDDhhmm", now)}",
    "index,manifest:org.opencontainers.image.vendor=The CloudNativePG Contributors",
    "index,manifest:org.opencontainers.image.title=CloudNativePG PostgreSQL ${pgVersion} minimal",
    "index,manifest:org.opencontainers.image.description=A minimal PostgreSQL ${pgVersion} container image",
    "index,manifest:org.opencontainers.image.documentation=https://github.com/cloudnative-pg/postgres-containers",
    "index,manifest:org.opencontainers.image.authors=The CloudNativePG Contributors",
    "index,manifest:org.opencontainers.image.licenses=Apache-2.0"
  ]
//  platforms = ["linux/amd64", "linux/arm64"]
}
