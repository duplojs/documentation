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

Pour ilustré la méthodologie, le bute choisit sera d'envoyer un message a utilisateur.

Aprés avoir établir ce que nous voulons, nous pouvons commencé pars définir le document que notre route renvera. Cela  nous permetera de mettre en place le contrat de sorti.

{% highlight ts mark_lines="1 2 3 4 5 6 7 8" %}
import { zod } from "@duplojs/core";

export const messageSchema = zod.object({
	senderId: zod.number(),
	receiverId: zod.number(),
	content: zod.string(),
	postedAt: zod.date(),
});
{% endhighlight %}

{: .note }
Quand le body de votre contrat est on object, il est préférable de le déclaré dans un autre fichier. Dans une architecture simple, créer un dossier `src/schemas` et enregister vos schema dans des fichier différent suivant le document qu'il représente.


Ensuite nous pouvont commencer a déclaré notre route. Nous utiliserons la méthode `POST` et le chemain `/users/{receiverId}/messages` car c'est un envois de donnés dans les messages d'un utilisateur.

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
L'information décris ce sur quoi la route c'est arréter. Ici, si `message.posted` est reçue cela signif que la route c'est arréter aprés avoir poster le message.

Dans notre cas, pour envoyer un message nous voulons étre sur que l'utilisateur qui le reçois éxiste avant de stocker son message. Ici il sera nomé `receiver` et son `id` est présent dans les paramétre du path (`/users/{receiverId}/messages`) de notre route. La prochainbe étape sera donc de l'extraire, afain d'avoir le `receiverId` indéxé dans le floor.

```ts
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
```

{: .note }
Les paramétes de path sont toujours des `string`. C'est pour cela qu'on utilise le `coerce` de zod pour le convertir en `number`.

Ensuite, pour vérifier que notre receveur éxiste. Nous allez utilisé le checker `userExist` provenant de cette [exmple](../do-check#création-dun-checker) et en faire un preset Checker.

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

Une fois devenu un preset checker, son implémentation sera bq plus explicite et rapide.

```ts
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
```

Pour obtenir le contenue du message il nous faut égalment l'extraire.

```ts
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
		}).strip(),
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
```

{: .note }
Il est totalment possible d'utilisais la premiere `ExtractStep` pour obtenir le body. Mais imaginon que pars soucie de performace, nous ne voulont pas extraiter le contenu du body avant.

Mais noubliont pas, si qu'elle qu'un reçoi un message c'est que qu'elle qu'un la envoyer. C'est moi en temp qu'utilisateur qui est appeler la route pour poster un message dans la pile d'un autre utilisateur. Pour cela, imaginon que notre `userId` (ou `senderId`) sois stoker dans un header `userId`. habituelment il aurait du s'obtenire a traver token qu'il aurait fallu validé en amond mais pour notre exemple, ont vas faire simple.

```ts
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
		}).strip(),
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
```

<br>

[\<\< Définir une réponse](../define-response){: .btn .mr-4 }
[Routine de vérification >\>\>](../verification-routine){: .btn .btn-yellow } 