local discordRest = 'https://discord.com/api/v10'
local botToken = Config.BotToken
local channelId = Config.TicketChannelId
local ticketThreads = {} -- [ticketId] = threadId

-- HTTP Headers for Discord API
local function getHeaders()
    return {
        ['Content-Type'] = 'application/json',
        ['Authorization'] = 'Bot ' .. botToken
    }
end

-- Make Discord API request
local function discordRequest(method, endpoint, data, callback)
    local url = discordRest .. endpoint
    
    PerformHttpRequest(url, function(statusCode, response, headers)
        if callback then
            local success = statusCode >= 200 and statusCode < 300
            local parsed = nil
            if response and response ~= '' then
                parsed = json.decode(response)
            end
            callback(success, parsed, statusCode)
        end
    end, method, data and json.encode(data) or '', getHeaders())
end

-- Build staff ping string
local function getStaffPings()
    if not Config.PingStaff then return '' end
    
    local pings = ''
    for _, roleId in ipairs(Config.StaffRoles) do
        pings = pings .. '<@&' .. roleId .. '> '
    end
    return pings
end

-- Create ticket thread and send initial message
RegisterNetEvent('grimm-tickets:discord:createTicket', function(playerData)
    -- Build embed
    local embed = {
        title = '📩 New Ticket #' .. playerData.ticketId,
        color = Config.Colors.Open,
        fields = {
            {
                name = '👤 Player',
                value = playerData.characterName .. '\n`' .. playerData.steamName .. '`',
                inline = true
            },
            {
                name = '🆔 Identifiers',
                value = 'Server ID: `' .. playerData.source .. '`\nCitizen ID: `' .. playerData.citizenId .. '`',
                inline = true
            },
            {
                name = '📶 Connection',
                value = 'Ping: `' .. playerData.ping .. 'ms`',
                inline = true
            }
        },
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        footer = {
            text = 'Project Roots Tickets'
        }
    }
    
    -- Add location if enabled
    if Config.SaveLocation and playerData.location then
        table.insert(embed.fields, {
            name = '📍 Location',
            value = playerData.location.street .. ', ' .. playerData.location.zone .. 
                    '\n`' .. playerData.location.coords.x .. ', ' .. playerData.location.coords.y .. ', ' .. playerData.location.coords.z .. '`',
            inline = false
        })
    end
    
    -- Add message
    table.insert(embed.fields, {
        name = '💬 Message',
        value = playerData.message,
        inline = false
    })
    
    -- Add instructions
    table.insert(embed.fields, {
        name = '📝 Instructions',
        value = '• Reply in this thread to respond to the player\n• Type `!close` to close the ticket\n• Player will see your messages in-game',
        inline = false
    })
    
    -- First, create a message in the channel
    local messageData = {
        content = getStaffPings() .. 'New support ticket!',
        embeds = { embed }
    }
    
    discordRequest('POST', '/channels/' .. channelId .. '/messages', messageData, function(success, response, statusCode)
        if not success then
            print('^1[grimm-tickets]^7 Failed to create ticket message: ' .. tostring(statusCode))
            return
        end
        
        local messageId = response.id
        
        -- Create a thread from the message
        local threadData = {
            name = 'Ticket-' .. playerData.ticketId .. ' | ' .. playerData.characterName,
            auto_archive_duration = 1440 -- 24 hours
        }
        
        discordRequest('POST', '/channels/' .. channelId .. '/messages/' .. messageId .. '/threads', threadData, function(threadSuccess, threadResponse, threadStatus)
            if threadSuccess and threadResponse then
                local threadId = threadResponse.id
                ticketThreads[playerData.ticketId] = threadId
                
                -- Save thread ID to database
                MySQL.update('UPDATE grimm_tickets SET discord_thread_id = ? WHERE ticket_id = ?', {
                    threadId, playerData.ticketId
                })
                
                print('^2[grimm-tickets]^7 Created Discord thread for ticket #' .. playerData.ticketId)
                
                -- Start listening for replies in this thread
                startThreadListener(playerData.ticketId, threadId)
            else
                print('^1[grimm-tickets]^7 Failed to create thread: ' .. tostring(threadStatus))
            end
        end)
    end)
end)

-- Player reply to ticket
RegisterNetEvent('grimm-tickets:discord:playerReply', function(ticketId, playerName, message)
    local threadId = ticketThreads[ticketId]
    
    -- If not in memory, fetch from database
    if not threadId then
        local result = MySQL.query.await('SELECT discord_thread_id FROM grimm_tickets WHERE ticket_id = ?', { ticketId })
        if result and result[1] and result[1].discord_thread_id then
            threadId = result[1].discord_thread_id
            ticketThreads[ticketId] = threadId
        end
    end
    
    if not threadId then
        print('^1[grimm-tickets]^7 No thread found for ticket #' .. ticketId)
        return
    end
    
    local embed = {
        author = {
            name = '💬 ' .. playerName .. ' (Player)'
        },
        description = message,
        color = Config.Colors.Reply,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }
    
    discordRequest('POST', '/channels/' .. threadId .. '/messages', { embeds = { embed } }, function(success)
        if not success then
            print('^1[grimm-tickets]^7 Failed to send player reply to Discord')
        end
    end)
end)

