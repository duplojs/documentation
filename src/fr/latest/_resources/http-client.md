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

## Exemple minimal

```typescript
import { HttpClient } from '@duplojs/http-client';

const httpClient = new HttpClient({
    baseUrl: "/"
});

const promiseRequest = httpClient
    .get(
        "/users/{userId}",
        {
            params: {
                userId: "mySuperUserId",
            },
        },
    )

promiseRequest
    .whenResponseSuccess((response) => {
        console.log(response)
    })
    .whenError((error) => {
        console.error(error)
    });

const response = await promiseRequest

const successResponse = await promiseRequest.iWantResponseSuccess();
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
> - Un client http a été créé avec la baseUrl `/`.
> - Nous utilisons la méthode `get` du client http pour effectuer une requête HTTP GET, cette méthode renvois un `Promise`.
> - La requête est faite sur le path `/users/{userId}`, la valeur `{userId}` du path sera remplacée par la valeur définit dans `params.userId`.
> - La méthode `whenResponseSuccess` de `PromiseRequest` est utilisée pour définir un callback qui sera executé dans le cas où la requête porte un code `200`.
> - La méthode `whenError` de `PromiseRequest` est utilisée pour définir un callback qui sera executé en cas de d'échec de la requête.
> - La `PromiseRequest` est `await` pour obtenir la réponse.
> - La méthode `iWantResponseSuccess` de `PromiseRequest` renvois un `Promise` qui réussis uniquement si la requête porte un code `200`.
></div>

## Pourquoi @duplojs/http-client ?

Bien que des librairies comme `fetch` ou `axios` soient largement utilisées pour les requêtes HTTP, `@duplojs/http-client` apporte plusieurs avantages significatifs :

1. **Support des réponses avec information.**
2. **Systéme de hook complet.**
3. **Typage bout en bout possible**

## Création de l'instance du client HTTP

Pour créer une nouvelle instance du client HTTP, utilisez la classe `HttpClient`.
Celle-ci accepte un objet de configuration avec les propriétés suivantes :

```ts
import { HttpClient } from '@duplojs/http-client';

