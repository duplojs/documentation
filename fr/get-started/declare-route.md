---
layout: default
parent: Commencer
title: Déclarer une route
nav_order: 1
---

# Déclarer une route
{: .no_toc }

Dans cette section, nous allons voir comment déclarer des routes dans DuploJS, enregistrer ces routes, et comprendre le principe le floor.

1. TOC
{:toc}

## Créer une route simple

Dans Duplo, plusieurs objets complexes nécessitent l'utilisation d'un [builder](../../required/design-patern-builder). La fonction `useBuilder` permet d'accéder aux différents builders disponibles.
Ici, nous utiliserons `useBuilder` pour obtenir la méthode `createRoute`, qui donne accès au builder pour créer une route.

```ts
import { useBuilder, Response } from "@duplojs/core";

export const myRoute = useBuilder()
    .createRoute("GET", "/hello-world")
    .handler(() => {
        return new Response(
            200, 
            "Hello World!", 
            "This is a body."
        );
    });
```

Dans cet exemple :

- La méthode `createRoute` est utilisée pour créer un builder d’objet Route.
- La route créée est de type `GET` avec le chemin `/hello-world`.
- La méthode `handler` fait partie du builder de route et termine la création de celle-ci.
- La méthode handler doit contenir l'action de la route et renvoyer une réponse positive.

## Enregistrer les routes

Après avoir défini les routes, il faut les enregistrer pour qu'elles soient utilisables par DuploJS.

### Enregistrer une route
{: .no_toc }

La méthode la plus simple pour enregistrer une route est d'utiliser `register`.

```ts
import { Duplo } from "@duplojs/core";
import { myRoute } from "./route";

const duplo = new Duplo({
    environment: "TEST"
});

duplo.register(myRoute);
```

Ici :

- `new Duplo` initialise l'application avec un environnement de test.
- `register` ajoute la route `myRoute` pour qu'elle soit active dans l'application.

### Enregistrer toutes les routes créées
{: .no_toc }

Il est possible d'enregistrer des routes à la volée sans les spécifier en utilisant `getAllCreatedDuplose()`.

```ts
import { Duplo, useBuilder } from "@duplojs/core";
import "./route";

const duplo = new Duplo({
    environment: "TEST"
});

duplo.register(...useBuilder.getAllCreatedDuplose());
```

Dans cet exemple :

- `import "./route";` permet d'executer le fichier sans importer ses variables.
- `getAllCreatedDuplose()` récupère toutes les routes créées avec `useBuilder`.

## Le floor

Le *floor* dans DuploJS est un accumulateur typé, qui s'enrichi suivant les différentes étapes implémentées dans les routes. Chaque route possède son propre floor pendant son éxecution.

```ts
import { makeFloor } from "@duplojs/core";

const floor = makeFloor<{foo: "bar", prop: number}>();

const bar = floor.pickup("foo"); // typeof bar === "bar"

const { foo, prop } = floor.pickup(["foo", "prop"]); 
// typeof foo === "bar"
// typeof prop === number
```

Ici :

- `makeFloor` crée un floor avec des propriétés spécifiques (`foo` et `prop`).
- `pickup` permet d'accéder aux valeurs de ces propriétés.

### Exemple du floor dans une route
{: .no_toc }

<!-- Si une route utilise un floor, le handler peut accéder aux valeurs du floor en utilisant `pickup`. -->
La méthode `handler` reçoit en premier argument la méthode pickup du floor de la route.

```ts
import { Response, useBuilder, zod } from "@duplojs/core";

export const myRoute = useBuilder()
    .createRoute("GET", "/hello-world")
    //... différentes étapes de la route
    .extract({
        query:{
            foo: zod.string()
        }
    })
    .handler((pickup) => {
        // Ici, pickup est utilisé pour accéder aux propriétés du floor
        const bar = pickup("foo");

        return new Response(
            200, 
            `Hello ${bar}`, 
            "this is a body"
        );
    });
```

Dans cet exemple :

- `pickup` est passé au handler, permettant d’accéder aux propriétés du floor comme `foo`.
- Le typage de la propriété `foo` est garanti.

## Les informations

Comme vous pouvez l'observer dans les exemples donnés précédement, lorsque l'on instancie une réponse, nous précisons en second argument l'information de celle-ci.

```ts
import { useBuilder, Response } from "@duplojs/core";

export const myRoute = useBuilder()
    .createRoute("GET", "/hello-world")
    .handler(() => {
        return new Response(
            200, 
            "My super info!", 
            undefined
        );
    });
```

Dans cette exemple :

- La réponse renvoyée aura un header se nommant `information` possédant la valeur `My super info!`.

Dans l'idéal, chaque réponse envoyée possède une information différente, ce qui permet d'identifier de quelle partie du code provient la réponse. Le front pourra également se baser sur ces informations pour identifier le succès ou l'erreur d'une réponse. Par exemple, il peut vous arriver de renvoyer des erreurs 400 pour des raisons différentes. Cela vous permettera de les différencier.

## Les réponse preset

<br>

[Obtenir de la donnée d'une requête >\>\>](../getting-data-from-request){: .btn .btn-yellow}