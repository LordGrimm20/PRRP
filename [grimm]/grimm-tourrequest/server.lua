local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('GrimmTour:Server:CheckCompletion', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not Player.PlayerData then 
        return 
    end

    local citizenId = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM GrimmNewPlayerIntro WHERE CitizenId = ?', { citizenId })

    if result and result[1] ~= nil then
        TriggerClientEvent('GrimmTour:Client:SetCompleted', src, true)
    else
        TriggerClientEvent('GrimmTour:Client:SetCompleted', src, false)
    end
end)

RegisterNetEvent('GrimmTour:Server:CompleteTour', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player or not Player.PlayerData then 
        return 
    end

    local citizenId = Player.PlayerData.citizenid
    local result = MySQL.query.await('SELECT * FROM GrimmNewPlayerIntro WHERE CitizenId = ?', { citizenId })

    if not result then
        return
    end

    if result[1] == nil then        
        local insertId = MySQL.insert.await('INSERT INTO GrimmNewPlayerIntro (CitizenId) VALUES (?)', { citizenId })
        
        if insertId then
            TriggerClientEvent('GrimmTour:Client:SetCompleted', src, true)
            
            -- Give reward
            if QBCore.Shared.Items['carvoucher'] then
                Player.Functions.AddItem('carvoucher', 1)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['carvoucher'], 'add')
            end
            
            TriggerClientEvent('QBCore:Notify', src, 'Tour completed! You received a free car voucher!', 'success')
        end
    end
end)