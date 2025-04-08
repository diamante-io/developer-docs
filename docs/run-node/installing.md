# Installing

Installing Diamante Core from source is the recommended method for developers who seek maximum control over their installation. While it may require more effort compared to using pre-built packages or Docker images, building from source ensures that you have the most up-to-date version and allows for customization as per your requirements. Additionally, building from source enables you to contribute to the Diamante Core project and understand its internals more deeply. Therefore, it is the preferred option for developers who prioritize control and flexibility over convenience.

<!-- ### Docker-based Installation

#### Development Environments

DDF maintains a quickstart image that bundles Diamante Core with aurora and PostgreSQL databases. It's a quick way to set up a default, non-validating, ephemeral configuration that should work for most developers.

In addition to DDF images, Satoshipay maintains separate Docker images for Diamante Core and aurora. The Satoshipay Diamante Core Docker image comes in a few flavors, including one with the AWS CLI installed and one with the Google Cloud SDK installed. The aurora image supports all aurora environment variables.

#### Production Environments

The DDF also maintains a Diamante-Core-only standalone image: diamante/diamante-core.

Example usage:

```bash
docker run diamante/diamante-core:latest help
docker run diamante/diamante-core:latest gen-seed
```

To run the daemon, you need to provide a configuration file:

```bash
# Initialize PostgreSQL DB (see DATABASE config option)
docker run -v "/path/to/config/dir:/etc/diamante/" diamante/diamante-core:latest new-db
# Run diamante-core daemon in the background
docker run -d -v "/path/to/config/dir:/etc/diamante/" diamante/diamante-core:latest run
```

The image utilizes deb packages, so it's possible to confirm the checksum of the diamante-core binary in the Docker image matches that in the cryptographically signed deb package. See the packages documentation for information on installing Debian packages. To calculate checksum in the Docker image, you can run:

```bash
docker run --entrypoint=/bin/sha256sum diamante/diamante-core:latest /usr/bin/diamante-core

```

### Package-based Installation

If you are using Ubuntu 18.04 LTS or later, we provide the latest stable releases of diamante-core and diamante-aurora in Debian binary package format.

You may choose to install these packages individually, which offers the greatest flexibility but requires manual creation of the relevant configuration files and configuration of a PostgreSQL database. -->

### Installing from source

See the [install from source](https://github.com/diamante-io/Diamante-Net-Core/blob/master/INSTALL.md) for build instructions.

### Release Version

In general, you should install the latest release build. Builds are backward compatible and are cumulative.

The version number scheme that we follow is `protocol_version.release_number.patch_number` where:

- `protocol_version` is the maximum protocol version supported by that release (all versions are 100% backward compatible),
- `release_number` is bumped when a set of new features or bug fixes not impacting the protocol are included in the release,
- `patch_number` is used when a critical fix has to be deployed.
