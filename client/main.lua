-- ============================================================
-- CLIENT MAIN — State, NUI bridge, vehicle/mission management
-- ============================================================

-- State Variables
local npcPed = false
local illegalNpcPed = false
nuiReady = false
local blipsList = {}
local returnBlip = nil
cam = false
local routeBlip = false
local carryBoxProp = false
local isProcessingJob = false
local isJobActive = false
local isPauseMenuOpen = false
local truckVehicle = false
local trailerVehicle = false
local attachedObject = false
local isIllegalMissionActive = false
illegal = false
local selectedRoute = nil
local selectedTruck = nil
local selectedMission = nil
local currentPhase = 0
local trailerAttached = false
local isAcceptedIllegal = false
local isPendingCall = false


-- ============================================================
-- CORE INIT
-- ============================================================

CreateThread(function()
  while Core == nil do
    Wait(0)
  end

  Core = GetCore()
  Config.Framework = select(2, GetCore())

  InitNPCInteraction()
  SetPlayerJob()
end)

-- ============================================================
-- NUI BRIDGE
-- ============================================================

--- Sends an action and payload to the NUI React app.
--- Blocks until the NUI is ready.
--- @param action  string
--- @param payload any
function NuiMessage(action, payload)
  WaitNui()
  SendNUIMessage({
    action = action,
    payload = payload
  })
end

function TriggerCallback(callbackName, data)
  local result = false
  local status = "UNKOWN"
  local timeout = 0

  WaitCore()
  WaitNui()

  if Config.Framework == "esx" or Config.Framework == "oldesx" then
    Core.TriggerServerCallback(callbackName, function(response)
      status = "SUCCESS"
      result = response
    end, data)
  else
    if Core and Core.Functions and Core.Functions.TriggerCallback then
      Core.Functions.TriggerCallback(callbackName, function(response)
        status = "SUCCESS"
        result = response
      end, data)
    else
      Peak.Utils.Warn('TriggerCallback failed: Core.Functions.TriggerCallback is nil. Framework:', Config.Framework)
      status = "FAILED"
    end
  end

  CreateThread(function()
    while result == false do
      if status ~= "UNKOWN" then
        break
      end
      Wait(1000)
      if timeout == 4 then
        status = "FAILED"
        result = false
        break
      end
      timeout = timeout + 1
    end
  end)

  while status == "UNKOWN" do
    Wait(0)
  end

  return result
end

local function GetFuel(vehicle)
  if not DoesEntityExist(vehicle) then return 0 end

  -- ox_fuel (State Bags)
  if GetResourceState('ox_fuel') == 'started' then
    return Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)
  end

  local system = Config.Fuel
  if system == 'ox_fuel' then
    return Entity(vehicle).state.fuel or GetVehicleFuelLevel(vehicle)
  elseif system == 'legacyfuel' or system == 'LegacyFuel' then
    return exports.LegacyFuel:GetFuel(vehicle)
  elseif system == 'ps-fuel' then
    return exports['ps-fuel']:GetFuel(vehicle)
  elseif system == 'ti_fuel' then
    return exports['ti_fuel']:getFuel(vehicle)
  elseif system == 'okokGasStation' then
    return exports['okokGasStation']:GetFuel(vehicle)
  else
    return GetVehicleFuelLevel(vehicle)
  end
end

--- Blocks execution until nuiReady is true.
function WaitNui()
  while not nuiReady do
    Wait(0)
  end
end

local function ResolveNuiCallback(cb, payload)
  if cb then
    cb(payload or { ok = true })
  end
end

RegisterNUICallback("ready", function(data, cb)
  nuiReady = true
  ResolveNuiCallback(cb)
end)

-- ============================================================
-- NPC SPAWNING
-- ============================================================

--- Spawns the main trucking job NPC at Config.NpcLocation.
function SpawnPed()
  if DoesEntityExist(npcPed) then
    DeleteEntity(npcPed)
  end

  local model = Config.NpcLocation.model
  Peak.Utils.Debug("Spawning NPC with model:", model)
  
  RequestModel(model)
  local timeout = 0
  while not HasModelLoaded(model) and timeout < 100 do
    Wait(10)
    timeout = timeout + 1
  end

  if not HasModelLoaded(model) then
    Peak.Utils.Warn("Failed to load NPC model:", model)
    return
  end

  local coords = Config.NpcLocation.coords
  npcPed = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false, false)
  FreezeEntityPosition(npcPed, true)
  SetEntityInvincible(npcPed, true)
  SetBlockingOfNonTemporaryEvents(npcPed, true)
  Peak.Utils.print("Trucker Job NPC spawned.")
end

function SpawnIllegalPed()
  if DoesEntityExist(illegalNpcPed) then
    DeleteEntity(illegalNpcPed)
  end

  local model = Config.IllegalNPC.model
  Peak.Utils.Debug("Spawning Illegal NPC with model:", model)

  RequestModel(model)
  local timeout = 0
  while not HasModelLoaded(model) and timeout < 100 do
    Wait(10)
    timeout = timeout + 1
  end

  if not HasModelLoaded(model) then
    Peak.Utils.Warn("Failed to load Illegal NPC model:", model)
    return
  end

  local coords = Config.IllegalNPC.coords
  illegalNpcPed = CreatePed(0, model, coords.x, coords.y, coords.z, coords.w, false, false)
  FreezeEntityPosition(illegalNpcPed, true)
  SetEntityInvincible(illegalNpcPed, true)
  SetBlockingOfNonTemporaryEvents(illegalNpcPed, true)
  Peak.Utils.print("Illegal NPC spawned.")
