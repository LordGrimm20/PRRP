fx_version 'cerulean'
game 'gta5'

name 'grimm-tickets'
description 'In-game ticket system with Discord integration for Project Roots'
author 'LordGrimm20'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/discord.lua'
}

dependencies {
    'ox_lib',
    'oxmysql'
}
