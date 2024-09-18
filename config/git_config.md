### Git Configuration

#### Configure Git

1. Configure Git globally:
  ```sh
  git config --global -e
  ```

2. If you haven't set your default editor, configure it:
  ```sh
  sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 100
  sudo update-alternatives --config editor
  ```

3. Insert the following configuration into your global `.gitconfig` file:
  ```ini
  [user]
    name = Example Name
    email = example@mail.com
  [core]
    editor = nvim --wait
    autocrlf = input
  [init]
    defaultBranch = master
  ```

4. Use SSH instead of HTTP to avoid repeated use of GitHub tokens.

#### Generate SSH Key Pairs

1. Generate SSH key pairs:
  ```sh
  ssh-keygen -t ed25519 -b 4096 -C "example@mail.com"
  ```

2. Copy the public key to your GitHub account.

3. Edit your `~/.ssh/config` file:
  ```sh
  nano ~/.ssh/config
  ```

4. Add the following content to the file:
  ```ini
  Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
  ```

5. Start the SSH agent:
  ```sh
  eval "$(ssh-agent -s)"
  ```

6. Add the SSH key to the agent:
  ```sh
  ssh-add ~/.ssh/id_ed25519
  ```

7. Verify your GitHub connection:
  ```sh
  ssh -vT git@github.com
  ```

8. Finally, Clone your repository using SSH:
  ```sh
  git clone git@github.com:github_username/repo
  ```
---