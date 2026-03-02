fx_version 'cerulean'
game 'gta5'

name 'red40_mining'
description 'A mining script by Red40 Development'
author 'Red40 Development'
version '0.0.1'

ox_lib 'locale'

client_scripts {
    'bridge/client/*.lua',
    'client/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
}

server_scripts {
    'bridge/server/*.lua',
    'server/*.lua',
}

files {
    'locales/**/*',
    'config/client.lua',
    'config/shared.lua'
}

escrow_ignore {
    '**/*',
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'