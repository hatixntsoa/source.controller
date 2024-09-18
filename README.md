## Simple Git & GitHub Shell Scripts

### Prerequisites
  - **Packages** : ``git`` ``gh``
  > git and github cli should be installed  
    and they need to be well configured to work

``GitHub CLI Guide`` :   [Gh Config](config/gh_config.md)  
``Git Guide`` :   [Git Config](config/git_config.md)  

___

### Scripts Installation (Local)

- **Clone the repo**
```sh
git clone https://github.com/h471x/git_gh.git
```
- **Change directory**
```sh
cd git_gh
```
- **Execution Permissions**
```sh
chmod u+x {gh_scripts/*,git_scripts/*,setup/*}
```
- **Install the script**
```sh
./setup/install.sh
```