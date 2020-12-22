# vim:ft=sh

# Bubble Theme
# Inspired by bubblewritten and agnoster
# written by hohmannr

# SYMBOL CONSTANTS
blub_left=''
blub_right=''

# prompt_symbol='|->'
prompt_symbol='||>'


user_symbol='%n'
user_machine_symbol=' גּ '
machine_symbol='%M'

filepath_symbol='%~'

git_branch_symbol=''
git_clean_symbol=''
git_modified_symbol='•'
git_added_symbol=''
git_deleted_symbol=''
git_renamed_symbol=''
git_untracked_symbol='裸'
git_copied_symbol=''
git_unmerged_symbol='!'
git_stashed_symbol=''

ssh_symbol='ssh'

# COLOR CONSTANTS
# NOTE: Possible values include zsh-color-strings like 'red', 'black', 'magenta' etc. Aswell as zsh-color-codes which you can list with the command 'spectrum_ls', e.g. '078' for the 78th color code.
bubble_color='black'

prompt_symbol_color='blue'
prompt_symbol_error_color='red'

user_color='green'
user_machine_symbol_color='green'
machine_color='magenta'

filepath_color='blue'
dir_color='blue'

git_clean_color='green'
git_unstaged_color='yellow'
git_staged_color='magenta' 
git_stashed_color='blue'
git_unmerged_color='red'
git_symbols_color='black'

ssh_symbol_color='black'
ssh_bubble_color='green'

# Config for bits stollen from Spaceship:
SPACESHIP_DIR_SHOW="${SPACESHIP_DIR_SHOW=true}"
SPACESHIP_DIR_TRUNC="${SPACESHIP_DIR_TRUNC=4}"
SPACESHIP_DIR_TRUNC_PREFIX="${SPACESHIP_DIR_TRUNC_PREFIX=}"
SPACESHIP_DIR_TRUNC_REPO="${SPACESHIP_DIR_TRUNC_REPO=true}"

SPACESHIP_TIME_SHOW="${SPACESHIP_TIME_SHOW=true}"
SPACESHIP_TIME_FORMAT="${SPACESHIP_TIME_FORMAT=false}"
SPACESHIP_TIME_12HR="${SPACESHIP_TIME_12HR=false}"
SPACESHIP_TIME_COLOR="${SPACESHIP_TIME_COLOR="yellow"}"

SPACESHIP_BATTERY_SHOW="${SPACESHIP_BATTERY_SHOW=always}"
SPACESHIP_BATTERY_SYMBOL_CHARGING="${SPACESHIP_BATTERY_SYMBOL_CHARGING=""}"
SPACESHIP_BATTERY_SYMBOL_DISCHARGING="${SPACESHIP_BATTERY_SYMBOL_DISCHARGING=""}"
SPACESHIP_BATTERY_SYMBOL_FULL="${SPACESHIP_BATTERY_SYMBOL_FULL=""}"
SPACESHIP_BATTERY_THRESHOLD="${SPACESHIP_BATTERY_THRESHOLD=99}"

SPACESHIP_KUBECTL_SHOW="${SPACESHIP_KUBECTL_SHOW=true}"
SPACESHIP_KUBECTL_COLOR="${SPACESHIP_KUBECTL_COLOR="magenta"}"
SPACESHIP_KUBECTL_SYMBOL="${SPACESHIP_KUBECTL_SYMBOL="⎈"}"



# HELPER FUNCTIONS
bubblify () {
    # This is a helper function to build custom bubbles.
    # 
    # ARGS      VALUES          DESC
    # ----      ------          ----
    # 1.        {0, 1, 2, 3}        0: build left side bubble: content█
    #                               1: build right side bubble: █content                
    #                               2: build middle part: █content█
    #                               3: build custom colored whole bubble: content
    #
    # 2.        string              content to be displayed in partial bubble
    #
    # 3.        {'red', '073' ...}  foreground color (text color) as zsh-color-string or zsh-color-code
    #
    # 4.        {'red', '073' ...}  background color (bubble segment color) as zsh-color-string or zsh-color-code

    if [[ $1 -eq 0 ]]; then
        echo -n "$(foreground $4)$blub_left$(foreground $3)$(background $4)$2%{$reset_color%}"
    elif [[ $1 -eq 1 ]]; then
        echo -n "$(foreground $3)$(background $4)$2%{$reset_color%}"
    elif [[ $1 -eq 2 ]]; then
        echo -n "$(foreground $3)$(background $4)$2%{$reset_color%}$(foreground $4)$blub_right%{$reset_color%}"
    elif [[ $1 -eq 3 ]]; then
        echo -n "$(foreground $4)$blub_left$(foreground $3)$(background $4)$2%{$reset_color%}$(foreground $4)$blub_right%{$reset_color%}"
    else
        echo -n 'bblfy_fail'
    fi
}

