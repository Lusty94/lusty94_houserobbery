fx_version 'cerulean'
game 'gta5'
author 'QB / Lusty94'
description 'Improved QB-HouseRobbery'
version '1.2.0' -- same as qb-houserobbery WILL FORK IF UPDATED FROM QB TO KEEP VERSION NUMBERS THE SAME
lua54 'yes'

client_script 'client/main.lua'

server_script 'server/main.lua'

shared_scripts {
    'config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    '@ox_lib/init.lua',
}

escrow_ignore {
    'client/**.lua',
    'server/**.lua',
    'locales/**.lua',
    'config.lua',
}