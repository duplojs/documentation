---
nav_order: 5
layout: default
title: Les Hooks
---

# Les Hooks
{: .no_toc }

Dans cette section, nou allons découvrir les hooks de Duplo, leur utilité et comment les utiliser pour étendre les fonctionnalités de votre application.
Tous les exemples présentés dans cette section sont disponibles en entier [ici](https://github.com/dupljs/examples/tree/1.x/resources/hooks).

1. TOC
{:toc}

## Exemple minimal

```typescript
import { Duplo } from "@duplojs/core";

const duplo = new Duplo({
    environment: "DEV",
});

duplo.hook(
    "onError", 
    (request, error) => {
        console.error(`${request.method} ${request.path} - Error:`, error);
    }
);
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
> - À travers l'instance `Duplo`, nous avons enregistré un hook `onError`.
> - Ce hook est déclenché à chaque fois qu'une erreur se produit dans une route.
> - Il affiche dans la console le message d'erreur associé à la requête.
></div>

## Qu'est-ce qu'un hook ?

Un **hook** est un mécanisme qui permet d'intercepter et de réagir à des événements spécifiques dans l'application. Il s'agit d'une fonction qui est appelée automatiquement par Duplo lorsqu'un événement particulier se produit, comme une requête HTTP, une erreur ou la fin du traitement d'une requête. Dans Duplo, on distingue deux catégories de hooks :
- **Hooks de route** : Ils sont liés aux requêtes HTTP et permettent d'effectuer des actions avant ou après le traitement d'une requête.
- **Hooks de serveur** : Ils sont liés au cycle de vie du serveur et permettent d'effectuer des actions lors de son initialisation.

## Comment utiliser les hooks

Pour utiliser les hooks dans Duplo, vous devez d'abord créer une instance `Duplo`. Ensuite, vous pouvez enregistrer des hooks en utilisant la méthode `hook` de l'instance. Cette méthode prend deux arguments :
1. Le nom du hook (par exemple, `onRequest`, `onError`, etc.)
2. La fonction de rappel (callback) qui sera exécutée lorsque le hook est déclenché.

## Cas d'utilisation des hooks

Les hooks sont particulièrement utiles pour étendre les fonctionnalités de votre application, par exemple :
- **Gestion des erreurs** : Vous pouvez enregistrer un hook pour capturer les erreurs et les enregistrer dans un fichier de log ou les afficher dans la console.
- **Modification des requêtes** : Vous pouvez utiliser un hook pour modifier les en-têtes de la requête ou le corps de la requête avant qu'elle ne soit traitée par une route.
- **Modification des réponses** : Vous pouvez utiliser un hook pour modifier les en-têtes de réponse ou le corps de la réponse avant qu'elle ne soit envoyée au client.

Les hooks permettent également de créer des plugins réutilisables qui peuvent être partagés entre différentes applications Duplo. Par exemple, vous pouvez créer un plugin pour gérer les en-têtes CORS.

### Exemple d'utilisation dans la réalisation d'un plugin CORS

```typescript
import { type Duplo, OkHttpResponse } from "@duplojs/core";

export function cors(allowOrigin: string) {
	return function(instance: Duplo) {
		instance.hook(
			"beforeSend",
			(_request, response) => {
				response.setHeader(
					"Access-Control-Allow-Origin",
					allowOrigin,
				);
				response.setHeader(
					"Access-Control-Expose-Headers",
					instance.config.keyToInformationInHeaders,
				);
			},
		);
		instance.hook(
			"beforeRouteExecution",
			(request) => {
				if (request.method === "OPTIONS" && request.matchedPath === null) {
					return new OkHttpResponse("cors").setHeader("Access-Control-Allow-Headers", "*");
				}
			},
		);
	};
}
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
> - Un plugin CORS est créé en utilisant un hook `beforeSend` pour ajouter les en-têtes CORS à la réponse.
> - Un hook `beforeRouteExecution` est utilisé pour gérer les requêtes `OPTIONS` et renvoyer une réponse appropriée si la route n'est pas trouvée.
></div>

## Types de hooks

### Hooks de route

| Nom du hook | Description |
| --- | --- |
| `beforeRouteExecution` | Appelé avant l'exécution d'une route. |
| `parsingBody` | Appelé avant l'analyse du corps de la requête. |
| `onError` | Appelé lorsqu'une erreur se produit lors du traitement d'une requête. |
| `beforeSend` | Appelé avant l'envoi de la réponse. |
| `serializeBody` | Appelé avant la sérialisation du corps de la réponse. |
| `afterSend` | Appelé après l'envoi de la réponse. |

### Hooks de serveur

| Nom du hook | Description |
| --- | --- |
| `onStart` | Appelé lorsque le serveur démarre. |
| `onHttpServerError` | Appelé lorsqu'une erreur se produit au niveau du serveur HTTP. |
| `onRegistered` | Appelé lorsqu'une route est enregistrée. |
| `beforeBuildRouter` | Appelé avant la construction du routeur. |