---
layout: default
parent: Commencer
title: Aborder une nouvelle route
nav_order: 5
---

# Aborder une nouvelle route
{: .no_toc }
Cette partie aborde la méthodologie de travail à adopter lors de l'utilisation du framework **DuploJS**.
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/1.x/get-started/how-to-approach-new-road).

1. TOC
{:toc}

## Outils à ma disposition
Pour rappel, dans **DuploJS**, une route est constituée d'étapes à franchir avant d'effectuer une action. Chaque étape est une vérification qui peut mettre fin à l'exécution de la route en renvoyant une réponse. Les différentes étapes abordées précédement sont :
- les [`ExtractStep`](../getting-data-from-request) qui permettent d'extraire de la donnée de la requête courante.
- les [`CheckerStep`](../do-check#les-checkers) qui effectuent une vérification à partir d'une valeur d'entrée.
- les [`CutStep`](../do-check#les-cuts) qui effectuent une vérification directement au sein de la route pour des cas uniques.

> La [`HandlerStep`](../first-route#créer-une-route-simple) fait exception car elle doit contenir l'action d'une route, elle sera donc la dernière étape et devra renvoyer une réponse positive.

En plus de jouer un role de **garde**, les étapes enrichissent de manière typées le [**floor**](../first-route#le-floor) qui est un accumulateur de données.

Pour finir, il existe les [**contrats de sortie**](../define-response) qui permettent explicitement d'indiquer ce que l'on renvoie. C'est un aspect très important qui garantit un retour correct.

## Comment procéder ?
Pour commencer, il vous faut établir un but. 
À quoi votre route va-t-elle servir :
- À récupérer des informations d'un utilisateur ?
- À poster un message dans une conversation ?
- À ajouter un utilisateur à une organisation ?
- À créer un utilisateur ?

Pour illustrer la méthodologie, le but choisi sera d'envoyer un message à un utilisateur.

Après avoir établi ce que nous voulons, nous pouvons commencer par définir le document que notre route renverra. Cela nous permettera de mettre en place le contrat de sortie.

```ts
import { zod } from "@duplojs/core";

export const messageSchema = zod.object({
    senderId: zod.number(),
    receiverId: zod.number(),
    content: zod.string(),
    postedAt: zod.date(),
});
```

{: .note }
Quand le body de votre contrat est un objet, il est préférable de le déclarer dans un autre fichier. Dans une architecture simple, créez un dossier `src/schemas` et enregistez vos schémas dans des fichiers différents suivant le document qu'ils représentent.


Ensuite nous pouvons commencer à déclarer notre route. Nous utiliserons la méthode `POST` et le chemin `/users/{receiverId}/messages`, car il s'agit d'un envoi de données dans les messages d'un utilisateur.

```ts
import { makeResponseContract, OkHttpResponse, useBuilder, type ZodSpace } from "@duplojs/core";

useBuilder()
    .createRoute("POST", "/users/{receiverId}/messages")
    .handler(
        (pickup) => {
            const postedMessage: ZodSpace.infer<typeof messageSchema> = {
                postedAt: new Date(),
                /* ... */
            };

            return new OkHttpResponse("message.posted", postedMessage);
        },
        makeResponseContract(OkHttpResponse, "message.posted", messageSchema)
    );
```

{: .note }
L'information décrit comment la route s'est arrêtée. Ici, si la réponse `message.posted` est reçue, cela signifie que la route s'est arrêtée après avoir posté le message.

Dans notre cas, pour envoyer un message, nous voulons être sûr que l'utilisateur qui le reçoit existe avant de stocker son message. Ici il sera nommé `receiver` et son `id` est présent dans les paramètres du path `/users/{receiverId}/messages` de notre route. La prochaine étape sera donc de l'extraire, afin d'avoir le `receiverId` indéxé dans le floor.

{% highlight ts mark_lines="5 6 7 8 9 12 15" %}
import { makeResponseContract, OkHttpResponse, useBuilder, zod, type ZodSpace } from "@duplojs/core";

useBuilder()
    .createRoute("POST", "/users/{receiverId}/messages")
    .extract({
        params: {
            receiverId: zod.coerce.number(),
        },
    })
    .handler(
        (pickup) => {
            const { receiverId } = pickup(["receiverId"]);

            const postedMessage: ZodSpace.infer<typeof messageSchema> = {
                receiverId,
                postedAt: new Date(),
                /* ... */
            };

            return new OkHttpResponse("message.posted", postedMessage);
        },
        makeResponseContract(OkHttpResponse, "message.posted", messageSchema)
    );
{% endhighlight %}

{: .note }
Les paramètres de path sont toujours des `string`. C'est pour cela que l'on utilise le `coerce` de zod pour le convertir en `number`.

Ensuite, il faut vérifier que notre receveur existe. Nous allons utiliser le checker `userExist` provenant de cette [exemple](../do-check#création-dun-checker) et en faire un preset checker.

```ts
import { createPresetChecker, makeResponseContract, NotFoundHttpResponse } from "@duplojs/core";

export const iWantUserExist = createPresetChecker(
    userExistCheck,
    {
        result: "user.exist",
        catch: () => new NotFoundHttpResponse("user.notfound"),
        indexing: "user",
    },
    makeResponseContract(NotFoundHttpResponse, "user.notfound"),
);
```

Une fois devenu un preset checker, son implémentation sera beaucoup plus explicite et rapide.

{% highlight ts mark_lines="10 11 12 13 16 19" %}
import { makeResponseContract, OkHttpResponse, useBuilder, zod, type ZodSpace } from "@duplojs/core";

useBuilder()
    .createRoute("POST", "/users/{receiverId}/messages")
    .extract({
        params: {
            receiverId: zod.coerce.number(),
        },
    })
    .presetCheck(
        iWantUserExist,
        (pickup) => pickup("receiverId"),
    )
    .handler(
        (pickup) => {
            const { user } = pickup(["user"]);

            const postedMessage: ZodSpace.infer<typeof messageSchema> = {
                receiverId: user.id,
                postedAt: new Date(),
                /* ... */
            };

            return new OkHttpResponse("message.posted", postedMessage);
        },
        makeResponseContract(OkHttpResponse, "message.posted", messageSchema)
    );
{% endhighlight %}

Pour obtenir le contenu du message il nous faut également l'extraire.

{% highlight ts mark_lines="14 15 16 17 18 21 25" %}
import { makeResponseContract, OkHttpResponse, useBuilder, zod, type ZodSpace } from "@duplojs/core";

useBuilder()
    .createRoute("POST", "/users/{receiverId}/messages")
    .extract({
        params: {
            receiverId: zod.coerce.number(),
        },
    })
    .presetCheck(
        iWantUserExist,
        (pickup) => pickup("receiverId"),
    )
    .extract({
        body: zod.object({
            content: zod.string(),
        }),
    })
    .handler(
        (pickup) => {
            const { user, body } = pickup(["user", "body"]);

            const postedMessage: ZodSpace.infer<typeof messageSchema> = {
                receiverId: user.id,
                content: body.content,
                postedAt: new Date(),
                /* ... */
            };

            return new OkHttpResponse("message.posted", postedMessage);
        },
        makeResponseContract(OkHttpResponse, "message.posted", messageSchema)
    );
{% endhighlight %}

{: .note }
Il est tout à fait possible d'utiliser la première `ExtractStep` pour obtenir le body. Mais imaginons que, par soucis de performance, nous ne souhaitions pas extraire le contenu du body immédiatement.

N'oublions pas que si quelqu'un reçoit un message, c'est qu'une autre personne l'a envoyé. C'est moi, en temps qu'utilisateur qui ai appelé la route pour poster un message dans la pile d'un autre utilisateur. Pour cela, imaginons que notre `userId` (ou `senderId`) soit stocké dans un header `userId`. Habituellement, il aurait dû être obtenu via un token qu'il aurait fallu valider en amont, mais pour notre exemple, nous ferons plus simple.

{% highlight ts mark_lines="9 10 11" %}
import { makeResponseContract, OkHttpResponse, useBuilder, zod, type ZodSpace } from "@duplojs/core";

useBuilder()
    .createRoute("POST", "/users/{receiverId}/messages")
    .extract({
        params: {
            receiverId: zod.coerce.number(),
        },
        headers: {
            userId: zod.coerce.number(),
        },
    })
    .presetCheck(
        iWantUserExist,
        (pickup) => pickup("receiverId"),
    )
    .extract({
        body: zod.object({
            content: zod.string(),
        }),
    })
    .handler(
        (pickup) => {
            const { user, body } = pickup(["user", "body"]);

            const postedMessage: ZodSpace.infer<typeof messageSchema> = {
                receiverId: user.id,
                content: body.content,
                postedAt: new Date(),
                /* ... */
            };

            return new OkHttpResponse("message.posted", postedMessage);
        },
        makeResponseContract(OkHttpResponse, "message.posted", messageSchema)
    );
{% endhighlight %}

Nous rencontrons ici un petit problème. Il y a deux utilisateurs différents dans la route : le `sender` et le `receiver`. Dans le cas actuel, si je réutilise mon preset checker `iWantUserExist` en y envoyant mon `userId` à la place de `receiverId`, le preset checker va réindexer l'utilisateur trouvé à l'index `user` dans le floor. Cela écrasera la valeur indéxée du précédant preset checker. De plus, un second problème arrive. Si le preset checker est re-implémenté tel quel, la route peut renvoyer deux fois la même information `user.notfound` pour 2 raisons différentes. La solution à tous nos problèmes est de créer un second preset checker à partir du premier.

{% highlight ts mark_lines="13 14 15 16 17 18" %}
import { createPresetChecker, makeResponseContract, NotFoundHttpResponse } from "@duplojs/core";

export const iWantUserExist = createPresetChecker(
    userExistCheck,
    {
        result: "user.exist",
        catch: () => new NotFoundHttpResponse("user.notfound"),
        indexing: "user",
    },
    makeResponseContract(NotFoundHttpResponse, "user.notfound"),
);

export const iWantReceiverExist = iWantUserExist
    .rewriteIndexing("receiver")
    .redefineCatch(
        () => new NotFoundHttpResponse("receiver.notfound"),
        makeResponseContract(NotFoundHttpResponse, "receiver.notfound"),
    );
{% endhighlight %}

Avec cela, le preset checker `iWantReceiverExist` indexera la donnée à `receiver` dans le floor et, en cas d'échec, l'information `receiver.notfound` sera renvoyée. Il ne reste plus qu'à l'implémenter.

{% highlight ts mark_lines="13 14 15 16 17 18 19 20 28 31 32" %}
import { makeResponseContract, OkHttpResponse, useBuilder, zod, type ZodSpace } from "@duplojs/core";

useBuilder()
    .createRoute("POST", "/users/{receiverId}/messages")
    .extract({
        params: {
            receiverId: zod.coerce.number(),
        },
        headers: {
            userId: zod.coerce.number(),
        },
    })
    .presetCheck(
        iWantUserExist,
        (pickup) => pickup("userId"),
    )
    .presetCheck(
        iWantReceiverExist,
        (pickup) => pickup("receiverId"),
    )
    .extract({
        body: zod.object({
            content: zod.string(),
        }),
    })
    .handler(
        (pickup) => {
            const { user, receiver, body } = pickup(["user", "receiver", "body"]);

            const postedMessage: ZodSpace.infer<typeof messageSchema> = {
                senderId: user.id,
                receiverId: receiver.id,
                content: body.content,
                postedAt: new Date(),
            };

            return new OkHttpResponse("message.posted", postedMessage);
        },
        makeResponseContract(OkHttpResponse, "message.posted", messageSchema),
    );
{% endhighlight %}

La déclaration de la route s'arrête ici. Toutes vos vérifications sont explicites, votre code est robuste et sans erreur grâce au typage de bout en bout !

<br>

[\<\< Définir une réponse](../define-response){: .btn .mr-4 }
[Routine de vérification >\>\>](../verification-routine){: .btn .btn-yellow } 