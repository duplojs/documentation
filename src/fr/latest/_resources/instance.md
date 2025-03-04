---
nav_order: 1
layout: default
title: Instance Duplo
---

# Instance Duplo
{: .no_toc }

Dans cette section, nous allont voirs comment créer une instance Duplo, a quoi serret elle et qu'elle sont c'est paramétre. 
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/1.x/resources/config).

1. TOC
{:toc}

## Créer une instance Duplo
Pour créer un instance **Duplo** il suffit d'importer la class `Duplo` depuis `@duplojs/core` et de l'instancier. Le seul paramétre de l'instance obligatoire est `environment`, mais il est possible que tierce librairy (comme `@duplojs/node`) ajoute d'autre paramétre obligatoire.

```ts
import { Duplo } from "@duplojs/core";

const duplo = new Duplo({
    environment: "DEV",
});
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Une instance `Duplo` a étais créée.
- La valeur de `environment` a étais définit sur `"DEV"`.
></div>

## A quoi serre l'instance Duplo
L'instance `Duplo` serre a centralisé les objets de la librairy. Par exemple la déclaration des routes ne dépend pas de l'instance, il est donc n'ésséserre de les enregister pour les centralisé. Cela évite une dépendance décendente, et donc des probléme d'importation. L'instance seul ne serre pas a grand chose, c'est grace a des plugins tierce qu'elle pourra étre capable de géré un serveur web par exemple. C'est grace a cette dépendance a des librairy tierce que **Duplo** est indépendant de la platforme (**NodeJS**, **Bun** ou **Deno** n'est plus une question difficile).

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
- La librairy de portage `@duplojs/node` est utiliser pour que l'instance puisse géré des serveur web sur **NodeJS**.
- Les propriéter `port` et `host` on étais ajouter pars la librairy de portage `@duplojs/node`.
- Les **processes** et les **routes** déclaré sont tout enregistré dans une instance `Duplo`.
- un serveur web est lancer grace a la méthode `launch` qui a étais ajouter par la librairy de portage `@duplojs/node`.
></div>

## Configuration
Pour instancier un objet `Duplo`, il faut passé en argument un objet qui définit les paramétre de l'instance.

### DuploConfig
{: .no_toc }

Propriéter|Type|Valeur pars défaut|Definition 
---|---|---|---
environment|`"DEV" | "PROD" | "TEST"`|requie|Définit l'environement dans lequel se lance l'instance.
disabledRuntimeEndPointCheck|`boolean`|`false`|Désactive l'éxéctuion des contrat de sortie.
disabledZodAccelerator|`boolean`|`false`|Désactive l'optimisation des schema zod pars [@duplojs/zod-accelerator](https://github.com/duplojs/zod-accelerator).
keyToInformationInHeaders|`string`|`"information"`|Définit la clef de l'**information** dans les headers.
plugins|[`DuploPlugins`](#duploconfig)`[]`|`[]`|Tableau qui contien les plugins que vas utilisé l'instance.
bodySizeLimit|`number | `[`BytesInString`](#bytesinstring)|`"50mb"`|La taille maximale du body qu'il est possible d'accepter.
recieveFormDataOptions|[`RecieveFormDataOptions`](#recieveformdataoptions) |`{ uploadDirectory: "upload", prefixTempName: "tmp-", strict: false }`|Permet de définir les option pars défaut de la récéption des form data.
prefix|`string | string[]`|`[]`|Définit un ou plusieur préfix sur chaq'une des routes enregistré.
keepDescriptions|`boolean`|`false`|Indique qu'il faut garder les description aprés le lancement.

### DuploPlugins
{: .no_toc }

|Type|
|---|
|`(instance: Duplo) => void;`.|

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
- La fonction `myPlugin` créer un plugin en currying.
- `myPlugin` est implémenter dans l'instance.
></div>

### BytesInString
{: .no_toc }

|Type|
|---|
|`${number}b` | `${number}kb` | `${number}mb` | `${number}gb` | `${number}tb` | `${number}pb`|

### RecieveFormDataOptions
{: .no_toc }

Propriéter|Type|Valeur pars défaut|Definition
---|---|---|---
uploadDirectory|`string`|`"upload"`|Définit le dossier par défaut qui serra utilisé pour l'upload des fichers de FormData.
prefixTempName|`string`|`"tmp-"`|Définit un préfixe par défaut qui sera donner au fichier upload.
strict|`boolean`|`false`|Définit la propriéter strict par défaut.

## Hooks de l'instance
**Duplo** posséde un systéme de hook qui permet d'influencer le comportement des routes ou de l'instance. Les hooks sont des fonction callback qui seront appeler a des moment précie. 

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
- Un hook `beforeRouteExecution` a été ajouter a l'instance.
- Un hook `onError` a été ajouter a l'instance.
- Un hook `onStart` a été ajouter a l'instance.
></div>

## Géstion d'une route introuvable
Géstion d'une route introuvable ce fait directement sur l'instance. Vous pouvez utilisez la méthode de l'instance `setNotfoundHandler` pour customisé la réponse.

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
- La gestion d'une route introuvable a étais définit avec la méthode `setNotfoundHandler` de l'instance.
- Lorsqu'une route est sera introuvable, une `NotFoundHttpResponse` sera envoyer avec l'information `"not_found"`.
></div>

## Géstion par défaut des erreur d'extraction
Si une erreur survient lors d'une `ExtractStep`, celle si coupe l'éxécution de la route et renvois une réponse. La méthode de l'instance `setExtractError` permet définir la réponse pars défaut qui sera renvoyer.

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
- La gestion des erreur d'extraction a étais définit avec la méthode `setExtractError` de l'instance.
- Lorsqu'un schema zod d'`ExtractStep` ne sera pas respecter, pars défaut une réponse `UnprocessableEntityHttpResponse` sera envoyer avec l'information `"bad_type"`.
></div>

## Enregister les Duplose de la librairy
`Duplose` est une class abstraite sur la qu'elle ce base la class `Route` et la class `Process`. Les objet `Duplose` peuvent avoir besoin de ce fair enregister dans une instance Duplo pour fonctioner. Pour cela on utilise la méthode `register`.

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
- On utilise la méthode `register` pour enregister tout les processes créer avec le `useProcessBuilder`.
- On utilise la méthode `register` pour enregister toute les routes créer avec le `useRouteBuilder`.
></div>

// présentation override
// exemple