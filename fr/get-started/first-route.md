---
layout: default
parent: Commencer
title: Ma première route
nav_order: 1
---

# Ma première route
{: .no_toc }

Dans cette section, nous allons voir la base de la création et du fonctionnement des routes.
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/first-route).

1. TOC
{:toc}

## Créer une route simple

Dans Duplo, plusieurs objets complexes nécessitent l'utilisation d'un [builder](../../required/design-patern-builder). La fonction `useBuilder` permet d'accéder aux différents builders disponibles.
Ici, nous utiliserons `useBuilder` pour obtenir la méthode `createRoute`, qui donne accès au builder pour créer une route.

```ts
import { useBuilder, OkHttpResponse } from "@duplojs/core";

export const myRoute = useBuilder()
    .createRoute("GET", "/hello-world")
    .handler(() => {
        return new OkHttpResponse(
            "Hello World!", 
            "This is a body."
        );
    });
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La méthode `createRoute` est utilisée pour créer un builder d’objet Route.
- La route créée est de type `GET` avec le chemin `/hello-world`.
- La méthode `handler` fait partie du builder de route et termine la création de celle-ci.
- La méthode handler doit contenir l'action de la route et renvoyer une réponse positive.
></div>

{: .note }
La méthode `handler` fait partir du builder de l'objet `Route`. Elle a pour effet direct d'ajouter une `HandlerStep` aux étapes de la route en cours de création. Les routes ne peuvent avoir qu'une seule `HandlerStep` qui doit obligatoirement être la dernière `Step`. C'est pourquoi l'appel de cette méthode clôture la création de l'objet route et le renvoie.

### Cycle d'exécution
{: .no_toc }
Une route est constituée de `Step` implémentées à travers un builder. L'ordre d'implémentation est important car l'exécution d'une route est séquentielle, du haut vers le bas. Chaque `Step` a la possibilité d'interrompre l'exécution et de renvoyer une réponse.

```ts
import { useBuilder, OkHttpResponse } from "@duplojs/core";

useBuilder()
    .createRoute("GET", "/hello-world")
    .extract(/* ... */)
    .check(/* ... */)
    .exec(/* ... */)
    .handler(() => {
        return new OkHttpResponse(
            "Hello World!", 
            "This is a body."
        );
    });
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Une route a été créée avec 4 `Step`.
- Le cycle d'exécution de la route se lit du haut vers le bas :
    - `ExtractStep`
    - `CheckerStep`
    - `ProcessStep`
    - `HandlerStep`
></div>

### Paramètres de path
{: .no_toc }
Les `Route` peuvent être dynamiques pour accepter des paramètres. Les paramètres courants sont accessibles à travers la clé `params` de l'objet `Request`.

```ts
import { useBuilder, OkHttpResponse } from "@duplojs/core";

useBuilder()
    .createRoute("GET", "/user/{userId}")
    .handler(() => {
        return new OkHttpResponse(
            "Hello World!", 
            "This is a body."
        );
    });
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La route possède un paramètre `userId`.
- Les paramètres sont toujours de type `string`
></div>

## Les réponses prédéfinies
Comme vous avez pu le remarquer, l'objet retourné par le handler des routes en exemple est `OkHttpResponse`. Cet objet est une réponse prédéfinie. Ici `OkHttpResponse` représente une réponse avec le code `200`. Il existe plus de 30 objets de réponse prédéfinis. Tous ces objets sont des extensions de l'objet `Response`. Les réponses prédéfinies ont été créées pour éviter d'utiliser directement des codes de statut de réponse qui sont de simples nombres. Cela permet d'apporter plus de sens lors de la lecture du code.

```ts
import { Response, OkHttpResponse } from "@duplojs/core";

// output: true
console.log(new OkHttpResponse(undefined) instanceof Response);

const presetReponse = new OkHttpResponse("OK", "Hello, World!");
// équivalent a
const reponse = new Response(200, "OK", "Hello, World!");
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- L'instance de l'objet `OkHttpResponse` est bien également une instance de l'objet `Reponse`.
- Les constantes `presetReponse` et `reponse`, contiennent toutes deux une réponse équivalente avec un statut à `200`.
- L'utilisation du nombre `200` tel quel est une mauvaise pratique appelée `magic number`.
></div>

### Créer ses réponses prédéfinies
{: .no_toc }
Il est très simple de créer ses propres réponses prédéfinies. Cela peut vous permettre de factoriser une routine de définition de headers par exemple.

