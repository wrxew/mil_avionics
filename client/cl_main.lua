-- =====================================================
-- MIL AVIONICS | TGP + FLIR + LOCK + TARGET INFO + LASER
-- Requiere funcs.lua:
--  - RotationToDirection
--  - Clamp
--  - GetBasicFlightData
-- =====================================================

-- =========================
-- FLIR SYSTEM
-- =========================
FLIR = {
    active = false,
    mode = "BLACK_HOT",
    uiTick = 0
}

local FLIR_TIME_CYCLES = {
    WHITE_HOT = "heliGunCam",
    BLACK_HOT = "nightvision"
}

local function EnableFLIR()
    FLIR.active = true
    SetTimecycleModifier(FLIR_TIME_CYCLES[FLIR.mode])
    SetTimecycleModifierStrength(1.0)
    SendNUIMessage({ type = "FLIR_TOGGLE", state = true, mode = FLIR.mode })
end

local function DisableFLIR()
    FLIR.active = false
    ClearTimecycleModifier()
    SendNUIMessage({ type = "FLIR_TOGGLE", state = false })
end

local function ToggleFLIR()
    if FLIR.active then DisableFLIR() else EnableFLIR() end
end

-- =========================
-- LASER DESIGNATOR
-- =========================
LASER = {
    active = false,
    hitPos = nil,
    range = nil
}

local function ToggleLaser()
    LASER.active = not LASER.active

    if not LASER.active then
        LASER.hitPos = nil
        LASER.range = nil
    end
end


local function UpdateLaser()
    if not LASER.active or not TGP.cam then return end

    local camPos = GetCamCoord(TGP.cam)
    local camRot = GetCamRot(TGP.cam, 2)
    local dir = RotationToDirection(camRot)
    local dest = camPos + dir * 10000.0

    local ray = StartShapeTestRay(
        camPos.x, camPos.y, camPos.z,
        dest.x, dest.y, dest.z,
        10,
        GetVehiclePedIsIn(PlayerPedId(), false),
        0
    )

    local _, hit, endPos = GetShapeTestResult(ray)

    -- si no impacta, proyecta igual
    LASER.hitPos = (hit == 1) and endPos or dest
    LASER.range = #(LASER.hitPos - camPos)
end


local function DrawLaserDot()
    if not LASER.active or not LASER.hitPos then return end

    DrawMarker(
        28,
        LASER.hitPos.x, LASER.hitPos.y, LASER.hitPos.z,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0.06, 0.06, 0.06,
        255, 0, 0, 200,
        false, true, 2,
        nil, nil, false
    )
end

-- =========================
-- TGP SYSTEM
-- =========================
TGP = {
    active = false,
    cam = nil,

    fov = 45.0,
    minFov = 4.0,
    maxFov = 60.0,
    zoomStep = 2.0,

    pan = 0.0,
    tilt = -15.0,
    panMin = -120.0,
    panMax = 120.0,
    tiltMin = -90.0,
    tiltMax = 25.0,

    lock = {
        active = false,
        entity = nil,
        point = nil
    },

    uiTick = 0
}

-- =========================
-- KEY MAPPING
-- =========================
RegisterKeyMapping('tgp_toggle', 'TGP - Activar / Desactivar cámara', 'keyboard', 'E')
RegisterCommand('tgp_toggle', function()
    if TGP.active then
        DestroyTGPCam()
        DisableFLIR()
    else
        CreateTGPCam()
    end
end, false)

-- =========================
-- CAMERA
-- =========================
function CreateTGPCam()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end

    TGP.cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    AttachCamToEntity(TGP.cam, veh, 0.0, 2.5, -1.2, true)
    SetCamFov(TGP.cam, TGP.fov)
    RenderScriptCams(true, false, 0, true, true)

    TGP.active = true
    SendNUIMessage({ type = "TGP_TOGGLE", state = true })
end

function DestroyTGPCam()
    if TGP.cam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(TGP.cam)
        TGP.cam = nil
    end

    TGP.active = false
    TGP.lock.active = false
    TGP.lock.entity = nil
    TGP.lock.point = nil

    LASER.active = false
    LASER.hitPos = nil
    LASER.range = nil

    DisableFLIR()
    ClearTimecycleModifier()

    SendNUIMessage({ type = "TGP_TOGGLE", state = false })
    SendNUIMessage({ type = "LOCK_UPDATE", state = false })
    SendNUIMessage({ type = "TARGET_UPDATE", clear = true })
end

-- =========================
-- INPUT BLOCK
-- =========================
local function DisableAircraftControls()
    DisableControlAction(0, 1, true)
    DisableControlAction(0, 2, true)
    DisableControlAction(0, 80, true)

    DisableControlAction(0, 81, true)
    DisableControlAction(0, 82, true)
    DisableControlAction(0, 85, true)

    DisableControlAction(0, 24, true)
    DisableControlAction(0, 25, true)
    DisableControlAction(0, 37, true)
    DisableControlAction(0, 68, true)
    DisableControlAction(0, 69, true)
    DisableControlAction(0, 99, true)
    DisableControlAction(0, 100, true)
end

