# gcp-typescript-cloudrun-function-cookiecutter-template

GCP TypeScript Cloud Run Function Boilerplate Template

## Prerequisites

### Required Programs

Before setting up this project, ensure the following programs are installed:

### Xcode CLI

To use homebrew to install Python packages, you need a compiler

```bash
xcode-select --install
```

### Homebrew

Homebrew is a package manager for macOS, used to install other tools like `asdf` and `jq`.

Installation:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### jq

jq is a lightweight and flexible command-line JSON processor, used for automating JSON file generation.

Installation:

```bash
brew install jq
```

### asdf

asdf is a version manager for multiple runtimes like Python, Node.js, Java, Go, etc.

Installation:

```bash
brew install asdf
```

- Add asdf to your shell by adding the following lines to your shell configuration (~/.zshrc or ~/.bashrc):

  For `~/.zshrc`:

  ```bash
  echo '. $(brew --prefix asdf)/libexec/asdf.sh' >> ~/.zshrc
  ```

  For `~/.bashrc`:

  ```bash
  echo '. $(brew --prefix asdf)/libexec/asdf.sh' >> ~/.bashrc
  ```

- After adding the line, reload the shell configuration file for the changes to take effect:

  For `~/.zshrc`:

  ```bash
  source ~/.zshrc
  ```

  For `~/.bashrc`:

  ```bash
  source ~/.bashrc
  ```

### python

- Install the Python plugin and Python 3.12.7 using asdf:

  ```bash
  asdf plugin add python
  asdf install python 3.12.7
  asdf global python 3.12.7
  ```

- Verify the installation:

  ```bash
  python --version
  ```

### Cookiecutter

- Cookiecutter is a command-line utility that creates projects from project templates. It makes starting new projects easier by generating directory structures with sensible defaults. Install it using pip:

  ```bash
  pip install cookiecutter
  ```

  - Creating boilerplate repo:

    ```bash
    cookiecutter https://github.com/nodejs-projects-kenanhancer/gcp-typescript-cloudrun-function-cookiecutter-template.git
    ```
