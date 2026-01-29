fx_version 'cerulean'
game 'gta5'

name 'grimm-hud'
description 'Custom HUD for Project Roots RP'
author 'PRRP Development'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/status.lua',
    'client/location.lua',
    'client/voice.lua',
    'client/media.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
    'html/fonts/*.ttf',
    'html/fonts/*.woff',
    'html/fonts/*.woff2',
}

dependencies {
    'qb-core',
    'pma-voice',
}

escrow_ignore {
    'config.lua',
    'html/css/style.css',
}
