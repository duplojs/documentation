---
layout: default
parent: Commencer
title: Définir une réponse
nav_order: 4
---

# Définir une réponse
{: .no_toc }
Dans **Duplo** il est possible de définir des réponses afin de créer des contrats de sortie pour les **routes**. Cela ne ce fait pas via des interfaces Typescript mais part le biais des schémas Zod, ça offre l'avantage de pouvoir étre interprêté au runtime en plus de pouvoir servir de contrat de type pour Typescript. Par défaut **Duplo** exécute les schémas à chaque renvoi d'une réponse. Cela permet de s'assurer de l'authenticité du type avant de répondre. Il est bien évidement possible de désactiver cette fonctionalitée en environement de production.
Tous les exemples présenté dans ce cours sont disponible en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/define-response).

1. TOC
{:toc}

## Les contrats de sortie
Un contrat de sortie est un objet réponse avec comme body un schéma Zod. Les contrats s'applique uniquement pour 3 propriétés, le `code`, l'`information` et le `body`. Un contrat peut être un objet réponse ou un tableau d'objet réponse. La fonction `makeResponseContract` optimise les contrats dans le cas d'un code et body similaire mais a information différente.

```ts
import { OkHttpResponse, Response, zod, makeResponseContract, ForbiddenHttpResponse } from "@duplojs/core";

new Response(200, "SuperInfo", zod.undefined());
// same as
new OkHttpResponse("SuperInfo", zod.undefined());
// same as
makeResponseContract(OkHttpResponse, "SuperInfo")[0];

new OkHttpResponse(
    "SuperInfo",
    zod.object({
        id: zod.string(),
        name: zod.string(),
    }),
);
// same as
makeResponseContract(
    OkHttpResponse,
    "SuperInfo",
    zod.object({
        id: zod.string(),
        name: zod.string(),
    }),
)[0];

<const>[
    new ForbiddenHttpResponse("token.expire", zod.undefined()),
    new ForbiddenHttpResponse("token.invalid", zod.undefined()),
];
// same as
makeResponseContract(ForbiddenHttpResponse, ["token.expire", "token.invalid"]);
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Plusieurs contrats de sortie ont été créés. On les reconnais car le body de ces objets réponse on été défini sur des schémas Zod.
- Les contrats de sortie peuvent être des tableaus.
- Il est préférable d'utiliser la fonction `makeResponseContract` pour bien différencier une réponse d'un contrat de sortie.
- La fonction `makeResponseContract` renvois un tablau de contrat de sortie.
- Avec la fonction `makeResponseContract`, le schéma donné par défaut au body est `zod.undefined()`.
></div>

## Implémentations d'un contrat
L'implémentations d'un contrat permet son utilisation. Les étapes des **route** pouvant implémenter un contrat sont les `HandlerStep`, les `CheckerStep` et les `CutStep`. 

```ts
import { useBuilder, zod, ForbiddenHttpResponse, NoContentHttpResponse, NotFoundHttpResponse, makeResponseContract } from "@duplojs/core";

useBuilder()
    .createRoute("DELETE", "/users/{userId}")
    .extract({
        params: {
            userId: zod.coerce.number(),
        },
    })
    .check(
        userExistCheck,
        {
            input: (pickup) => pickup("userId"),
            result: "user.exist",
            indexing: "user",
            catch: () => new NotFoundHttpResponse("user.notfound"),
        },
        makeResponseContract(NotFoundHttpResponse, "user.notfound"),
    )
    .cut(
        ({ pickup, dropper }) => {
            const { email } = pickup("user");

            if (email === "admin@example.com") {
                return new ForbiddenHttpResponse("userIsAdmin");
            }

            return dropper(null);
        },
        [],
        makeResponseContract(ForbiddenHttpResponse, "userIsAdmin"),
    )
    .handler(
        (pickup) => {
            const { id } = pickup("user");

            // action to delete user

            return new NoContentHttpResponse("user.deleted");
        },
        makeResponseContract(NoContentHttpResponse, "user.deleted"),
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La `CheckerStep` implémente un contrat et l'applique a la méthode `catch` des paramétre du **checker**.
- La `CutStep` implémente un contrat de sortie dans le cas ou la fonction renverait un objet réponse.
- La `HandlerStep` implémente un contrat de sortie pour ça réponse.
></div>

{: .note}
Les contrat de sortie définisse le type que doit renvoyer les fonction concernés et pas l'inverse. L'erreur typescript en cas de non respect sera indiqué sur le retour de la fonction et non sur le contrat. Les contrat peuvent paraître comme étand du travaile en plus mais il vous aideront fortement dans le cadre de test unitaire/end to end, il pourront aussi aider a générer un swagger ou un client http 100% typé de façon automatique! 

### Implémentations un contrat sur un preset checker
{: .no_toc }
Les **preset checkers** peuvent également implémenter un contrat de sortie qui sera directement transmis a la **route** sans besoin de le re spésifier.

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

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Le **preset checker** porte un contrat de sotie et l'applique a la méthode `catch` des paramétre du **checker**.
- Si le **preset checker** est implémenter sur une **route**, le contrat sera transmis aussi. 
></div>

<br>

[\<\< Faire une vérification](../do-check){: .btn .mr-4 }
[Aborder une nouvelle route >\>\>](../how-to-approach-new-road){: .btn .btn-yellow } 