-- =====================================================
-- MIL AVIONICS | LASER GUIDED BOMB (BÁSICO)
-- Tecla: H
-- =====================================================

local function IsValidBombAircraft()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then return false end

    local model = GetEntityModel(veh)
    return Config.BombAircrafts[model] == true
end

-- Calcula tiempo de caída según altura
local function CalculateFallTime(altitude)
    local ratio = math.min(altitude / Config.Bomb.maxAltRef, 1.0)
    return Config.Bomb.minFallTime +
        (Config.Bomb.maxFallTime - Config.Bomb.minFallTime) * ratio
end

-- Lanzamiento de bomba guiada
local function DropLaserGuidedBomb()
    if not TGP.active or not LASER.active or not LASER.hitPos then return end
    if not IsValidBombAircraft() then return end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local planePos = GetEntityCoords(veh)

    local altitude = planePos.z
    local fallTime = CalculateFallTime(altitude)

    local targetPos = LASER.hitPos

    -- Feedback mínimo
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", false)

    -- Simulación de caída
    CreateThread(function()
        Wait(math.floor(fallTime * 1000))

        AddExplosion(
            targetPos.x,
            targetPos.y,
            targetPos.z,
            29,     -- tipo explosión (bomba)
            10.0,   -- daño
            true,
            false,
            1.0
        )
    end)
end

-- =========================
-- INPUT
-- =========================
CreateThread(function()
    while true do
        Wait(0)

        -- H = soltar bomba
        if IsControlJustPressed(0, 74) then
            DropLaserGuidedBomb()
        end
    end
end)
