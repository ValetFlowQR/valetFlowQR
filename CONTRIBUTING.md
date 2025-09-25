# 📖 Guía de Contribución

Este documento explica cómo trabajaremos en equipo para mantener el proyecto **organizado, limpio y bien administrado** usando GitHub Projects, Issues y ramas.

---

## 🚀 Flujo de trabajo general

### 1️⃣ Planificación
- Cada historia de usuario y criterio de aceptación estará en **GitHub Projects** como un **Issue**.  
- Cada Issue tendrá:
  - Un responsable asignado
  - Etiquetas (`frontend`, `backend`, `alta prioridad`, etc.)

### 2️⃣ Trabajo en ramas
- **Nunca trabajamos directamente en `main`.**  
- Cada nueva funcionalidad o corrección se desarrolla en una rama `feature/*` creada a partir de `develop`.

### 3️⃣ Pull Requests (PR)
- Al terminar una tarea, se crea un **PR** desde la rama `feature/*` hacia `develop`.  
- Otro miembro del equipo debe revisar y aprobar antes de hacer merge.

### 4️⃣ Integración a main
- Solo cuando la funcionalidad esté probada y estable, `develop` se fusionará en `main`.  
- Esto ocurre normalmente al final de un **Sprint** o entrega.

---

## 🌳 Estructura de ramas

- `main` → versión estable, lista para producción.  
- `develop` → integración de todas las funcionalidades en desarrollo.  
- `feature/nombre-funcionalidad` → ramas temporales para cada Issue.  

**Ejemplos de ramas feature:**  
feature/registro-vehiculo
feature/pago-digital
feature/reporte-problemas
feature/contributing


---

## 🛠️ Comandos básicos de Git

### Clonar el proyecto

git clone https://github.com/ORGANIZACION/REPO.git
cd REPO

---

## Crear y subir una nueva rama

### Siempre partiendo de develop:
git checkout develop
git pull origin develop
git checkout -b feature/nombre-funcionalidad
git push -u origin feature/nombre-funcionalidad

## Subir cambios
git add .
git commit -m "Descripción clara del cambio"
git push origin feature/nombre-funcionalidad

## Actualizar tu rama con lo más reciente de develop
git checkout develop
git pull origin develop
git checkout feature/nombre-funcionalidad
git merge develop

## 🔄 Pull Requests

    1. Abrir un PR desde tu rama feature/* hacia develop.
    2. Enlazar el Issue con palabras clave (ej. Closes #12).
    3. Otro miembro revisa y aprueba antes de hacer merge.



## ✅ Reglas del equipo

    *Hacer commits pequeños y frecuentes.
    *Escribir mensajes de commit claros (ej. "feat(registro): formulario de registro de *vehículo").
    *Revisar y aprobar PRs de compañeros.
    *Mantener el código limpio y documentado.
    *Antes de empezar una tarea → asegurarse de tener lo último de develop.