foreground () {
    # Helper function for 256 color support beyond basic color terms such as 'black', 'red' ...
    if [[ $1 =~ '[0-9]{3}' && $1 -le 255 && $1 -ge 0 ]]; then
        echo -n "%{$FG[$1]%}"
    else
        echo -n "%{$fg[$1]%}"
    fi
}

background () {
    # Helper function for 256 color support beyond basic color terms such as 'black', 'red' ...
    if [[ $1 =~ '[0-9]{3}' && $1 -le 255 && $1 -ge 0 ]]; then
        echo "%{$BG[$1]%}"
    else
        echo "%{$bg[$1]%}"
    fi
}

# ------------------------------------------------------------------------------
# UTILS
# Utils for common used actions
# ------------------------------------------------------------------------------

# Check if command exists in $PATH
# USAGE:
#   spaceship::exists <command>
spaceship::exists() {
  command -v $1 > /dev/null 2>&1
}

# Check if the current directory is in a Git repository.
# USAGE:
#   spaceship::is_git
spaceship::is_git() {
  # See https://git.io/fp8Pa for related discussion
  [[ $(command git rev-parse --is-inside-work-tree 2>/dev/null) == true ]]
}


# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------
SPACESHIP_KUBECTL_VERSION_SHOW="${SPACESHIP_KUBECTL_VERSION_SHOW=true}"
SPACESHIP_KUBECTL_VERSION_PREFIX="${SPACESHIP_KUBECTL_VERSION_PREFIX=""}"
SPACESHIP_KUBECTL_VERSION_SUFFIX="${SPACESHIP_KUBECTL_VERSION_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_KUBECTL_VERSION_COLOR="${SPACESHIP_KUBECTL_VERSION_COLOR="cyan"}"

# Show current kubectl version
spaceship_kubectl_version() {
  [[ $SPACESHIP_KUBECTL_VERSION_SHOW == false ]] && return

  spaceship::exists kubectl || return

  # if kubectl can't connect kubernetes cluster, kubernetes version section will be not shown
  local kubectl_version=$(kubectl version --short 2>/dev/null | grep "Server Version" | sed 's/Server Version: \(.*\)/\1/')
  [[ -z $kubectl_version ]] && return
}

