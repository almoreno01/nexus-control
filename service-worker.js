const CACHE_NAME = "nexus-pwa-push-rpc-secure-v15-2";
const APP_ASSETS = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./assets/full-logo.png",
  "./assets/simple-logo.png",
  "./probar-conexion.html",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/apple-touch-icon-simple.png"
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


self.addEventListener("notificationclick", event => {
  event.notification.close();
  const target = event.notification?.data?.url || "./";
  event.waitUntil(
    self.clients.matchAll({type:"window", includeUncontrolled:true}).then(clients => {
      for(const client of clients){
        if("focus" in client){
          client.postMessage({type:"NEXUS_NOTIFICATION_OPEN"});
          return client.focus();
        }
      }
      return self.clients.openWindow ? self.clients.openWindow(target) : undefined;
    })
  );
});


self.addEventListener("push", event => {
  let payload = {};
  try{
    payload = event.data ? event.data.json() : {};
  }catch(e){
    payload = {
      title:"NEXUS",
      body:event.data ? event.data.text() : "Nueva alerta"
    };
  }

  const title = payload.title || "NEXUS · Alerta de nivel";
  const options = {
    body: payload.body || "Una tabla alcanzó el nivel configurado.",
    tag: payload.tag || payload.notificationId || "nexus-alert",
    icon: payload.icon || "./icons/icon-192.png",
    badge: payload.badge || "./icons/icon-192.png",
    data: {
      url: payload.url || "./",
      notificationId: payload.notificationId || ""
    }
  };

  event.waitUntil((async () => {
    await self.registration.showNotification(title, options);

    try{
      const count = Number(payload.badgeCount || 0);
      if(self.navigator && typeof self.navigator.setAppBadge === "function"){
        if(count > 0) await self.navigator.setAppBadge(count);
        else if(typeof self.navigator.clearAppBadge === "function"){
          await self.navigator.clearAppBadge();
        }
      }
    }catch(e){}

    const clients = await self.clients.matchAll({
      type:"window",
      includeUncontrolled:true
    });

    clients.forEach(client => {
      client.postMessage({
        type:"NEXUS_PUSH_RECEIVED",
        payload
      });
    });
  })());
});