end

AddEventHandler("onResourceStop", function(resourceName)
  if GetCurrentResourceName() ~= resourceName then
    return
  end

  if DoesEntityExist(npcPed) then
    DeleteEntity(npcPed)
  end

  if DoesEntityExist(illegalNpcPed) then
    DeleteEntity(illegalNpcPed)
  end
end)

CreateThread(function()
  -- Wait for framework to be ready
  while not Peak.Client.Ready do
    Wait(100)
  end
  
  SpawnPed()
  SpawnIllegalPed()
end)

CreateThread(function()
  while not nuiReady do
    Wait(2000)
    if NetworkIsSessionStarted() then
      SendNUIMessage({ action = "checknui" })
    end
  end
end)

RegisterNUICallback("close", function(data, cb)
  isEditingHud = false
  NuiMessage("toggle_hud_edit", { editing = false })
  SetNuiFocus(false, false)
  if DoesCamExist(cam) then
    RenderScriptCams(false, true, 500, true, true)
    DestroyCam(cam, true)
  end
  ResolveNuiCallback(cb)
end)

RegisterNetEvent("peak-trucking:OpenMenu")
AddEventHandler("peak-trucking:OpenMenu", function()
  if canOpenMenu() then
    TriggerServerEvent("peak-trucking:CheckDailyMission")
    NuiMessage("open")
    SetNuiFocus(true, true)
    CreateCamera()
  else
    createNotification(Config.Language.notaccessjob)
  end
end)

-- ============================================================
-- BLIPS & CAMERA
-- ============================================================

--- Creates a map blip at a coord or for an entity.
function CreateBlip(coords, sprite, color, scale, name, show, isEntity, entity)
  if show then
    local blip = nil
    if isEntity then
      blip = AddBlipForEntity(entity)
    else
      blip = AddBlipForCoord(coords)
    end

    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(name)
    EndTextCommandSetBlipName(blip)

    return blip
  end
end

function Close()
  NuiMessage("close")
end

CreateThread(function()
  Wait(2000)

  local npcCoords = Config.NpcLocation.coords
  local npcBlip = CreateBlip(
    vector3(npcCoords.x, npcCoords.y, npcCoords.z),
    Config.NpcLocation.blip.sprite,
    Config.NpcLocation.blip.color,
    Config.NpcLocation.blip.scale,
    Config.NpcLocation.blip.name,
    Config.NpcLocation.blip.show
  )
  table.insert(blipsList, npcBlip)
  NuiMessage("set_missions", Config.Missions)
end)

-- ============================================================
-- VEHICLE & OBJECT SPAWNING
-- ============================================================

--- Spawns a vehicle model, optionally handing keys and warping the player.
--- @param modelName    string
--- @param coords       vector3|vector4
--- @param teleportInto boolean
--- @param heading      number|nil
--- @param giveKey      boolean|nil
--- @return number  Vehicle entity handle
function SpawnVehicle(modelName, coords, teleportInto, heading, giveKey)
  local modelHash = GetHashKey(modelName)
  RequestModel(modelHash)

  while not HasModelLoaded(modelHash) do
    Wait(0)
  end

  local vehicle = CreateVehicle(modelHash, coords.x, coords.y, coords.z, true, true)

  if giveKey then
    Config.GiveVehicleKey(GetVehicleNumberPlateText(vehicle), GetHashKey(vehicle), vehicle)
  end

  Config.SetVehicleFuel(vehicle, 100.0)

  if heading then
    SetEntityHeading(vehicle, heading)
  end

  if teleportInto then
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
  end

  return vehicle
end

function SpawnObject(modelName, coords)
  local modelHash = GetHashKey(modelName)
  RequestModel(modelHash)

  while not HasModelLoaded(modelHash) do
    Wait(0)
  end

  local object = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, true)
  return object
end

-- ============================================================
-- JOB INFO & PROP HELPERS
-- ============================================================

--- Sends a job HUD key-value update to the NUI.
function setJobInfo(key, value)
  NuiMessage("setJobInfo", {
    key = key,
    value = value
  })
end

function LoadPropDict(propName)
  while not HasModelLoaded(GetHashKey(propName)) do
    RequestModel(GetHashKey(propName))
    Wait(10)
  end
end

function AttachBoxToPed()
  local propName = "hei_prop_heist_box"
  local boneId = 60309
  local offset = { 0.025, 0.08, 0.255, -145.0, 290.0, 0.0 }

  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)

  if not HasModelLoaded(propName) then
    LoadPropDict(propName)
  end

  carryBoxProp = CreateObject(GetHashKey(propName), playerCoords.x, playerCoords.y, playerCoords.z + 0.2, true, true,
    true)

  AttachEntityToEntity(
    carryBoxProp,
    playerPed,
    GetPedBoneIndex(playerPed, boneId),
    offset[1], offset[2], offset[3],
    offset[4], offset[5], offset[6],
    true, true, false, true, 1, true
  )

  SetModelAsNoLongerNeeded(propName)

  while not HasAnimDictLoaded("anim@heists@box_carry@") do
    RequestAnimDict("anim@heists@box_carry@")
    Citizen.Wait(100)
  end

  TaskPlayAnim(playerPed, "anim@heists@box_carry@", "idle", 4.0, 4.0, -1, 51, 0, false, false, false)
