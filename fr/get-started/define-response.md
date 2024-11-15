---
layout: default
parent: Commencer
title: Définir une réponse
nav_order: 4
---

# Définir une réponse
Dans **Duplo** il est possiblde définier des réponse afain de créer des contrat de sorti pour les route. Cela ne ce fait pas via des interface typescripte mais pars le bier des schema zod, ça offre l'avantage de pourvoir étre interpréter au runtime en plus de pouvoir servire de contrat de type pour typescript. Par défaut **Duplo** éxécute les schema a chaque renvois d'une réponse. Cela permet de s'assuré de l'autenticité du type avand de répondre. Il est bien évidement possible de désactiver cette fonctionaliter en environement de production.
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/define-response).

## Les contrats de sortie
Un contrat de sorti est un objet réponse avec comme body un schema zod. Les contrat s'applique uniquement pour 3 propriéter, le `code`, l'`information` et le `body`. Un contrat peut étre un objet réponse ou un tableau d'objet réponse. La fonction `makeResponseContract` optimise les contrats dans le cas d'un code et body similaire mais a information diférente.

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
	new ForbiddenHttpResponse("token.invalide", zod.undefined()),
];
// same as
makeResponseContract(ForbiddenHttpResponse, ["token.expire", "token.invalide"]);
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Plusieur contrat de sorti on étais créer. On les reconnai car le body de ces objet réponse on étais défini sur des schema zod.
- Il est préférable d'uitilisé la fonction `makeResponseContract` pour bien différencier une réponse d'un contrat de sortie.
- Avec la fonction `makeResponseContract`, le schema donner par défaut au body est `zod.undefined()`.
></div>

## Implémentations d'un contrat

<br>

[\<\< Faire une vérification](../do-check){: .btn .mr-4 }
[Définir une réponse >\>\>](../how-to-approach-new-road){: .btn .btn-yellow } 