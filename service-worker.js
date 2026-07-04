const CACHE_NAME = "nexus-pwa-reinicio-total-v1";
const APP_ASSETS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./probar-conexion.html",
  "./icons/icon-192.png",
  "./icons/icon-512.png"
];

self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(APP_ASSETS)).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)))).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", event => {
  const req = event.request;
  if (req.method !== "GET") return;

  const url = new URL(req.url);

  // No cachear llamadas a Supabase ni APIs externas.
  if (url.origin !== self.location.origin) return;

  // index/config: red primero para evitar quedarse con configuración vieja.
  if (url.pathname.endsWith("/") || url.pathname.endsWith("/index.html") || url.pathname.endsWith("/supabase-config.js")) {
    event.respondWith(
      fetch(req).then(res => {
        const copy = res.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(req, copy));
        return res;
      }).catch(() => caches.match(req).then(cached => cached || caches.match("./index.html")))
    );
    return;
  }

  // Resto de assets: caché primero.
  event.respondWith(
    caches.match(req).then(cached => cached || fetch(req).then(res => {
      const copy = res.clone();
      caches.open(CACHE_NAME).then(cache => cache.put(req, copy));
      return res;
    }))
  );
});