# Show current context in kubectl
spaceship_kubectl_context() {
  [[ $SPACESHIP_KUBECONTEXT_SHOW == false ]] && return

  spaceship::exists kubectl || return

  local kube_context=$(kubectl config current-context 2>/dev/null)
  [[ -z $kube_context ]] && return

  if [[ $SPACESHIP_KUBECONTEXT_NAMESPACE_SHOW == true ]]; then
    local kube_namespace=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
    [[ -n $kube_namespace && "$kube_namespace" != "default" ]] && kube_context="$kube_context ($kube_namespace)"
  fi

  # Apply custom color to section if $kube_context matches a pattern defined in SPACESHIP_KUBECONTEXT_COLOR_GROUPS array.
  # See Options.md for usage example.
  local len=${#SPACESHIP_KUBECONTEXT_COLOR_GROUPS[@]}
  local it_to=$((len / 2))
  local 'section_color' 'i'
  for ((i = 1; i <= $it_to; i++)); do
    local idx=$(((i - 1) * 2))
    local color="${SPACESHIP_KUBECONTEXT_COLOR_GROUPS[$idx + 1]}"
    local pattern="${SPACESHIP_KUBECONTEXT_COLOR_GROUPS[$idx + 2]}"
    if [[ "$kube_context" =~ "$pattern" ]]; then
      section_color=$color
      break
    fi
  done

  [[ -z "$section_color" ]] && section_color=$SPACESHIP_KUBECONTEXT_COLOR
}




# PROMPT FUNCTIONS
git_bubble () {
    # This parses 'git status -s' to retrieve all necessary information...I am new to this zsh scripting...mercy!
    local git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)

    if [[ -n $git_branch ]]; then

        local git_branch_trimmed=$(echo "$git_branch" | cut -f1,2 -d'-')
        # If trimmed, add "..."
        if [ $git_branch != $git_branch_trimmed ]; then
          git_branch_trimmed="${git_branch_trimmed}..."
        fi

        # branch name with symbol, initialize symbols and git status output
        local git_info="$git_branch_symbol $git_branch_trimmed"
        local git_info="$git_branch_symbol $git_branch"
        local git_symbols=""
        local git_status=$(git status -s 2> /dev/null | awk '{print substr($0,1,2)}') 

        # used for coloring (and some for icons)
        local git_unmerged=$(grep -m1 -E -- 'U|DD|AA' <<< $git_status)
        local git_branch_stashed=$(git stash list | grep $git_branch)
        local git_unstaged=$(echo -n $git_status | awk '{print substr($0,2,1)}')

        # used for icons
        local git_not_clean=$git_status
        local git_modified=$(grep -m1 'M' <<< $git_status)
        local git_added=$(grep -m1 'A' <<< $git_status)
        local git_deleted=$(grep -m1 'D' <<< $git_status)
        local git_untracked=$(grep -m1 '??' <<< $git_status)
        local git_renamed=$(grep -m1 'R' <<< $git_status)
        local git_copied=$(grep -m1 'C' <<< $git_status)

        # coloring
        if [[ -n $git_unmerged ]]; then
            local git_color=$git_unmerged_color   
            git_symbols="$git_symbols$git_unmerged_symbol"
        elif [[ -n $git_branch_stashed ]]; then
            local git_color=$git_stashed_color
            git_symbols="$git_symbols$git_stashed_symbol"
        elif [[ -n "${git_unstaged//[$' \t\r\n']}" && -n $git_not_clean ]]; then
            local git_color=$git_unstaged_color
        elif [[ -z "${git_unstaged//[$' \t\r\n']}" && -n $git_not_clean ]]; then
            local git_color=$git_staged_color
        else
            local git_color=$git_clean_color
            git_symbols="$git_symbols$git_clean_symbol"
        fi

        # icons
        if [[ -n $git_modified ]]; then
            git_symbols="$git_symbols$git_modified_symbol"
        fi
        if [[ -n $git_added ]]; then
            git_symbols="$git_symbols$git_added_symbol"
        fi
        if [[ -n $git_deleted ]]; then
            git_symbols="$git_symbols$git_deleted_symbol"
        fi
        if [[ -n $git_untracked ]]; then
            git_symbols="$git_symbols$git_untracked_symbol"
        fi
        if [[ -n $git_renamed ]]; then
            git_symbols="$git_symbols$git_renamed_symbol"
        fi
        if [[ -n $git_copied ]]; then
            git_symbols="$git_symbols$git_copied_symbol"
        fi

        echo -n "$(bubblify 0 "$git_info " $git_color $bubble_color)$(bubblify 2 " $git_symbols" $git_symbols_color $git_color) "
    fi
}

ssh_bubble () {
    # detects an ssh connection and displays a bubble 
    if [[ -n $SSH_CLIENT || -n $SSH_TTY || -n $SSH_CONNECTION ]]; then
        echo -n "$(bubblify 3 "$ssh_symbol" $ssh_symbol_color $ssh_bubble_color) "
    fi
}

