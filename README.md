# 🛫 MIL AVIONICS

### Versión **0.1** – *Prototype Build*

MIL AVIONICS es un sistema experimental de aviónica avanzada para **FiveM**, enfocado en sensores, designación de blancos y armamento guiado, inspirado en sistemas reales de combate aéreo.

Esta versión corresponde a una **base funcional inicial**.

---

## ⚙️ SISTEMAS IMPLEMENTADOS (v0.1)

### 🎥 TGP (Targeting Pod)

* Cámara independiente del avión
* Pan / Tilt manual
* Zoom progresivo
* Seguimiento de punto o entidad
* Control estable al liberar lock

### 🔥 FLIR

* Modos térmicos (BLACK / WHITE HOT)
* Integrado con el TGP

### 🎯 LOCK

* Bloqueo de entidad o punto
* Seguimiento estable
* Información del objetivo:

  * Distancia
  * Velocidad
  * Altura

### 🔴 Designador Láser (LTD/R) — **EN DESARROLLO**

* Punto láser visible
* Funciona como **rangefinder**
* Puede activarse con o sin lock
* **Estado actual:**

  * Funcional a nivel lógico
  * No finalizado
  * Puede cambiar su comportamiento en futuras versiones

### 💣 Bomba Guiada por Láser (Prototype)

* Activación con tecla **H**
* Disponible solo en:

  * `raiju`
* Lógica basada en:

  * Altura del avión
  * Punto designado por láser
* Simulación por tiempo de caída + explosión
* **No incluye física real aún**

---

## 📂 ARCHIVOS CLAVE

* `client/*.lua` → TGP, FLIR, Láser
* `weapons.lua` → Lógica de bombas guiadas
* `config.lua` → Aviones permitidos y parámetros
* `html/` → Interfaz MFD / TGP

---

## ⚠️ NOTAS IMPORTANTES

* Este recurso se encuentra en **fase temprana (0.1)**
* El **láser NO está terminado**:

  * Puede presentar cambios
  * No es definitivo para armamento avanzado aún
* El sistema de armas es **experimental**
* No recomendado para servidores en producción sin pruebas

---

## 🧪 OBJETIVO DE ESTA VERSIÓN

Establecer una **base sólida** para:

* Aviónica avanzada
* Sensores realistas
* Integración futura con armamento guiado

---

## 🚀 ROADMAP (ALTA PRIORIDAD)

* Estado **LTD/R ARM – SAFE**
* Mejoras al láser
* Física real de bombas
* Tiempo a impacto
* Integración con más aeronaves

---

**MIL AVIONICS v0.1**

> Prototype first. Realism later.