end

-- Pause Menu Handler
CreateThread(function()
  while true do
    if IsPauseMenuActive() then
      if not isPauseMenuOpen and isJobActive then
        isPauseMenuOpen = true
        setJobInfo("started", false)
      end
    end

    if not IsPauseMenuActive() then
      if isPauseMenuOpen and isJobActive then
        isPauseMenuOpen = false
        setJobInfo("started", true)
      end
    end

    Wait(1500)
  end
end)

RegisterNUICallback("stopJob", function(data, cb)
  setJobInfo("started", false)
  isJobActive = false
  isProcessingJob = false
  isIllegalMissionActive = false
  illegal = false

  if DoesEntityExist(trailerVehicle) then
    DeleteVehicle(trailerVehicle)
  end

  if DoesEntityExist(attachedObject) then
    if IsEntityAVehicle(attachedObject) then
      DeleteVehicle(attachedObject)
    else
      DeleteEntity(attachedObject)
    end
  end

  if DoesEntityExist(truckVehicle) then
    Config.RemoveVehiclekey(GetVehicleNumberPlateText(truckVehicle), GetHashKey(truckVehicle), truckVehicle)
    DeleteEntity(truckVehicle)
  end

  DeleteWaypoint()

  if DoesBlipExist(routeBlip) then
    RemoveBlip(routeBlip)
  end

  TriggerServerEvent("peak-trucking:StartJob", false)
  ResolveNuiCallback(cb)
end)

