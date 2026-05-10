fx_version 'cerulean'
game 'gta5'
author 'Peak Studios'
description 'Peak Trucking'
version '0.1.0'
lua54 'yes'

shared_scripts {
    'shared/utils.lua',
    'shared/internal_config.lua',
    'shared/config.lua',
    'shared/locales.lua',
}

client_scripts {
    'client/init.lua',
    'client/custom.lua',
    'client/interactionHandler.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/init.lua',
    'server/custom.lua',
    'server/bridge.lua',
    'server/dailymissions.lua',
    'server/xp.lua',
    'server/main.lua',
}

ui_page 'ui/dist/index.html'

files {
    'ui/dist/index.html',
    'ui/dist/**/*',
}

dependencies {
    'oxmysql',
}
