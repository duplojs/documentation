---
parent: Installation
layout: default
title: NodeJS
nav_order: 1
---

## Prérequis minimums pour installer et utiliser Duplo
- [NodeJS v20 ou +](https://nodejs.org/fr/blog/release/v20.0.0)
- [Typescript v5.5 ou +](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-5.html)
- [tsx v4 ou +](https://www.npmjs.com/package/tsx)

# Installation manuelle
Si vous partez d'un projet vierge, commencez par l'initialiser.
```bash
npm init -y
```

Ensuite pour utiliser `Duplo` sur `NodeJS`, vous devez installer le package [@duplojs/core](https://github.com/duplojs/core) et la librairie de portage [@duplojs/node](https://github.com/duplojs/node).
```bash
npm install "@duplojs/core@1.x" "@duplojs/node@1.x"
```

Installer également les packages [typescript](https://www.npmjs.com/package/typescript) et [tsx](https://www.npmjs.com/package/tsx) en dépendances de développement.
```bash
npm install --save-dev "typescript@>5.5" tsx
```

## Configuration package.json
Définissez le paramètre `type` sur la valeur `module` dans le `package.json`.

{% highlight js mark_lines="5 8" %}
{
    "name": "...",
    "version": "...",
    ...,
    "type": "module",
    "scripts": {
        /* permet de lancer le fichier src/main.ts avec la command npm run dev */
        "dev": "tsx --watch src/main.ts", 
        ...
    },
    ...
}
{% endhighlight %}

## Configuration tsconfig.json
Les paramètres suivants sont fortement conseillés à inclure dans votre fichier `tsconfig.json` pour une compatibilité optimale avec la plupart des packages.

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
        "skipLibCheck": true,
        ...
    },
    /* ce paramètre dépend de votre configuration */
    "include": ["src/**/*.ts"], 
    ...
}
```

## Premier fichier
Créez le fichier `src/main.ts` avec le contenu suivant.

```ts
import "@duplojs/node";
import { Duplo } from "@duplojs/core";

const duplo = new Duplo({
    environment: "DEV",
    host: "localhost",
    port: 1506,
});

// methode qui lance le serveur web
const server = await duplo.launch();
```

## Lancer le serveur
```bash
npx tsx src/main.ts
# ou
npm run dev
```


[Retour au sommaire](../..)