RegisterNUICallback("startJob", function(data, cb)
  if isProcessingJob then
    if Config.Debug then
      debugPrint("Spam Control")
    end
    ResolveNuiCallback(cb, { ok = false, error = "processing" })
    return
  end

  isProcessingJob = true

  if isJobActive then
    createNotification("You already have active mission.")
    isProcessingJob = false
    ResolveNuiCallback(cb, { ok = false, error = "active_job" })
    return
  end

  selectedRoute = data.route
  selectedTruck = data.truck
  selectedMission = data.mission

  if not selectedRoute then
    createNotification("Route not found.")
    isProcessingJob = false
    ResolveNuiCallback(cb, { ok = false, error = "missing_route" })
    return
  end

  if not selectedTruck then
    createNotification("Truck not found.")
    isProcessingJob = false
    ResolveNuiCallback(cb, { ok = false, error = "missing_truck" })
    return
  end

  isAcceptedIllegal = false
  local isMissionUnlocked = TriggerCallback("peak-trucking:CheckMissionUnlocked", selectedMission.id)

  trailerAttached = false
  local trailerSpawnLocation = TrailerSpawnCoords(selectedRoute.trailerSpawnAvaliableCoords)


  if isMissionUnlocked then
    local isTruckAllowed = false

    for _, vehicleName in pairs(selectedRoute.vehicle) do
      if vehicleName == selectedTruck.name then
        isTruckAllowed = true
      end
    end

    if selectedRoute.trailerSpawnAvaliableCoords and not trailerSpawnLocation then
      createNotification(Config.Language.spawn_location_full)
      isProcessingJob = false
      ResolveNuiCallback(cb, { ok = false, error = "spawn_full" })
      return
    end

    if not isTruckAllowed then
      createNotification(Config.Language.cant_select_truck)
      isProcessingJob = false
      ResolveNuiCallback(cb, { ok = false, error = "truck_not_allowed" })
      return
    end

    -- Spawn the truck
    truckVehicle = SpawnVehicle(
      selectedTruck.name,
      Config.VehSpawn,
      true,
      Config.VehSpawn.w,
      true
    )

    CreateBlip(false, 477, 3, 0.8, "Truck", true, true, truckVehicle)

    -- Spawn trailer if route has one
    if selectedRoute.trailerModel then
      CreateThread(function()
        local trailerSpawned = false
        while not trailerSpawned do
          local playerCoords = GetEntityCoords(PlayerPedId())
          local spawnLocation = vector3(trailerSpawnLocation.x, trailerSpawnLocation.y, trailerSpawnLocation.z)
          local distance = #(playerCoords - spawnLocation)

          if distance < 70.0 then
            trailerVehicle = SpawnVehicle(
              selectedRoute.trailerModel,
              vector3(trailerSpawnLocation.x, trailerSpawnLocation.y, trailerSpawnLocation.z + 1.0),
              false,
              trailerSpawnLocation.w
            )
            CreateBlip(false, 479, 3, 0.8, "Trailer", true, true, trailerVehicle)
            trailerSpawned = true
          end
          Wait(1000)
        end
      end)
    end

    -- Spawn attached cargo if route has one
    if selectedRoute.attachModel then
      CreateThread(function()
        local objectSpawned = false
        while not objectSpawned do
          if DoesEntityExist(trailerVehicle) then
            -- Check if it's a vehicle or object
            if selectedRoute.attachModel == "apc" or selectedRoute.attachModel == "rhino" or selectedRoute.attachModel == "scarab" then
              attachedObject = SpawnVehicle(
                selectedRoute.attachModel,
                vector3(trailerSpawnLocation.x, trailerSpawnLocation.y, trailerSpawnLocation.z + 1.0),
                false
              )
            else
              attachedObject = SpawnObject(selectedRoute.attachModel, trailerSpawnLocation)
            end

            local attachHeight = selectedRoute.attachModelHeight or 0.0
            AttachEntityToEntity(
              attachedObject,
              trailerVehicle,
              GetEntityBoneIndexByName(trailerVehicle, GetHashKey("boot")),
              0.0, 0.0, attachHeight,
              0.0, 0.0, 0.0,
              false, false, false, false, 0.0, true
            )
            objectSpawned = true
          end
          Wait(1000)
        end
      end)
    end

    -- Set route blip
    if selectedRoute.trailerSpawnAvaliableCoords then
      routeBlip = AddBlipForCoord(trailerSpawnLocation.x, trailerSpawnLocation.y, trailerSpawnLocation.z)
      SetBlipColour(routeBlip, 5)
      SetBlipRoute(routeBlip, true)
      SetBlipRouteColour(routeBlip, 5)
    else
      routeBlip = AddBlipForCoord(selectedRoute.destination.x, selectedRoute.destination.y, selectedRoute.destination.z)
      SetBlipColour(routeBlip, 5)
      SetBlipRoute(routeBlip, true)
      SetBlipRouteColour(routeBlip, 5)
    end

    createNotification(Config.Language.get_trailer)
    Close()

    isJobActive = true
    setJobInfo("started", true)
    TriggerServerEvent("peak-trucking:StartJob", selectedMission.id)
    setJobInfo("attachedTrailer", false)
    setJobInfo("routeHeader", selectedRoute.label)

    currentPhase = 1
    if not selectedRoute.trailerSpawnAvaliableCoords then
      currentPhase = 2
    end

    -- Ghost mode for spawn area
    if Config.EnableGhostMode then
      CreateThread(function()
        local isGhostActive = false
        while DoesEntityExist(truckVehicle) do
          local playerCoords = GetEntityCoords(PlayerPedId())
          local spawnCoords = vector3(Config.VehSpawn.x, Config.VehSpawn.y, Config.VehSpawn.z)
          local distance = #(playerCoords - spawnCoords)

          if distance < 15.0 then
            if not isGhostActive then
              SetLocalPlayerAsGhost(true)
              isGhostActive = true
            end
          elseif isGhostActive then
            SetLocalPlayerAsGhost(false)
            isGhostActive = false
          end

          Wait(1000)
        end
        SetLocalPlayerAsGhost(false)
      end)
    end

    -- Key press handler for marking locations
    CreateThread(function()
      while DoesEntityExist(truckVehicle) do
        if IsControlJustPressed(0, Config.KeyPressed.mark_location.key) then
          if not isIllegalMissionActive then
            if currentPhase == 1 then
              if selectedMission.id == 16 then
                -- Special mission 16 logic
                if DoesBlipExist(routeBlip) then
                  RemoveBlip(routeBlip)
                end
                routeBlip = AddBlipForCoord(selectedRoute.board.x, selectedRoute.board.y, selectedRoute.board.z)
                SetBlipColour(routeBlip, 5)
                SetBlipRoute(routeBlip, true)
                SetBlipRouteColour(routeBlip, 5)
              else
                if selectedRoute.trailerSpawnAvaliableCoords then
                  if DoesBlipExist(routeBlip) then
                    RemoveBlip(routeBlip)
                  end
                  routeBlip = AddBlipForCoord(trailerSpawnLocation.x, trailerSpawnLocation.y, trailerSpawnLocation.z)
                  SetBlipColour(routeBlip, 5)
                  SetBlipRoute(routeBlip, true)
                  SetBlipRouteColour(routeBlip, 5)
                end
              end
            end

            if currentPhase == 2 then
              if DoesBlipExist(routeBlip) then
                RemoveBlip(routeBlip)
              end
              routeBlip = AddBlipForCoord(selectedRoute.destination.x, selectedRoute.destination.y,
                selectedRoute.destination.z)
              SetBlipColour(routeBlip, 5)
              SetBlipRoute(routeBlip, true)
              SetBlipRouteColour(routeBlip, 5)
            end

            if currentPhase == 3 then
              if DoesBlipExist(routeBlip) then
                RemoveBlip(routeBlip)
              end
              routeBlip = AddBlipForCoord(Config.VehSpawn.x, Config.VehSpawn.y, Config.VehSpawn.z)
              SetBlipColour(routeBlip, 5)
              SetBlipRoute(routeBlip, true)
              SetBlipRouteColour(routeBlip, 5)
            end
          end
        end

        Wait(0)
      end
    end)

    -- Daily mission tracking
    CreateThread(function()
      while DoesEntityExist(truckVehicle) do
        Wait(60000)
        TriggerServerEvent("peak-trucking:AddDailyMissionProcess", "on_the_roads")
      end
    end)

    -- Vehicle health and fuel monitoring
    CreateThread(function()
      while DoesEntityExist(truckVehicle) do
        setJobInfo("bodyHealth", GetVehicleBodyHealth(truckVehicle) / 10)
        setJobInfo("fuel", GetFuel(truckVehicle))
        Wait(2000)
      end
    end)
    -- Main mission logic thread
    CreateThread(function()
      if selectedMission.id == 16 then
        -- Special mission 16: manual cargo loading
        local boxCount = 0
        local hasBox = false

        if DoesBlipExist(routeBlip) then
          RemoveBlip(routeBlip)
        end
        routeBlip = AddBlipForCoord(selectedRoute.board.x, selectedRoute.board.y, selectedRoute.board.z)
        SetBlipColour(routeBlip, 5)
        SetBlipRoute(routeBlip, true)
        SetBlipRouteColour(routeBlip, 5)

        while DoesEntityExist(truckVehicle) do
          local checkInterval = 1000

          local truckBackCoords = GetWorldPositionOfEntityBone(truckVehicle,
            GetEntityBoneIndexByName(truckVehicle, "platelight"))
          local playerCoords = GetEntityCoords(PlayerPedId())
          local distToTruck = #(playerCoords - truckBackCoords)

          local boardCoords = vector3(selectedRoute.board.x, selectedRoute.board.y, selectedRoute.board.z)
          local distToBoard = #(playerCoords - boardCoords)

          local loadDistance = 2.5

          -- Load box into truck
          if distToTruck < loadDistance and hasBox then
            checkInterval = 0
            DrawMarker(2, vector3(truckBackCoords.x, truckBackCoords.y, truckBackCoords.z + 1.0), 0.0, 0.0, 0.0, 0.0, 0.0,
              0.0, 0.5, 0.5, 0.5, 255, 255, 255, 255, true, false, false, true, false, false, false)
            DrawText3D(truckBackCoords.x, truckBackCoords.y, truckBackCoords.z, Config.Language.load_box)
            DrawMarker(2, truckBackCoords.x, truckBackCoords.y, truckBackCoords.z + 4.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
              0.5, 0.5, 0.5, 255, 255, 255, 255, true, false, false, true, false, false, false)

            if IsControlJustPressed(0, 38) then
              if not IsPedInAnyVehicle(PlayerPedId()) then
                boxCount = boxCount + 1
                hasBox = false
                DeleteEntity(carryBoxProp)
                ClearPedTasks(PlayerPedId())

                if boxCount == 10 then
                  ClearPedTasks(PlayerPedId())
                  break
                end
                Wait(1000)
              else
                createNotification(Config.Language.in_vehicle)
              end
            end
          end

          -- Pick up box from board
          if distToBoard < 5.0 and not hasBox then
            checkInterval = 0
            DrawMarker(2, vector3(selectedRoute.board.x, selectedRoute.board.y, selectedRoute.board.z), 0.0, 0.0, 0.0,
              0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 255, true, false, false, true, false, false, false)
            DrawText3D(selectedRoute.board.x, selectedRoute.board.y, selectedRoute.board.z, Config.Language.take_box)

            if IsControlJustPressed(0, 38) then
              if not IsPedInAnyVehicle(PlayerPedId()) then
                AttachBoxToPed()
                hasBox = true
              else
                createNotification(Config.Language.in_vehicle)
              end
            end
          end

          Wait(checkInterval)
        end
      else
        -- Standard trailer missions
        while selectedRoute.trailerSpawnAvaliableCoords and DoesEntityExist(truckVehicle) do
          local checkInterval = 1000

          local isTrailerAttached, vehicleTrailer = GetVehicleTrailerVehicle(truckVehicle)

          -- Break loop when trailer is successfully attached
          if isTrailerAttached then
            break
          end

          if DoesEntityExist(trailerVehicle) then
            local trailerCoords = GetEntityCoords(trailerVehicle)
            local truckCoords = GetEntityCoords(truckVehicle)
            local distance = #(truckCoords - trailerCoords)

            if distance < 100.0 then
              if distance < 50.0 then
                checkInterval = 0
                DrawMarker(2, trailerCoords.x, trailerCoords.y, trailerCoords.z + 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                  0.5, 0.5, 0.5, 255, 255, 255, 255, true, false, false, true, false, false, false)
              else
                checkInterval = 500
              end
            end
          end

          Wait(checkInterval)
        end
      end

      -- After trailer attached, set destination blip
      if DoesBlipExist(routeBlip) then
        RemoveBlip(routeBlip)
      end
      routeBlip = AddBlipForCoord(selectedRoute.destination.x, selectedRoute.destination.y, selectedRoute.destination.z)
      SetBlipColour(routeBlip, 5)
      SetBlipRoute(routeBlip, true)
      SetBlipRouteColour(routeBlip, 5)

      createNotification(Config.Language.deliver_trailer)
      setJobInfo("attachedTrailer", true)
      currentPhase = 2

      -- Drive to destination
      while DoesEntityExist(truckVehicle) do
        local checkInterval = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        local destination = vector3(selectedRoute.destination.x, selectedRoute.destination.y, selectedRoute.destination
          .z)
        local distanceToDest = #(playerCoords - destination)

        if distanceToDest < 10.0 then
          checkInterval = 0
          DrawMarker(23,
            vector3(selectedRoute.destination.x, selectedRoute.destination.y, selectedRoute.destination.z - 0.9), 0.0,
            0.0, 0.0, 0.0, 0.0, 0.0, 3.8, 3.8, 3.8, 255, 255, 255, 255, false, false, false, true, false, false, false)
          DrawText3D(selectedRoute.destination.x, selectedRoute.destination.y, selectedRoute.destination.z,
            Config.Language.deliver)

          if IsControlJustPressed(0, 38) then
            local vehicleSpeed = GetEntitySpeed(truckVehicle)

            if vehicleSpeed <= 0 then
              local hasTrailerNow, currentTrailer = GetVehicleTrailerVehicle(truckVehicle)

              -- Check if trailer is attached (when required)
              local trailerMatches = true
              if selectedRoute.trailerModel then
                if hasTrailerNow and currentTrailer == trailerVehicle then
                  trailerMatches = true
                else
                  trailerMatches = false
                end
              end

              if trailerMatches then
                -- Set return blip
                if DoesBlipExist(routeBlip) then
                  RemoveBlip(routeBlip)
                end

                Wait(500)

                returnBlip = AddBlipForCoord(Config.VehSpawn.x, Config.VehSpawn.y, Config.VehSpawn.z)
                SetBlipColour(returnBlip, 5)
                SetBlipRoute(returnBlip, true)
                SetBlipRouteColour(returnBlip, 5)
                SetNewWaypoint(Config.VehSpawn.x, Config.VehSpawn.y)

                createNotification(Config.Language.return_veh)
                setJobInfo("started", false)

                -- Detach and delete trailer
                if DoesEntityExist(trailerVehicle) then
                  DetachVehicleFromTrailer(truckVehicle)
                  CreateThread(function()
                    Wait(Config.VehicleDeleteTimeout)
                    DeleteVehicle(trailerVehicle)
                    if DoesEntityExist(attachedObject) then
                      if IsEntityAVehicle(attachedObject) then
                        DeleteVehicle(attachedObject)
                      else
                        DeleteEntity(attachedObject)
                      end
                    end
                  end)
                end

                break
              else
                createNotification(Config.Language.trailer_doesnt_match)
              end
            else
              createNotification(Config.Language.stop_vehicle)
            end
          end
        end

        Wait(checkInterval)
      end

      -- Return truck to spawn
      currentPhase = 3

      while DoesEntityExist(truckVehicle) do
        local checkInterval = 1000
        local playerCoords = GetEntityCoords(PlayerPedId())
        local spawnCoords = vector3(Config.VehSpawn.x, Config.VehSpawn.y, Config.VehSpawn.z)
        local distanceToSpawn = #(playerCoords - spawnCoords)

        if distanceToSpawn < 10.0 then
          checkInterval = 0
          DrawMarker(2, vector3(Config.VehSpawn.x, Config.VehSpawn.y, Config.VehSpawn.z), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.5, 0.5, 0.5, 255, 255, 255, 255, true, false, false, true, false, false, false)
          DrawText3D(Config.VehSpawn.x, Config.VehSpawn.y, Config.VehSpawn.z, Config.Language.finish_job)

          if IsControlJustPressed(0, 38) then
            setJobInfo("started", false)

            -- Track daily mission
            if selectedMission.reqLevel then
              TriggerServerEvent("peak-trucking:AddDailyMissionProcess", "complete_special_mission")
            else
              TriggerServerEvent("peak-trucking:AddDailyMissionProcess", "complete_mission")
            end

            -- Cleanup blips
            if DoesBlipExist(returnBlip) then
              RemoveBlip(returnBlip)
            end
            if DoesBlipExist(routeBlip) then
              RemoveBlip(routeBlip)
            end

            isJobActive = false
            isIllegalMissionActive = false
            isAcceptedIllegal = false

            -- Complete job
            TriggerServerEvent(
              "peak-trucking:FinishJob",
              selectedMission.id,
              GetVehicleBodyHealth(truckVehicle) / 10,
              trailerAttached,
              selectedRoute.label
            )

            createNotification(Config.Language.leave_vehicle)
            Config.RemoveVehiclekey(GetVehicleNumberPlateText(truckVehicle), GetHashKey(truckVehicle), truckVehicle)
            TaskLeaveAnyVehicle(PlayerPedId(), 0, 0)

            -- Delete truck after timeout
            CreateThread(function()
              Wait(Config.VehicleDeleteTimeout)
              DeleteVehicle(truckVehicle)
            end)

            -- Cleanup blips after 10s
            CreateThread(function()
              Wait(10000)
              if DoesBlipExist(returnBlip) then
                RemoveBlip(returnBlip)
              end
              if DoesBlipExist(routeBlip) then
                RemoveBlip(routeBlip)
              end
              RemoveBlip(returnBlip)
              RemoveBlip(routeBlip)
            end)

            break
          end
        end

        Wait(checkInterval)
      end
    end)
  else
    createNotification(Config.Language.mission_locked)
  end

  Wait(5000)
  isProcessingJob = false
  ResolveNuiCallback(cb)
end)

