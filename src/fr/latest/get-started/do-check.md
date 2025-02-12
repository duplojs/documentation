---
layout: default
parent: Commencer
title: Faire une vérification
nav_order: 3
---

# Faire une vérification
{: .no_toc }
Dans cette section, nous allons voir comment faire des **vérifications explicites**.
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/do-check).

1. TOC
{:toc}

## Les checkers
Les **checkers** sont des interfaces. Ils utilisent du code **impératif** pour le transformer en code **déclaratif**. Leur utilisation doit permettre de faire une **vérification**. Les **checkers** ne doivent pas être pensés pour un usage unique, ils doivent pouvoir être réutilisables en étant le plus neutres possibles. Une fois créé, un **checker** peut être implémenté dans des **routes** ou des **processes**. Les **checkers** vous permettent de créer une **vérification explicite** aux endroits où vous les implémentez. En plus de cela ils vont **normaliser** votre code, ce qui le rendra **robuste** au passage de différents développeurs.

### Exemple rapide
{: .no_toc }
Cette section contient de nombreuses informations. Pour faciliter votre compréhension, nous commencerons par vous présenter un petit exemple que vous pourrez survoler rapidement.
```ts
import { createChecker, useBuilder, zod, OkHttpResponse, NotFoundHttpResponse } from "@duplojs/core";

export const userExistCheck = createChecker("userExist")
    .handler(
        (input: number, output) => {
            const user = getUser({ id: input });

            if (user) {
                return output("user.exist", user);
            } else {
                return output("user.notfound", null);
            }
        },
    );

useBuilder()
    .createRoute("GET", "/users/{userId}")
    .extract({
        params: {
            userId: zod.coerce.number(),
        },
    })
    .check(
        userExistCheck,
        {
            input: (pickup) => pickup("userId"),
            result: "user.exist",
            indexing: "user",
            catch: () => new NotFoundHttpResponse("user.notfound"),
        },
    )
    .handler(
        (pickup) => {
            const user = pickup("user");

            return new OkHttpResponse("user.found", user);
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Un **checker** a été créé avec le nom `userExist`, sa valeur d'entrée est de type `number` et ses informations de sortie sont `user.exist` et `user.notfound`.
- Le **checker** `userExist` a été implémenté dans une **route**. La valeur d'entrée passée au **checker** corespond à la valeur `userId` du **floor**. L'information de sortie attendue pour passer à la suite est `user.exist`. La donnée renvoyée par le **checker** sera indéxée dans le **floor** à la clé `user`. Dans le cas où une information différente de `user.exist` est renvoyée par le **checker**, une réponse `NotFoundHttpResponse` sera renvoyée avec l'information `user.notfound`.
- En survolant rapidement la déclaration de la **route** nous pouvons déduire qu'elle renvoie la variable `user`. Cependant, pour cela, la **requête** doit inclure un paramètre `userId` de type `number`, et un utilisateur correspondant à ce paramètre doit exister.
></div>

## Création d'un checker
Le **checker** fait partie des objets complexes qui nécessitent un **[builder](../../required/design-patern-builder)**. Pour cela, on utilise la fonction `createChecker` qui prend en premier argument le nom du **checker**. Le **builder** ne renverra que la méthode `handler` qui, après avoir été appelée, clôturera la création du **checker**. La fonction passée en argument à la méthode `handler` sert à interfacer une opération. Cette fonction prend en premier argument une valeur d'entrée avec un type que vous devez définir. Cette valeur sera généralement nommée `input`. En second argument, la fonction vous donne une fonction `output`. Elle permet de construire un retour correct avec ce que vous lui donnez. La fonction `output` prend en premier argument une `string` qui donne un sens explicite à votre vérification. Elle prend en second argument une valeur qui peut être transmise. Le type de cette valeur est associé à la `string` passée en premier argument.

```ts
import { createChecker } from "@duplojs/core";