```ts
import { Response } from "@duplojs/core";

class MyCustomResponse<
    GenericInformation extends string | undefined = undefined,
    GenericBody extends unknown = undefined,
> extends Response<
        typeof MyCustomResponse.code,
        GenericInformation,
        GenericBody
    > {
    public constructor(
        information: GenericInformation = undefined as GenericInformation,
        body: GenericBody = undefined as GenericBody,
    ) {
        super(MyCustomResponse.code, information, body);

        this.setHeader("Cache-Control", "max-age=3600");
        this.setHeader("My-Super-Header", "my-super-value");
    }

    public static code = 200;
}

const myCustomResponse = new MyCustomResponse();
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- `MyCustomResponse` est une classe étendue de la classe `Response`.
- Le code prédéfini sera `200`.
- À chaque fois que la classe sera instanciée, les headers `Cache-Control` et `My-Super-Header` seront ajoutés à la réponse.
- Les generics sont importants pour un typage robuste.
></div>

## Les informations

Comme vous pouvez l'observer dans les exemples donnés précédemment, lorsque l'on instancie une réponse, nous précisons en second argument l'information de celle-ci.

```ts
import { useBuilder, OkHttpResponse } from "@duplojs/core";

export const myRoute = useBuilder()
    .createRoute("GET", "/hello-world")
    .handler(() => {
        return new OkHttpResponse(
            "My super info!", 
            undefined
        );
    });
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La réponse renvoyée aura un header nommé `information` possédant la valeur `My super info!`.
- La réponse a un body `undefined`.
></div>

Idéalement, chaque réponse envoyée possède une information différente, ce qui permet d'identifier de quelle partie du code provient la réponse. Le front pourra également se baser sur ces informations pour identifier le succès ou l'erreur d'une réponse. Par exemple, il peut arriver de renvoyer des erreurs 400 pour des raisons différentes. Cela permet de les différencier.

## Enregistrer les routes
Après avoir défini les routes, il faut les enregistrer pour qu'elles soient utilisables par une instance DuploJS. La méthode la plus simple pour enregistrer une route est d'utiliser `register`.

```ts
import { Duplo } from "@duplojs/core";
import { myRoute } from "./route";

const duplo = new Duplo({
    environment: "TEST"
});

duplo.register(myRoute);
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- `new Duplo` initialise l'application avec un environnement de test.
- `register` ajoute la route `myRoute` pour qu'elle soit active dans l'application.
></div>

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

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- `import "./route";` permet d'executer le fichier sans importer ses variables.
- `getAllCreatedDuplose()` récupère toutes les routes créées avec `useBuilder`.
></div>

## Le floor

Le `floor` dans DuploJS est un accumulateur typé, qui s'enrichit suivant les différentes étapes implémentées dans les routes. Chaque route possède son propre `floor` pendant son exécution.

```ts
import { makeFloor } from "@duplojs/core";

const floor = makeFloor<{foo: "bar", prop: number}>();

const bar = floor.pickup("foo"); // typeof bar === "bar"

const { foo, prop } = floor.pickup(["foo", "prop"]); 
// typeof foo === "bar"
// typeof prop === number
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- `makeFloor` crée un `floor` avec des propriétés spécifiques (`foo` et `prop`).
- `pickup` permet d'accéder aux valeurs de ces propriétés.
></div>

### Exemple du floor dans une route
{: .no_toc }

La méthode `handler` reçoit en premier argument la méthode pickup du `floor` de la route.

```ts
import { OkHttpResponse, useBuilder, zod } from "@duplojs/core";

export const myRoute = useBuilder()
    .createRoute("GET", "/hello-world")
    // Extract est une step qui permet d'enrichir le floor
    .extract({
        query: {
            foo: zod.string()
        }
    })
    .handler((pickup) => {
        // Ici, pickup est utilisé pour accéder aux propriétés du floor
        const bar = pickup("foo");

        return new OkHttpResponse(
            `Hello ${bar}`, 
            "this is a body"
        );
    });
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La méthode `extract` est utilisée pour enrichir le `floor`, son utilisation sera précisée plus tard.
- `pickup` est passé au handler, permettant d’accéder aux propriétés du `floor` comme `foo`.
- Le typage de la propriété `foo` est garanti.
></div>

<br>

[Obtenir de la donnée d'une requête >\>\>](../getting-data-from-request){: .btn .btn-yellow}