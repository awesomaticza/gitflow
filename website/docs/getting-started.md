---
id: getting-started
title: Getting Started
sidebar_position: 2
---

# Getting Started

This guide walks you through adding `gitflow` to a Maven project from scratch.

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| `gh` | GitHub CLI — creates PRs automatically | [Install GitHub CLI](https://cli.github.com/) |
| `make` | Delegates commands to the submodule | `brew install make` / `apt install make` |
| `mvn` | Maven — reads and writes the project version | [Install Maven](https://maven.apache.org/install.html) |

### Authenticate GitHub CLI

```bash
gh auth login
```

Follow the prompts: select `GitHub.com`, `SSH` protocol, and `Login with a web browser`.

## Step 1 — Add the Git Submodule

:::warning Use your own fork
The SSH URL below points to the `awesomaticza/gitflow` repository. Adding it directly as a submodule will fail unless your SSH key is authorised on that repository.

**Fork [awesomaticza/gitflow](https://github.com/awesomaticza/gitflow) into your own GitHub account or organisation first**, then substitute your fork's SSH URL in the command below. This way you own the submodule and can push changes freely.
:::

From the root of your project:

```bash
git submodule add git@github.com:<your-org>/gitflow.git .gitflow
```

This creates a `.gitflow/` folder that contains the scripts and Makefile.

## Step 2 — Create the Root `Makefile`

Create a `Makefile` that delegates the commands to the submodule's `Makefile`.

```makefile
GITFLOW_DIR := .gitflow
include $(GITFLOW_DIR)/Makefile
```

## Step 3 — Configure Maven to Initialise the Submodule

Add the following to your `pom.xml` so the submodule is checked out and kept up to date:

```xml
<build>
  <plugins>
    <plugin>
      <groupId>org.codehaus.mojo</groupId>
      <artifactId>exec-maven-plugin</artifactId>
      <version>3.5.1</version>
      <executions>
        <execution>
          <id>update-submodules</id>
          <phase>validate</phase>
          <goals><goal>exec</goal></goals>
          <configuration>
            <executable>git</executable>
            <arguments>
              <argument>submodule</argument>
              <argument>update</argument>
              <argument>--init</argument>
              <argument>--remote</argument>
            </arguments>
          </configuration>
        </execution>
        <execution>
          <id>make-hotfix-executable</id>
          <phase>validate</phase>
          <goals><goal>exec</goal></goals>
          <configuration>
            <executable>chmod</executable>
            <arguments>
              <argument>+x</argument>
              <argument>./.gitflow/scripts/hotfix.sh</argument>
            </arguments>
          </configuration>
        </execution>
        <execution>
          <id>make-release-executable</id>
          <phase>validate</phase>
          <goals><goal>exec</goal></goals>
          <configuration>
            <executable>chmod</executable>
            <arguments>
              <argument>+x</argument>
              <argument>./.gitflow/scripts/release.sh</argument>
            </arguments>
          </configuration>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
```

### Skip the Submodule Update on CI Builds

On a build server the submodule is already checked out by the CI system. Add this profile to suppress the `git submodule update` during CI builds:

```xml
<profiles>
  <profile>
    <id>build</id>
    <build>
      <plugins>
        <plugin>
          <groupId>org.codehaus.mojo</groupId>
          <artifactId>exec-maven-plugin</artifactId>
          <executions>
            <execution><id>update-submodules</id><phase>none</phase></execution>
            <execution><id>make-hotfix-executable</id><phase>none</phase></execution>
            <execution><id>make-release-executable</id><phase>none</phase></execution>
          </executions>
        </plugin>
      </plugins>
    </build>
  </profile>
</profiles>
```

Activate it in CI:
```bash
mvn clean package -Pbuild
```

## Step 4 — Commit

```bash
git commit -a -m "add gitflow as a submodule"
```

## Step 5 — Verify

```bash
make help

Usage:
  make 
  help             Show this help message.
  release          Create release
  hotfix           Create hotfix
```

Expected output lists the `release` and `hotfix` targets.
