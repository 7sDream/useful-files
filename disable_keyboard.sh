#!/bin/sh

xinput list

read -p "Input your [AT Translated Set 2 keyboard] id:" keyboardId

xinput list-props ${keyboardId}

read -p "Input your [disable] entry id:" disableID 

sleep 1

echo "#!/bin/sh\nxinput set-prop ${keyboardId} ${disableID} 1" > enable_keyboard.sh

chmod o+x enable_keyboard.sh

xinput set-prop ${keyboardId} ${disableID} 0