-- Standing logic for Illegal NPC moved to global scope for better responsiveness
CreateThread(function()
  while true do
    local checkInterval = 1500
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local illegalNpcCoords = vector3(
      Config.IllegalNPC.coords.x,
      Config.IllegalNPC.coords.y,
      Config.IllegalNPC.coords.z
    )
    local distanceToIllegalNpc = #(playerCoords - illegalNpcCoords)

    if distanceToIllegalNpc < 4.0 then
      checkInterval = 0
      DrawText3D(
        Config.IllegalNPC.coords.x,
        Config.IllegalNPC.coords.y,
        Config.IllegalNPC.coords.z + 1.1,
        Config.Language.take_illegal or "Press [E] for Illegal Dealings"
      )

      if IsControlJustPressed(0, 38) then
        if not DoesEntityExist(truckVehicle) or not isJobActive then
          createNotification(Config.Language.must_have_job or "You need an active trucker mission to deal with me.")
        else
          if isIllegalMissionActive or isPendingCall then
            createNotification(Config.Language.already_illegal or "You are already doing an illegal delivery or waiting for a call.")
          else
            isPendingCall = true
            createNotification(Config.Language.wait_call or "Stay close, we'll call you if we have work...")
            -- Hidden wait logic remains for immersion, but now we have a notification
            SetTimeout(math.random(15000, 25000), function()
              isPendingCall = false
              if #(GetEntityCoords(PlayerPedId()) - illegalNpcCoords) < 50.0 then
                isAcceptedIllegal = true
                NuiMessage("callillegal")
                -- Auto-decline after 15 seconds if no response
                SetTimeout(15000, function()
                  if isAcceptedIllegal then
                    isAcceptedIllegal = false
                    NuiMessage("declineillegal")
                  end
                end)
              else
                createNotification(Config.Language.too_far or "You wandered too far, the deal is off.")
              end
            end)
          end
        end
      end
    end
    Wait(checkInterval)
  end
end)

