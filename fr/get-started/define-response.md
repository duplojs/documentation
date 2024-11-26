---
layout: default
parent: Commencer
title: Définir une réponse
nav_order: 4
---

# Définir une réponse
{: .no_toc }
Dans **Duplo**, il est possible de définir des réponses afin de créer des contrats de sortie pour les **routes**. Cela ne se fait pas via des interfaces Typescript mais part le biais des schémas Zod. Cela offre l'avantage de pouvoir être interprêté au runtime en plus de pouvoir servir de contrat de type pour Typescript. Par défaut, **Duplo** exécute les schémas à chaque renvoi d'une réponse. Cela permet de s'assurer de l'authenticité du type avant de répondre. Il est bien évidemment possible de désactiver cette fonctionalité en environnement de production.
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/define-response).

1. TOC
{:toc}

## Les contrats de sortie
Un contrat de sortie est un objet réponse avec comme body un schéma Zod. Les contrats s'appliquent uniquement pour 3 propriétés, le `code`, l'`information` et le `body`. Un contrat peut être un objet réponse ou un tableau d'objets réponse. La fonction `makeResponseContract` optimise les contrats dans le cas d'un code et body similaire mais a information différente.

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
- Plusieurs contrats de sortie ont été créés. On les reconnait car le body de ces objets réponse ont été définis sur des schémas Zod.
- Les contrats de sortie peuvent être des tableaux.
- Il est préférable d'utiliser la fonction `makeResponseContract` pour bien différencier une réponse d'un contrat de sortie.
- La fonction `makeResponseContract` renvoie un tableau de contrat de sortie.
- Avec la fonction `makeResponseContract`, le schéma donné par défaut au body est `zod.undefined()`.
></div>

## Implémentation d'un contrat
L'implémentation d'un contrat permet son utilisation. Les étapes des **routes** pouvant implémenter un contrat sont les `HandlerStep`, les `CheckerStep` et les `CutStep`. 

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
- La `CheckerStep` implémente un contrat et l'applique à la méthode `catch` des paramètre du **checker**.
- La `CutStep` implémente un contrat de sortie dans le cas où la fonction renverait un objet réponse.
- La `HandlerStep` implémente un contrat de sortie pour sa réponse.
></div>

{: .note}
Les contrats de sortie définissent le type que doivent renvoyer les fonctions concernées, et non l'inverse. En cas de non-respect, TypeScript indiquera une erreur sur le retour de la fonction et non sur le contrat lui-même. Bien que les contrats puissent sembler représenter un travail supplémentaire, ils vous seront d'une grande aide pour les tests unitaires ou end-to-end. Ils pourront également faciliter la génération automatique d'une documentation Swagger ou d'un client HTTP 100 % typé.

### Implémentations un contrat sur un preset checker
{: .no_toc }
Les **preset checkers** peuvent également implémenter un contrat de sortie qui sera directement transmis à la **route**, sans qu'il soit nécessaire de le spécifier à nouveau.

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
- Le **preset checker** porte un contrat de sotie et l'applique à la méthode `catch` des paramètres du **checker**.
- Si le **preset checker** est implémenté sur une **route**, le contrat sera transmis aussi. 
></div>

### Echec d'un contrat implémenter 
Pour rappel les contrat implémenter sont éxécuter au run time pour s'assurer de la validité de la réponse. Cette fonctionnalité peut être désactivée en définissent l'option `disabledRuntimeEndPointCheck` de l'instance **Duplo** sur `true`. Si cette options n'est pas spécifier, chaque réponse renvoyer sera dabore comparé avec le contrat de sortie qui est accosier a la step répondante. Le code HTTP, l'information et le body sont les seul chose qui seront vérifier. En cas d'echec par le non repect d'un contrat, une erreur `ContractResponseError` sera `throw` par la route.

<br>

[\<\< Faire une vérification](../do-check){: .btn .mr-4 }
[Aborder une nouvelle route >\>\>](../how-to-approach-new-road){: .btn .btn-yellow } 