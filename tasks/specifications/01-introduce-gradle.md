# Introduce Gradle Projects

The `release` and `hotfix` scripts ONLY handle projects that use Apache Maven for their build management. I want these scripts to handle Gradle projects.

## TODO
1. Analyse how the `release` and  `hotfix` scripts will change to accommodate Gradle projects.
2. Use standard script patterns to separate concerns i.e. clearly seperate Maven and Gradle implementations

## Points to Consider
1. Provide a recommendation on how to handle the gitflow submodule for the Gradle implementation.
2. Provide a recommendation on how to skip the submodule update when necessary like when the build is run on the build server
3. How to enforce the NO SNAPSHOTS dependency for the Gradle implementation.
4. This will impact the the /Users/donald/10x/awesomatic.co.za/github-actions-workflows/.github/workflows/build.yml and /Users/donald/10x/awesomatic.co.za/github-actions-workflows/.github/workflows/release.yml  
    - Take speciail note of the `merge-2-develop` step as well.
5. Draw all diagrams using Mermaid - provide a good contrast between font and fill-in colours.

> NOTE: Do NOT implement this yet - write an implementation plan that I can review. Write a task list that you can pick up and implement after the review