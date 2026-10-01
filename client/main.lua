local ESX = { PlayerData = {}, PlayerLoaded = false }

local function adapt(d)
    if not d or not d.citizenid then return {} end
    local job = d.job or {}
    return {
        source = d.source,
        citizenid = d.citizenid,
        name = d.name,
        accounts = {
            { name = 'money', money = d.money.cash, label = 'Cash' },
            { name = 'bank', money = d.money.bank, label = 'Bank' },
            { name = 'black_money', money = d.money.dirty or 0, label = 'Black Money' }
        },
        money = d.money.cash,
        job = {
            name = job.name, label = job.label, grade = job.grade, grade_name = job.gradeName,
            grade_label = job.gradeName, grade_salary = job.salary or 0, onDuty = job.onduty
        },
        metadata = d.metadata,
        coords = d.position
    }
end

function ESX.GetPlayerData()
    ESX.PlayerData = adapt(exports.szcore:GetPlayerData())
    return ESX.PlayerData
end
function ESX.TriggerServerCallback(name, cb, ...)
    exports.szcore:TriggerCallback(name, function(ok, ...)
        if ok then cb(...) else cb(nil) end
    end, ...)
end
function ESX.ShowNotification(message) if GetResourceState('szcore_ui')=='started' then exports.szcore_ui:Notify({description=tostring(message),type='info'});return end;BeginTextCommandThefeedPost('STRING');AddTextComponentSubstringPlayerName(tostring(message));EndTextCommandThefeedPostTicker(false,false) end

RegisterNetEvent('esx:showNotification', function(message) ESX.ShowNotification(message) end)
AddEventHandler('szcore:client:onPlayerLoaded', function(data)
    ESX.PlayerData = adapt(data)
    ESX.PlayerLoaded = true
    TriggerEvent('esx:playerLoaded', ESX.PlayerData)
end)
AddEventHandler('szcore:client:onPlayerUnloaded', function()
    ESX.PlayerData = {}
    ESX.PlayerLoaded = false
    TriggerEvent('esx:onPlayerLogout')
end)
AddEventHandler('szcore:client:onPlayerData', function(path)
    ESX.PlayerData = adapt(exports.szcore:GetPlayerData())
    if path == 'job' then TriggerEvent('esx:setJob', ESX.PlayerData.job) end
end)

exports('getSharedObject', function() return ESX end)
