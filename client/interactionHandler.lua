-- ============================================================
-- INTERACTION HANDLER — NPC zone and job check setup
-- ============================================================

jobData = {
    jobname        = nil,
    job_grade_name = nil,
    job_grade      = nil,
    job_label      = nil,
}

-- ============================================================
-- NPC INTERACTION ZONES
-- ============================================================

--- Registers the interaction zone/prompt for the trucking NPC.
--- Behavior adapts to the detected Config.InteractionHandler / Config.Target.
function InitNPCInteraction()
    local npcCoords = vector3(
        Config.NpcLocation.coords.x,
        Config.NpcLocation.coords.y,
        Config.NpcLocation.coords.z
    )

    local target = Peak.Client.GetTargetSystem()

    if target == 'ox_target' then
        exports.ox_target:addBoxZone({
            name       = 'trucker-npc',
            coords     = npcCoords,
            size       = vec3(3.6, 3.6, 3.6),
            drawSprite = true,
            options    = {
                {
                    name  = 'trucker-npc',
                    event = 'peak-trucking:OpenMenu',
                    icon  = 'fas fa-gears',
                    label = L('open_menu'),
                }
            }
        })
        return
    end

    if target == 'qb-target' then
        exports['qb-target']:AddBoxZone(
            'trucker-npc',
            npcCoords,
            1.5, 1.6,
            {
                name     = 'trucker-npc',
                heading  = 12.0,
                debugPoly = false,
                minZ     = Config.NpcLocation.coords.z - 2,
                maxZ     = Config.NpcLocation.coords.z + 2,
            },
            {
                options = {
                    {
                        num        = 1,
                        type       = 'client',
                        icon       = 'fas fa-gears',
                        label      = L('open_menu'),
                        targeticon = 'fas fa-gears',
                        action     = function()
                            TriggerEvent('peak-trucking:OpenMenu')
                        end,
                    }
                },
                distance = 3.5,
            }
        )
        return
    end

    -- Fallback: text UI with proximity loop (drawtext / qb_textui / esx_textui)
    CreateThread(function()
        local showing = false
        local npcZ    = Config.NpcLocation.coords.z + 1
        local npcVec  = vector3(Config.NpcLocation.coords.x, Config.NpcLocation.coords.y, npcZ)

        while true do
            local plyCoords = GetEntityCoords(PlayerPedId())
            local dist      = #(npcVec - plyCoords)
            local cd        = 1500

            if dist < 5.0 then
                cd = 0

                if not showing then
                    Peak.Client.ShowTextUI(L('open_menu'))
                    showing = true
                end

                if Config.InteractionHandler == 'drawtext' then
                    DrawMarker(2, npcVec, 0, 0, 0, 0, 0, 0, 0.3, 0.2, 0.15, 255, 255, 255, 255, false, false, false, true, false, false, false)
                    DrawText3D(npcVec.x, npcVec.y, npcVec.z, L('open_menu'))
                end

                if IsControlJustPressed(0, 38) then
                    TriggerEvent('peak-trucking:OpenMenu')
                end
            else
                if showing then
                    Peak.Client.HideTextUI()
                    showing = false
                end
            end

            Wait(cd)
        end
    end)
end

-- ============================================================
-- JOB UPDATE LISTENERS
-- ============================================================

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function()
    Wait(1000)
    SetPlayerJob()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function()
    Wait(1000)
    SetPlayerJob()
end)

-- ============================================================
-- JOB & PLAYER STATE
-- ============================================================

--- Reads the player's current job from the framework and caches it in jobData.
function SetPlayerJob()
    WaitCore()
    Wait(500)

    local data = Peak.Client.GetPlayerData()
    if not data then return end

    local fw = Peak.Client.FrameworkName
    if fw == 'esx' then
        jobData.jobname        = data.job.name
        jobData.job_grade_name = data.job.label
        jobData.job_grade      = tonumber(data.job.grade)
    else
        jobData.jobname        = data.job.name
        jobData.job_grade_name = data.job.label
        jobData.job_grade      = data.job.grade.level
    end
end

--- Returns true if the local player is allowed to open the trucking menu.
--- @return boolean
function canOpenMenu()
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        return false
    end

    if Open and Open.CanOpenTruckingMenu then
        if not Open.CanOpenTruckingMenu() then return false end
    end

    if Config.JobName and Config.JobName ~= 'all' then
        if Config.JobName ~= jobData.jobname then
            return false
        end
    end

    return true
end

-- ============================================================
-- 3D TEXT HELPER
-- ============================================================

--- Renders 3D floating text at the given world coordinates.
--- @param x number
--- @param y number
--- @param z number
--- @param text string
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end
