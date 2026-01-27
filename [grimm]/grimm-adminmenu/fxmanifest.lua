fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Kakarot & Enhanced Team'
description 'Enhanced QBCore Admin Menu with Advanced Features'
version '2.0.0'

ui_page 'html/index.html'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config/config.lua'
}

client_scripts {
    '@menuv/menuv.lua',
    'client/noclip.lua',
    'client/entity_view.lua',
    'client/blipsnames.lua',
    'client/utils.lua',
    'client/client.lua',
    'client/events.lua',
    'entityhashes/entity.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/permissions.lua',
    'server/utils.lua',
    'server/server.lua',
    'server/commands.lua',
    'server/logs.lua'
}

files {
    'html/index.html',
    'html/index.js',
    'html/style.css'
}

dependency 'menuv'
