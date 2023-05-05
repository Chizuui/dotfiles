#!/nix/store/rnkas52f8868g1hjdlldbvh6snm3pglv-bash-5.2-p15/bin/bash
#!/bin/sh
player=$(playerctl --player=i,com,spotify,firefox,%any metadata --format '{{playerName}}')
player_name=$player
exec $player_name

