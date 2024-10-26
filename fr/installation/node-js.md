---
parent: Installation
layout: default
title: NodeJS
nav_order: 1
---

## Prérequit minimal pour installer et utiliser Duplo
- [NodeJS v20 ou +](https://nodejs.org/fr/blog/release/v20.0.0)
- [Typescript v5.5 ou +](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-5.html)
- [tsx v4 ou +](https://www.npmjs.com/package/tsx)

# Installation manuel
Pour utilisais `Duplo` sur `NodeJS`, il vous faut installer le [@duplojs/core](https://github.com/duplojs/core) et la librairy de portage [@duplojs/node](https://github.com/duplojs/node).
```bash
npm install @duplojs/core @duplojs/node
```

## Configuration package.json
Définisé le paramétre `type` sur la valeur `module` dans le `package.json`.

```js
{
    "name": "...",
    "version": "...",
    ...,
++  "type": "module",
    "scripts": {
        /* permet de lancer le fichier src/main.ts avec la command npm run dev */
++      "dev": "tsx src/main.ts", 
        ...
    },
    ...
}
```

## Configuration tsconfig.json
Les paramétres suivant sont fortement conseillés a inclure dans votre fichier `tsconfig.json` pour une compatibilité optimale avec le plus de package.

```js
{
    "compilerOptions": {
        "target": "ESNext",
        "lib": ["ESNext"], 
        "moduleDetection": "force",
        "module": "ESNext",
        "moduleResolution": "Bundler",           
        "types": ["node"],
        "noEmit": true,
        "esModuleInterop": true,
        "strict": true,
        ...
    },
    /* ce paramétre dépant de votre configuration */
    "include": ["src/**/*.ts"], 
    ...
}
```

## Premier fichier
Créer le fichier `src/main.ts` avec le contenue suivant dedans.

```ts
import "@duplojs/node";
import { Duplo, useBuilder } from "@duplojs/core";

const duplo = new Duplo({
    environment: "TEST",
    host: "localhost",
    port: 1506,
});

// method qui lance le serveur web
const server = await duplo.launch();
```

## Lancer le serveur
```bash
npx tsx src/main.ts
# ou
npm run dev
```


[Retour au Références](../..)