-- =========================
-- CONTROLS
-- =========================
local function UpdateTGPControls()
    if IsControlPressed(0, 175) then TGP.pan = TGP.pan - 0.6 end
    if IsControlPressed(0, 174) then TGP.pan = TGP.pan + 0.6 end
    if IsControlPressed(0, 172) then TGP.tilt = TGP.tilt + 0.6 end
    if IsControlPressed(0, 173) then TGP.tilt = TGP.tilt - 0.6 end

    TGP.pan  = Clamp(TGP.pan,  TGP.panMin,  TGP.panMax)
    TGP.tilt = Clamp(TGP.tilt, TGP.tiltMin, TGP.tiltMax)

    if IsControlJustPressed(0, 241) then
        TGP.fov = Clamp(TGP.fov - TGP.zoomStep, TGP.minFov, TGP.maxFov)
    elseif IsControlJustPressed(0, 242) then
        TGP.fov = Clamp(TGP.fov + TGP.zoomStep, TGP.minFov, TGP.maxFov)
    end

    SetCamFov(TGP.cam, TGP.fov)
end

-- =========================
-- RAYCAST + LOCK
-- =========================
local function RaycastFromTGP()
    local camPos = GetCamCoord(TGP.cam)
    local camRot = GetCamRot(TGP.cam, 2)
    local dir = RotationToDirection(camRot)
    local dest = camPos + dir * 8000.0

    local ray = StartShapeTestRay(
        camPos.x, camPos.y, camPos.z,
        dest.x, dest.y, dest.z,
        10,
        GetVehiclePedIsIn(PlayerPedId(), false),
        0
    )

    local _, hit, endPos, _, ent = GetShapeTestResult(ray)
    return hit == 1, endPos, ent
end

local function ToggleTGPLock()
    if TGP.lock.active then
        TGP.lock.active = false
        TGP.lock.entity = nil
        TGP.lock.point = nil
        TGP.pan = 0.0
        TGP.tilt = -15.0

        LASER.active = false
        LASER.hitPos = nil
        LASER.range = nil        

        SendNUIMessage({ type = "LOCK_UPDATE", state = false })
        SendNUIMessage({ type = "TARGET_UPDATE", clear = true })
        return
    end

    local hit, pos, ent = RaycastFromTGP()
    if hit then
        TGP.lock.active = true
        if ent and ent ~= 0 and DoesEntityExist(ent) then
            TGP.lock.entity = ent
            TGP.lock.point = nil
        else
            TGP.lock.entity = nil
            TGP.lock.point = pos
        end
        SendNUIMessage({ type = "LOCK_UPDATE", state = true })
    end
end

local function UpdateTGPLockTracking()
    if not TGP.lock.active then return false end

    if TGP.lock.entity and DoesEntityExist(TGP.lock.entity) then
        local p = GetEntityCoords(TGP.lock.entity)
        PointCamAtCoord(TGP.cam, p.x, p.y, p.z)
        return true
    end

    if TGP.lock.point then
        PointCamAtCoord(TGP.cam, TGP.lock.point.x, TGP.lock.point.y, TGP.lock.point.z)
        return true
    end

    return false
end

-- =========================
-- TARGET INFO
-- =========================
local function GetTrackedTargetData(entity)
    if not DoesEntityExist(entity) then return nil end

    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local src = veh ~= 0 and veh or ped

    local srcPos = GetEntityCoords(src)
    local tgtPos = GetEntityCoords(entity)

    return {
        rng = #(tgtPos - srcPos),
        spd = GetEntitySpeed(entity) * 1.94384,
        alt = tgtPos.z
    }
end

-- =========================
-- MAIN LOOP
-- =========================
CreateThread(function()
    while true do
        Wait(0)

        if TGP.active and TGP.cam then
            local flight = GetBasicFlightData()

            DisableAircraftControls()
            UpdateTGPControls()

            if IsControlJustPressed(0, 29) then ToggleTGPLock() end -- B
            if IsControlJustPressed(0, 348) then ToggleFLIR() end  -- Mouse wheel
            if IsControlJustPressed(0, 182) then ToggleLaser() end -- L

            if not UpdateTGPLockTracking() then
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                SetCamRot(TGP.cam, TGP.tilt, 0.0, GetEntityHeading(veh) + TGP.pan, 2)
            end

            UpdateLaser()
            DrawLaserDot()

            if flight and GetGameTimer() - TGP.uiTick > 100 then
                TGP.uiTick = GetGameTimer()

                SendNUIMessage({
                    type = "TGP_UPDATE",
                    zoom = math.floor((TGP.maxFov / TGP.fov) * 10) / 10,
                    locked = TGP.lock.active
                })

                SendNUIMessage({
                    type = "FLIGHT_UPDATE",
                    alt = flight.altitude_msl,
                    spd = flight.speed_knots,
                    hdg = flight.heading
                })

                if TGP.lock.active and TGP.lock.entity then
                    local tgt = GetTrackedTargetData(TGP.lock.entity)
                    if tgt then
                        SendNUIMessage({
                            type = "TARGET_UPDATE",
                            rng = tgt.rng,
                            spd = tgt.spd,
                            alt = tgt.alt
                        })
                    end
                else
                    SendNUIMessage({ type = "TARGET_UPDATE", clear = true })
                end

                if LASER.active and LASER.range then
                    SendNUIMessage({ type = "LASER_RANGE", range = LASER.range })
                else
                    SendNUIMessage({ type = "LASER_RANGE", clear = true })
                end
            end
        else
            Wait(0)
        end
    end
end)
