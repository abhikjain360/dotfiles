real=$HOME/.local/bin/claude
if [[ ! -x $real ]]; then
  real=$(command -v claude)
fi
work_dir=$HOME/work/.claude-config
state_dir=${XDG_STATE_HOME:-$HOME/.local/state}/cl
state=$state_dir/dirs.tsv

profiles=(personal)
if [[ -d $work_dir ]]; then
  profiles+=(work)
fi
subcommands=" agents attach auth auto-mode doctor gateway import install logs mcp plugin plugins purge respawn rm setup-token stop kill ultrareview update upgrade -v --version -h --help "

profile=personal
if [[ $PWD/ == "$HOME"/work/* && -d $work_dir ]]; then
  profile=work
fi
chrome=off
model=opus
effort=xhigh
session=new

saved=()
found=()
last=()
longest=-1
if [[ -r $state ]]; then
  while IFS=$'\t' read -r d p c m e s; do
    last=("$m" "$e")
    if [[ $d == "$PWD" ]] || [[ $PWD == "$d"/* && $d == "$HOME"/* ]]; then
      if ((${#d} > longest)); then
        longest=${#d}
        found=("$p" "$c" "$m" "$e")
      fi
    fi
    if [[ $d == "$PWD" ]]; then
      session=${s:-new}
    else
      saved+=("$d"$'\t'"$p"$'\t'"$c"$'\t'"$m"$'\t'"$e"$'\t'"$s")
    fi
  done <"$state"
fi
if ((${#found[@]})); then
  profile=${found[0]} chrome=${found[1]} model=${found[2]} effort=${found[3]}
elif ((${#last[@]})); then
  model=${last[0]} effort=${last[1]}
fi
if [[ ! -d $work_dir ]]; then
  profile=personal
fi

ui=1
given=" "
rest=()
sub=0
while (($#)); do
  a=$1
  shift
  case $a in
    personal | work)
      profile=$a
      given+="profile "
      ;;
    chrome | nochrome | no-chrome)
      chrome=on
      if [[ $a != chrome ]]; then
        chrome=off
      fi
      given+="chrome "
      ;;
    fable | opus | sonnet | haiku | --model)
      model=$a
      if [[ $a == --model ]]; then
        model=${1:?--model needs a value}
        shift
      fi
      given+="model "
      ;;
    low | medium | high | xhigh | max | --effort)
      effort=$a
      if [[ $a == --effort ]]; then
        effort=${1:?--effort needs a value}
        shift
      fi
      given+="effort "
      ;;
    new | continue | resume)
      session=$a
      given+="session "
      ;;
    y) ui=0 ;;
    *)
      if ((!${#rest[@]})) && [[ $subcommands == *" $a "* ]]; then
        sub=1
        rest=("$a" "$@")
        break
      fi
      rest+=("$a")
      ;;
  esac
done

if [[ $profile == work && ! -d $work_dir ]]; then
  echo "cl: no work profile at $work_dir" >&2
  exit 1
fi

rows=()
all=()
for name in profile chrome model effort session; do
  if [[ $name == profile && ${#profiles[@]} -lt 2 ]]; then
    continue
  fi
  all+=("$name")
  if [[ $given != *" $name "* ]]; then
    rows+=("$name")
  fi
done
if ((!${#rows[@]})); then
  rows=("${all[@]}")
fi
cur=0
height=$((${#rows[@]} + 2))

options() {
  case $1 in
    profile) opts=("${profiles[@]}") ;;
    chrome) opts=(off on) ;;
    model) opts=(fable opus sonnet haiku) ;;
    effort) opts=(low medium high xhigh max) ;;
    session) opts=(new continue resume) ;;
  esac
}

draw() {
  local buf i name opts opt label
  printf -v buf '\r\e[2m  %s\e[0m\e[K\n' "${PWD/#"$HOME"/\~}"
  for i in "${!rows[@]}"; do
    name=${rows[i]}
    options "$name"
    if ((i == cur)); then
      buf+=$'\e[36m› \e[0;1m'
    else
      buf+='  '
    fi
    printf -v label '%-8s\e[0m' "$name"
    buf+=$label
    for opt in "${opts[@]}"; do
      if [[ $opt != "${!name}" ]]; then
        buf+=$'\e[2m '"$opt"$' \e[0m'
      elif ((i == cur)); then
        buf+=$'\e[7;36m '"$opt"$' \e[0m'
      else
        buf+=$'\e[1m '"$opt"$' \e[0m'
      fi
    done
    buf+=$'\e[K\n'
  done
  buf+=$'\e[2m  ←→ tab change  ↑↓ move  ⏎ next  r resume  c continue  q quit\e[0m\e[K'
  printf '%s' "$buf"
}

clear_ui() {
  printf '\e[%dA\r\e[J\e[?25h\e[?7h\e[<u' $((height - 1))
}

step() {
  local name=${rows[cur]} opts i=-1 j
  options "$name"
  for j in "${!opts[@]}"; do
    if [[ ${opts[j]} == "${!name}" ]]; then
      i=$j
    fi
  done
  i=$(((i + $1 + ${#opts[@]}) % ${#opts[@]}))
  printf -v "$name" '%s' "${opts[i]}"
}

read_key() {
  local c code mods
  IFS= read -rsn1 key || key=q
  if [[ $key == $'\e' ]] && IFS= read -rsn1 -t 0.05 c; then
    key+=$c
    if [[ $c == '[' || $c == O ]]; then
      while IFS= read -rsn1 -t 0.05 c; do
        key+=$c
        case $c in
          [0-9\;:]) ;;
          *) break ;;
        esac
      done
    fi
  fi
  if [[ $key =~ $csi_u ]]; then
    code=${BASH_REMATCH[1]}
    mods=$(((${BASH_REMATCH[3]:-1} - 1) & 7))
    case $mods in
      0)
        if ((code < 127)); then
          printf -v c '%x' "$code"
          printf -v key '%b' "\\x$c"
        fi
        ;;
      1) key=shift-$code ;;
      4) key=ctrl-$code ;;
    esac
  fi
}

pick() {
  local key csi_u=$'^\e\\[([0-9]+)(;([0-9]+))?u$'
  trap 'clear_ui; exit 130' INT TERM
  printf '\e[?25l\e[?7l\e[>9u'
  draw
  while true; do
    read_key
    case $key in
      $'\e[A' | $'\eOA' | k) cur=$(((cur + ${#rows[@]} - 1) % ${#rows[@]})) ;;
      $'\e[B' | $'\eOB' | j) cur=$(((cur + 1) % ${#rows[@]})) ;;
      $'\e[C' | $'\eOC' | l | $'\t') step 1 ;;
      $'\e[D' | $'\eOD' | h | $'\e[Z' | shift-9) step -1 ;;
      '' | ' ' | $'\r')
        if ((cur == ${#rows[@]} - 1)); then
          break
        fi
        cur=$((cur + 1))
        ;;
      shift-13 | shift-32)
        if ((cur > 0)); then
          cur=$((cur - 1))
        fi
        ;;
      r)
        session=resume
        break
        ;;
      c)
        session="continue"
        break
        ;;
      q | $'\e' | $'\x04' | ctrl-100)
        clear_ui
        exit 0
        ;;
      ctrl-99)
        clear_ui
        exit 130
        ;;
    esac
    printf '\e[%dA' $((height - 1))
    draw
  done
  clear_ui
  trap - INT TERM
}

if ((ui && !sub)) && [[ -t 0 && -t 1 ]]; then
  pick
fi

if [[ $profile == work ]]; then
  export CLAUDE_CONFIG_DIR=$work_dir
else
  unset CLAUDE_CONFIG_DIR
fi

if ((sub)); then
  exec "$real" "${rest[@]}"
fi

if [[ ! -d $state_dir ]]; then
  mkdir -p "$state_dir"
fi
{
  if ((${#saved[@]})); then
    printf '%s\n' "${saved[@]}"
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$PWD" "$profile" "$chrome" "$model" "$effort" "$session"
} >"$state.$$"
mv -f "$state.$$" "$state"

if [[ $PWD == "$HOME" ]]; then
  config=${CLAUDE_CONFIG_DIR:-$HOME}/.claude.json
  if [[ -f $config ]] && ! jq -e --arg h "$HOME" '.projects[$h].hasTrustDialogAccepted' "$config" >/dev/null; then
    cp -p "$config" "$config.$$"
    jq --arg h "$HOME" '.projects[$h].hasTrustDialogAccepted = true' "$config" >"$config.$$"
    mv -f "$config.$$" "$config"
  fi
fi

args=(--model "$model" --effort "$effort" --dangerously-skip-permissions)
if [[ $chrome == on ]]; then
  args+=(--chrome)
else
  args+=(--no-chrome)
fi
case $session in
  continue) args+=(--continue) ;;
  resume) args+=(--resume) ;;
esac
exec "$real" "${args[@]}" "${rest[@]}"