export const userExistCheck = createChecker("userExist")
    .handler(
        (input: number, output) => {
            const user = getUser({ id: input });

            if (user) {
                return output("user.exist", user);
            } else {
                return output("user.notfound", null);
            }
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Un **checker** a été créé avec le nom `userExist`
- La methode `handler` définit la fonction **passe plat**.
- La methode `handler` clôture la **création** de l'objet `Checker` et le renvoie.
- La **valeur d'entrée** nommée `input` a été définie sur `number`.
- Le **checker** renvoie 2 **informations**, `user.exist` et `user.notfound`.
- L'**information** `user.exist` est associée au **type** de la variable `user`.
- L'**information** `user.notfound` est associée au **type** `null`.
></div>

Implémentation du checker [ici](#implémentation-dun-checker-dans-une-route).

{: .note }
Les **checkers** prennent une ou plusieurs **valeurs d'entrées** et retournent **plusieurs sorties**. On précise bien "**plusieurs**" car une **vérification** peut donner lieu à des résultats valides ou invalides, au minimum. La validité du résultat dépend du **contexte** dans lequel vous vous trouvez. Par exemple, le **checker** ci-dessus peut être utilisé pour **vérifier** qu'un utilisateur existe dans le cadre d'une authentification. Mais vous pouvez également souhaiter qu'un utilisateur n'existe pas dans le cas de la création d'un compte utilisateur. Le **checker** peut donc effectuer des vérifications selon le besoin que vous avez.

### Ajouter des options
{: .no_toc }
Il est possible d'ajouter des options au checker. Les options sont une manière de donner des directives suplémentaires pour l'exécution d'un checker. Pour typer vos options vous pouvez utiliser les génériques de la fonction `createChecker`. Vous pouvez définir les valeurs par défaut des options en passant un deuxième argument à la fonction `createChecker`. Les options seront données à la fonction passe plat en troisième argument.

```ts
import { createChecker } from "@duplojs/core";

interface InputCompareDate {
    reference?: Date;
    compared: Date;
}

interface OptionsCompareDate {
    compareType: "greater" | "lower";
}

export const compareDateCheck = createChecker<OptionsCompareDate>(
    "compareDate",
    { compareType: "lower" },
)
    .handler(
        (input: InputCompareDate, output, options) => {
            const { reference = new Date(), compared } = input;

            if (options.compareType === "greater") {
                if (reference.getTime() > compared.getTime()) {
                    return output("valid", null);
                } else {
                    return output("invalid", null);
                }
            } else if (reference.getTime() < compared.getTime()) {
                return output("valid", null);
            } else {
                return output("invalid", null);
            }
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Un **chercker** nommé `compareDate` a été créé avec comme option l'interface `OptionsCompareDate`.
- La valeur par défaut de l'option `compareType` est `lower`.
- La **valeur d'entrée** nommée `input` a été définie sur `InputCompareDate`.
- L'option `compareType` nous indique quel type de comparaison faire.
></div>

Implémentation du checker [ici](#implémentation-dun-checker-avec-options).

### Multiple entrées
{: .no_toc }
Pour rendre un checker plus flexible, il est possible d'assigner plusieurs types à son argument `input`. Pour optimiser cette pratique, **Duplo** met à disposition la fonction `createTypeInput`. Cette fonction prend en générique un type objet et renvoie un objet avec des méthodes. Le nom des méthodes correspond aux clés du type objet donné en générique et le premier argument des méthodes correspond au type des clés. Les méthodes de votre input renvoient un objet avec une propriété `inputName` corespondant au nom de la méthode et une autre propriété `value` corespondant à l'argument passé à la méthode.

```ts
import { createTypeInput } from "@duplojs/core";

export const inputUserExist = createTypeInput<{
    id: number;
    email: string;
}>();

inputUserExist.id(123); // { inputName: "id", value: 123 };
inputUserExist.email("foo"); // { inputName: "email", value: "foo" };
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Un input a été créé avec les méthodes `id` et `email`.
- La méthode `id` a comme premier argument un `number`.
- La méthode `id` renvoie un objet de type `{ inputName: "id", value: number }`.
- La méthode `email` a comme premier argument une `string`.
- La méthode `email` renvoie un objet de type `{ inputName: "email", value: string }`.
></div>

Pour utiliser l'input, il suffit d'utiliser l'interface `GetTypeInput` et lui donner votre input.
```ts
import { createChecker, createTypeInput, type GetTypeInput } from "@duplojs/core";

export const inputUserExist = createTypeInput<{
    id: number;
    email: string;
}>();

export const userExistCheck = createChecker("userExist")
    .handler(
        ({ inputName, value }: GetTypeInput<typeof inputUserExist>, output) => {
            const query: Parameters<typeof getUser>[0] = {};

            if (inputName === "id") {
                query.id = value;
            } else if (inputName === "email") {
                query.email = value;
            }

            const user = getUser(query);

            if (user) {
                return output("user.exist", user);
            } else {
                return output("user.notfound", null);
            }
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- L'input `inputUserExist` est utilisé comme **input** de la fonction passe plat.
- Si `inputName` est égal à `id`, la recherche se fera par l'id.
- Si `inputName` est égal à `email`, la recherche se fera par l'email.
></div>

Implémentation du checker [ici](#utilisé-une-checker-avec-un-multi-input).

## Implémentation d'un checker dans une route
Les **checkers** une fois créés peuvent être implémentés dans des **routes** ou des **processes**. Pour cela, les **[builders](../../required/design-patern-builder)** proposent la méthode `check`. Cette méthode a pour effet direct d'ajouter une `CheckerStep` aux **étapes** de la **route** en cours de création. Elle prend en premier argument le **checker** que vous voulez implémenter et en second argument les paramètres contextuels. Les propriétés importantes des paramètres sont :
- `input`: fonction qui envoie la valeur d'entrée du **checker**. Elle a en premier argument la méthode `pickup` du **floor**.
- `result`: `string` qui correspond à l'information de sortie du **checker** attendu.
- `indexing`: clé d'indexation de la donnée dans le **floor**.
- `catch`: callback appelé dans le cas où le résultat du **checker** ne correspond pas au `result` indiqué.

```ts
import { useBuilder, zod, OkHttpResponse, NotFoundHttpResponse } from "@duplojs/core";

useBuilder()
    .createRoute("GET", "/users/{userId}")
    .extract({
        params: {
            userId: zod.coerce.number(),
        },
    })
    .check(
        userExistCheck,
        {
            input: (pickup) => pickup("userId"),
            result: "user.exist",
            indexing: "user",
            catch: () => new NotFoundHttpResponse("user.notfound"),
        },
    )
    .handler(
        (pickup) => {
            const user = pickup("user");

            return new OkHttpResponse("user.found", user);
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Le checker `userExist` est implémenté dans la **route**.
- Le resultat attendu pour passer à l'**étape** suivante est `user.exist`.
- Si Le resultat de `userExist` correspond au resultat attendu, les données renvoyées par le **checker** seront indexées dans le **floor** à la clé `user`, et la **route** passera à l'étape **suivante**.
- Si le resultat ne correspond pas, l'exécution s'arrêtera ici et la **route** renverra la réponse retournée par la fonction `catch`.
></div>

### Implémentation d'un checker avec options
{: .no_toc }
Dans les paramètres d'implémentation d'un **checker**, il existe une propriété `options`. Cette propriété permet de modifier les options par défaut d'un **checker** de façon **locale**.

```ts
import { ConflictHttpResponse, CreatedHttpResponse, useBuilder, zod } from "@duplojs/core";

useBuilder()
    .createRoute("POST", "/events")
    .extract({
        body: zod.object({
            name: zod.string(),
            date: zod.coerce.date(),
        }),
    })
    .check(
        compareDateCheck,
        {
            input: (pickup) => ({ compared: pickup("body").date }),
            options: { compareType: "greater" },
            result: "valid",
            catch: () => new ConflictHttpResponse("event.expire"),
        },
    )
    .handler(
        (pickup) => {
            const { name, date } = pickup("body");

            const event = {
                id: 1,
                name,
                date,
            };

            return new CreatedHttpResponse("event.created", event);
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Le checker `compareDate` est implémenté dans la **route**.
- L'option `compareType` du checker a été définie sur `greater`
- Le resultat attendu pour passer à l'**étape** suivante est `valid`.
- Si Le resultat de `compareDate` correspond au resultat attendu, la **route** passera à l'étape **suivante** et aucune donnée ne sera indexée dans le floor car la clé `indexing` n'a pas été spécifiée.
- Si le resultat ne correspond pas, l'exécution s'arrêtera ici et la **route** renverra la réponse retournée par la fonction `catch`.
></div>

### Utiliser un checker avec un multi input
{: .no_toc }
Les entrées multiples rendent vos **checker** très flexibles. Elles facilitent l'adaptabilité de vos **checker** dans des contextes différents. Pour cela il suffit d'appeler les méthodes de votre objet, que vous avez créé avec la fonction `createTypeInput`.

```ts
import { useBuilder, zod, ConflictHttpResponse, OkHttpResponse, NotFoundHttpResponse, CreatedHttpResponse } from "@duplojs/core";

useBuilder()
    .createRoute("GET", "/users/{userId}")
    .extract({
        params: {
            userId: zod.coerce.number(),
        },
    })
    .check(
        userExistCheck,
        {
            input: (pickup) => inputUserExist.id(pickup("userId")),
            result: "user.exist",
            indexing: "user",
            catch: () => new NotFoundHttpResponse("user.notfound"),
        },
    )
    .handler(
        (pickup) => {
            const user = pickup("user");
            return new OkHttpResponse("user.found", user);
        },
    );

useBuilder()
    .createRoute("POST", "/register")
    .extract({
        body: zod.object({
            email: zod.string().email(),
            password: zod.string(),
        }),
    })
    .check(
        userExistCheck,
        {
            input: (pickup) => inputUserExist.email(pickup("body").email),
            result: "user.notfound",
            catch: () => new ConflictHttpResponse("email.taken"),
        },
    )
    .handler(
        (pickup) => {
            const { email, password } = pickup("body");

            const user = {
                id: 1,
                email,
                password,
            };

            return new CreatedHttpResponse("user.created", user);
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Le checker `userExist` a été implémenté dans deux **routes**.
- Les méthodes `email` et `id` de l'objet `inputUserExist` sont utilisées dans les fonctions input à l'endroit où est implémenté le checker `userExist`.
- L'utilisation de `inputUserExist.email` permettra de chercher un utilisateur par son adresse email.
- L'utilisation de `inputUserExist.id` permettra de chercher un utilisateur par son identifiant.
></div>

## Les presets checkers
Pour simplifier l'implémentation des **checkers**, vous pouvez en faire des **presets checkers**. Les **presets checkers** sont tout simplement des **checkers** avec des paramètres d'implémentation pré-configurés. Pour créer des **presets checkers**, il vous suffit d'utiliser la fonction `createPresetChecker`. Cette fonction prend en premier argument un **checker** et en second ses paramètres d'implémentation. Les paramètres sont similaires à ceux vus précédement. Vous y trouverez le paramètre `transformInput` en plus qui permet de changer le type de l'entrée du **checker** avec une fonction interface.

```ts
import { createPresetChecker, NotFoundHttpResponse } from "@duplojs/core";

export const iWantUserExist = createPresetChecker(
    userExistCheck,
    {
        result: "user.exist",
        catch: () => new NotFoundHttpResponse("user.notfound"),
        indexing: "user",
    },
);

export const iWantUserExistById = createPresetChecker(
    userExistCheck,
    {
        result: "user.exist",
        catch: () => new NotFoundHttpResponse("user.notfound"),
        indexing: "user",
        transformInput: (input: number) => ({
            inputName: <const>"id",
            value: input,
        }),
    },
);

export const iWantUserExistByEmail = createPresetChecker(
    userExistCheck,
    {
        result: "user.exist",
        catch: () => new NotFoundHttpResponse("user.notfound"),
        transformInput: inputUserExist.email,
    },
);
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Des **presets Checkers** sont créés avec le **checker** `userExist` de cet [exemple](#multiple-entrés) (**checker** avec entrées multiples).
- Le **preset Checker** `iWantUserExist` prédéfinit les 3 paramètres d'implémentation de base.
- Le **preset Checker** `iWantUserExistById` fait la même chose que `iWantUserExist` mais transforme le type d'entrée en `number`.
- Le **preset Checker** `iWantUserExistByEmail` fait la même chose que `iWantUserExist` mais utilise une méthode d'un multi-input pour transformer le type d'entrée en `string`.
></div>

## Implémentation d'un preset checker dans une route
L'implémentation des **presets Checkers** est très simple, il suffit d'utiliser la méthode `presetCheck` du **[builder](../../required/design-patern-builder)** des **Routes** ou des **Processes**. Cette méthode prend 2 arguments, le premier argument doit être un `presetCheck` et le second est une fonction qui renvoit la valeur d'entrée du **preset Checker**. Cette fonction a en premier argument la méthode `pickup` du **floor**.

```ts
import { useBuilder, zod, OkHttpResponse } from "@duplojs/core";

useBuilder()
    .createRoute("GET", "/user/{userId}")
    .extract({
        params: {
            userId: zod.coerce.number(),
        },
    })
    .presetCheck(
        iWantUserExistById,
        (pickup) => pickup("userId"),
    )
    .handler(
        (pickup) => {
            const user = pickup("user");

            return new OkHttpResponse("user.found", user);
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Une route avec un **preset Checker** implémenté a été créée.
- En survolant rapidement la déclaration de la **route**, nous pouvons déduire qu'elle renvoie la variable `user`. Cependant, il est nécessaire que la **requête** possède un paramètre `userId` de type `number` et qu'un utilisateur correspondant à ce paramètre existe.
></div>

{: .note}
La méthode `presetCheck` appelle la méthode `check` en lui donnant tous les paramètres prédéfinis. Il n'existe donc pas d'étape spécifique pour les **presets Checkers**, ils sont implémentés dans l'objet route comme les **checkers**.

## Les cuts
Les **cuts** sont des **étapes** (`CutStep`) au même titre que les **checkers**. Dans le meilleur des mondes, les **checkers** suffisent à faire toutes les vérifications. Cependant dans la réalité, il arrive fréquemment de devoir écrire du code spécifique pour des cas uniques. C'est précisément pour gérer ces exceptions que les **cuts** ont été développés.

### Implémentation d'un cut dans une route
{: .no_toc }
Pour implémenter un **cut**, il suffit d'utiliser la méthode `cut` du **[builder](../../required/design-patern-builder)** des **Routes** ou des **Processes**. En premier argument, la méthode `cut` prend une fonction et en second argument un tableau. La fonction prend en argument un objet contenant la méthode `pickup` du **floor** et la méthode `dropper`. La fonction doit contenir une vérification. Elle doit renvoyer une **réponse** ou le résultat de la fonction `dropper`. Dans le cas de renvoi d'un objet **réponse**, l'exécution de la route se stoppera à cette étape. La méthode `dropper` permet d'indexer dans le **floor** des données obtenues dans la `CutStep`. Cette méthode prend en argument le type `null | Record<string, unknown>`. Dans le cas d'un argument `null`, rien ne sera indexé. Mais dans le cas d'un argument `Record<string, unknown>`, chaque clé de l'objet pourrait être indéxée dans le **floor**. Pour cela il suffit de les indiquer dans le tableau passé en second argument de la méthode `cut` du **builder**.

```ts
import { useBuilder, zod, ForbiddenHttpResponse, NoContentHttpResponse } from "@duplojs/core";

useBuilder()
    .createRoute("DELETE", "/users/{userId}")
    .extract({
        params: {
            userId: zod.coerce.number(),
        },
    })
    .presetCheck(
        iWantUserExistById,
        (pickup) => pickup("userId"),
    )
    .cut(
        ({ pickup, dropper }) => {
            const { email } = pickup("user");

            if (email === "admin@example.com") {
                return new ForbiddenHttpResponse("userIsAdmin");
            }

            return dropper(null);
        },
        []
    )
    .handler(
        (pickup) => {
            const { id } = pickup("user");

            // ...

            return new NoContentHttpResponse("user.deleted");
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Une route avec un **cut** implémenté a été créée.
- Le **cut** vérifie un cas particulier avant la suppression d'un utilisateur.
- Le **cut** ne renvoie pas de données car il appelle la fonction `dropper` avec `null`.
- Aucune clé n'est indéxée dans le **floor** à la suite de ce **cut**.
></div>

<br>

[\<\< Obtenir de la donnée d'une requête](../getting-data-from-request){: .btn .mr-4 }
[Définir une réponse >\>\>](../define-response){: .btn .btn-yellow } 