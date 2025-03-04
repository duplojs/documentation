---
nav_order: 6
layout: default
title: Génération de types
---

# Génération de types - types-codegen

`@duplojs/types-codegen` est une librairie permettant de générer des types TypeScript à partir des routes de votre application. Elle est particulièrement utile pour la création de clients HTTP typés et la génération de documentation Swagger.
vous pouvez consulter la documentation du client HTTP typé [ici](https://docs.duplojs.dev/fr/latest/resources/http-client/) qui utilise les types générés par `@duplojs/types-codegen`.

## Installation

Pour utiliser `@duplojs/types-codegen`, vous devez l'installer en tant que dépendance de développement de votre projet.

```bash
npm install -d @duplojs/types-codegen
```

## Utilisation

Pour générer du typages à partir des routes de votre application, vous aurez besoin d'ajouter une commande dans votre fichier `package.json`.

```json
{
  ...
  "scripts": {
    "generate-types": "duplojs-types-codegen --input src/routes/index.ts --output src/types/duplojsTypesCodegen.d.ts"
  }
  ...
}
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Une commande `generate-types` a étais ajouter dans le fichier `package.json`.
- La commande `duplojs-types-codegen` est utilisé pour générer les types.
- L'option `--input` est utilisé pour spécifier le fichier d'entrée.
- L'option `--output` est utilisé pour spécifier le fichier de sortie des types.
></div>

{: .note }
il est également possible d'utiliser `type-codegen` via `npx` sans l'installer.

## Options

`@duplojs/types-codegen` propose plusieurs options pour personnaliser la génération des types.

| Option | Alias | Description |
|--------|-------|-------------|
| `--watch` | - | Permet de surveiller le  fichier contenant les routes et de regénérer les types à chaque modification |
| `--import` | - | Permet d'importer des modules |
| `--require` | - | Permet d'importer des fichiers qui sont requis par les routes |
| `--include` | `-i` | Permet de spécifier le ou les fichiers à inclure dans la génération |
| `--output` | `-o` | Permet de spécifier le fichier de sortie |

{: .note }
> Les options `--import`, `--require` et `--include` peuvent être utilisées de deux façons pour spécifier plusieurs fichiers :
> - En séparant les fichiers par des virgules : `--require src/config.ts,src/env.ts`
> - En répétant l'option : `--require src/config.ts --require src/env.ts`

## Exemples de préconfiguration

Exemple basic :

```json
{
  ...
  "scripts": {
    "generate-types": "duplojs-types-codegen --import @duplojs/node/globals --input src/routes/index.ts --output src/types/duplojsTypesCodegen.d.ts",
    "generate:types:watch": "duplojs-types-codegen --watch --import @duplojs/node/globals --input src/routes/index.ts --output src/types/duplojsTypesCodegen.d.ts",
  }
  ...
}
```

Exemple avec utilisation de `--require` :

```json
{
  ...
  "scripts": {
    "generate-types": "duplojs-types-codegen --import @duplojs/node/globals --require src/env.ts --input src/routes/index.ts --output src/types/duplojsTypesCodegen.d.ts",
    "generate:types:watch": "duplojs-types-codegen --watch --import @duplojs/node/globals --require src/env.ts --input src/routes/index.ts --output src/types/duplojsTypesCodegen.d.ts",
  }
  ...
}
```
