#!/bin/bash
set -e # exit on first error (used for return)
TAG_REGEX="^[0-9]+\.[0-9]+\.[0-9]+$"

message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

getHotfixReleaseVersion() {
  # Get the latest tag from the master branch, if any
  LATEST_TAG=$(git describe --tags --abbrev=0 $(git rev-list --tags --max-count=1 master) 2>/dev/null)  || true

  # Check if LATEST_TAG is not empty
  if [[ -z "$LATEST_TAG" ]]; then
    echo "Error: No tags found, aborting hotfix..."
    exit 1
  fi

  # Validate LATEST_TAG format
  if [[ ! "$LATEST_TAG" =~ $TAG_REGEX ]]; then
    echo "Error: LATEST_TAG is not in the valid format (e.g., X.Y.Z)"
    exit 1
  fi

  # Split LATEST_TAG into parts
  IFS='.' read -r V_MAJOR V_MINOR V_PATCH <<< "$LATEST_TAG"

  # Increment the minor version
  ((V_PATCH++))

  # Create the RELEASE_VERSION
  RELEASE_VERSION="$V_MAJOR.$V_MINOR.$V_PATCH"
}

updateProjectVersion() {
  # Check if a pom.xml file exists
  pom_file=$(find . -maxdepth 1 -name "pom.xml" -print -quit)

  if [[ -n "$pom_file" ]]; then
    # Use Maven to update the project version
    mvn versions:set -DnewVersion="$RELEASE_VERSION" --no-transfer-progress
    echo "Updated version to $RELEASE_VERSION in $pom_file"
  else
    echo "Error: pom.xml not found."
    exit 1
  fi
}

message ">>> Starting hotfix"

[[ ! -x "$(command -v gh)" ]] && echo "gh not found, you need to install github CLI" && exit 1
[[ ! -x "$(command -v mvn)" ]] && echo "mvn not found, you need to install maven CLI" && exit 1

gh auth status

# 1. Make sure branch is set to master
[[ $(git rev-parse --abbrev-ref HEAD) != "master" ]] && echo "ERROR: Checkout to master" && exit 1

# 2. Make sure branch is clean
[[ $(git status --porcelain --untracked-files=no -- . ':(exclude).gitflow') ]] && echo "ERROR: The branch is not clean, commit your changes before creating the release" && exit 1

message ">>> Pulling master"
git pull origin master
message ">>> Pulling tags"
git fetch --prune

getHotfixReleaseVersion

message ">>> Checking for SNAPSHOT dependencies"
if mvn help:all-profiles 2>/dev/null | grep -q "enforce-no-snapshots"; then
  mvn validate -Penforce-no-snapshots -Pci-build --no-transfer-progress
  message ">>> No SNAPSHOT dependencies found"
else
  message ">>> WARNING: 'enforce-no-snapshots' Maven profile not found — skipping SNAPSHOT dependency check"
fi

message ">>> Hotfix: $RELEASE_VERSION"

BRANCH_NAME="hotfix/$RELEASE_VERSION"

# 3. Start hotfix
read -r -p "Proceed to create the branch '$BRANCH_NAME' [Y/n]:  " RESPONSE
if [[ $RESPONSE =~ ^([yY][eE][sS]|[yY])$ ]]; then

  message ">>>>> Creating branch '$BRANCH_NAME' from master..."
  git checkout -b "$BRANCH_NAME" $LATEST_TAG

  message ">>> Update project to version: $RELEASE_VERSION"
  updateProjectVersion

  git commit -a -m "update project version to $RELEASE_VERSION"
  git push -u origin "$BRANCH_NAME"
  gh pr create --base master --head "$BRANCH_NAME" --title "Hotfix - $RELEASE_VERSION" --fill

else

  message "Action cancelled exiting..."
  exit 1

fi