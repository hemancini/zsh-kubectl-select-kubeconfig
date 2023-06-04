# zsh-kubectl-select-kubeconfig

A zsh plugin for kubectl and eks clusters, handles kubeconfig files from a directory and displays a prompt function. This plugin only works with previously configured aws profiles.

## Requirements

- [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh#basic-installation)
- [kubectl](https://kubernetes.io/releases/download/#kubectl)
- [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

## Installation

1. Clone this repository in oh-my-zsh's plugins directory:

   ```zsh
   git clone https://github.com/hemancini/zsh-kubectl-select-kubeconfig.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-kubectl-select-kubeconfig
   ```

2. Activate the plugin in `~/.zshrc`:

   ```zsh
   plugins=(... kubectl-select-kubeconfig)
   ```

3. Prompt function

   You can add the current eks cluste in your prompt by adding `$(kubectl_prompt)`
   to your `PROMPT` or `RPROMPT` variable.

   ```sh
   RPROMPT='$(kubectl_prompt)'
   ```

4. Restart zsh (such as by opening a new instance of your terminal emulator).

   ```zsh
   source ~/.zshrc
   ```

## Plugin commands

- `ksc <kubeconfig>`: sets `$KUBECONFIG` and `$KUBE_CONFIG_PATH`. Display in `kubectl_prompt`.
  Run `ksc` without arguments to clear the kubeconfig.
- `ksc ls`: list all kubeconfig files in `$KSC_BASEPATH`.
- `ksc help`: display help message.

## Plugin options

- set `$KSC_BASEPATH` to the directory where your kubeconfig files are stored. Default: `~/.kubeconfigs`

## Configuration

Kubeconfig files in directory `~/.kubeconfigs`:

```zsh
ls -1 ~/.kubeconfigs
my-kubeconfig-1
my-kubeconfig-2
my-kubeconfig-3
```

The kubeconfig files must have the following parameters `my-kubeconfig-1`:

```yaml
users:
  - name: <context>
    user:
      exec:
        ...
        env:
          - name: AWS_PROFILE
            value: source-profile-name
```

You can configure the kubeconfig files with the following command:

```zsh
aws eks update-kubeconfig --name <cluster_name> --dry-run > ~/.kubeconfigs/<my-kubeconfig-1>
```

Source profile credentials in `~/.aws/credentials`:

```ini
[source-profile-name]
aws_access_key_id = ...
aws_secret_access_key = ...
```
