### GitHub CLI (gh) Authentication Guide

#### 1. **Install GitHub CLI**

Before starting the authentication process, make sure you have GitHub CLI installed. You can find installation instructions on the [GitHub CLI installation page](https://cli.github.com/).

#### 2. **Authenticate with GitHub CLI**

1. **Start Authentication**

    Open your terminal and run the following command to start the authentication process:

    ```sh
    gh auth login
    ```

2. **Choose Authentication Method**

    You will be prompted to choose a method for authentication. You can choose between:

    - **Login with a web browser**: This is the recommended method as it provides a more secure authentication process.
    - **Authenticate with a personal access token (PAT)**: Useful if you prefer not to use the browser or need to automate the process.

    If you choose the browser method, you'll be given a URL to open in your browser. If you choose PAT, you'll need to generate a PAT from your GitHub account settings.

3. **Login with Web Browser**

    If you choose to login with a web browser, follow these steps:

    - Copy the provided URL and paste it into your web browser.
    - Log in to your GitHub account if prompted.
    - Authorize GitHub CLI to access your GitHub account by granting the necessary permissions.
    - After successful authentication, you'll receive a verification code. Enter this code into your terminal when prompted.

4. **Login with Personal Access Token**

    If you choose to authenticate with a PAT:

    - Go to your GitHub account settings and generate a new PAT with the required scopes (e.g., `repo`, `delete_repo`).
    - Paste the PAT into your terminal when prompted.

#### 3. **Authorize Specific Permissions**

To authorize GitHub CLI for specific permissions like deleting repositories, you may need to refresh your authentication and grant additional scopes:

1. **Refresh Authentication**

    Run the following command to refresh your authentication and add permissions:

    ```sh
    gh auth refresh -s delete_repo
    ```

    This command updates the authentication to include the `delete_repo` scope, allowing you to delete repositories via the CLI.

2. **Verify Authorization**

    To ensure that the authorization is complete, you can check the scopes granted to GitHub CLI:

    ```sh
    gh auth status
    ```

    This will display the authentication status and the permissions granted.

#### 4. **Troubleshooting**

If you encounter issues during authentication, consider the following:

- **Check for Correct Scopes**: Ensure that the personal access token has the correct scopes if you’re using PAT.
- **Reauthenticate**: If issues persist, try re-authenticating with `gh auth login` and follow the steps again.
- **Consult GitHub CLI Documentation**: Refer to the [GitHub CLI documentation](https://cli.github.com/manual/) for more detailed information and troubleshooting steps.

---