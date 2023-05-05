#!/nix/store/rnkas52f8868g1hjdlldbvh6snm3pglv-bash-5.2-p15/bin/bash
## Author : Aditya Shakya (adi1090x)
## Github : @adi1090x

# Current Theme
theme='~/.config/rofi/powermenu.rasi'

# CMDs
lastlogin="`last $USER | head -n1 | tr -s ' ' | cut -d' ' -f5,6,7`"
uptime="`uptime | sed -e 's/up //g'`"
host=`hostname`

# Options
shutdown=""
reboot=""
lock=""
suspend=""
logout=""
yes=''
no=''

# Rofi CMD
rofi_cmd() {
  rofi -dmenu \
    -p " $host@$USER" \
    -mesg " Last Login: $lastlogin |  Uptime: $uptime" \
    -theme "$theme"
}

# Confirmation CMD
confirm_cmd() {
  rofi -theme-str 'window {location: center; anchor: center; fullscreen: true; width: 350px;}' \
    -theme-str 'mainbox {children: [ "message", "listview" ]; margin: 575px 950px;}' \
    -theme-str 'listview {columns: 2; lines: 1;}' \
    -theme-str 'element-text {horizontal-align: 0.5;}' \
    -theme-str 'textbox {horizontal-align: 0.5;}' \
    -theme-str 'element {padding: 30px;}' \
    -dmenu \
    -p 'Confirmation' \
    -mesg 'Are you Sure?' \
    -theme "$theme"
}

# Ask for confirmation
confirm_exit() {
  echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
  selected="$(confirm_exit)"
  if [[ "$selected" == "$yes" ]]; then
    if [[ $1 == '--shutdown' ]]; then
      systemctl poweroff
    elif [[ $1 == '--reboot' ]]; then
      systemctl reboot
    elif [[ $1 == '--suspend' ]]; then
      mpc -q pause
      wpctl set-mute @DEFAULT_SINK@ toggle
      systemctl suspend
    elif [[ $1 == '--logout' ]]; then
            pkill Hyprland
    fi
  else
    exit 0
  fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
    run_cmd --shutdown
        ;;
    $reboot)
    run_cmd --reboot
        ;;
    $lock)
    if [[ -x '/usr/bin/betterlockscreen' ]]; then
      betterlockscreen -l
    elif [[ -x '/usr/bin/i3lock' ]]; then
      i3lock
    fi
        ;;
    $suspend)
    run_cmd --suspend
        ;;
    $logout)
    run_cmd --logout
        ;;
esac

