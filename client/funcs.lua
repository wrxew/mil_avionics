-- =========================================
-- MIL AVIONICS | BASIC FLIGHT SENSORS
-- Altitude / Speed / Heading
-- =========================================

local function IsAircraft(vehicle)
    local class = GetVehicleClass(vehicle)
    return class == 15 or class == 16 -- Helicopter / Plane
end

-- Conversión m/s a knots
local function MsToKnots(ms)
    return ms * 1.94384
end

-- Core sensor function
function GetBasicFlightData()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh == 0 or not IsAircraft(veh) then
        return nil
    end

    -- Posición
    local coords = GetEntityCoords(veh)
    local groundZ = 0.0
    local hasGround, groundZ = GetGroundZFor_3dCoord(
        coords.x, coords.y, coords.z, false
    )

    -- Altitudes
    local altitudeMSL = coords.z
    local altitudeAGL = hasGround and (coords.z - groundZ) or 0.0

    -- Velocidad
    local speedMS = GetEntitySpeed(veh)
    local speedKnots = MsToKnots(speedMS)

    -- Heading
    local heading = GetEntityHeading(veh)

    -- Actitud
    local pitch = GetEntityPitch(veh)
    local roll  = GetEntityRoll(veh)

    return {
        vehicle      = veh,
        altitude_msl = math.max(altitudeMSL, 0.0),
        altitude_agl = math.max(altitudeAGL, 0.0),
        speed_ms     = speedMS,
        speed_knots  = speedKnots,
        heading      = heading,
        pitch        = pitch,
        roll         = roll
    }
end

-- =========================================
-- MIL AVIONICS | VISUAL AIRCRAFT DETECTION
-- Field of View based detection
-- =========================================

local function IsAircraft(vehicle)
    local class = GetVehicleClass(vehicle)
    return class == 15 or class == 16 -- Helicopter / Plane
end

local function Normalize(vec)
    local mag = #(vector3(vec.x, vec.y, vec.z))
    if mag == 0 then return vector3(0, 0, 0) end
    return vector3(vec.x / mag, vec.y / mag, vec.z / mag)
end

local function Dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z
end

-- Main detection function
-- fovDeg: total field of view (ej. 90)
-- maxDistance: meters
function DetectAircraftInFOV(fovDeg, maxDistance)
    local ped = PlayerPedId()
    local camRot = GetGameplayCamRot(2)
    local camPos = GetGameplayCamCoord()

    local fovRad = math.rad(fovDeg)
    local cosThreshold = math.cos(fovRad / 2)

    -- Vector forward de la cámara
    local camForward = Normalize(
        RotationToDirection(camRot)
    )

    local detected = {}

    local vehicles = GetGamePool("CVehicle")
    for _, veh in ipairs(vehicles) do
        if IsAircraft(veh) and veh ~= GetVehiclePedIsIn(ped, false) then
            local vehPos = GetEntityCoords(veh)
            local toTarget = vector3(
                vehPos.x - camPos.x,
                vehPos.y - camPos.y,
                vehPos.z - camPos.z
            )

            local distance = #(toTarget)
            if distance <= maxDistance then
                local dirToTarget = Normalize(toTarget)
                local dot = Dot(camForward, dirToTarget)

                -- Dentro del FOV
                if dot >= cosThreshold then
                    -- Línea de visión (opcional pero realista)
                    if HasEntityClearLosToEntity(ped, veh, 17) then
                        table.insert(detected, {
                            vehicle  = veh,
                            coords   = vehPos,
                            distance = distance,
                            dot      = dot
                        })
                    end
                end
            end
        end
    end

    return detected
end

-- =========================================
-- MIL AVIONICS | UTILS
-- =========================================

function RotationToDirection(rot)
    local rotZ = math.rad(rot.z)
    local rotX = math.rad(rot.x)
    local cosX = math.abs(math.cos(rotX))

    return vector3(
        -math.sin(rotZ) * cosX,
         math.cos(rotZ) * cosX,
         math.sin(rotX)
    )
end

function Clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

