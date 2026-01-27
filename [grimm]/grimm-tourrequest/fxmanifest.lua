fx_version 'bodacious'
game 'gta5'

author 'Grimm'
version '2.0.0'
description 'New player city tour with multiple trigger options'

shared_scripts { 
	'Config.lua'
}

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}

lua54 'yes'