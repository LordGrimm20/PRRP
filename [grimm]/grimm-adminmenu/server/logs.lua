-- Discord Webhook Logging System
function SendLog(logType, title, color, message, mention)
    if not Config.EnableAdvancedLogs then return end
    if not Config.Logs[logType] or Config.Logs[logType].webhook == '' then return end
    
    local webhook = Config.Logs[logType].webhook
    local embedColor = Config.Logs[logType].color
    
    local embed = {
        {
            ['title'] = title,
            ['color'] = embedColor,
            ['description'] = message,
            ['footer'] = {
                ['text'] = os.date('%Y-%m-%d %H:%M:%S'),
            },
        }
    }
    
    local data = {
        ['embeds'] = embed
    }
    
    if mention then
        data['content'] = '@everyone'
    end
    
    PerformHttpRequest(webhook, function(err, text, headers)
        if err ~= 200 and err ~= 204 then
            print('[qb-adminmenu] Error sending log to Discord: ' .. err)
        end
    end, 'POST', json.encode(data), { ['Content-Type'] = 'application/json' })
end

-- QBCore Logging Integration
RegisterNetEvent('qb-admin:server:createLog', function(logType, title, color, message, screenshot)
    TriggerEvent('qb-log:server:CreateLog', logType, title, color, message, screenshot)
end)
