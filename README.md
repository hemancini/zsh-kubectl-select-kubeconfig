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
   plugins=(... zsh-kubectl-select-kubeconfig)
   ```

3. Restart zsh (such as by opening a new instance of your terminal emulator) or execute:

   ```zsh
   source ~/.zshrc
   ```

## Aliases

| Alias | Command   |
| ----- | --------- |
| `k`   | `kubectl` |

## Plugin commands

- `ksc <kubeconfig>`: sets `$KUBECONFIG` and `$KUBE_CONFIG_PATH`. Display in `kubectl_prompt_info`.
  Run `ksc` without arguments to clear the kubeconfig.
- `ksc ls`: list all kubeconfig files in `$KSC_BASEPATH`.
- `ksc help`: display help message.

## Plugin options

- set `KSC_BASEPATH` to the directory where your kubeconfig files are stored. Default: `~/.kubeconfigs`
- Set `SHOW_KSC_PROMPT=false` in your zshrc file if you want to prevent the plugin from modifying your RPROMPT. Some themes might overwrite the value of RPROMPT instead of appending to it.

## Theme

The plugin creates an `kubectl_prompt_info` function that you can use in your theme, which displays
the current `cluster name`. It uses four variables to control how that is shown:

- ZSH_THEME_KSC_COLOR: sets the color of the prompt. Defaults to `033`. Use `spectrum_ls` to display the colors possible.
- ZSH_THEME_KSC_PREFIX: sets the prefix of the prompt. Defaults to `<`.
- ZSH_THEME_KSC_SUFFIX: sets the suffix of the prompt. Defaults to `>`.

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
