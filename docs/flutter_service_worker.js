'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "c5eda70fbe5dba903a369ad530323fed",
"/": "c5eda70fbe5dba903a369ad530323fed",
"main.dart.js": "f1617a7cef3c3c4ee77ec7f517846b0e",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "de2e1d9a88f1dc96ac598119090e9ea5",
"assets/LICENSE": "52f2d64c15da677cc88ae6a0acc3fa63",
"assets/AssetManifest.json": "acdf7c2462f9a9d4a6c6387382580be4",
"assets/FontManifest.json": "f7161631e25fbd47f3180eae84053a51",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/assets/images/ball-black.png": "5a854f4f2ceaa2b81abe556f12c427dd",
"assets/assets/images/ball-red.png": "c3a279d2f119490d60579d53cab18e07",
"assets/assets/images/ball-white.png": "d47cb2eee79de20e1ceef82bfc081712",
"assets/assets/images/ball-blue.png": "3d7a7a8dc7d99555517cbe98ac32d661",
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
