---
layout: default
parent: Commencer
title: Obtenir de la donnée d'une requête
nav_order: 2
---

# Obtenir de la donnée d'une requête
{: .no_toc }
Dans cette section, nous allons voir comment **obtenir** de la **donnée  typée** d'une **requête**, de manière **robuste** et **100% fiable**. 
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/getting-data-from-request).

1. TOC
{:toc}

## La methode extract
La methode `extract` fait partie du **[builder](../../required/design-patern-builder)** de l'objet `Route`. Elle a pour effet direct d'ajouter une `ExtractStep` aux **étapes** de la **route** en cours de création. Le but d'une **étape** `ExtractStep` est de **récupérer** des **données** provenant de la **requête** courante. Pour cela, **Duplo** utilise la librairie de parsing **[zod](../../required/zod)**, qui garantit la **validité** du **type** des **données** et **enrichit** le `floor`.

```ts
import { CreatedHttpResponse, useBuilder, zod } from "@duplojs/core";

useBuilder()
    .createRoute("POST", "/user")
    .extract({
        body: zod.object({
            userName: zod.string(),
            email: zod.string(),
            age: zod.coerce.string(),
        }).strip(),
    })
    .handler(
        (pickup) => {
            const { userName, email, age } = pickup("body");

            const user = {
                id: 1,
                userName,
                email,
                age,
            };

            return new CreatedHttpResponse(
                "user.created",
                user,
            );
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La methode `extract` est utilisée **avant** la methode `handler` donc l'**exécution** de l'**étape** `ExtractStep` se fait **avant** celle de `HandlerStep`.
- `extract` prend en premier argument un objet ayant les **mêmes clés** que l'objet `Request`.
- Le schéma `zod` défini pour la **clé** `body` de l'objet sera **appliqué à la valeur** contenue dans `Request.body`.
- La **clé** `body` est ajoutée au `floor` et aura le **type défini** par le schéma `zod`.
- En cas d'échec du parsing, la **route** renverra une **réponse** d'erreur et **l'exécution s'arrêtera** à l'**étape** `ExtractStep`. Toutes les **étapes** déclarées derrière ne seront donc **pas éxécutées**.
- La méthode `strip` du schéma `zod` permet d'éviter une erreur TypeScript `ts(2589)`.
></div>

## Niveau d'extraction de la donnée
Il existe deux niveaux d'**extraction** : simple ou profond.

```ts
import { OkHttpResponse, useBuilder, zod } from "@duplojs/core";

useBuilder()
    .createRoute("GET", "/user/{userId}")
    .extract({
        params: zod.object({
            userId: zod.string(),
        }).strip(),
    })
    .handler(
        (pickup) => {
            const params = pickup("params");

            console.log(params.userId);

            return new OkHttpResponse(
                "user",
                undefined,
            );
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- L'**extraction** est faite à un niveau simple.
- La **clé** `params` sera ajoutée au `floor` et aura le **type défini** par le schéma `zod`.
></div>

```ts
import { OkHttpResponse, useBuilder, zod } from "@duplojs/core";

useBuilder()
    .createRoute("GET", "/user/{userId}")
    .extract({
        params: {
            userId: zod.string(),
        },
    })
    .handler(
        (pickup) => {
            const userId = pickup("userId");

            console.log(userId);

            return new OkHttpResponse(
                "user",
                undefined,
            );
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- L'**extraction** est faite à un niveau profond.
- La **clé** `userId` sera ajoutée au `floor` et aura le **type défini** par le schéma `zod`.
></div>

## Gestion des échecs
En cas d'**échec d'exécution** d'une **étape** `ExtractStep` causé par l'**invalidité d'une donnée**, une **réponse** `UnprocessableEntityHttpResponse` sera **renvoyée**. Il est possible de modifier ce comportement par défaut en passant un **callbac** en deuxième argument de `extract`.

```ts
import { OkHttpResponse, InternalServerErrorHttpResponse, useBuilder, zod } from "@duplojs/core";

useBuilder()
    .createRoute("GET", "/user/{userId}")
    .extract(
        {
            params: {
                userId: zod.string(),
            },
        },
        (type, key, zodError) => new InternalServerErrorHttpResponse(
            "error",
            zodError,
        ),
    )
    .handler(
        (pickup) => {
            const userId = pickup("userId");

            console.log(userId);

            return new OkHttpResponse(
                "user.get",
                undefined,
            );
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- En cas d'**échec du parsing** de `userId`, une `InternalServerErrorHttpResponse` sera **renvoyée**.
- La **clé** `userId` sera ajoutée au `floor` et aura le **type défini** par le schéma `zod`.
></div>

### Gestion des échecs global
{: .no_toc }
Il est possible de changer le comportement par défaut des échecs pour toutes les **étapes** `ExtractStep` en utilisant `setExtractError` d'une instance **Duplo**. Cela s'applique à toutes les **routes** enregistrées dans cette instance.

```ts
import { UnprocessableEntityHttpResponse, useBuilder, Duplo } from "@duplojs/core";

const duplo = new Duplo({ environment: "TEST" });

duplo.setExtractError(
    (type, key, zodError) => new UnprocessableEntityHttpResponse(
        "error.extract",
        zodError,
    ),
);

duplo.register(...useBuilder.getAllCreatedDuplose());
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- `new Duplo` initialise l'application avec un environnement de test.
- Toutes les **routes** créées avec `useBuilder` sont enregistrées dans l'instance.
- La methode `setExtractError` définit le comportement par défaut en cas d'échec des **étapes** `ExtractStep` avec le **renvoi** d'une `UnprocessableEntityHttpResponse`.
></div>

<br>

[\<\< Ma première route](../first-route){: .btn .mr-4 }
[Faire une vérification >\>\>](../do-check){: .btn .btn-yellow } 