-- Close ticket
RegisterNetEvent('grimm-tickets:discord:closeTicket', function(ticketId, closedBy)
    local threadId = ticketThreads[ticketId]
    
    if not threadId then
        local result = MySQL.query.await('SELECT discord_thread_id FROM grimm_tickets WHERE ticket_id = ?', { ticketId })
        if result and result[1] and result[1].discord_thread_id then
            threadId = result[1].discord_thread_id
        end
    end
    
    if not threadId then return end
    
    -- Send closed message
    local embed = {
        title = '🔒 Ticket Closed',
        description = 'This ticket has been closed by **' .. closedBy .. '**',
        color = Config.Colors.Closed,
        timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
    }
    
    discordRequest('POST', '/channels/' .. threadId .. '/messages', { embeds = { embed } }, function()
        -- Archive the thread
        discordRequest('PATCH', '/channels/' .. threadId, { archived = true, locked = true }, function()
            print('^3[grimm-tickets]^7 Archived Discord thread for ticket #' .. ticketId)
        end)
    end)
    
    ticketThreads[ticketId] = nil
end)

-- Poll for new messages in threads (Discord doesn't support webhooks for this easily)
local pollInterval = 5000 -- 5 seconds
local lastMessageIds = {} -- [threadId] = lastMessageId

function startThreadListener(ticketId, threadId)
    -- Get the last message ID to start from
    discordRequest('GET', '/channels/' .. threadId .. '/messages?limit=1', nil, function(success, messages)
        if success and messages and messages[1] then
            lastMessageIds[threadId] = messages[1].id
        end
    end)
end

-- Check if a user has staff roles
local function checkIfStaff(userId, callback)
    if not Config.GuildId or Config.GuildId == '' then
        print('^1[grimm-tickets]^7 ERROR: GuildId not set in config!')
        callback(false)
        return
    end
    
    discordRequest('GET', '/guilds/' .. Config.GuildId .. '/members/' .. userId, nil, function(success, member, statusCode)
        if not success or not member then
            print('^1[grimm-tickets]^7 Failed to fetch member: ' .. tostring(statusCode))
            callback(false)
            return
        end
        
        local isStaff = false
        if member.roles then
            for _, roleId in ipairs(member.roles) do
                for _, staffRoleId in ipairs(Config.StaffRoles) do
                    if roleId == staffRoleId then
                        isStaff = true
                        break
                    end
                end
                if isStaff then break end
            end
        end
        
        callback(isStaff)
    end)
end

-- Poll all active threads for new messages
CreateThread(function()
    while true do
        Wait(pollInterval)
        
        for ticketId, threadId in pairs(ticketThreads) do
            -- Get messages after last known message
            local endpoint = '/channels/' .. threadId .. '/messages?limit=10'
            if lastMessageIds[threadId] then
                endpoint = endpoint .. '&after=' .. lastMessageIds[threadId]
            end
            
            discordRequest('GET', endpoint, nil, function(success, messages, statusCode)
                --print('^3[grimm-tickets DEBUG]^7 Poll response - Success: ' .. tostring(success) .. ' Status: ' .. tostring(statusCode) .. ' Messages: ' .. tostring(messages and #messages or 0))
                if not success or not messages then return end
                
                for i = #messages, 1, -1 do -- Process oldest first
                    local msg = messages[i]
                    
                    -- Skip bot messages
                    if msg.author and not msg.author.bot then
                        local content = msg.content
                        local authorName = msg.author.global_name or msg.author.username
                        local authorId = msg.author.id
                        
                        --print('^3[grimm-tickets DEBUG]^7 Message from: ' .. authorName .. ' Content: ' .. tostring(content))
                        
                        -- Check if user has staff role
                        checkIfStaff(authorId, function(isStaff)
                            --print('^3[grimm-tickets DEBUG]^7 Is staff: ' .. tostring(isStaff))
                            
                            if isStaff and content and content ~= '' then
                                -- Check for close command
                                if content:lower() == '!close' then
                                    TriggerEvent('grimm-tickets:server:closeTicketFromDiscord', ticketId, authorName)
                                else
                                    -- Send reply to player
                                    TriggerEvent('grimm-tickets:server:staffReply', ticketId, authorName, content)
                                    print('^2[grimm-tickets]^7 Staff reply sent to player from: ' .. authorName)
                                end
                            elseif not isStaff then
                                print('^3[grimm-tickets]^7 User ' .. authorName .. ' is not staff, ignoring message')
                            end
                        end)
                    end
                    
                    -- Update last message ID
                    lastMessageIds[threadId] = msg.id
                end
            end)
        end
    end
end)

-- Load existing open tickets on resource start
CreateThread(function()
    Wait(5000) -- Wait for database connection
    
    local result = MySQL.query.await('SELECT ticket_id, discord_thread_id FROM grimm_tickets WHERE status = ?', { 'open' })
    
    if result then
        for _, ticket in ipairs(result) do
            if ticket.discord_thread_id then
                ticketThreads[ticket.ticket_id] = ticket.discord_thread_id
                startThreadListener(ticket.ticket_id, ticket.discord_thread_id)
            end
        end
        print('^2[grimm-tickets]^7 Loaded ' .. #result .. ' open tickets')
    end
end)
