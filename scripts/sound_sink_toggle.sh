#!/nix/store/rnkas52f8868g1hjdlldbvh6snm3pglv-bash-5.2-p15/bin/bash
devices=()

# Find existing audio devices and their IDs
speaker=$(pw-cli ls Node | grep "output.pci" | grep -v "iec" | awk -F ' = ' '{print $2}')
if [ ! -z "$speaker" ]; then
    speaker_id=$(pw-dump Node Device | jq '.[].info.props|select(."node.name" == '"$speaker"') | ."object.id"')
    devices+=("$speaker_id")
    echo "Speaker exists: $speaker_id"
fi

bluetooth=$(pw-cli ls Node | grep "output.bluetooth" | cut -d'=' -f2)
if [ ! -z "$bluetooth" ]; then
    bluetooth_id=$(pw-dump Node Device | jq '.[].info.props|select(."node.name" == '"$bluetooth"') | ."object.id"')
    devices+=("$bluetooth_id")
    echo "Bluetooth exists: $bluetooth_id"
fi

headset=$(pw-cli ls Node | grep "output.usb" | cut -d'=' -f2)
if [ ! -z "$headset" ]; then
    headset_id=$(pw-dump Node Device | jq '.[].info.props|select(."node.name" == '"$headset"') | ."object.id"')
    devices+=("$headset_id")
    echo "Headset exists: $headset_id"
fi

# Get the current default sink ID
default_sink_name=$(pw-metadata 0 'default.audio.sink' | grep 'value' | sed "s/.* value:'//;s/' type:.*$//;" | jq .name)
default_sink_id=$(pw-dump Node Device | jq '.[].info.props|select(."node.name" == '"$default_sink_name"') | ."object.id"')

# Set the next device in the list as the default sink
current_device_index=0
for device_id in "${devices[@]}"; do
    if [[ "$default_sink_id" == "$device_id" ]]; then
        current_device_index=$((current_device_index + 1))
        next_device_index=$((current_device_index % ${#devices[@]}))
        next_device_id=${devices[$next_device_index]}
        wpctl set-default "$next_device_id"
        echo "Default sink set to $next_device_id"
        exit 0
    fi
    current_device_index=$((current_device_index + 1))
done

# If the current default sink is not in the list, set the first device in the list as the default sink
if [ "${#devices[@]}" -gt 0 ]; then
    wpctl set-default "${devices[0]}"
    echo "Default sink set to ${devices[0]}"
fi

