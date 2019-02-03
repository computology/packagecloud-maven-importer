# packagecloud Maven Importer

Command line utility to import/mirror artifacts from a local Maven repository to a [packagecloud.io](https://packagecloud.io/l/maven-repository) repository.

## Features

  * Supports JAR, WAR, POM, AAR and APK artifacts (along with their checksums, signatures, sources, and javadocs). However, `-SNAPSHOT` artifacts are __not__ supported.

  * Only imports newly seen artifacts, can be run from cron to periodically mirror new artifacts.

  * Import can be resumed if it fails.

## Installation

This gem requires that the `sqlite3` development libraries be present on your system prior to installation. To install these, try running `brew install sqlite3`, `yum install sqlite-devel` or `apt-get install libsqlite3-dev`.

    gem install packagecloud-maven-importer

## Examples

To import a repository located at `~/.m2/repository` into a packagecloud repository `capotej/mvntest`, you would run:

    packagecloud-maven-importer --username capotej \
    --repository mvntest                           \
    --api-token 101010101                          \
    --maven-repository-path ~/.m2/repository

For automation (such as periodic mirroring to a packagecloud repository), make sure to pass `--yes` to skip any confirmations.

To blow away the local artifact database and process/upload everything again, pass `--force-start-over`.

## How it works

packagecloud maven importer builds a database of supported artifacts found at `--maven-repository-path`, then tries to upload them all one by one. On subsequent runs, it uses this database to only upload newly found artifacts (if any).


## Usage

          Usage: packagecloud-maven-importer [options]                                                                      
    -m PATH_TO_MAVEN_REPOSITORY,     Path to local Maven repository (Example: ~/.m2/repository)
        --maven-repository-path
    -u, --username USERNAME          packagecloud username
    -h, --hostname HOSTNAME          packagecloud hostname
    -p, --port PORT                  packagecloud port
    -s, --scheme SCHEME              packagecloud scheme (http/https)
    -r, --repository REPOSITORY      packagecloud repository
    -a, --api-token API_TOKEN        packagecloud API token
    -y, --yes                        Answer yes to any questions
    -f, --force-start-over           Clear local artifact database and start over
    -d PATH_TO_DATABASE,             Path to local artifact database (for resuming uploads/incremental sync)
        --database-path

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in this project's, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/packagecloud-maven-importer/blob/master/CODE_OF_CONDUCT.md).

Copyright 2019 Computology, LLC
