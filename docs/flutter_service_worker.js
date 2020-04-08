'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "c5eda70fbe5dba903a369ad530323fed",
"main.dart.js": "bf70abc5fd0142d97de8ee567b470fbe",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "651e2ebaf425d06418a736988e436ca1",
"assets/LICENSE": "21eba787d0ae0012ae813b6a1964ccbf",
"assets/AssetManifest.json": "799967dd040832b2cd1b516b2d890818",
"assets/FontManifest.json": "f7161631e25fbd47f3180eae84053a51",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/assets/images/icons8-neutral-transparent.png": "12c654f41b94152d308db2d91dacdc26",
"assets/assets/images/ball-black.png": "5a854f4f2ceaa2b81abe556f12c427dd",
"assets/assets/images/black-ball-smaller.png": "4eee2ee0aad6bdfaf8242c5640b3e4dc",
"assets/assets/images/ball-red.png": "c3a279d2f119490d60579d53cab18e07",
"assets/assets/images/ball-white.png": "d47cb2eee79de20e1ceef82bfc081712",
"assets/assets/images/ball-blue.png": "3d7a7a8dc7d99555517cbe98ac32d661",
"assets/assets/images/icons8-neutral-yellow.png": "3bf30fb3d5bcef0d4ba79cb76e5d71c9",
"assets/assets/audio/click.wav": "614fec9801d664ed68dc0feba0d0cb41",
"assets/assets/audio/billiard-tick.wav": "0aada737a76ba282fb3392f6d613ce68"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
