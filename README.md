## Simple Git & GitHub Shell Scripts

### Description
These shell scripts are crafted to enhance and streamline your `Git` and `GitHub CLI` workflows.  
By leveraging the **GitHub API**, they allow you to perform ``essential GitHub operations directly from the terminal``.  
  
Whether you need to `create`, `delete`, `change visibility`, or `manage collaborators`  
for your GitHub repositories, these scripts enable you to do so efficiently  
``without ever leaving the command line``.

### Prerequisites
- **Packages**: Ensure `git` and `gh` are installed and properly configured.
  - **GitHub CLI Guide**: [Gh Config](config/gh_config.md)
  - **Git Guide**: [Git Config](config/git_config.md)
- **Font**: `Nerd Font` is recommended for optimal display.

### Scripts Installation (Local)

1. **Clone the repository**
  ```sh
  git clone https://github.com/hatixntsoa/source_controller.git
  ```
2. **Navigate to the directory**
  ```sh
  cd git_gh
  ```
3. **Set execution permissions**
  ```sh
  chmod u+x {gh_scripts/*,git_scripts/*,setup/*}
  ```
4. **Run the installation script**
  ```sh
  ./setup/install.sh
  ```

### Usages

Once the scripts are installed, you can check for them by running:
```sh
ls -l $(whereis sh | grep -o '/[^ ]*/bin' | head -n 1) | grep 'git_gh' | awk '{print $NF}' | xargs -n 1 basename | sed 's/\.sh$//'
```

- **gh Scripts** : GitHub operations management

| **Name** | **Usage** |
|----------|-----------|
| `ghc`    | Create a new repository |
| `ghf`    | Fork a repository |
| `ghd`    | Delete an existing repository |
| `ghv`    | View and toggle an existing repository's visibility |
| `gck`    | Create a new branch locally and remotely |
| `gcln`   | Clone a repository |
| `gbd`    | Delete an existing branch locally and remotely |
| `ghadd`  | Add a new collaborator to the repository by username |
| `ghdel`  | Remove an existing collaborator from the repository by username |
| `ghcls`  | List all collaborators for the repository by usernames |

- **git Scripts** : common git operations (optional)

| **Name** | **Usage** |
|----------|-----------|
| `gad`    | Add and Commit changes |
| `gcb`    | Switch to the previously checked-out branch |
| `gdf`    | Short for git diff |
| `glc`    | Display the number of commits with last messages made by the current user |
| `gmb`    | Merge the specified branch into the current branch |
| `gnm`    | Rename the current branch |
| `gpsh`   | Push local commits to its remote |
| `gpl`    | Pull remote commits to local |
| `gst`    | Short for git status -s |
| `grst`   | Restore changes made |
