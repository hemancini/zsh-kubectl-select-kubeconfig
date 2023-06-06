#!/bin/zsh

alias k="kubectl"

function ksc() {
  if [[ -z "$1" ]]; then
    unset KUBECONFIG KUBE_CONFIG_PATH
    echo "Kubeconfig cleared." >&2
    return 0
  fi

  if [[ ! -d "${KSC_BASEPATH:-$HOME/.kubeconfigs}" ]]; then
    echo "${fg[red]}kubeconfig base path '${KSC_BASEPATH:-$HOME/.kubeconfigs}' not found${reset_color}" >&2
    return 1
  fi

  if [[ "$1" == "ls" ]]; then
    _ksc_kubeconfig_list
    return 0
  fi

  if [[ "$1" == "help" ]]; then
    _ksc_usage
    return 0
  fi

  local -a available_kubeconfigs
  available_kubeconfigs=($(_ksc_kubeconfig_list))
  if [[ -z "${available_kubeconfigs[(r)$1]}" ]]; then
    echo "${fg[red]}kubeconfig file '$1' not found in '${KSC_BASEPATH:-$HOME/.kubeconfigs}'" >&2
    echo "Available kubeconfig files: ${(j:, :)available_kubeconfigs:-no profiles found}${reset_color}" >&2
    return 1
  fi

  local kube_config="${KSC_BASEPATH:-$HOME/.kubeconfigs}/$1"
  export KUBECONFIG="$kube_config"
  export KUBE_CONFIG_PATH="$kube_config"

  local context="$(_ksc_current_context)"
  local ksc_aws_profile="$(_ksc_current_aws_profile $context)"

  local -a available_profiles
  available_profiles=($(_ksc_aws_profiles))
  if [[ -z "${available_profiles[(r)$ksc_aws_profile]}" ]]; then
    echo "${fg[red]}Profile '$ksc_aws_profile' not found in '${AWS_CONFIG_FILE:-$HOME/.aws/config}'" >&2
    echo "Available profiles: ${(j:, :)available_profiles:-no profiles found}${reset_color}" >&2
    unset KUBECONFIG KUBE_CONFIG_PATH
    return 1
  fi

  return 0
}

function _ksc_usage() {
    cat <<EOF
Usage:

    ksc <kubeconfig>
    ksc <command>

The commands are:

    ls          list kubeconfig files
    help        show this help
    no command  clear kubeconfig

EOF
}

function _ksc_kubeconfig_list() {
  ls -1 ${KSC_BASEPATH:-$HOME/.kubeconfigs} 2> /dev/null && return
}

function _ksc_current_context(){
  if ! context="$(kubectl config current-context 2> /dev/null)"; then
      echo -e "${fg[red]}Context not found${reset_color}" >&2
      return 1
  fi
  echo $context
}

function _ksc_aws_profiles() {
  aws --no-cli-pager configure list-profiles 2> /dev/null && return
  [[ -r "${AWS_CONFIG_FILE:-$HOME/.aws/config}" ]] || return 1
  grep --color=never -Eo '\[.*\]' "${AWS_CONFIG_FILE:-$HOME/.aws/config}" | sed -E 's/^[[:space:]]*\[(profile)?[[:space:]]*([^[:space:]]+)\][[:space:]]*$/\2/g'
}

function _ksc_current_aws_profile(){
  if ! ksc_aws_profile="$(kubectl config view -o "jsonpath={.users[?(@.name==\"$1\")].user.exec.env[0].value}" 2> /dev/null)"; then
      echo -e "${fg[red]}AWS profile '$1' not found${reset_color}" >&2
      return 1
  fi
  echo $ksc_aws_profile
}

function kubectl_prompt() {

  if [[ -z "$KUBECONFIG" ]]; then
    return 0
  fi

  # check if envdir is loaded and if so, set KUBECONFIG
  if [[ ! -z "$DIRENV_FILE" && ! -z "$KUBECONFIG" ]]; then
    local envrc_kubeconfig="$(echo "$DIRENV_FILE" | awk -F '/.envrc' '{print $1}')/$KUBECONFIG"
    if [[ -f "$envrc_kubeconfig" ]]; then
      export KUBECONFIG="$envrc_kubeconfig"
      export KUBE_CONFIG_PATH="$envrc_kubeconfig"
    fi
  fi

  local prompt_context() {
    echo -e "%{$FG[033]%}$1%{$reset_color%}" && return
  }

  local context="$(_ksc_current_context)"
  if [[ -z "$context" ]]; then
    prompt_context "context not found"
    return 1
  fi
  
  local cluster_name="$(kubectl config view -o "jsonpath={.contexts[?(@.name==\"$context\")].context.cluster}" | awk -F'/' '{print $2}')"
  local ksc_aws_profile="$(_ksc_current_aws_profile $context)"

  if [[ -z "$cluster_name" ]]; then
    prompt_context "cluster not found"
  elif [[ ! -z "$ksc_aws_profile" && "$cluster_name" != "$ksc_aws_profile" ]]; then
    prompt_context "$ksc_aws_profile:$cluster_name"
  else
    prompt_context "$cluster_name"
  fi
}
