function svn_prompt_info() {
  local info
  info=$(svn info 2>&1) || return 1 # capture stdout and stderr
  local repo_need_upgrade=$(svn_repo_need_upgrade $info)

  if [[ -n $repo_need_upgrade ]]; then
    printf '%s%s%s%s%s%s%s\n' \
      "$ZSH_PROMPT_BASE_COLOR" \
      "$ZSH_THEME_SVN_PROMPT_PREFIX" \
      "$ZSH_PROMPT_BASE_COLOR" \
      "$repo_need_upgrade" \
      "$ZSH_PROMPT_BASE_COLOR" \
      "$ZSH_THEME_SVN_PROMPT_SUFFIX" \
      "$ZSH_PROMPT_BASE_COLOR"
  else
    printf '%s%s%s%s %s%s%s:%s%s%s%s' \
      "$ZSH_PROMPT_BASE_COLOR" \
      "$ZSH_THEME_SVN_PROMPT_PREFIX" \
      "$(svn_status_info $info)" \
      "$ZSH_PROMPT_BASE_COLOR" \
      \
      "$ZSH_THEME_BRANCH_NAME_COLOR" \
      "$(svn_current_branch_name $info)" \
      "$ZSH_PROMPT_BASE_COLOR" \
      \
      "$(svn_current_revision $info)" \
      "$ZSH_PROMPT_BASE_COLOR" \
      "$ZSH_THEME_SVN_PROMPT_SUFFIX" \
      "$ZSH_PROMPT_BASE_COLOR"
  fi
}

function svn_repo_need_upgrade() {
  grep -q "E155036" <<< "${1:-$(svn info 2> /dev/null)}" && \
    echo "E155036: upgrade repo with svn upgrade"
}

function svn_current_branch_name() {
  grep '^URL:' <<< "${1:-$(svn info 2> /dev/null)}" | egrep -o '(tags|branches)/[^/]+|trunk'	
}

function svn_repo_root_name() {
  grep '^Repository\ Root:' <<< "${1:-$(svn info 2> /dev/null)}" | sed 's#.*/##'
}

function svn_current_revision() {
  echo "${1:-$(svn info 2> /dev/null)}" | sed -n 's/Revision: //p'
}

function svn_status_info() {
  local      clean='%76F'   # green foreground
  local   modified='%178F'  # yellow foreground
  local  untracked='%39F'   # blue foreground
  local conflicted='%196F'  # red foreground
  local svn_status_string="$ZSH_THEME_SVN_PROMPT_CLEAN"
  local svn_status="$(svn status 2> /dev/null)";
  local svn_num_add=$(grep -E '^\s*A' &> /dev/null <<< $svn_status | wc -l)
  local svn_num_del=$(grep -E '^\s*D' &> /dev/null <<< $svn_status | wc -l)
  local svn_num_mod=$(grep -E '^\s*[MR~]' &> /dev/null <<< $svn_status | wc -l)
  local svn_num_new=$(grep -E '^\s*\?' &> /dev/null <<< $svn_status | wc -l)
  local svn_num_con=$(grep -E '^\s*[CI!L]' &> /dev/null <<< $svn_status | wc -l)
  if [[ $svn_num_add > 0 ]]; then
    svn_status_string="$svn_status_string ${modified}$svn_num_add${ZSH_THEME_SVN_PROMPT_ADDITIONS:-+}"
  fi
  if [[ $svn_num_del > 0 ]]; then
    svn_status_string="$svn_status_string ${modified}$svn_num_del${ZSH_THEME_SVN_PROMPT_DELETIONS:-✖}"
  fi
  if [[ $svn_num_mod > 0 ]]; then
    svn_status_string="$svn_status_string ${modified}${svn_num_mod}${ZSH_THEME_SVN_PROMPT_MODIFICATIONS:-∿}"
  fi
  if [[ $svn_num_new > 0 ]]; then
    svn_status_string="$svn_status_string ${untracked}${svn_num_new}${ZSH_THEME_SVN_PROMPT_UNTRACKED:-?}"
  fi
  if [[ $svn_num_con > 0 ]]; then
    svn_status_string="$svn_status_string ${conflicted}${svn_num_con}${ZSH_THEME_SVN_PROMPT_CONFLICT:-!}"
  fi
  echo $svn_status_string
}
