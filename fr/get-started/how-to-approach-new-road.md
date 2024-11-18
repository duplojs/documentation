---
layout: default
parent: Commencer
title: Aborder une nouvelle route
nav_order: 5
---

# Aborder une nouvelle route
{: .no_toc }
Cette parite aborde la méthodologie de travaille a adopter quand vous utilisez **DuploJS**.
Tous les exemples présenté dans ce cours sont disponible en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/how-to-approach-new-road).

1. TOC
{:toc}

## Outils à ma disposition
Pour rappel, dans **DuploJS** une route est constituer d'étape a franchir avand d'éfféctuer une action. Chaque étape est une vérification qui peux mettre fin a l'éxécution de la route en renvoyen une réponse. Les différente étape aborder précédement sont :
- les [`ExtractStep`](../getting-data-from-request) qui permette de d'extraire de la donné de la requéte courante.
- les [`CheckerStep`](../do-check#les-checkers) qui effectute une vérification a partire d'une valeur d'entrés.
- les [`CutStep`](../do-check#les-cuts) qui effectute une vérification directement au saint de la route pour des cas unique.

> La [`HandlerStep`](../first-route#créer-une-route-simple) fait exception car elle doit contenir l'action d'une route, elle sera donc la dernier étape et devra renvoyer une réponse positive.

En plus de jouer un role de **garde**, les étapes enrichie de manier typé le [**floor**](../first-route#le-floor) qui est un accumulateur de donnés.

Pour finir, il éxiste les [**contrat de sorti**](../define-response) qui permette explicitement d'indiqué ce qu'on renvoi. C'est un aspect trés important qui garanti un retoure correct.

## Comment procéder ?
Pour commencer, il vous faut établir un bute. 
A quoi votre route vas t'elle servir :
- a récupéré des info d'un utilisateur ?
- a poster un message dans une conversation ?
- a ajouter un utilisateur a une organization ?
- a créer un utilisateur ?

Aprés avoir établir ce que vous voulez, vous pouvé commencer a déclaré votre route.
Dans l'exemple, le bute choisit est de poster un message dans une conversation entre deux utilisateur.

```ts
import { useBuilder } from "@duplojs/core";

useBuilder()
	.createRoute("POST", "/messages")
	.handler(
		(pickup) => {
			// action pour poster un message.
		},
	);
```

Ensuite créer le zod schema du body qui sera utilisais dans le contrat de sortie pour établire ce que vous aller renvoyer.

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
Quand le body de votre contrat est on object, il est préférable de le déclaré dans un autre fichier. Dans une architecture simple, créer un dossier `src/schemas` et enregister vos schema dans des fichier différent suivant le document qu'il représente.

```ts
import { makeResponseContract, OkHttpResponse, useBuilder } from "@duplojs/core";

useBuilder()
	.createRoute("POST", "/messages")
	.handler(
		(pickup) => {
			// action to post message
			
			return new OkHttpResponse("message.posted", {...});
		},
		makeResponseContract(OkHttpResponse, "message.posted", messageSchema)
	);
```

{: .note }
L'information décris ce sur quoi la route c'est arréter. Ici, si `message.posted` est reçue cela signif que la route c'est arréter aprés avoir poster le message.

<br>

[\<\< Définir une réponse](../define-response){: .btn .mr-4 }
[Routine de vérification >\>\>](../verification-routine){: .btn .btn-yellow } 