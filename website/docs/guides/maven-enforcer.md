---
id: maven-enforcer
title: Preventing SNAPSHOT Dependencies in Releases
sidebar_position: 1
---

# Preventing SNAPSHOT Dependencies in Releases

By default the `release.sh` and `hotfix.sh` scripts check whether a Maven profile called `enforce-no-snapshots` exists in the project. If it does, they run `mvn enforcer:enforce -Penforce-no-snapshots` **before** creating any branch. If any non-test dependency is a SNAPSHOT version the build fails immediately with a clear message — before a branch or PR is created.

Projects that have not configured the profile receive a warning and the script continues. This makes adoption gradual and non-breaking.

## Why This Matters

Shipping a SNAPSHOT dependency to production means you're releasing code that is, by definition, not yet stable. The same artifact coordinates could produce a different binary tomorrow. The Enforcer check eliminates this risk.

## Setting Up the Profile

Add the following profile to your project's `pom.xml`:

```xml
<profiles>
  <profile>
    <id>enforce-no-snapshots</id>
    <build>
      <plugins>
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-enforcer-plugin</artifactId>
          <version>3.5.0</version>
          <executions>
            <execution>
              <id>no-snapshot-deps</id>
              <phase>validate</phase>
              <goals>
                <goal>enforce</goal>
              </goals>
              <configuration>
                <rules>
                  <requireReleaseDeps>
                    <message>SNAPSHOT dependencies are not allowed in a release build. Please update all dependencies to release versions.</message>
                    <failWhenParentIsSnapshot>false</failWhenParentIsSnapshot>
                    <excludes>
                      <!-- Exclude test-scoped dependencies -->
                      <exclude>*:*:*:*:test</exclude>
                    </excludes>
                  </requireReleaseDeps>
                </rules>
                <fail>true</fail>
              </configuration>
            </execution>
          </executions>
        </plugin>
      </plugins>
    </build>
  </profile>
</profiles>
```

### Key Configuration Choices

| Setting | Value | Reason |
|---------|-------|--------|
| `failWhenParentIsSnapshot` | `false` | The project itself lives at `x.y.z-SNAPSHOT` on `develop` — only *dependency* SNAPSHOTs are disallowed |
| Test scope exclusion | `*:*:*:*:test` | Allows SNAPSHOT test libraries (Spock, Spring Boot Test starters) without blocking releases |
| Profile isolation | `enforce-no-snapshots` | Normal `mvn clean verify` is unaffected; only the release/hotfix scripts opt in |

## Verifying the Setup

**Confirm the profile is recognised:**
```bash
mvn help:all-profiles
```
The output should include `enforce-no-snapshots`.

**Confirm the rule passes with your current dependencies:**
```bash
mvn validate -Penforce-no-snapshots -Pci-build
```
Expected: `BUILD SUCCESS`.

**Confirm the rule fires on a SNAPSHOT dependency (optional smoke test):**

Temporarily change a dependency version in `pom.xml` to `x.y.z-SNAPSHOT`, run the command above, and verify you get:
```
BUILD FAILURE
SNAPSHOT dependencies are not allowed in a release build.
```
Revert the temporary change immediately.

## How the Scripts Use the Profile

Both `release.sh` and `hotfix.sh` contain this guard:

```bash
if mvn help:all-profiles -q 2>/dev/null | grep -q "enforce-no-snapshots"; then
  mvn validate -Penforce-no-snapshots -Pci-build --no-transfer-progress
else
  # Profile not present — warn and continue
  echo "WARNING: 'enforce-no-snapshots' profile not found — skipping SNAPSHOT check"
fi
```

The check runs **after** the latest commits are pulled but **before** any branch is created, so failures are fast and leave no git artifacts to clean up.
