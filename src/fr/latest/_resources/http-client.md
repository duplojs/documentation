---
nav_order: 7
layout: default
title: Client Http
---

# Client Http
{: .no_toc }

`@duplojs/http-client` est une librairie permettant de créer des clients HTTP typés. Elle a été conçue pour être utilisée avec `@duplojs/types-codegen` qui génère les types à partir des routes de votre application DuploJS. Vous pouvez consulter la documentation de `@duplojs/types-codegen` [ici](https://docs.duplojs.dev/fr/latest/resources/generate-types/) pour plus d'informations.

1. TOC
{:toc}

## Installation

Pour utiliser `@duplojs/http-client`, vous devez l'installer en tant que dépendance de votre projet.

```bash
npm install @duplojs/http-client
```

## Creation de l'intance du client HTTP

Pour créer une nouvelle instance du client HTTP, utilisez la classe `HttpClient`.
Celle-ci accepte un objet de configuration avec les propriétés suivantes :

| Propriété | Type | Valeur par défaut | Description |
|-----------|-----------|-----------|-------------|
| `baseUrl` | `string` | - | URL de base de l'API |
| `keyToInformation` | `string` | - | jsp xD |

Le client HTTP peut être utilisé de deux manières :
- Sans typage (utilisation basique)
- Avec le typage généré par `@duplojs/types-codegen` (recommandé)

### 1. Création sans typage
{: .no_toc }

| Type | Définition |
|------|------------|
| `HttpClient` | instance du client HTTP |

```typescript
import { HttpClient } from '@duplojs/http-client';

const httpClient = new HttpClient({
    baseUrl: 'your-base-url', // Obligatoire
});
```

### 2. Création avec typage généré
{: .no_toc }

| Type | Définition |
|------|------------|
| `HttpClientRoute<TransformCodegenRouteToHttpClientRoute<CodegenRoutes>` | instance du client HTTP avec les routes typées |

```typescript
import { HttpClient, type TransformCodegenRouteToHttpClientRoute, } from '@duplojs/http-client';
import { CodegenRoutes } from "your/path/to/types";

export type HttpClientRoute = TransformCodegenRouteToHttpClientRoute<
    CodegenRoutes
>;

const httpClient = new HttpClient<HttpClientRoute>({
    baseUrl: 'your-base-url', // Obligatoire
});
```

{: .note }
>L'utilisation du typage généré par `@duplojs/types-codegen` est fortement recommandée car elle permet de bénéficier de :
> - L'autocomplétion des routes
> - La vérification des types pour les paramètres de requête
> - La validation des réponses à la compilation

## Méthodes de l'instance du client HTTP

Une fois l'instance du client HTTP créée, vous pouvez utiliser les méthodes suivantes :

| Méthode | Description | Documentation détaillée |
|---------|-------------|------------------------|
| `setDefaultRequestParams` | Définit les paramètres par défaut pour toutes les requêtes | [En savoir plus](./http-client/default-params) |
| `setInterceptor` | Configure les intercepteurs de requêtes ou de réponses | [En savoir plus](./http-client/interceptors) |
| `request` | Effectue une requête HTTP | [En savoir plus](./http-client/request) |
| `get` | Effectue une requête HTTP GET | [En savoir plus](./http-client/get) |
| `post` | Effectue une requête HTTP POST | [En savoir plus](./http-client/post) |
| `put` | Effectue une requête HTTP PUT | [En savoir plus](./http-client/put) |
| `patch` | Effectue une requête HTTP PATCH | [En savoir plus](./http-client/patch) |
| `delete` | Effectue une requête HTTP DELETE | [En savoir plus](./http-client/delete) |

## Clés de l'instance du client HTTP

L'instance du client HTTP expose plusieurs clés permettant d'accéder à ses propriétés internes :

| Clé | Type | Description | Documentation détaillée |
|-----|------|-------------|------------------------|
| `baseUrl` | `string` | URL de base définie lors de l'initialisation | [En savoir plus](./http-client/base-url) |
| `defaultParams` | `DefaultRequest` | Paramètres par défaut appliqués à toutes les requêtes | [En savoir plus](./http-client/default-params) |
| `interceptor` | `Interceptor` | Intercepteurs configurés sous forme de callbacks pour modifier les requêtes/réponses | [En savoir plus](./http-client/interceptors) |
| `hooks` | `Hooks` | Système de hooks post-requête | [En savoir plus](./http-client/hooks) |

// TODO: créer un repertoire pour chaque clé et chaque méthode et y décrire sont fonctionnement avec sont typage et un maximum d'exemple pour illustrer le propos
// TODO: Mettre et avant et expliquer la force du typage généré par @duplojs/types-codegen et montrer tout les types qui permet de recuperer les informations de la requête et de la réponse
// TODO: proposer un mini projet duplo/vue pour montrer comment utiliser le client http dans un vrai projet

// info (ajouter un mini router en fin de page pour redirriger le methode en methodes comme docusaurus)
