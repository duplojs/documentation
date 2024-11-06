---
layout: default
parent: Commencer
title: Déclarer une route
nav_order: 1
---

# Déclarer une route
{: .no_toc }

Dans cette section, nous allons voirs la base de la création et du fonctionnement des routes.
Tous les exemples présent dans ce cours son disponible en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/declare-route).

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

Dans cet exemple :
- La méthode `createRoute` est utilisée pour créer un builder d’objet Route.
- La route créée est de type `GET` avec le chemin `/hello-world`.
- La méthode `handler` fait partie du builder de route et termine la création de celle-ci.
- La méthode handler doit contenir l'action de la route et renvoyer une réponse positive.

### La method handler
{: .no_toc }
La method `handler` fait partir du builder de l'objet `Route`. Elle a pour effet direct d'ajouter une `HandlerStep` au étape de la route en cours de création. Les routes ne peuve avoir qu'une seul `HandlerStep` qui est obligatoirment la dernier `Step`. C'est pour cela que l'appel de cette method cloture la création de l'objet route et le renvois.

### Cycle d'éxécution
{: .no_toc }
Une route est constituer de `Step` implémenter a traver un builder. l'ordre d'implémentation compte car l'éxécution d'une route est sécanciel, du haut vers le bas. Chaque `Step` vas avoir la posibilité d'interompre l'éxécution et renvoyer une réponse.

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

Dans cet exemple :
- Une route a étais créer avec 4 `Step`.
- Le cycle d'éxécution de la route ce lit du haut vers le bas :
    - `ExtractStep`
    - `CheckerStep`
    - `ProcessStep`
    - `HandlerStep`

### Paramétre de path
{: .no_toc }
Les `Route` peuvet étre dynamic pour avoir des paramétre. Les paramétre courant sont accecible a travers la clef `params` de l'object `Request`.

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

Dans cet exemple :
- La route posséde un paramétre `userId`.
- Les paramétres sont tout le temps de type `string`

## Les réponses prédéfinit
Comme vous avez pue le remarqué, l'objet retourné par le handler des route en exemple est `OkHttpResponse`. cette objet est une réponse prédéfinit. Ici `OkHttpResponse` représente une réponse avec le code `200`. il éxiste plus de 30 objet de réponse prédéfinit. Tous ces objet sont étendu de l'objet `Response`. Les réponses prédéfinit ont étais créer pour éviter d'utilisé directement des status de réponse qui sont juste des nombre. Cela permet d'avoir plus de sens lors de la lecture du code.

```ts
import { Response, OkHttpResponse } from "@duplojs/core";

// output: true
console.log(new OkHttpResponse(undefined) instanceof Response);

const presetReponse = new OkHttpResponse("OK", "Hello, World!");
// équivalent a
const reponse = new Response(200, "OK", "Hello, World!");
```

Dans cet exemple :
- L'instance de l'objet `OkHttpResponse` est bien une instance égalment de l'objet `Reponse`.
- Les constante `presetReponse` et `reponse`, contienne tout deux une réponse équivalente avec un status a `200`.
- L'utilisation du nombre `200` t'el qu'elle est une mauvaise pratique qui porte le nom de `magic number`.

### Créer ses réponses prédéfinit
{: .no_toc }
Il est trés simple de créer c'est propre réponse prédéfinit. Cela peut vous permettre de factorisé une routine de défiintion de headers pars exemple. 

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

Dans cet exemple :
- `MyCustomResponse` est une class étendu de la class `Response`.
- Le code prédéfinit sera `200`.
- A chaque fois que la classe sera instancier, les headers `Cache-Control` et `My-Super-Header` seront ajouter a la réponse.
- Les generic sont important pour un typage robuste

## Les informations

Comme vous pouvez l'observer dans les exemples donnés précédement, lorsque l'on instancie une réponse, nous précisons en second argument l'information de celle-ci.

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

Dans cette exemple :
- La réponse renvoyée aura un header se nommant `information` possédant la valeur `My super info!`.
- La réponse porte un body `undefined`.

Dans l'idéal, chaque réponse envoyée possède une information différente, ce qui permet d'identifier de quelle partie du code provient la réponse. Le front pourra également se baser sur ces informations pour identifier le succès ou l'erreur d'une réponse. Par exemple, il peut vous arriver de renvoyer des erreurs 400 pour des raisons différentes. Cela vous permettera de les différencier.

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

Dans cet exemple :
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

Le `floor` dans DuploJS est un accumulateur typé, qui s'enrichi suivant les différentes étapes implémentées dans les routes. Chaque route possède son propre `floor` pendant son éxecution.

```ts
import { makeFloor } from "@duplojs/core";

const floor = makeFloor<{foo: "bar", prop: number}>();

const bar = floor.pickup("foo"); // typeof bar === "bar"

const { foo, prop } = floor.pickup(["foo", "prop"]); 
// typeof foo === "bar"
// typeof prop === number
```

Dans cet exemple :
- `makeFloor` crée un `floor` avec des propriétés spécifiques (`foo` et `prop`).
- `pickup` permet d'accéder aux valeurs de ces propriétés.

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

Dans cet exemple :
- La method `extract` est utilisais pour enrichier le `floor`, son utilisation sera présicé plus tard.
- `pickup` est passé au handler, permettant d’accéder aux propriétés du `floor` comme `foo`.
- Le typage de la propriété `foo` est garanti.

<br>

[Obtenir de la donnée d'une requête >\>\>](../getting-data-from-request){: .btn .btn-yellow}