-- Illegal Action Handlers
CreateThread(function()
  while true do
    local wait = 1000
    if isAcceptedIllegal then
      wait = 0
      if IsControlJustPressed(0, 246) then -- [Y] Accept
        NuiMessage("acceptillegal")
        isAcceptedIllegal = false
        isIllegalMissionActive = true
        TriggerServerEvent("peak-trucking:AcceptIllegalDeal")
        createNotification(Config.Language.go_to_pickup or "Go to the pickup point and load the goods.")

        -- Hide phone UI after a short delay (Trevor call immersion)
        SetTimeout(10000, function()
          NuiMessage("declineillegal")
        end)

        -- Set blip to board location
        if DoesBlipExist(routeBlip) then
          RemoveBlip(routeBlip)
        end
        routeBlip = AddBlipForCoord(
          Config.IllegalNPC.boardLocation.x,
          Config.IllegalNPC.boardLocation.y,
          Config.IllegalNPC.boardLocation.z
        )
        SetBlipColour(routeBlip, 5)
        SetBlipRoute(routeBlip, true)
        SetBlipRouteColour(routeBlip, 5)

        -- Illegal box pickup logic
        CreateThread(function()
          local boxCount = 0
          local hasBox = false

          while isIllegalMissionActive and DoesEntityExist(truckVehicle) do
            local pedCoords = GetEntityCoords(PlayerPedId())
            local truckBackCoords = GetWorldPositionOfEntityBone(truckVehicle, GetEntityBoneIndexByName(truckVehicle, "platelight"))
            -- Fallback if no platelight bone
            if truckBackCoords == vector3(0,0,0) then
              truckBackCoords = GetEntityCoords(truckVehicle)
            end
            local distToTruck = #(pedCoords - truckBackCoords)

            local boardLocation = vector3(
              Config.IllegalNPC.boardLocation.x,
              Config.IllegalNPC.boardLocation.y,
              Config.IllegalNPC.boardLocation.z
            )
            local distToBoard = #(pedCoords - boardLocation)

            -- Carrying box to truck
            if distToTruck < 2.5 and hasBox then
              DrawMarker(2, vector3(truckBackCoords.x, truckBackCoords.y, truckBackCoords.z + 1.0), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 255, true, false, false, true, false, false, false)
              DrawText3D(truckBackCoords.x, truckBackCoords.y, truckBackCoords.z, Config.Language.load_box)

              if IsControlJustPressed(0, 38) then
                if not IsPedInAnyVehicle(PlayerPedId()) then
                  boxCount = boxCount + 1
                  hasBox = false
                  DeleteEntity(carryBoxProp)
                  ClearPedTasks(PlayerPedId())
                  TriggerServerEvent("peak-trucking:GiveIllegalItem")
                  setJobInfo("boxProgress", boxCount .. "/10")
                else
                  createNotification(Config.Language.in_vehicle)
                end

                if boxCount == 10 then
                  ClearPedTasks(PlayerPedId())
                  trailerAttached = true
                  setJobInfo("boxProgress", nil) -- Clear progress after completion
                  
                  -- Update blip to next destination
                  if currentPhase == 1 then
                    if DoesBlipExist(routeBlip) then RemoveBlip(routeBlip) end
                    routeBlip = AddBlipForCoord(selectedRoute.destination.x, selectedRoute.destination.y, selectedRoute.destination.z)
                    SetBlipColour(routeBlip, 5)
                    SetBlipRoute(routeBlip, true)
                    SetBlipRouteColour(routeBlip, 5)
                  end
                  
                  isIllegalMissionActive = false
                  break
                end
                Wait(1000)
              end
            end

            -- Pick up box from board location
            if distToBoard < 5.0 and not hasBox then
              DrawMarker(2, vector3(boardLocation.x, boardLocation.y, boardLocation.z), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 255, 255, 255, 255, true, false, false, true, false, false, false)
              DrawText3D(Config.IllegalNPC.boardLocation.x, Config.IllegalNPC.boardLocation.y, Config.IllegalNPC.boardLocation.z, Config.Language.take_box)

              if IsControlJustPressed(0, 38) then
                if not IsPedInAnyVehicle(PlayerPedId()) then
                  AttachBoxToPed()
                  hasBox = true
                else
                  createNotification(Config.Language.in_vehicle)
                end
              end
            end
            Wait(0)
          end
        end)
      elseif IsControlJustPressed(0, 249) then -- [N] Decline
        NuiMessage("declineillegal")
        isIllegalMissionActive = false
        isAcceptedIllegal = false
      end
    end
    Wait(wait)
  end
end)


