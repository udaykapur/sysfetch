#!/bin/bash

# this script search '41' in /proc/bus/pci/devices for vendor and device id, then scrapes https://pci-ids.ucw.cz using taken id's for GPU output

html_strip="s|</b>|-|g;s|<[^>]*>||g"
while read -r line ; do
	case $line in
		*41*) id=${line:4} ;;
	esac
done < /proc/bus/pci/devices
id=$(cut -f2 <<< $id)
vendor_id=${id::-4}
device_id=${id:4}

pci_id=$(curl https://pci-ids.ucw.cz/read/PC/$vendor_id 2>/dev/null)
while read -r line ; do
	case $line in
		*'="nam'*) gpu_vendor=$line ;;
	esac
done <<< $pci_id
gpu_vendor=$(sed "$html_strip" <<< $gpu_vendor)
gpu_vendor=${gpu_vendor//Name: }
gpu_vendor=${gpu_vendor//Note: nee}

while read -r line ; do
	case $line in
		*$device_id*) gpu_name=$line ;;
	esac
done <<< $pci_id

gpu_name=$(sed "$html_strip" <<< $gpu_name)
gpu_name=${gpu_name:4}

gpu_strip="s/Advanced Micro Devices, Inc.//;s/ATI Technologies, Inc.//"
gpu_vendor=$(sed "$gpu_strip" <<< $gpu_vendor)
gpu="$gpu_vendor $gpu_name"
gpu=$(tr -d '[]' <<< $gpu)
echo $gpu
