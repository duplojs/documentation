---
nav_order: 7
layout: default
title: Client Http
---

# Client Http
{: .no_toc }

`@duplojs/http-client` est une librairie permettant de créer des clients HTTP typés. Elle a été conçue pour être utilisée avec `@duplojs/types-codegen` qui génère les types à partir des routes de votre application DuploJS. Vous pouvez consulter la documentation de `@duplojs/types-codegen` [ici](https://docs.duplojs.dev/fr/latest/resources/generate-types) pour plus d'informations.

1. TOC
{:toc}

## Installation

Pour utiliser `@duplojs/http-client`, vous devez l'installer en tant que dépendance de votre projet.

```bash
npm install @duplojs/http-client
```

## Pourquoi @duplojs/http-client ?

Bien que des librairies comme `fetch` ou `axios` soient largement utilisées pour les requêtes HTTP, `@duplojs/http-client` apporte plusieurs avantages significatifs :

1. **Typage fort entre le front et le back**
   - Génération automatique des types via `@duplojs/types-codegen`
   - Cohérence garantie entre les types côté client et serveur
   - Autocomplétion intelligente des routes et paramètres

2. **Système d'informations typées**
   - Les réponses sont typées en fonction de l'information retournée
   - Le type retourné correspond exactement à ce que vous attendez

En effet, avec `@duplojs/http-client`, vous bénéficier du travail de typage éffectuer en back. Avec cette solution plus besoin de swagger ou de documentation pour connaitre les routes et les types de retour. Vous avez tout en main pour travailler de manière plus efficace.

## Le concept d'information dans les réponses HTTP

Par défaut, HTTP utilise des codes de statut (200, 404, 500, etc.) pour indiquer le résultat d'une requête. Cependant, ces codes sont souvent trop génériques et manquent de contexte. Par exemple, un code 404 peut signifier :
- La route n'existe pas
- La ressource demandée n'existe pas

Pour résoudre ce problème, `@duplojs/http-client` introduit le concept d'**information**. Une information est un identifiant unique envoyé dans les en-têtes HTTP qui permet d'identifier précisément le résultat d'une requête.

```typescript
await httpClient
    .post(
        "/timesheet",
        {
            body: {
                ...
            },
        },
    )
    .whenInformation("timesheet.created", () => {
        // code par rapport à l'information timesheet.created
    })
    .whenInformation("workLocation.notfound", () => {
        // code par rapport à l'information workLocation.notfound
    })
    .whenInformation("workingTime.exceeds13hWithoutBreak", () => {
        // code par rapport à l'information workingTime.exceeds13hWithoutBreak
    })
    .whenInformation("workingTime.exceeds24Hours", () => {
        // code par rapport à l'information workingTime.exceeds24Hours
    });
```

{: .highlight }
> Dans cet exemple, nous utilisons la méthode `whenInformation` pour exécuter du code en fonction de l'information retournée par la requête.
> - Si l'information est `timesheet.created`, le premier callback sera exécuté.
> - Si l'information est `workLocation.notfound`, le deuxième callback sera exécuté.
> - Si l'information est `workingTime.exceeds13hWithoutBreak`, le troisième callback sera exécuté.
> - Si l'information est `workingTime.exceeds24Hours`, le quatrième callback sera exécuté.

{: .note }
> Les informations sont définies par le serveur et peuvent être utilisées pour transmettre des messages d'erreur, des messages de succès, des messages d'avertissement, etc.
> Cela évite d'avoir à analyser le corps de la réponse pour déterminer le résultat de la requête.

## Création de l'instance du client HTTP

Pour créer une nouvelle instance du client HTTP, utilisez la classe `HttxpClient`.
Celle-ci accepte un objet de configuration avec les propriétés suivantes :

| Propriété | Type | Valeur par défaut | Description |
|-----------|-----------|-----------|-------------|
| `baseUrl` | `string` | - | URL de base de l'API |
| `keyToInformation` | `string` | `information` | clé qui désigne l'info dans le header |


```typescript
import { HttpClient, type TransformCodegenRouteToHttpClientRoute } from '@duplojs';
import { CodegenRoutes } from "./types/routes";

type HttpClientRoute = TransformCodegenRouteToHttpClientRoute<CodegenRoutes>;

const httpClient = new HttpClient<HttpClientRoute>({
    baseUrl: "your-base-url", // Obligatoire
    keyToInformation: "your-key-to-information" // Optionnel
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
> - `CodegenRoutes` est le type généré par `@duplojs/types-codegen` à partir des routes de votre application DuploJS.
> - Le type `TransformCodegenRouteToHttpClientRoute` est une fonction générique qui transforme le type `CodegenRoutes` en un type utilisable par `HttpClient`.
> - `HttpClientRoute` est le type utilisable par `HttpClient` après transformation.
> - `baseUrl` est l'URL de base de l'API.
> - `keyToInformation` permet de redéfinir la clé qui désigne l'information dans les en-têtes HTTP.
></div>

{: .note }
> L'utilisation du typage généré par `@duplojs/types-codegen` permet de bénéficier de :
> - L'autocomplétion des routes
> - La vérification des types pour les paramètres de requête
> - La validation des réponses à la compilation

## Méthodes de l'instance du client HTTP

Une fois l'instance du client HTTP créée, vous pouvez utiliser les méthodes suivantes :

| Méthode | Description | Documentation détaillée |
|---------|-------------|------------------------|
| `setDefaultRequestParams` | Définit les paramètres par défaut pour toutes les requêtes | [En savoir plus](../setDefaultRequestParams) |
| `setInterceptor` | Configure les intercepteurs de requêtes ou de réponses | [En savoir plus](../interceptors) |
| `request` | Effectue une requête HTTP | [En savoir plus](../request) |
| `get` | Effectue une requête HTTP GET | [En savoir plus](../get) |
| `post` | Effectue une requête HTTP POST | [En savoir plus](../post) |
| `put` | Effectue une requête HTTP PUT | [En savoir plus](../put) |
| `patch` | Effectue une requête HTTP PATCH | [En savoir plus](../patch) |
| `delete` | Effectue une requête HTTP DELETE | [En savoir plus](../delete) |

## Clés de l'instance du client HTTP

L'instance du client HTTP expose plusieurs clés permettant d'accéder à ses propriétés internes :

| Clé | Type | Description | Documentation détaillée |
|-----|------|-------------|------------------------|
| `baseUrl` | `string` | URL de base définie lors de l'initialisation | - |
| `defaultParams` | `DefaultRequest` | Paramètres par défaut appliqués à toutes les requêtes | [En savoir plus](../default-params) |
| `interceptor` | `Interceptor` | Intercepteurs configurés sous forme de callbacks pour modifier les requêtes/réponses | [En savoir plus](../interceptors) |
| `hooks` | `Hooks` | Système de hooks post-requête | [En savoir plus](../hooks) |

// TODO: créer un repertoire pour chaque clé et chaque méthode et y décrire sont fonctionnement avec sont typage et un maximum d'exemple pour illustrer le propos
// TODO: Mettre et avant et expliquer la force du typage généré par @duplojs/types-codegen et montrer tout les types qui permet de recuperer les informations de la requête et de la réponse
// TODO: proposer un mini projet duplo/vue pour montrer comment utiliser le client http dans un vrai projet

// info (ajouter un mini router en fin de page pour redirriger le methode en methodes comme docusaurus)