RegisterNUICallback("getLeaderboard", function(data, cb)
  local leaderboard = TriggerCallback("peak-trucking:GetLeaderboard")
  cb(leaderboard)
end)

RegisterNetEvent("peak-trucking:SyncPlayerDataByKey")
AddEventHandler("peak-trucking:SyncPlayerDataByKey", function(key, value)
  NuiMessage("SyncPlayerDataByKey", {
    key = key,
    value = value
  })
end)

RegisterNUICallback("UnlockMission", function(data, cb)
  TriggerServerEvent("peak-trucking:UnlockMission", data.mission)
  ResolveNuiCallback(cb)
end)

function createNotification(message)
  NuiMessage("createNotification", message)
end

RegisterNetEvent("peak-trucking:createNotification")
AddEventHandler("peak-trucking:createNotification", function(message)
  createNotification(message)
end)

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function()
  TriggerServerEvent("peak-trucking:LoadPlayerData")
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
  TriggerServerEvent("peak-trucking:LoadPlayerData")
end)

AddEventHandler("onResourceStart", function(resourceName)
  if GetCurrentResourceName() ~= resourceName then
    return
  end

  WaitNui()
  WaitCore()
  WaitPlayer()

  while Core == nil do
    Wait(0)
  end

  TriggerServerEvent("peak-trucking:LoadPlayerData")
end)

