#!/bin/bash
set -e # exit on first error (used for return)

message() {
  echo -e "\n######################################################################"
  echo "# $1"
  echo "######################################################################"
}

getReleaseVersion() {
  PROJECT_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
  RELEASE_VERSION=$(echo "$PROJECT_VERSION" | sed 's/-SNAPSHOT//')
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

message ">>> Starting release"

[[ ! -x "$(command -v gh)" ]] && echo "gh not found, you need to install github CLI" && exit 1
[[ ! -x "$(command -v mvn)" ]] && echo "mvn not found, you need to install maven CLI" && exit 1

gh auth status

# 1. Make sure branch is set to develop
[[ $(git rev-parse --abbrev-ref HEAD) != "develop" ]] && echo "ERROR: Checkout to develop" && exit 1

# 2. Make sure branch is clean
[[ $(git status --porcelain --untracked-files=no -- . ':(exclude).gitflow') ]] && echo "ERROR: The branch is not clean, commit your changes before creating the release" && exit 1

# Retrieve the commit hash argument
COMMIT_HASH=$1

# Check if COMMIT_HASH is provided
if [ -z "$COMMIT_HASH" ]; then
  message ">>> Pull lastest changes from develop"
  git pull origin develop
else
  message ">>> Checkout commit hash from develop: $COMMIT_HASH"
  git checkout "$COMMIT_HASH"
fi

message ">>> Pulling tags"
git fetch --prune

getReleaseVersion

message ">>> Checking for SNAPSHOT dependencies"
if mvn help:all-profiles 2>/dev/null | grep -q "enforce-no-snapshots"; then
  mvn validate -Penforce-no-snapshots -Pbuild --no-transfer-progress
  message ">>> No SNAPSHOT dependencies found"
else
  message ">>> WARNING: 'enforce-no-snapshots' Maven profile not found — skipping SNAPSHOT dependency check"
fi

message ">>> Release: $RELEASE_VERSION"

# Get the latest tag from the master branch, if any
LATEST_TAG=$(git describe --tags --abbrev=0 $(git rev-list --tags --max-count=1 master) 2>/dev/null) || true
if [[ -z "$LATEST_TAG" ]]; then
  read -r -p "Proceed to create release '$RELEASE_VERSION'? [Y/n]:  " RESPONSE
else
  read -r -p "Last release version was '$LATEST_TAG', proceed to create release '$RELEASE_VERSION'? [Y/n]:  " RESPONSE
fi

if [[ $RESPONSE =~ ^([yY][eE][sS]|[yY])$ ]]; then

  BRANCH_NAME="release/$RELEASE_VERSION"
  message ">>>>> Create branch '$BRANCH_NAME' from develop"

  git switch -c "$BRANCH_NAME"

  message ">>> Update project to version: $RELEASE_VERSION"
  updateProjectVersion

  git commit -a -m "update project version to $RELEASE_VERSION"
  git push -u origin "$BRANCH_NAME"
  gh pr create --base master --head "$BRANCH_NAME" --title "Release - $RELEASE_VERSION" --fill

else

  message "Action cancelled exiting..."
  exit 1

fi
