// === GRIEER SW - NIE CACHEN ===
self.addEventListener('install', function(e){ self.skipWaiting(); });
self.addEventListener('activate', function(e){
  e.waitUntil(
    caches.keys().then(function(names){
      return Promise.all(names.map(function(n){ return caches.delete(n); }));
    }).then(function(){ return self.clients.claim(); })
  );
});
self.addEventListener('fetch', function(e){
  // IMMER frisch laden, NIE aus Cache
  e.respondWith(
    fetch(e.request, {cache: 'no-store'}).catch(function(){
      return new Response('Offline', {status: 503});
    })
  );
});