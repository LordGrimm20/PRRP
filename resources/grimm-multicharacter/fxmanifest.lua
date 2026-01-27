fx_version 'cerulean'
game 'gta5'

name 'grimm-multicharacter'
description 'Multi-Character Selection & Spawn System for Project Roots'
author 'Project Roots Development'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
    'html/assets/*.png',
    'html/assets/*.svg'
}

lua54 'yes'

dependencies {
    'qb-core',
    'oxmysql'
}
