local ESX = { PlayerData = {}, Players = {} }
local wrappers = {}

local function mapAccount(name)
    if name == 'money' then return 'cash' end
    if name == 'black_money' then return 'dirty' end
    return name
end

local function esxJob(player)
    player=exports.szcore:GetPlayer(player.PlayerData.source) or player
    local j = player.PlayerData.job
    return {
        name = j.name,
        label = j.label,
        grade = j.grade,
        grade_name = j.gradeName,
        grade_label = j.gradeName,
        grade_salary = j.salary or 0,
        onDuty = j.onduty,
        isboss = j.boss == true
    }
end

local function wrap(player)
    if not player then return nil end
    local src = player.PlayerData.source
    if wrappers[src] and wrappers[src]._citizenid==player.PlayerData.citizenid then return wrappers[src] end

    local x = setmetatable({ source=src,playerId=src }, {__index=function(_,key)
        local live=exports.szcore:GetPlayer(src);if not live then return nil end
        local d=live.PlayerData
        if key=='identifier' then return d.license elseif key=='name' then return d.name
        elseif key=='job' then return esxJob(live) elseif key=='accounts' then return wrappers[src].getAccounts()
        elseif key=='inventory' then return wrappers[src].getInventory() elseif key=='metadata' then return d.metadata
        elseif key=='group' then return exports.szcore:IsAdmin(src) and 'admin' or 'user' end
    end})
    function x.getIdentifier() return player.PlayerData.license end
    function x.getName() return player.PlayerData.name end
    function x.getMoney() return player.getMoney('cash') end
    function x.setMoney(amount, reason) return player.setMoney('cash', amount, reason) end
    function x.addMoney(amount, reason) return player.addMoney('cash', amount, reason) end
    function x.removeMoney(amount, reason) return player.removeMoney('cash', amount, reason) end
    function x.getAccount(name)
        local account = mapAccount(name)
        return { name = name, money = account and (player.getMoney(account) or 0) or 0 }
    end
    function x.addAccountMoney(name, amount, reason)
        local account = mapAccount(name); return account and player.addMoney(account, amount, reason) or false
    end
    function x.removeAccountMoney(name, amount, reason)
        local account = mapAccount(name); return account and player.removeMoney(account, amount, reason) or false
    end
    function x.setAccountMoney(name, amount, reason)
        local account = mapAccount(name); return account and player.setMoney(account, amount, reason) or false
    end
    function x.getAccounts(minimal)
        if minimal then return { money = player.getMoney('cash'), bank = player.getMoney('bank'), black_money = player.getMoney('dirty') or 0 } end
        return {
            { name = 'money', money = player.getMoney('cash'), label = 'Cash' },
            { name = 'bank', money = player.getMoney('bank'), label = 'Bank' },
            { name = 'black_money', money = player.getMoney('dirty') or 0, label = 'Black Money' }
        }
    end
    function x.getInventory(minimal)
        if GetResourceState('szcore_inventory')~='started' then return {} end
        local inv=exports.szcore_inventory:GetPlayerInventory(src);local out={};if not inv then return out end
        for slot,e in pairs(inv.items or {}) do if minimal then out[e.name]=(out[e.name] or 0)+e.amount else local def=exports.szcore:GetItemDefinition(e.name) or {};out[#out+1]={name=e.name,count=e.amount,label=def.label or e.name,weight=def.weight or 0,usable=def.usable==true,rare=false,canRemove=true,slot=slot,metadata=e.metadata} end end;return out
    end
    function x.getInventoryItem(name)
        if GetResourceState('szcore_inventory')~='started' then return {name=name,count=0} end
        local inv=exports.szcore_inventory:GetPlayerInventory(src);if not inv then return {name=name,count=0} end
        return {name=name,count=exports.szcore_inventory:GetItemCount(inv.inventory_id,name)}
    end
    function x.addInventoryItem(name,count,metadata,slot)
        local inv=GetResourceState('szcore_inventory')=='started' and exports.szcore_inventory:GetPlayerInventory(src);return inv and exports.szcore_inventory:AddItem(inv.inventory_id,name,count,metadata,slot) or false
    end
    function x.removeInventoryItem(name,count)
        local inv=GetResourceState('szcore_inventory')=='started' and exports.szcore_inventory:GetPlayerInventory(src);return inv and exports.szcore_inventory:RemoveItem(inv.inventory_id,name,count) or false
    end
    function x.canCarryItem(name,count)
        local inv=GetResourceState('szcore_inventory')=='started' and exports.szcore_inventory:GetPlayerInventory(src);return inv and exports.szcore_inventory:CanCarryItem(inv,name,count) or false
    end
    function x.getJob() return esxJob(player) end
    function x.setJob(name,grade)return exports.szcore:ReplacePrimaryGroup(src,'jobs',name,grade)end
    function x.getMeta(key) return player.getMetadata(key) end
    function x.setMeta(key, value) return player.setMetadata(key, value) end
    function x.getGroup() return exports.szcore:IsAdmin(src) and 'admin' or 'user' end
    function x.showNotification(message) TriggerClientEvent('esx:showNotification', src, message) end
    function x.getCoords(vector)
        local ped=GetPlayerPed(src);local c=GetEntityCoords(ped);local p={x=c.x,y=c.y,z=c.z,w=GetEntityHeading(ped)}
        return vector and vector3(p.x, p.y, p.z) or { x = p.x, y = p.y, z = p.z, heading = p.w }
    end
    x._citizenid=player.PlayerData.citizenid
    wrappers[src] = x
    ESX.Players[src] = x
    return x
end

function ESX.GetPlayerFromId(source) return wrap(exports.szcore:GetPlayer(source)) end
function ESX.GetPlayerFromIdentifier(identifier)
    for _, id in ipairs(GetPlayers()) do
        local p = exports.szcore:GetPlayer(tonumber(id))
        if p and p.PlayerData.license == identifier then return wrap(p) end
    end
end
function ESX.GetExtendedPlayers(key, value)
    local out = {}
    for _, id in ipairs(GetPlayers()) do
        local p = exports.szcore:GetPlayer(tonumber(id))
        if p then
            local include = not key
            if key == 'job' then include = p.PlayerData.job.name == value end
            if key == 'group' then include = ((exports.szcore:IsAdmin(p.PlayerData.source) and 'admin' or 'user')==value) end
            if include then out[#out + 1] = wrap(p) end
        end
    end
    return out
end
function ESX.GetPlayers()
    local ids = {}
    for _, id in ipairs(GetPlayers()) do ids[#ids + 1] = tonumber(id) end
    return ids
end
function ESX.RegisterUsableItem(item,cb)
    if GetResourceState('szcore_inventory')=='started' then exports.szcore_inventory:RegisterUsableItem(item,function(source,entry) cb(source,entry) end) end
end
function ESX.RegisterServerCallback(name, cb)
    exports.szcore:CreateCallback(name, function(source, ...)
        local p=promise.new();local resolved=false
        SetTimeout(15000,function()if not resolved then resolved=true;p:resolve({})end end)
        cb(source,function(...)if not resolved then resolved=true;p:resolve({...})end end,...)
        return table.unpack(Citizen.Await(p))
    end)
end
function ESX.DoesJobExist(job, grade)
    local jobs = exports.szcore:GetJobs()
    return jobs[job] ~= nil and jobs[job].grades[tonumber(grade) or 0] ~= nil
end

AddEventHandler('szcore:server:playerLoaded', function(source, player)
    local xPlayer = wrap(player)
    TriggerEvent('esx:playerLoaded', source, xPlayer, false)
end)
AddEventHandler('szcore:server:playerUnloaded', function(source)
    TriggerEvent('esx:playerDropped', source)
    wrappers[source] = nil
    ESX.Players[source] = nil
end)
AddEventHandler('szcore:server:jobChanged', function(source, job, old)
    local player = exports.szcore:GetPlayer(source)
    TriggerEvent('esx:setJob', source, player and esxJob(player) or job, old)
end)

exports('getSharedObject', function() return ESX end)

function ESX.GetJobs()return exports.szcore:GetJobs()end
function ESX.GetNumPlayers(key,value)
    if not key then return exports.szcore:GetPlayerCount()end
    if key=='job' then return exports.szcore:GetJobCount(value,false)end
    return #ESX.GetExtendedPlayers(key,value)
end
AddEventHandler('playerDropped',function()wrappers[source]=nil;ESX.Players[source]=nil end)
