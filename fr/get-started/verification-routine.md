---
layout: default
parent: Commencer
title: Routine de vérification
nav_order: 6
---

# Routine de vérification
{: .no_toc }
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/verification-routine).

1. TOC
{:toc}

## Les process
Les processes font partie des objet complexe de DuploJS. Leurs création passe aussi par le bier d'un **[builder](../../required/design-patern-builder)**. L'objet `Route` et l'objet `Process` sont tout les deux étendu de l'objet `Duplose`. Un **process** n'est donc pas diférent dans ça structure est ça déclaration pars rapport a une route. Cependant, le builder des **process** ne propose pas de method `handler` car ceux-ci ne doivent pas avoir de d'étape `HandlerStep`. Les `HandlerStep` pour les **Routes**, ont pour role de contenire l'actions de la route. Dans le cas des **Process**, il ne doivent pas avoir d'action car ils sont uniquement la pour faire des vérification routiniére. Les **Process** son parfait pour :
- l’authentification
- la vérificarion de role
- factoriser quelconque suite de vérification.

## Créer un process
La créaction d'un **Process** est semblable a c'elle d'une **Route**. Il faut applé la fonction `useBuiler` pour utilisé la méthode `createProcess` qui donne accés en suite au **[builder](../../required/design-patern-builder)** de l'objet `Process`. La méthode `createProcess` prends en première argument une `string` qui correspond au nom du **Process**. La créations d'un process ce cloture par l'appel de la méthode `exportation` du **[builder](../../required/design-patern-builder)**. Cette méthode prend en argument un tableau de clef qui index des donné dans le **floor** du **process**. Chanque clef spécifier pourras étre utilisé afin d'importer des donner du process dans le floor des **routes**/**processes** qui l'implémente. Les **processes** peuvent être créés avec des options qui pourront étre override lore de leurs implémentation. Pour cela il suffit de définir a la propriété `options` dans l'objet en deuxième argument de la méthode `createProcess`.

```ts
import { ForbiddenHttpResponse, makeResponseContract, useBuilder, zod } from "@duplojs/core";

interface MustBeConnectedOptions {
    role: "user" | "admin";
}

export const mustBeConnectedProcess = useBuilder()
    .createProcess(
        "mustBeConnected",
        {
            options: <MustBeConnectedOptions>{
                role: "user",
            },
        },
    )
    .extract(
        {
            headers: {
                authorization: zod.string(),
            },
        },
        () => new ForbiddenHttpResponse("authorization.missing"),
    )
    .check(
        valideTokenCheck,
        {
            input: (pickup) => pickup("authorization"),
            result: "token.valide",
            catch: () => new ForbiddenHttpResponse("authorization.invalide"),
            indexing: "contentAuthorization",
        },
        makeResponseContract(ForbiddenHttpResponse, "authorization.invalide"),
    )
    .cut(
        ({ pickup, dropper }) => {
            const { contentAuthorization, options } = pickup(["contentAuthorization", "options"]);

            if (contentAuthorization.role !== options.role) {
                return new ForbiddenHttpResponse("authorization.wrongRole");
            }

            return dropper(null);
        },
        [],
        makeResponseContract(ForbiddenHttpResponse, "authorization.wrongRole"),
    )
    .exportation(["contentAuthorization"]);
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Un process portant le nom de `mustBeConnected` a étais créer.
- Le process créer export la donné indéxer a `contentAuthorization`, pour permettre au route/process qu'il l'implémente d'utilisé cette donné.
- Le process a étais créer avec l'option `role` qui a pour valer pas défaut `user`.
- En survolant le code nous pouvont déduire que le demande une `authorization` présente dans les headers, qui contien un token qui doit valide. Aprés la vérification du token, on obtien sont contenue ce qui permet de comparé le role de l'utilisateur avec le role paramétré. Ce process permet donc l'authentifacation d'un uitilisateur.
></div>

{: .note }
Les process peuvent ont les même step disponible que les route (saufe la `HandlerStep`). il n'y a aucune diférence d'utilisation.

## Implémentation d'un process
Les processes peuvent ce faire implémenter a dans des route, dans des proccesses mais aussi avand des routes et avand des processes.

### Implémentation basic
{: .no_toc }
Pour implémenter un process dans une route ou un process, il faut utilisé la méthode `execute` des **[builders](../../required/design-patern-builder)**. Cette méthode prend en premier argument un process et en seconde les paramétres d'implémentation. Deux propriéter importante a retenir de des paramétre d'implémentation, `options` qui permet d'override les options pars défaut et `pickup` qui permet de récupérer dans la route des donnés exporter provenant du floor du process.

```ts
import { makeResponseContract, OkHttpResponse, useBuilder } from "@duplojs/core";

