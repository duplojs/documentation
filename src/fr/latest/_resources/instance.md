---
nav_order: 1
layout: default
title: Instance Duplo
---

# Instance Duplo
{: .no_toc }

Dans cette section, nous allons découvrir comment créer une instance Duplo, comprendre son utilité et explorer ses différents paramètres.
Tous les exemples présentés dans cette section sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/1.x/resources/config).

1. TOC
{:toc}

## Créer une instance Duplo

Pour créer une instance **Duplo**, il faut :
1. Importer la class `Duplo` depuis `@duplojs/core`
2. L'instancier avec au minimum le paramètre `environment`

{: .note }
> Des librairies tierces (comme `@duplojs/node`) peuvent ajouter d'autres paramètres obligatoires.

```ts
import { Duplo } from "@duplojs/core";

const duplo = new Duplo({
    environment: "DEV",
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Une instance `Duplo` a été créée.
- La valeur de `environment` a été défini sur `"DEV"`.
></div>

## À quoi sert l'instance Duplo

L'instance `Duplo` est le point central de la librairie. Elle fonctionne sur un principe d'enregistrement : bien que la déclaration des routes soit indépendante, celles-ci doivent être enregistrées dans l'instance pour être utilisables. Cette architecture permet d'éviter les dépendances descendantes et les problèmes d'importation circulaire.

L'instance seule a des fonctionnalités limitées. Ce sont les plugins tiers qui lui permettent d'étendre ses capacités, comme par exemple la gestion d'un serveur web.

Cette architecture basée sur des librairies tierces permet à **Duplo** d'être indépendant de la plateforme d'exécution. Ainsi, le choix entre **NodeJS**, **Bun** ou **Deno** devient flexible.

```ts
import "@duplojs/node";
import { Duplo, useProcessBuilder, useRouteBuilder } from "@duplojs/core";

const duplo = new Duplo({
    environment: "DEV",
    port: 1506,
    host: "localhost",
});

duplo.register(...useProcessBuilder.getAllCreatedProcess());
duplo.register(...useRouteBuilder.getAllCreatedRoute());

await duplo.launch();
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La librairie de portage `@duplojs/node` est utilisée pour que l'instance puisse gérer des serveurs web sur **NodeJS**.
- Les propriétés `port` et `host` ont été ajoutées par la librairie de portage `@duplojs/node`.
- Les **processes** et les **routes** déclarés sont tous enregistrés dans une instance `Duplo`.
- Un serveur web est lancé grâce à la méthode `launch` qui a été ajoutée par la librairie de portage `@duplojs/node`.
></div>

## Configuration

Pour instancier un objet `Duplo`, il faut passer en argument un objet qui définit les paramètres de l'instance.

### DuploConfig
{: .no_toc }