dir_bubble () {
  [[ $SPACESHIP_DIR_SHOW == false ]] && return

  local 'dir' 'trunc_prefix'

  # Threat repo root as a top-level directory or not
  if [[ $SPACESHIP_DIR_TRUNC_REPO == true ]] && spaceship::is_git; then
    local git_root=$(git rev-parse --show-toplevel)

    # Check if the parent of the $git_root is "/"
    if [[ $git_root:h == / ]]; then
      trunc_prefix=/
    else
      trunc_prefix=$SPACESHIP_DIR_TRUNC_PREFIX
    fi

    # `${NAME#PATTERN}` removes a leading prefix PATTERN from NAME.
    # `$~~` avoids `GLOB_SUBST` so that `$git_root` won't actually be
    # considered a pattern and matched literally, even if someone turns that on.
    # `$git_root` has symlinks resolved, so we use `${PWD:A}` which resolves
    # symlinks in the working directory.
    # See "Parameter Expansion" under the Zsh manual.
    dir="$trunc_prefix$git_root:t${${PWD:A}#$~~git_root}"
  else
    if [[ SPACESHIP_DIR_TRUNC -gt 0 ]]; then
      # `%(N~|TRUE-TEXT|FALSE-TEXT)` replaces `TRUE-TEXT` if the current path,
      # with prefix replacement, has at least N elements relative to the root
      # directory else `FALSE-TEXT`.
      # See "Prompt Expansion" under the Zsh manual.
      trunc_prefix="%($((SPACESHIP_DIR_TRUNC + 1))~|$SPACESHIP_DIR_TRUNC_PREFIX|)"
    fi

    dir="$trunc_prefix%${SPACESHIP_DIR_TRUNC}~"
  fi

  if [[ ! -w . ]]; then
    SPACESHIP_DIR_SUFFIX="%F{$SPACESHIP_DIR_LOCK_COLOR}${SPACESHIP_DIR_LOCK_SYMBOL}%f${SPACESHIP_DIR_SUFFIX}"
  fi

  echo -n "$bubble_left$(foreground $dir_color)$dir$bubble_right"
}

time_bubble () {
  [[ $SPACESHIP_TIME_SHOW == false ]] && return

  local 'time_str'

  if [[ $SPACESHIP_TIME_FORMAT != false ]]; then
    time_str="${SPACESHIP_TIME_FORMAT}"
  elif [[ $SPACESHIP_TIME_12HR == true ]]; then
    time_str="%D{%r}"
  else
    time_str="%D{%T}"
  fi
  echo -n "$bubble_left$(foreground $SPACESHIP_TIME_COLOR)$time_str$bubble_right"
}

# Show section only if either of follow is true
# - Always show is true
# - battery percentage is below the given limit (default: 10%)
# - Battery is fully charged
# Escape % for display since it's a special character in zsh prompt expansion
battery_bubble () {
  [[ $SPACESHIP_BATTERY_SHOW == false ]] && return

  local battery_data battery_percent battery_status battery_color

  if spaceship::exists pmset; then
    battery_data=$(pmset -g batt | grep "InternalBattery")

    # Return if no internal battery
    [[ -z "$battery_data" ]] && return

    battery_percent="$( echo $battery_data | grep -oE '[0-9]{1,3}%' )"
    battery_status="$( echo $battery_data | awk -F '; *' '{ print $2 }' )"
  elif spaceship::exists acpi; then
    battery_data=$(acpi -b 2>/dev/null | head -1)

    # Return if no battery
    [[ -z $battery_data ]] && return

    battery_status_and_percent="$(echo $battery_data |  sed 's/Battery [0-9]*: \(.*\), \([0-9]*\)%.*/\1:\2/')"
    battery_status_and_percent_array=("${(@s/:/)battery_status_and_percent}")
    battery_status=$battery_status_and_percent_array[1]:l
    battery_percent=$battery_status_and_percent_array[2]

	# If battery is 0% charge, battery likely doesn't exist.
    [[ $battery_percent == "0" ]] && return

  elif spaceship::exists upower; then
    local battery=$(command upower -e | grep battery | head -1)

    # Return if no battery
    [[ -z $battery ]] && return

    battery_data=$(upower -i $battery)
    battery_percent="$( echo "$battery_data" | grep percentage | awk '{print $2}' )"
    battery_status="$( echo "$battery_data" | grep state | awk '{print $2}' )"
  else
    return
  fi

  # Remove trailing % and symbols for comparison
  battery_percent="$(echo $battery_percent | tr -d '%[,;]')"

  # Change color based on battery percentage
  if [[ $battery_percent == 100 || $battery_status =~ "(charged|full)" ]]; then
    battery_color="green"
  elif [[ $battery_percent -lt $SPACESHIP_BATTERY_THRESHOLD ]]; then
    battery_color="red"
  else
    battery_color="yellow"
  fi

  # Battery indicator based on current status of battery
  if [[ $battery_status == "charging" ]];then
    battery_symbol="${SPACESHIP_BATTERY_SYMBOL_CHARGING}"
  elif [[ $battery_status =~ "^[dD]ischarg.*" ]]; then
    battery_symbol="${SPACESHIP_BATTERY_SYMBOL_DISCHARGING}"
  else
    battery_symbol="${SPACESHIP_BATTERY_SYMBOL_FULL}"
  fi


  echo -n "$(bubblify 0 "$battery_percent " $battery_color $bubble_color)$(bubblify 2 " $battery_symbol" $bubble_color $battery_color) "
}