useBuilder()
    .createRoute("GET", "/user")
    .execute(
        mustBeConnectedProcess,
        {
            options: { role: "user" },
            pickup: ["contentAuthorization"],
        },
    )
    .presetCheck(
        iWantUserExistById,
        (pickup) => pickup("contentAuthorization").id,
    )
    .handler(
        (pickup) => {
            const { user } = pickup(["user"]);

            return new OkHttpResponse("user.getSelf", user);
        },
        makeResponseContract(OkHttpResponse, "user.getSelf", userSchema),
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Le process `mustBeConnected` a étais implémenter dans un route.
- L'options `role` du process est définit sur `user`.
- Le paramétre `pickup` rapatrie la donner `contentAuthorization` dans le floor de la route.
></div>

### Implémentation preflight
{: .no_toc }
il est possible d'implémenter un process avant la création d'une route/process. Le process devient un **preflight**. Les **preflight** s'éxécute avant l'interprétation du body. Il est conseiller de les utilisais pour faire des routine d'autentification.

```ts
import { makeResponseContract, OkHttpResponse, useBuilder, zod } from "@duplojs/core";

useBuilder()
    .preflight(
        mustBeConnectedProcess,
        {
            options: { role: "admin" },
        },
    )
    .createRoute("GET", "/users/{userId}")
    .extract({
        params: {
            userId: zod.coerce.number(),
        },
    })
    .presetCheck(
        iWantUserExistById,
        (pickup) => pickup("userId"),
    )
    .handler(
        (pickup) => {
            const { user } = pickup(["user"]);

            return new OkHttpResponse("user.get", user);
        },
        makeResponseContract(OkHttpResponse, "user.get", userSchema),
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Le process `mustBeConnected` a étais implémenter en temp que preflight.
- L'options `role` du process est définit sur `admin`.
></div>

{: .note }
Il possible d'implémenter autent de preflight que vous voulez. Vous pouvez trés bien ajouter localment un preflight avant la déclaration d'une route, cela d'effet de bord.

## Créer ses propres builders
comme vue précédement, un process implémenter en preflight est complétement indépendent. Cela nous permet de crer nos propre **[builders](../../required/design-patern-builder)** avec des preflight déja intégrés.

```ts
import { makeResponseContract, NoContentHttpResponse, useBuilder, zod } from "@duplojs/core";

export function mustBeConnectedBuilder(options: MustBeConnectedOptions) {
    return useBuilder()
        .preflight(
            mustBeConnectedProcess,
            {
                options,
                pickup: ["contentAuthorization"],
            },
        );
}

mustBeConnectedBuilder({ role: "admin" })
    .createRoute("DELETE", "/users/{userId}")
    .extract({
        params: {
            userId: zod.coerce.number(),
        },
    })
    .presetCheck(
        iWantUserExistById,
        (pickup) => pickup("userId"),
    )
    .handler(
        (pickup) => {
            const { user } = pickup(["user"]);

            // action

            return new NoContentHttpResponse("user.delete");
        },
        makeResponseContract(NoContentHttpResponse, "user.delete"),
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Un builder nomé `mustBeConnectedBuilder` a étais créer.
- Le builder prend le options du process `mustBeConnected` en agrument, ce qui permet d'étre fléxible sur qu'elle rolle éxiger pour la connexion.
- Il est possible d'utilisé `mustBeConnectedBuilder` pour déclarer autent de route/process que nous voulont.
- Une route `DELETE : /users/{userId}` a étais créer avec `mustBeConnectedBuilder`.
></div>

<br>

[\<\< Aborder une nouvelle route](../how-to-approach-new-road){: .btn .mr-4 } 