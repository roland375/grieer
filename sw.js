const CACHE='grieer-v54';
self.addEventListener('install',e=>e.waitUntil(
  caches.open(CACHE)
    .then(c=>c.addAll(['./', './index.html', './manifest.json', './sw.js']))
    .then(()=>self.skipWaiting())
));
self.addEventListener('activate',e=>e.waitUntil(
  caches.keys()
    .then(ks=>Promise.all(ks.filter(k=>k!==CACHE).map(k=>caches.delete(k))))
    .then(()=>self.clients.claim())
));
self.addEventListener('fetch',e=>{
  if(e.request.url.includes('api.anthropic.com')||
     e.request.url.includes('ki-proxy')){
    e.respondWith(
      fetch(e.request).catch(()=>new Response(
        '{"error":{"message":"offline"}}',
        {status:503,headers:{'Content-Type':'application/json'}}
      ))
    );
    return;
  }
  e.respondWith(
    caches.match(e.request).then(cached=>{
      if(cached) return cached;
      return fetch(e.request).then(r=>{
        if(r&&r.status===200){
          const c=r.clone();
          caches.open(CACHE).then(ch=>ch.put(e.request,c));
        }
        return r;
      }).catch(()=>caches.match('./index.html'));
    })
  );
});
