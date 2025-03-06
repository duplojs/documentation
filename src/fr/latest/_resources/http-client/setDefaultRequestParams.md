---
layout: default
parent: Client Http
title: setDefaultRequestParams
nav_order: 1
---

# Méthode `setDefaultRequestParams`
{: .no_toc }

La méthode `setDefaultRequestParams` permet de définir des paramètres par défaut qui seront appliqués à toutes les requêtes effectuées par le client HTTP. Ces paramètres peuvent être surchargés individuellement lors de l'appel des méthodes HTTP.

## Utilisation basique

```typescript
const httpClient = new HttpClient<HttpClientRoute>({
    baseUrl: "https://api.example.com"
});

httpClient.setDefaultRequestParams({
    headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer token"
    },
    credentials: "include"
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Les en-têtes `Content-Type` et `Authorization` seront ajoutés à toutes les requêtes.
- Les credentials seront inclus dans toutes les requêtes.
></div>

## Paramètres disponibles

| Paramètre | Type | Description |
|-----------|------|-------------|
| `credentials` | `"include" | "same-origin" | "omit"` | Gestion des credentials |
| `mode` | `"cors" | "no-cors" | "same-origin" | "navigate"` | Mode CORS |
| `headers` | `Record<string, string>` | En-têtes HTTP par défaut |
| `params` | `Record<string, string>` | Paramètres d'URL par défaut |
| `query` | `Record<string, string>` | Paramètres de requête par défaut |
| `redirect` | `"manual" | "follow" | "error"` | Gestion des redirections |
| `referrer` | `"no-referrer" | "client"` | Referrer |
| `referrerPolicy` | `"no-referrer" | "no-referrer-when-downgrade" | "origin" | "origin-when-cross-origin" | "same-origin" | "strict-origin" | "strict-origin-when-cross-origin" | "unsafe-url"` | Politique de referrer |
| `integrity` | `string` | Intégrité |
| `signal` | `AbortSignal | null` | Signal d'annulation |
| `window` | `any` | Fenêtre |
| `keepalive` | `boolean` | Keepalive |
| `dispatcher` | `Dispatcher | undefined` | Dispatcher |
| `duplex` | `"half" | undefined` | Duplex |

## Exemple complet

Pour montrer un cas d'utilisation complet, voici un exemple de configuration d'un client HTTP avec des paramètres par défaut ainsi que sont utilisation.
Tout d'abord, nous créons une instance du client HTTP et définissons les paramètres par défaut :

```typescript
export const httpClient = new HttpClient<HttpClientRoute>({
 baseUrl: "api.example.com",
});

httpClient.setDefaultRequestParams({
    headers: {
        "Content-Type": "application/json",
        "Accept-Language": "fr-FR"
    },
    mode: "cors",
    query: {
        "version": "1.0"
    }
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
> - L'URL de base de l'API est `api.example.com`.
> - Les en-têtes `Content-Type` et `Accept-Language` seront ajoutés à toutes les requêtes.
> - Le mode CORS est activé.
> - Le paramètre de requête `version` est défini à `1.0`.
> - Les autres paramètres sont laissés à leurs valeurs par défaut.
></div>

Ensuite nous utilisons le client HTTP pour effectuer une requête :

```typescript
// Les paramètres par défaut sont appliqués automatiquement
const response = await httpClient.get(
    "/users/{userId}",
    {
        params: {
            userId: String(1),
        },
    },
).iWantInformation("user.found");

// Les paramètres peuvent être surchargés
const specificResponse = await httpClient.get(
    "/users/{userId}",
    {
        params: {
            userId: String(1),
        },
        headers: {
            "Accept-Language": "en-US", // Surcharge le paramètre par défaut
            "Authorization": "Bearer token" // Ajout d'un nouveau paramètre
        }
    },
).iWantInformation("user.found");
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
> - La première requête utilise les paramètres par défaut définis précédemment.
> - La deuxième requête surcharge le paramètre `Accept-Language` et ajoute un nouvel en-tête `Authorization`.
></div>

```typescript
import {
 HttpClient,
 type TransformCodegenRouteToHttpClientRoute,
} from "@duplojs/http-client";
import { CodegenRoutes } from "../types/duplojsTypesCodegen";

export type HttpClientRoute = TransformCodegenRouteToHttpClientRoute<
 CodegenRoutes
>;

export const httpClient = new HttpClient<HttpClientRoute>({
 baseUrl: "your.server.url",
});

httpClient.setDefaultRequestParams({
    credentials: "include", // include, same-origin, omit
    mode: "cors", // cors, no-cors, same-origin, navigate
    headers: {
        // set your default headers here
        // example:
        // "Content-Type": "application/json",
    },
    params: {
        // set your default query params here
        // example:
        // "api_key": "your_api_key",
    },
    query: {
        // set your default query params here
        // example:
        // "user_id": "your_user_id",
    },
    redirect: "follow", // manual, follow, error
    referrer: "client", // no-referrer, client
    referrerPolicy: "no-referrer-when-downgrade", // no-referrer, no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
    integrity: "",
    signal: null, // (type: AbortSignal | null)
    window: null,
    keepalive: false, // (type: boolean)
    dispatcher: undefined, // (type: Dispatcher | undefined)
    duplex: "half", // half, undefined
});

```

[Méthode request() >>>](../request){: .btn .btn-yellow }