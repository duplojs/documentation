---
nav_order: 6
layout: default
title: Génération de types
---

# Génération de types avec types-codegen
{: .no_toc }

`@duplojs/types-codegen` est une librairie permettant de générer des types TypeScript à partir des routes de votre application. Elle est particulièrement utile pour la création de clients HTTP typés. vous pouvez consulter la documentation du client HTTP typé [ici](https://docs.duplojs.dev/fr/latest/resources/http-client/) qui utilise les types générés par `@duplojs/types-codegen`. Tous les exemples présentés dans cette section sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/1.x/resources/types-codegen).

1. TOC
{:toc}

## Installation

Pour utiliser `@duplojs/types-codegen`, vous devez l'installer en tant que dépendance de développement de votre projet.

```bash
npm install --save-dev "@duplojs/types-codegen@1.x"
```

## Utilisation

Pour générer du typages à partir des routes de votre application, vous aurez besoin d'ajouter une commande dans votre fichier `package.json`.

```json
{
  ...,
  "scripts": {
    ...,
    "generate-types": "duplojs-types-codegen --import @duplojs/node/globals --include src/routes/index.ts --output duplojsTypesCodegen.d.ts"
  },
  ...
}
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Une commande `generate-types` a étais ajouter dans le fichier `package.json`.
- La commande `duplojs-types-codegen` est utilisé pour générer les types.
- L'option `--include` est utilisé pour spécifier le fichier d'entrée.
- L'option `--output` est utilisé pour spécifier le fichier de sortie des types.
></div>

{: .note }
Il est également possible d'utiliser `@duplojs/types-codegen` via `npx` sans l'installer.

## Options

`@duplojs/types-codegen` propose plusieurs options pour personnaliser la génération des types.

| Option | Alias | Description |
|--------|-------|-------------|
| `--watch` | `-w` | Permet de surveiller le  fichier contenant les routes et de regénérer les types à chaque modification |
| `--import` | - | Permet d'importer des modules nécessaires à l'exécution (comme `@duplojs/node/globals`) |
| `--require` | - | Permet d'importer des fichiers nécessaires à l'exécution, notamment ceux déclarant des variables globales |
| `--include` | `-i` | Permet de spécifier le ou les fichiers à inclure dans la génération |
| `--output` | `-o` | Permet de spécifier le fichier de sortie |
| `--exclude` | `-e` | Permet d'exclure des routes de la génération |

{: .note }
> Les options `--import`, `--require` et `--include` peuvent être utilisées de deux façons pour spécifier plusieurs fichiers :
> - En séparant les fichiers par des virgules : `--require src/config.ts,src/env.ts`
> - En répétant l'option : `--require src/config.ts --require src/env.ts`

## Exemple de sortie

`@duplojs/types-codegen` génère des types TypeScript à partir des routes de votre application. Voici un exemple de fichier de sortie :

```typescript
type CodegenRoutes = ({
    method: "GET";
    path: "/products";
    response: {
        code: 200;
        information: "products.found";
        body: {
            id: number;
            name: string;
            price: number;
            quantity: number;
        }[];
    };
}) | ({
    method: "GET";
    path: "/users/{userId}";
    params: {
        userId: number;
    };
    response: {
        code: 404;
        information: "user.notfound";
        body?: undefined;
    } | {
        code: 200;
        information: "user.found";
        body: {
            id: number;
            name: string;
            email: string;
        };
    };
});

export { CodegenRoutes };
```

## Source du typages
Le type générer trouve ça source dans vos route. Les ellement de vos routes qui enrichisse la génération sont :
- La méthode.
- Les paths.
- Les `ExtractStep`.
- Les contrat de sortie des `Step`.

```ts
// preset checker
export const IWantUserExistById = createPresetChecker(
    userExistCheck,
    {
        transformInput: userExistInput.id,
        result: "user.exist",
        catch: () => new NotFoundHttpResponse("user.notfound"),
        indexing: "user",
    },
    makeResponseContract(NotFoundHttpResponse, "user.notfound"), // Response Contract CheckerStep
);

// route
useBuilder()
    .createRoute("GET", "/users/{userId}") // méthod, path
    .extract({ // ExtractStep
        params: {
            userId: zod.coerce.number(),
        },
    })
    .presetCheck(
        IWantUserExistById,
        (pickup) => pickup("userId"),
    )
    .handler(
        (pickup) => {
            const { id, name, email } = pickup("user");

            return new OkHttpResponse("user.found", {
                id,
                name,
                email,
            });
        },
        makeResponseContract(OkHttpResponse, "user.found", userSchema), // Response Contract HandlerStep
    );

// output
type CodegenRoutes = ({
    method: "GET";
    path: "/users/{userId}";
    params: {
        userId: number;
    };
    response: {
        code: 404;
        information: "user.notfound";
        body?: undefined;
    } | {
        code: 200;
        information: "user.found";
        body: {
            id: number;
            name: string;
            email: string;
        };
    };
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Le type `CodegenRoutes` de l'exemple ci dessus a étais génére a patire de la route de ce même exemple.
- Le preset checker `IWantUserExistById` a un contrat de réponse intégré, qui est transmit a la route dans laquel il est implémenter.
- La `HandlerStep` de la route posséde un contrat de réponse.
></div>

{: .note }
Les route hérite des contrat appartenent au proccess implémenter. 

### Ignoré les contrat d'une step
{: .no_toc }
Il est possible d'indiquer au générateur qu'on ne souhaite pas prendre en compte les contrat du step. Pour cela, il suffit de passé une instance de l'objet `IgnoreByTypeCodegenDescription` dans les déscriptions d'une step.

```ts
import { useBuilder, zod, OkHttpResponse, makeResponseContract } from "@duplojs/core";
import { IgnoreByTypeCodegenDescription } from "@duplojs/types-codegen";

useBuilder()
    .createRoute("GET", "/users/{userId}")
    .extract(
        {
            headers: {
                authorization: zod.string(),
            },
        },
        undefined,
        new IgnoreByTypeCodegenDescription(),  
    )
    .extract({
        params: {
            userId: zod.coerce.number(),
        },
    })
    .presetCheck(
        IWantUserExistById,
        (pickup) => pickup("userId"),
        new IgnoreByTypeCodegenDescription(),
    )
    .handler(
        (pickup) => {
            const { id, name, email } = pickup("user");

            return new OkHttpResponse("user.found", {
                id,
                name,
                email,
            });
        },
        makeResponseContract(OkHttpResponse, "user.found", userSchema),
    );

// output
type CodegenRoutes = ({
    method: "GET";
    path: "/users/{userId}";
    params: {
        userId: number;
    };
    response: {
        code: 200;
        information: "user.found";
        body: {
            id: number;
            name: string;
            email: string;
        };
    };
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- L'`ExtractStep` sera ignorer et le type générer ne contiendra pas de header `authorization`.
- La `CheckerStep` sera ignorer et le type générer ne contiendra pas de réponse associer a son contrat.
></div>

### Ignoré les contrat d'une route
{: .no_toc }
Il est aussi possible d'indiquer au générateur qu'on souhaite ignoré une route. Pour cela, il suffit de passé une instance de l'objet `IgnoreByTypeCodegenDescription` dans les déscriptions d'une route.

```ts
import { useBuilder, zod, OkHttpResponse, makeResponseContract } from "@duplojs/core";
import { IgnoreByTypeCodegenDescription } from "@duplojs/types-codegen";

useBuilder(new IgnoreByTypeCodegenDescription())
    .createRoute("GET", "/users/{userId}", new IgnoreByTypeCodegenDescription()) // same thing
    .extract({
        params: {
            userId: zod.coerce.number(),
        },
    })
    .presetCheck(
        IWantUserExistById,
        (pickup) => pickup("userId"),
    )
    .handler(
        (pickup) => {
            const { id, name, email } = pickup("user");

            return new OkHttpResponse("user.found", {
                id,
                name,
                email,
            });
        },
        makeResponseContract(OkHttpResponse, "user.found", userSchema),
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La description `IgnoreByTypeCodegenDescription` peut étre placer sois en argument du `useBuilder` sois en argument de la méthode `createRoute`.
- Aucun type ne sera générer a partir de cette route.
></div>

{: .note }
Touts les exemple d'ignore de contrat sur les routes s'applique égalment au process.

## Utilsation sans la commande

Il est également possible d'utiliser `@duplojs/types-codegen` sans la commande en important directement la fonction `generateTypeFromRoutes`.

```typescript
import { useRouteBuilder } from "@duplojs/core";
import { generateTypeFromRoutes } from "@duplojs/types-codegen";

import "./path-to-ma-routes";

const routes = [...useRouteBuilder.getAllCreatedRoute()];
const generatedTypes = generateTypeFromRoutes(routes);

console.log(generatedTypes);
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Les routes sont récupérées à l'aide de `useRouteBuilder.getAllCreatedRoute()`.
- Les routes sont importées à l'aide de `./path-to-ma-routes`.
- Les types sont générés à l'aide de `generateTypeFromRoutes`.
- Les types générés sont affichés dans la console.
></div>
