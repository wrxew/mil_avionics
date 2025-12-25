// =======================================
// MIL AVIONICS | TGP / FLIR UI CONTROLLER
// =======================================

const mfd = document.getElementById('mfd');

// ===============================
// FLIGHT DATA
// ===============================
const altEl = document.getElementById('alt');
const spdEl = document.getElementById('spd');
const hdgEl = document.getElementById('hdg');

// ===============================
// TARGET DATA (LOCK VEHÍCULO)
// ===============================
const tgtRng = document.getElementById('tgtRng');
const tgtSpd = document.getElementById('tgtSpd');
const tgtAlt = document.getElementById('tgtAlt');

// ===============================
// ESTADOS
// ===============================
const lockEl = document.getElementById('lock');
const flirModeEl = document.getElementById('flirMode');
const zoomEl = document.getElementById('zoom');

// ===============================
// COMPASS
// ===============================
const compassTape = document.getElementById('compassTape');

// ===============================
// LASER
// ===============================
const laserDot = document.getElementById('laserDot');
const laserRange = document.getElementById('laserRange');


// ===============================
// INIT
// ===============================
clearTargetData();
initCompass();

// ===============================
// EVENT LISTENER
// ===============================
window.addEventListener('message', (event) => {
    const d = event.data;

    switch (d.type) {

        // =========================
        // TGP ON / OFF
        // =========================
        case 'TGP_TOGGLE':
            if (mfd) mfd.classList.toggle('hidden', !d.state);
            if (!d.state) clearTargetData();
            break;

        // =========================
        // FLIGHT DATA + COMPASS
        // =========================
        case 'FLIGHT_UPDATE':
            if (altEl) altEl.textContent = `ALT ${Math.round(d.alt)}`;
            if (spdEl) spdEl.textContent = `SPD ${Math.round(d.spd)}`;
            if (hdgEl) hdgEl.textContent = `HDG ${Math.round(d.hdg)}`;

            updateCompass(d.hdg);
            break;

        // =========================
        // TGP GENERAL
        // =========================
        case 'TGP_UPDATE':
            if (zoomEl && d.zoom !== undefined)
                zoomEl.textContent = `${d.zoom.toFixed(1)}X`;

            if (lockEl)
                lockEl.textContent = d.locked ? 'LOCK' : 'NO LOCK';

            if (!d.locked) clearTargetData();
            break;

        // =========================
        // FLIR STATE
        // =========================
        case 'FLIR_TOGGLE':
            if (flirModeEl)
                flirModeEl.textContent = d.state ? d.mode : 'TV';
            break;

        // =========================
        // TARGET DATA (SOLO LOCK VEHÍCULO)
        // =========================
        case 'TARGET_UPDATE':

            if (d.clear) {
                clearTargetData();
                return;
            }

            if (
                d.rng === undefined ||
                d.spd === undefined ||
                d.alt === undefined
            ) {
                clearTargetData();
                return;
            }

            if (tgtRng) tgtRng.textContent = `RNG ${Math.round(d.rng)}m`;
            if (tgtSpd) tgtSpd.textContent = `SPD ${Math.round(d.spd)}kt`;
            if (tgtAlt) tgtAlt.textContent = `ALT ${Math.round(d.alt)}ft`;
            break;
    }
});

// ===============================
// COMPASS FUNCTIONS
// ===============================
function initCompass() {
    if (!compassTape) return;

    compassTape.innerHTML = '';

    for (let i = 0; i < 360; i += 5) {
        const tick = document.createElement('div');
        tick.className = 'tick' + (i % 10 !== 0 ? ' small' : '');

        if (i === 0) tick.textContent = 'N';
        else if (i === 90) tick.textContent = 'E';
        else if (i === 180) tick.textContent = 'S';
        else if (i === 270) tick.textContent = 'W';
        else tick.textContent = i.toString().padStart(3, '0');

        compassTape.appendChild(tick);
    }

    // duplicar para scroll infinito
    compassTape.innerHTML += compassTape.innerHTML;
}

function updateCompass(hdg) {
    if (!compassTape || hdg === undefined) return;

    const pxPerDeg = 26 / 5; // coherente con CSS
    const offset = (hdg % 360) * pxPerDeg;

    compassTape.style.transform = `translate(${-offset}px, -50%)`;
}

// ===============================
// HELPERS
// ===============================
function clearTargetData() {
    if (tgtRng) tgtRng.textContent = 'RNG ---';
    if (tgtSpd) tgtSpd.textContent = 'SPD ---';
    if (tgtAlt) tgtAlt.textContent = 'ALT ---';
}

function clearLaser() {
    if (laserDot) laserDot.style.display = 'none';
    if (laserRange) laserRange.textContent = 'RNG ---';
}

window.addEventListener('message', (event) => {
    const d = event.data;

    switch (d.type) {

        // =========================
        // LASER RANGEFINDER
        // =========================
        case 'LASER_RANGE':

            if (d.clear) {
                clearLaser();
                return;
            }

            // Mostrar punto láser en UI
            if (laserDot) {
                laserDot.style.display = 'block';
            }

            // Mostrar distancia
            if (laserRange && d.range !== undefined) {
                laserRange.textContent = `RNG ${Math.round(d.range)}m`;
            }
            break;

        // =========================
        // AL APAGAR TGP
        // =========================
        case 'TGP_TOGGLE':
            if (!d.state) {
                clearLaser();
            }
            break;

        // =========================
        // AL PERDER LOCK
        // =========================
        case 'LOCK_UPDATE':
            if (!d.state) {
                clearLaser();
            }
            break;
    }
});