# vim filetype declaration for highlighting
# vim:ft=sh

# Bubble Theme
# Inspired by bubblewritten and agnoster
# written by hohmannr

# SYMBOL CONSTANTS
blub_left=''
blub_right=''

prompt_symbol='-->'

user_symbol='%n'
user_machine_symbol='@' machine_symbol='%M'

filepath_symbol='%~'

git_branch_symbol=''
git_new_symbol=''
git_deleted_symbol=''
git_modified_symbol='•'
git_renamed_symbol=''
git_untracked_symbol='裸'

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

git_default_color='green'
git_modified_color='yellow'
git_staged_color='magenta' 
git_icons_color='black'

ssh_symbol_color='black'
ssh_bubble_color='green'

# Config for bits stollen from Spaceship:
SPACESHIP_DIR_SHOW="${SPACESHIP_DIR_SHOW=true}"
SPACESHIP_DIR_PREFIX="${SPACESHIP_DIR_PREFIX="in "}"
SPACESHIP_DIR_TRUNC="${SPACESHIP_DIR_TRUNC=4}"
SPACESHIP_DIR_TRUNC_PREFIX="${SPACESHIP_DIR_TRUNC_PREFIX=}"
SPACESHIP_DIR_TRUNC_REPO="${SPACESHIP_DIR_TRUNC_REPO=true}"

SPACESHIP_TIME_SHOW="${SPACESHIP_TIME_SHOW=false}"
SPACESHIP_TIME_PREFIX="${SPACESHIP_TIME_PREFIX="at "}"
SPACESHIP_TIME_SUFFIX="${SPACESHIP_TIME_SUFFIX="$SPACESHIP_PROMPT_DEFAULT_SUFFIX"}"
SPACESHIP_TIME_FORMAT="${SPACESHIP_TIME_FORMAT=false}"
SPACESHIP_TIME_12HR="${SPACESHIP_TIME_12HR=false}"
SPACESHIP_TIME_COLOR="${SPACESHIP_TIME_COLOR="yellow"}"



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

# PROMPT FUNCTIONS
git_bubble () {
    # This parses git status in a very very ugly and dirty way to retrieve all necessary information...I am new to this bash scripting...mercy!
    # NOTE: Feel free to submit a pull request to beautify this code to reduce lagg.
    local git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)

    if [[ -n $git_branch ]]; then
        # branch name with symbol
        local git_info="$git_branch_symbol $git_branch"

        # used for coloring
        local git_status=$(git status 2> /dev/null) 

        local git_untracked=$(echo "$git_status" | grep -m1 "Untracked files:")
        local git_unstaged=$(echo "$git_status" | grep -m1 "Changes not staged for commit:") local git_staged=$(echo "$git_status"| grep -m1 "Changes to be committed:")
        
        # used for icons
        local git_modified=$(echo "$git_status" | grep -m1 "modified:")
        local git_renamed=$(echo "$git_status" | grep -m1 "renamed:")
        local git_new=$(echo "$git_status" | grep -m1 "new file:")
        local git_deleted=$(echo "$git_status" | grep -m1 "deleted:")

        # determining coloring
        if [[ -n $git_untracked || -n $git_unstaged ]]; then
            local git_color=$git_modified_color
        elif [[ -n $git_staged ]]; then
            local git_color=$git_staged_color
        else
            local git_color=$git_default_color
        fi

        # determining which icons to add 
        local git_icons=""
        if [[ -n $git_modified ]]; then
            git_icons="$git_icons$git_modified_symbol"
        fi
        if [[ -n $git_renamed ]]; then
            git_icons="$git_icons$git_renamed_symbol"
        fi
        if [[ -n $git_new ]]; then
            git_icons="$git_icons$git_new_symbol"
        fi
        if [[ -n $git_deleted ]]; then
            git_icons="$git_icons$git_deleted_symbol"
        fi
        if [[ -n $git_untracked ]]; then
            git_icons="$git_icons$git_untracked_symbol"
        fi

        echo -n "$(bubblify 0 "$git_info " $git_color $bubble_color)$(bubblify 2 " $git_icons" $git_icons_color $git_color) "
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
  local git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)

  # Threat repo root as a top-level directory or not
  if [[ $SPACESHIP_DIR_TRUNC_REPO == true ]] && [[ -n $git_branch ]]; then
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

PROMPT='$(ssh_bubble)$user_machine_bubble$(dir_bubble)$_newline$end_of_prompt%{$reset_color%}'
RPROMPT='%{$_lineup%}$(git_bubble)$error_code_bubble%{$_linedown%}$(time_bubble)%{$reset_color%}'

