# git-scripts

# Installation

1. Clone repository
2. Add git-commands subdir to PATH
3. Make sure that scripts in git-commands and git-hooks directories are executable
4. Configure repository where you want to use these commands
    ```
    git config jira.key KEY
    git config jira.url URL
    git config jira.username USERNAME
    ```

# GitBash
1. In your ~./gitconfig file use "windoux" style path for include
```
[include]
    path = "c:/path/to/your/git-repos/git-scripts/git-alias"
```