| Propriété | Type | Valeur par défaut | Définition |
|-----------|------|-------------------|------------|
| environment | `"DEV" | "PROD" | "TEST"` | requis | Définit l'environnement dans lequel se lance l'instance. |
| disabledRuntimeEndPointCheck | `boolean` | `false` | Désactive l'exécution des contrats de sortie. |
| disabledZodAccelerator | `boolean` | `false` | Désactive l'optimisation des schémas zod par [@duplojs/zod-accelerator](https://github.com/duplojs/zod-accelerator). |
| keyToInformationInHeaders | `string` | `"information"` | Définit la clé de l'**information** dans les headers. |
| plugins | [`DuploPlugins`](#duploconfig)`[]` | `[]` | Tableau qui contient les plugins que va utiliser l'instance. |
| bodySizeLimit | `number | `[`BytesInString`](#bytesinstring) | `"50mb"` | La taille maximale du body qu'il est possible d'accepter. |
| receiveFormDataOptions | [`RecieveFormDataOptions`](#recieveformdataoptions) | `{ uploadDirectory: "upload", prefixTempName: "tmp-", strict: false }` | Permet de définir les options par défaut de la réception des form data. |
| prefix | `string | string[]` | `[]` | Définit un ou plusieurs préfixes sur chacune des routes enregistrées. |
| keepDescriptions | `boolean` | `false` | Indique qu'il faut garder les descriptions après le lancement. |

### DuploPlugins
{: .no_toc }

| Type | Définition |
|------|------------|
| `(instance: Duplo) => void;` | Les plugins sont des fonctions qui sont appelées lors de l'instanciation. |

```ts
import { Duplo } from "@duplojs/core";

interface MyPluginOptions {
    disabledOptimization?: boolean;
}

function myPlugin(options?: MyPluginOptions) {
    return (instance: Duplo) => {
        if (options?.disabledOptimization) {
            instance.config.disabledZodAccelerator = true;
        }
    };
}

const duplo = new Duplo({
    environment: "DEV",
    plugins: [myPlugin({ disabledOptimization: true })],
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La fonction `myPlugin` crée un plugin en currying (propagation fonctionnelle).
- `myPlugin` est implémenté dans l'instance.
></div>

### BytesInString
{: .no_toc }

| Type | Définition |
|------|------------|
| `` `${number}b` | `${number}kb` | `${number}mb` | `${number}gb` | `${number}tb` | `${number}pb` `` | Ce type représente une quantité de bytes. |

### ReceiveFormDataOptions
{: .no_toc }

| Propriété | Type | Valeur par défaut | Définition |
|-----------|------|-------------------|------------|
| uploadDirectory | `string` | `"upload"` | Définit le dossier par défaut qui sera utilisé pour l'upload des fichiers de FormData. |
| prefixTempName | `string` | `"tmp-"` | Définit un préfixe par défaut qui sera donné aux fichiers uploadés. |
| strict | `boolean` | `false` | Définit la propriété strict par défaut. |

## Hooks de l'instance

**Duplo** possède un système de hooks qui permet d'influencer le comportement des routes ou de l'instance. Les hooks sont des fonctions callback qui seront appelées à des moments précis.

```ts
import { Duplo } from "@duplojs/core";

const duplo = new Duplo({
    environment: "DEV",
});

duplo.hook("beforeRouteExecution", (request) => {
    console.log(request.method, request.path);
});

duplo.hook("onError", (request, error) => {
    console.log("Error !");
});

duplo.hook("onStart", (instance) => {
    console.log("Server is Ready !");
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Un hook `beforeRouteExecution` a été ajouté à l'instance.
- Un hook `onError` a été ajouté à l'instance.
- Un hook `onStart` a été ajouté à l'instance.
></div>

## Gestion d'une route introuvable

Géstion d'une route introuvable ce fait directement sur l'instance. Vous pouvez utiliser la méthode de l'instance `setNotfoundHandler` pour modifier la réponse.

```ts
import { Duplo } from "@duplojs/core";

const duplo = new Duplo({
    environment: "DEV",
});

duplo.setNotfoundHandler((request) => new NotFoundHttpResponse("not_found"));
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La gestion d'une route introuvable a été définie avec la méthode `setNotfoundHandler` de l'instance.
- Lorsqu'une route sera introuvable, une `NotFoundHttpResponse` sera envoyée avec l'information `"not_found"`.
></div>

## Géstion par défaut des erreurs d'extraction

Si une erreur survient lors d'une `ExtractStep`, celle-ci coupe l'exécution de la route et renvoie une réponse. La méthode `setExtractError` de l'instance permet de définir la réponse par défaut qui sera renvoyée.

```ts
import { Duplo } from "@duplojs/core";

const duplo = new Duplo({
    environment: "DEV",
});

duplo.setExtractError((type, key, error) => new UnprocessableEntityHttpResponse("bad_type"));
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- La gestion des erreurs d'extraction a été définie avec la méthode `setExtractError` de l'instance.
- Lorsqu'un schéma zod d'`ExtractStep` ne sera pas respecté, par défaut une réponse `UnprocessableEntityHttpResponse` sera envoyée avec l'information `"bad_type"`.
></div>

## Enregistrer les Duploses de la librairie

`Duplose` est une class abstraite sur laquelle se basent les class `Route` et `Process`. Les objets `Duplose` peuvent avoir besoin d'être enregistrés dans une instance Duplo pour fonctionner. Pour cela, on utilise la méthode `register`.

```ts
import { Duplo, useProcessBuilder, useRouteBuilder } from "@duplojs/core";

const duplo = new Duplo({
    environment: "DEV",
});

duplo.register(...useProcessBuilder.getAllCreatedProcess());
duplo.register(...useRouteBuilder.getAllCreatedRoute());
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- On utilise la méthode `register` pour enregistrer tous les processes créés avec le `useProcessBuilder`.
- On utilise la méthode `register` pour enregistrer toutes les routes créées avec le `useRouteBuilder`.
></div>

## Override configuration

Si vous voulez ajouter de nouvelles options à la configuration ou créer un nouvel environnement, il vous suffit d'override les types. C'est de cette manière que la librairie `@duplojs/node` ajoute des paramètres supplémentaires.

```ts
import { Duplo } from "@duplojs/core";

declare module "@duplojs/core" {
    interface DuploConfig {
        myNewOptions: boolean;
    }

    interface Environments {
        FOO: true; // true est obligatoire
    }
}

const duplo = new Duplo({
    environment: "FOO",
    myNewOptions: false,
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- L'interface `DuploConfig` a été overridée pour ajouter la propriété `myNewOptions`.
- L'interface `Environments` a été overridée pour ajouter l'environnement `FOO`.
></div>
