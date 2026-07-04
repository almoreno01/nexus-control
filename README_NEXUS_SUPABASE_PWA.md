# NEXUS Versión 1 - Supabase + GitHub Pages + PWA

Cambio radical aplicado:
- Backend anterior eliminado.
- Sincronización usando Supabase REST.
- App preparada como PWA: manifest, service-worker e iconos.
- Paquete listo para publicar en GitHub Pages.
- Se mantiene la interfaz y la lógica principal de NEXUS Versión 1.

## Archivos principales

- `index.html`: aplicación completa.
- `supabase-config.js`: aquí debes pegar la URL y la anon public key de Supabase.
- `schema_supabase.sql`: crea las tablas y políticas necesarias en Supabase.
- `manifest.webmanifest`: instalación PWA.
- `service-worker.js`: caché básico para abrir la app como PWA.
- `icons/`: iconos para instalación.

## Pasos para Supabase

1. Crea un proyecto en Supabase.
2. Abre `SQL Editor`.
3. Ejecuta completo el archivo `schema_supabase.sql`.
4. Ve a `Project Settings > API`.
5. Copia:
   - Project URL
   - anon public key
6. Pega esos valores en `supabase-config.js`.

## Pasos para GitHub Pages

1. Crea un repositorio en GitHub.
2. Sube todos estos archivos a la raíz del repositorio.
3. En GitHub, entra a `Settings > Pages`.
4. Selecciona:
   - Source: Deploy from a branch
   - Branch: main
   - Folder: /root
5. Guarda y abre la URL publicada.

## Instalación PWA

En Android/Chrome:
- Abre la URL de GitHub Pages.
- Menú de Chrome.
- Instalar aplicación o Añadir a pantalla principal.

En iPhone/Safari:
- Abre la URL.
- Compartir.
- Añadir a pantalla de inicio.

## Seguridad

El SQL incluido deja lectura/escritura abierta para que funcione sin Supabase Auth.
Esto es similar a las reglas abiertas usadas antes en backend anterior.
Para uso real con más personas, conviene cerrar las políticas con autenticación.


## Corrección savefix

Esta versión corrige el guardado en Supabase:
- Usuarios creados/editados/borrados se suben a `nexus_meta`.
- Tablas creadas al crear usuarios se sincronizan también como registros.
- Registros añadidos/editados/borrados fuerzan escritura en `nexus_records`.
- Compatible con `anonKey` y con claves nuevas `sb_publishable_...`.
- En Ajustes muestra estado básico de Supabase.

Después de subir esta versión a GitHub, conserva tus datos reales en `supabase-config.js`.