# Show both kubectl version and kubectl context:
#   spaceship_kubectl_version
#   spaceship_kubectl_context
kubectl_bubble () {
  [[ $SPACESHIP_KUBECTL_SHOW == false ]] && return

  local kubectl_version="$(spaceship_kubectl_version)" kubectl_context="$(spaceship_kubectl_context)"

  [[ -z $kubectl_version && -z $kubectl_context ]] && return

  echo -n "$(bubblify 0 "$kubectl_context " $SPACESHIP_KUBECTL_COLOR $bubble_color)$(bubblify 2 " $SPACESHIP_KUBECTL_SYMBOL" $bubble_color $SPACESHIP_KUBECTL_COLOR) "
}



testing_bubble () {
    # tests color support
    echo -n "$(bubblify 0 "Zelda " "black" "088")$(bubblify 1 " Link " "black" "089")$(bubblify 1 " Daruk " "black" "090")$(bubblify 1 " Urbosa " "black" "091")$(bubblify 1 " Mipha " "black" "092")$(bubblify 2 " Revali" "black" "093")$_newline$_newline"
    echo -n "$(bubblify 0 "Zelda " "black" "166")$(bubblify 1 " Link " "black" "167")$(bubblify 1 " Daruk " "black" "168")$(bubblify 1 " Urbosa " "black" "169")$(bubblify 1 " Mipha " "black" "170")$(bubblify 2 " Revali" "black" "171")$_newline$_newline"
    echo -n "$(bubblify 0 "Zelda " "black" "082")$(bubblify 1 " Link " "black" "083")$(bubblify 1 " Daruk " "black" "084")$(bubblify 1 " Urbosa " "black" "085")$(bubblify 1 " Mipha " "black" "086")$(bubblify 2 " Revali" "black" "087") "
}

# DEFAULT PROMPT BUILDING BLOCKS
bubble_left="$(foreground $bubble_color)$blub_left%{$reset_color%}$(background $bubble_color)"
bubble_right="%{$reset_color%}$(foreground $bubble_color)$blub_right%{$reset_color%} "

end_of_prompt_bubble="$bubble_left%(?,$(foreground $prompt_symbol_color)$prompt_symbol,$(foreground $prompt_symbol_error_color)$prompt_symbol)$bubble_right"

end_of_prompt=" %(?,$(foreground $prompt_symbol_color)$prompt_symbol,$(foreground $prompt_symbol_error_color)$prompt_symbol%{$reset_color%}) "

# user_machine_bubble="$bubble_left$(foreground $user_color)$user_symbol$(foreground $user_machine_symbol_color)$user_machine_symbol$(foreground $machine_color)$machine_symbol$bubble_right"
user_machine_bubble="$bubble_left$(foreground $user_color)$user_symbol$bubble_right"

filepath_bubble="$bubble_left$(foreground $filepath_color)$filepath_symbol$bubble_right"

error_code_bubble="%(?,,$bubble_left$(foreground $prompt_symbol_error_color)%?$bubble_right)"

# PROMPTS
# different prompts to try out, just uncomment/comment

# --- 1 ---
#PROMPT='$(ssh_bubble)$user_machine_bubble$filepath_bubble$(git_bubble)'

# --- 2 ---
#PROMPT='$end_of_prompt_bubble'
#RPROMPT='$(ssh_bubble)$filepath_bubble$(git_bubble)$error_code_bubble'

# --- 3 ---
_newline=$'\n'
_lineup=$'\e[1A'
_linedown=$'\e[1B'

PROMPT='$(ssh_bubble)$user_machine_bubble$(dir_bubble)$_newline$(git_bubble)$(kubectl_bubble)$error_code_bubble$end_of_prompt%{$reset_color%}'
RPROMPT='%{$_lineup%}$(time_bubble)$(battery_bubble)%{$_linedown%}%{$reset_color%}'