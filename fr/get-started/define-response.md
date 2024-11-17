---
layout: default
parent: Commencer
title: Définir une réponse
nav_order: 4
---

# Définir une réponse
{: .no_toc }
Dans **Duplo** il est possible de définir des réponses afin de créer des contrats de sortie pour les routes. Cela ne ce fait pas via des interfaces Typescript mais part le biais des schémas Zod, ça offre l'avantage de pouvoir étre interprêté au runtime en plus de pouvoir servir de contrat de type pour Typescript. Par défaut **Duplo** exécute les schémas à chaque renvoi d'une réponse. Cela permet de s'assurer de l'authenticité du type avant de répondre. Il est bien évidement possible de désactiver cette fonctionalitée en environement de production.
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
makeResponseContract(OkHttpResponse, "SuperInfo");

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
);

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
- Il est préférable d'utiliser la fonction `makeResponseContract` pour bien différencier une réponse d'un contrat de sortie.
- Avec la fonction `makeResponseContract`, le schéma donné par défaut au body est `zod.undefined()`.
></div>

## Implémentations d'un contrat

<br>

[\<\< Faire une vérification](../do-check){: .btn .mr-4 }
[Aborder une nouvelle route >\>\>](../how-to-approach-new-road){: .btn .btn-yellow } 