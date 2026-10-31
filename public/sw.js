var CACHE_NAME = 'amira-shell-v1';
var APP_SHELL = [
  '/',
  '/index.html',
  '/manifest.json',
  '/logo_icon.png',
  '/icon-192.png',
  '/icon-512.png'
];

self.addEventListener('install', function (event) {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CACHE_NAME).then(function (cache) {
      return cache.addAll(APP_SHELL);
    })
  );
});

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(
        keys.filter(function (k) { return k !== CACHE_NAME; })
          .map(function (k) { return caches.delete(k); })
      );
    }).then(function () { return self.clients.claim(); })
  );
});

// Doar cereri GET, doar acelasi domeniu - orice request catre chat (n8n, alt domeniu,
// POST-uri) trece direct la retea, neatins, ca sa nu afecteze functionarea chat-ului.
self.addEventListener('fetch', function (event) {
  var req = event.request;
  if (req.method !== 'GET') return;

  var url = new URL(req.url);
  if (url.origin !== self.location.origin) return;

  event.respondWith(
    fetch(req).then(function (res) {
      var resClone = res.clone();
      caches.open(CACHE_NAME).then(function (cache) { cache.put(req, resClone); });
      return res;
    }).catch(function () {
      return caches.match(req).then(function (cached) {
        return cached || caches.match('/index.html');
      });
    })
  );
});
