---
layout: default
parent: Commencer
title: Routine de vérification
nav_order: 6
---

# Routine de vérification
{: .no_toc }
Dans cette partie, nous allons voir comment créer des routines de vérification.
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/0.x/get-started/verification-routine).

1. TOC
{:toc}

## Les process
Les **processes** font partie des objets complexes de DuploJS. Leur création passe aussi par le biais d'un **[builder](../../required/design-patern-builder)**. Les objets `Route` et `Process` sont tous deux des extensions de l'objet `Duplose`. Un **process** n'est donc pas fondamentalement différent dans sa structure et sa déclaration. Cependant, le builder des **processes** ne propose pas de méthode `handler`, car ceux-ci ne doivent pas inclure d'étape `HandlerStep`.

Les `HandlerStep`, utilisés pour les **Routes**, ont pour rôle de contenir l'action associée à la route. Dans le cas des **processes**, ils ne doivent pas inclure d'actions, car leur but est uniquement de réaliser des vérifications routinières. Les **processes** sont particulièrement adaptés pour :

- l’authentification,
- la vérification des rôles,
- la factorisation d'utilisations récurrentes.


## Créer un process
La création d'un **Process** est semblable à celle d'une **Route**. Il faut appeler la fonction `useBuilder` pour utiliser la méthode `createProcess`, qui donne ensuite accès au **[builder](../../required/design-patern-builder)** de l'objet `Process`. 

La méthode `createProcess` prend comme premier argument une `string` correspondant au nom du **Process**. La création d'un process se clôture par l'appel de la méthode `exportation` du **[builder](../../required/design-patern-builder)**. Cette méthode prend en argument un tableau de `string`, qui représente les index des données présentes dans le **floor** du **Process**. Chaque clé spécifiée pourra être utilisée pour importer des données du **Process** dans le floor des **Routes** ou des **Processes** qui l'implémentent.

Les **Processes** peuvent être créés avec des options pouvant être surchargées lors de leur implémentation. Pour cela, il suffit de définir la propriété `options` dans l'objet passé en deuxième argument de la méthode `createProcess`.


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
- Un process nommé `mustBeConnected` a été créé.  
- Le process exporte la donnée indexée sous `contentAuthorization`, permettant aux routes/processes qui l'implémentent d'utiliser cette donnée.  
- Le process a été créé avec l'option `role`, dont la valeur par défaut est `user`.  
- En survolant le code, nous pouvons déduire que le process exige un header `authorization` contenant un token. Ce token inclut des informations sur l'utilisateur. Grâce à ces informations, l'accès est interdit à l'utilisateur si son rôle ne correspond pas au rôle spécifié dans les options.
></div>

{: .note }
Les processes ont les mêmes steps disponibles que les routes (sauf la `HandlerStep`). Il n'y a aucune différence d'utilisation.

## Implémentation d'un process
Les **processes** peuvent être implémentés dans des routes, dans d'autres processes, mais aussi avant des routes et avant des processes.

### Implémentation basic
{: .no_toc }
Pour implémenter un **process** dans une route ou un autre process, il faut utiliser la méthode `execute` des **[builders](../../required/design-patern-builder)**. Cette méthode prend en premier argument un process et en second les paramètres d'implémentation. 

Deux propriétés importantes sont à retenir dans les paramètres d'implémentation :  
- `options` : permet de surcharger les options par défaut du process.  
- `pickup` : permet de récupérer dans la route les données exportées depuis le **floor** du process. 

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
- Le process `mustBeConnected` a été implémenté dans une route.  
- L'option `role` du process est définie sur `user`.  
- Le paramètre `pickup` rapatrie la donnée `contentAuthorization` dans le **floor** de la route.
></div>

### Implémentation preflight
{: .no_toc }
Il est possible d'implémenter un process avant la création d'une route/d'un process. Le process devient un **preflight**. Les **preflights** s'éxécutent avant l'interprétation du body. Il est conseillé de les utiliser pour faire des routines d'autentification.

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
- Le process `mustBeConnected` a été implémenté en tant que preflight.
- L'option `role` du process est définie sur `admin`.
></div>

{: .note }
Il est possible d'implémenter autant de **preflights** que vous le souhaitez. Vous pouvez très bien ajouter localement un **preflight** avant la déclaration d'une route, sans effets de bord.

## Créer ses propres builders
Comme vu précédemment, un **process** implémenté en **preflight** est complètement indépendant. Cela nous permet de créer nos propres **[builders](../../required/design-patern-builder)** avec des **preflights** déjà intégrés.

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
- Un builder nommé `mustBeConnectedBuilder` a été créé.  
- Le builder prend les options du process `mustBeConnected` en argument, ce qui permet d'être flexible sur le rôle exigé pour la connexion.  
- Il est possible d'utiliser `mustBeConnectedBuilder` pour déclarer autant de routes/processes que nous le souhaitons.  
- Une route `DELETE : /users/{userId}` a été créée avec `mustBeConnectedBuilder`.
></div>

<br>

[\<\< Aborder une nouvelle route](../how-to-approach-new-road){: .btn .mr-4 } 