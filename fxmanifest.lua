fx_version 'adamant'
game 'gta5'

author 'RX DEV'
description 'Avionics'
version '1.0.0'

lua54 'yes'

client_scripts {
    'config.lua',
    'client/**.lua'
}

server_scripts {
    'server/**.lua'
}

shared_scripts {
   'config.lua',
   'shared/**.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/**.css',
    'html/**.js',
    --'html/img/**.png',
    'html/sounds/**.mp3'
}