const httpClient = new HttpClient({
    baseUrl: "https://google.com/base/url",
    keyToInformation: "my-info" 
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
> - Un objet `HttpClient` a été instancié.
> - Le lien de l'API qui sera utilisé pour faire des requête est `https://google.com/base/url`.
> - La clef à laquelle sera rattachée l'information dans les headers est `my-info`.
></div>

| Propriété | Type | Valeur par défaut | Description |
|-----------|-----------|-----------|-------------|
| `baseUrl` | `string` | - | URL de base de l'API |
| `keyToInformation` | `string` | `information` | clé qui désigne l'info dans le header |

## Le concept d'information dans les réponses HTTP

Par défaut, HTTP utilise des codes de statut (200, 404, 500, etc.) pour indiquer le résultat d'une requête. Cependant, ces codes sont souvent trop génériques et manquent de contexte. Par exemple, un code 404 peut signifier :
- La route n'existe pas
- La ressource demandée n'existe pas

Pour résoudre ce problème, `@duplojs/http-client` introduit le concept d'**information**. Une information est un identifiant unique envoyé dans les en-têtes HTTP qui permet d'identifier précisément le résultat d'une requête.

```ts
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

## Requêtes POST

Pour effectuer une requête POST, utilisez la méthode `post` qui est disponible sur l'instance du client HTTP.

```ts
httpClient
    .post(
        "/products", 
        {
            body: {
                name: "shoes",
                price: 100
            }
        }
    )
    .whenResponseSuccess(() => {
        console.log("Product created");
    })
    .whenError(() => {
        console.log("Product not created");
    });
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
> - Nous utilisons la méthode `post` pour effectuer une requête HTTP POST.
> - La route `/products` est utilisée pour créer un nouveau produit.
> - Les données du produit sont définies dans l'objet `body`.
> - La méthode `whenResponseSuccess` est utilisée pour exécuter du code en cas de succès.
> - La méthode `whenError` est utilisée pour exécuter du code en cas d'erreur.
></div>

{: .note }
> La fonctionnement des méthodes `put`, `patch` et `delete` est similaire à celle de la méthode `post`.

## Méthodes de l'instance du client HTTP

Une fois l'instance du client HTTP créée, vous pouvez utiliser les méthodes suivantes :

| Méthode | Description |
|---------|-------------|
| `setDefaultRequestParams` | Définit les paramètres par défaut pour toutes les requêtes |
| `setInterceptor` | Configure les intercepteurs de requêtes ou de réponses |
| `request` | Effectue une requête HTTP |
| `get` | Effectue une requête HTTP GET |
| `post` | Effectue une requête HTTP POST |
| `put` | Effectue une requête HTTP PUT |
| `patch` | Effectue une requête HTTP PATCH |
| `delete` | Effectue une requête HTTP DELETE |

## Paramètres par défaut de la requête

La méthode `setDefaultRequestParams` permet de définir des paramètres par défaut qui seront appliqués à toutes les requêtes effectuées par le client HTTP. Ces paramètres peuvent être surchargés individuellement lors de l'appel des méthodes HTTP.

### Utilisation basique
{: .no_toc }

```ts
const httpClient = new HttpClient({
    baseUrl: "https://api.example.com"
});

httpClient.setDefaultRequestParams({
    headers: {
        "Content-Type": "application/json",
        get Authorization() {
            return `Bearer ${localStorage.getItem("token")}`;
        }
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

### Paramètres disponibles
{: .no_toc }

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

### Exemple complet
{: .no_toc }

Pour montrer un cas d'utilisation complet, voici un exemple de configuration d'un client HTTP avec des paramètres par défaut ainsi que sont utilisation.
Tout d'abord, nous créons une instance du client HTTP et définissons les paramètres par défaut :

```ts
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

```ts
// Les paramètres par défaut sont appliqués automatiquement
const response = await httpClient
    .get(
        "/users/{userId}",
        {
            params: {
                userId: "1",
            },
        },
    )
    .iWantInformation("user.found");

// Les paramètres peuvent être surchargés
const specificResponse = await httpClient
    .get(
        "/users/{userId}",
        {
            params: {
                userId: "1",
            },
            headers: {
                "Accept-Language": "en-US", // Surcharge le paramètre par défaut
                "Authorization": "Bearer token" // Ajout d'un nouveau paramètre
            }
        },
    )
    .iWantInformation("user.found");
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
> - La première requête utilise les paramètres par défaut définis précédemment.
> - La deuxième requête surcharge le paramètre `Accept-Language` et ajoute un nouvel en-tête `Authorization`.
></div>

```ts
import { HttpClient } from "@duplojs/http-client";

export const httpClient = new HttpClient({
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

## Intercepteurs

Les intercepteurs permettent d'intercepter et de modifier les requêtes avant leur envoi ou les réponses avant leur traitement. Cette fonctionnalité est particulièrement utile pour :
- Ajouter des en-têtes d'authentification dynamiques
- Effectuer des transformations de données
- Logger les requêtes/réponses
- Gérer les erreurs de manière centralisée

### Exemple d'utilisation
{: .no_toc }

```ts
// Intercepteur de requête
httpClient.setInterceptor("request", async (request) => {
    // Ajout d'un token d'authentification
    if (request.headers) {
        request.headers["Authorization"] = `Bearer ${await getToken()}`;
    }
    return request;
});

// Intercepteur de réponse
httpClient.setInterceptor("response", async (response) => {
    // Gestion centralisée des erreurs
    if (response.code === 401) {
        await refreshToken();
        // Relancer la requête...
    }
    return response;
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
> - L'intercepteur de requête ajoute un token d'authentification à chaque requête
> - L'intercepteur de réponse gère le rafraîchissement du token en cas d'expiration
></div>

### Types d'intercepteurs
{: .no_toc }

| Type | Signature | Description |
|------|-----------|-------------|
| `request` | `(request: RequestDefinition) => Promise<RequestDefinition>` | Modifie la requête avant son envoi |
| `response` | `(response: Response) => Promise<Response>` | Transforme la réponse avant son traitement |

### Cas d'utilisation courants
{: .no_toc }

#### Authentification dynamique
{: .no_toc }

```ts
httpClient.setInterceptor("request", async (request) => {
    const token = await getToken();
    if (request.headers) {
        request.headers["Authorization"] = `Bearer ${token}`;
    }
    return request;
});

```

#### Logging des requêtes
{: .no_toc }

```ts
httpClient.setInterceptor("request", (request) => {
    console.log(`[${new Date().toISOString()}] ${request.method} ${request.path}`);
    return request;
});
```

#### Transformation du corp des réponses
{: .no_toc }

```ts
httpClient.setInterceptor("response", async (response) => {
    if (response.body) {
        response.body = {
            ...response.body,
            timestamp: new Date().toISOString(),
        }
    };
    return response;
});
```

#### Gestion globale des erreurs
{: .no_toc }

```ts
httpClient.setInterceptor("response", async (response) => {
    if (!response.ok) {
        switch (response.code) {
            case 401:
                await refreshToken();
                break;
            case 403:
                redirectToLogin();
                break;
            default:
                // Ne rien faire pour laisser le traitement de l'erreur à la route
                break;
        }
    }
    return response;
});
```

## Hooks

Les hooks permettent d'exécuter du code en fonction de certaines conditions sur les réponses HTTP. Contrairement aux intercepteurs qui modifient les requêtes/réponses, les hooks sont purement réactifs et ne peuvent pas modifier les réponses.

### Types de hooks disponibles
{: .no_toc }

| Type | Description |
|------|-------------|
| `code` | Se déclenche sur un code HTTP spécifique |
| `general` | Se déclenche sur une plage de codes HTTP (200-299, 400-499, 500-599) |
| `error` | Se déclenche quand `response.ok` est `false` |
| `information` | Se déclenche sur une information spécifique |

### Exemples d'utilisation des hooks
{: .no_toc }

#### Hook sur un code HTTP spécifique
{: .no_toc }

```ts
httpClient.hooks.add({
    type: "code",
    value: 401,
    callback: async (response) => {
        await refreshToken();
    }
});
```

#### Hook sur une plage de codes HTTP
{: .no_toc }

```ts
httpClient.hooks.add({
    type: "general",
    value: 200, // Se déclenche pour tous les codes 2XX
    callback: async (response) => {
        console.log("Requête réussie:", response);
    }
});
```

#### Hook sur les erreurs
{: .no_toc }

```ts
httpClient.hooks.add({
    type: "error",
    callback: async (response) => {
        console.error("Une erreur est survenue:", response);
        notifyError(response);
    }
});
```

#### Hook sur une information spécifique
{: .no_toc }

```ts
httpClient.hooks.add({
    type: "information",
    value: "user.found",
    callback: async (response) => {
        updateUserCache(response.body);
    }
});
```
{: .no_toc }

{: .highlight }
>Points importants :
><div markdown="block">
> - Les hooks sont exécutés après le traitement de la réponse
> - Plusieurs hooks peuvent être définis pour le même type/valeur
> - Les hooks ne peuvent pas modifier la réponse
> - Les hooks sont exécutés de manière asynchrone
></div>

### Cas d'utilisation courants des hooks
{: .no_toc }

1. **Notification utilisateur**

```ts
// Afficher une notification pour chaque erreur
httpClient.hooks.add({
    type: "error",
    callback: (response) => {
        showToast({
            type: "error",
            message: "Une erreur est survenue"
        });
    }
});

// Afficher un message de succès spécifique
httpClient.hooks.add({
    type: "information",
    value: "user.created",
    callback: () => {
        showToast({
            type: "success",
            message: "Utilisateur créé avec succès"
        });
    }
});
```

1. **Rafraîchissement automatique**

```ts
// Actualiser la liste des utilisateurs
httpClient.hooks.add({
    type: "information",
    value: "user.updated",
    callback: () => {
        refreshUserList();
    }
});
```

1. **Redirection**

```ts
// Rediriger vers la page de connexion
httpClient.hooks.add({
    type: "code",
    value: 401,
    callback: () => {
        router.push("/login");
    }
});
```

{: .note }
> Ces exemples illustrent des cas d'utilisation simples mais fréquents dans une application web moderne.

// TODO: proposer un mini projet duplo/vue pour montrer comment utiliser le client http dans un vrai projet