-- Send config data to NUI
CreateThread(function()
  Wait(2000)

  while Core == nil do
    Wait(0)
  end

  WaitNui()

  NuiMessage("setXP", Config.XP)
  NuiMessage("setLanguage", Config.Language)
  NuiMessage("setTrucks", Config.Trucks)
  NuiMessage("setTrucksCopy", Config.Trucks)
  NuiMessage("setKeyBinds", Config.KeyPressed)
end)

function CreateCamera()
  if IsPedInAnyVehicle(PlayerPedId(), false) then
    return
  end

  local camOffset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 1.38, -1.7, 0)

  RenderScriptCams(true, true, 500, true, true)
  DestroyCam(cam, false)

  if not DoesCamExist(cam) then
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    SetCamCoord(cam, camOffset.x, camOffset.y, camOffset.z + 0.2)
    SetCamRot(cam, 5.0, 0.0, GetEntityHeading(PlayerPedId()))
    SetCamNearClip(cam, 0.1)
    SetCamFarClip(cam, 1000.0)
    SetCamFov(cam, 68.0)
    SetCamDofFnumberOfLens(cam, 24.0)
    SetCamDofFocalLengthMultiplier(cam, 50.0)
  end
end

CreateThread(function()
  WaitCore()
end)

function PeakGetVehicles()
  return GetGamePool("CVehicle")
end

function PeakGetVehiclesInArea(coords, radius)
  return PeakEnumerateEntitiesWithinDistance(PeakGetVehicles(), false, coords, radius)
end

function PeakEnumerateEntitiesWithinDistance(entities, useIndex, center, radius)
  local nearbyEntities = {}

  if center then
    center = vector3(center.x, center.y, center.z)
  else
    local playerPed = PlayerPedId()
    center = GetEntityCoords(playerPed)
  end

  for index, entity in pairs(entities) do
    local entityCoords = GetEntityCoords(entity)
    local distance = #(center - entityCoords)

    if radius >= distance then
      local idx = #nearbyEntities + 1
      local val = entity
      if useIndex and index then
        val = index
      end
      nearbyEntities[idx] = val
    end
  end

  return nearbyEntities
end

function TrailerSpawnCoords(availableCoords)
  local freeCoords = {}

  if availableCoords then
    for _, coord in ipairs(availableCoords) do
      local coordVec4 = vector4(coord.x, coord.y, coord.z, coord.w)
      local nearbyVehicles = PeakGetVehiclesInArea(coordVec4, 5.0)

      if next(nearbyVehicles) == nil then
        table.insert(freeCoords, coordVec4)
      end
    end

    if #freeCoords > 0 then
      local randomIndex = math.random(1, #freeCoords)
      return freeCoords[randomIndex]
    end
  end

  return false
end

function WaitPlayer()
  if Config.Framework == "esx" or Config.Framework == "oldesx" then
    while Core.GetPlayerData() == nil do
      Wait(0)
    end
    while Core.GetPlayerData().job == nil do
      Wait(0)
    end
  else
    while Core.Functions.GetPlayerData() == nil do
      Wait(0)
    end
    while Core.Functions.GetPlayerData().metadata == nil do
      Wait(0)
    end
  end
end

-- ============================================================
-- HUD REPOSITIONING
-- ============================================================

local isEditingHud = false

RegisterCommand("truckhud", function()
  isEditingHud = not isEditingHud
  if isEditingHud then
    NuiMessage("toggle_hud_edit", { editing = true })
    SetNuiFocus(true, true)
    createNotification(Config.Language.edit_hud_hint or "HUD Edit Mode: Drag to move. Press ESC or run /truckhud again to save.")
  else
    NuiMessage("toggle_hud_edit", { editing = false })
    SetNuiFocus(false, false)
  end
end)

RegisterNUICallback("save_hud_pos", function(data, cb)
  isEditingHud = false
  NuiMessage("toggle_hud_edit", { editing = false })
  SetNuiFocus(false, false)
  ResolveNuiCallback(cb)
end)
