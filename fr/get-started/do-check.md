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
Les **checkers** sont des interfaces. Ils utilise du code **impératif** pour le transformer en code **déclaratif**. Leur utilisation doit permettre de faire une **vérification**. Les **checkers** ne doive pas étre penssé pour un usage unique, ils doivent pouvoir étre réutilisable en étand le plus neutre possible. Une foit créer, un **checker** peut étre implémenter dans des **routes** ou des **processes**. Les **checkers** vous permette de créer une **vérification explicite** au endroit ou vous les implémenter. En plus de cela il vont **normalisé** votre code, ce qui le rendra **robuste** au passage de différent developeur.

### Exemple rapide
{: .no_toc }
Cette partie est trés danse en information donc je vais commencer pars vous donner un petit exemple que vous pouvez survolé. 

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
- Un **checker** a été créé avec le nom `userExist`, ça valeur d'entré est de type `number` et ces information de sortie sont `user.exist` et `user.notfound`.
- Le **checker** `userExist` a étais implémenter dans une **route**. La valeur d'entré passé au **checker** corespond a la valeur `userId` du **floor**. L'information de sorti attendu pour passé a la suite est `user.exist`. La donner renvoyer pars le **checker** sera indéxé dans le **floor** a la clef `user`. Dans le cas ou une information différente a `user.exist` est renvoyer pars le **checker**, une réponse `NotFoundHttpResponse` sera renvoyer avec l'information `user.notfound`.
- En survolant rapidement la déclaration de la **route** nous pouvont déduire qu'elle renvois la variable `user`. Cepandent, pour cela il faut que la **requéte** posséde un paramétre `userId` de type `number` et que a partire de ce paramétre il faut qu'un utilisateur éxiste.
></div>

## Création d'un checker
Le **checker** fait partie des objets complexes qui nécessitent un **[builder](../../required/design-patern-builder)**. Pour cela, on utilise la fonction `createChecker` qui prend en premier argument le nom du **checker**. Le **builder** ne renverra que la méthode `handler` qui aprés avoir étais appeler, clotura la création du **checker**. La fonction passé en argument a la méthode `handler` serre a interfacé une opération. Cette fonction prend en premier argument une valeur d'entré avec un type que vous devez définir, cette valeur sera généralment nomé `input`. En second argument la fonction vous donne une fonction `output`, cette fonction `output` permet que construire un retour correct avec a ce que vous lui donner. La fonction `output` prend en premier argument une `string` qui donne un sens explicite a votre vérification. En second argument la fonction `output` prend une valeur qui peut étre transmise. Le type de cette valeur est accosier a la `string` passé premier argument.

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
- La methode `handler` cloture la **création** de l'objet `Checker` et le renvois.
- La **valuer d'entré** nomé `input` a étais définit sur `number`.
- Le **checker** renvoit 2 **information**, `user.exist` et `user.notfound`.
- l'**information** `user.exist` est accosier au **type** de la variable `user`.
- l'**information** `user.notfound` est associer au **type** `null`.
></div>

Implémentation du checker [ici](#implémentation-dun-checker-dans-une-route).

{: .note }
Les **checkers** prennent une ou plusieurs **valeurs d'entrée** et retournent **plusieurs sorties**. Je précise bien "**plusieurs**" car une **vérification** peut donner lieu à des résultats valides ou invalides, au minimum. La validité du résulta du dépend du **contexte** dans lequel vous vous trouvez. Par exemple, le **checker** ci-dessus peut être utilisé pour **vérifier** qu'un utilisateur existe dans le cadre d'une authentification. Mais vous pouvez également souhaiter qu'un utilisateur n'existe pas dans le cas de la création d'un compte utilisateur. Le **checker** peut donc effectuer des vérifications selon le besoin que vous avez.

### Ajouter des options
{: .no_toc }
Il est possible d'ajouter des options au checker. Les options sont une maniere de donner des directives suplémentaire pour l'éxécution d'un checker. Pour typé vos options vous pouver utilisé les généric de la fonction `createChecker`. Vous pouvez définir les valeur par défaut des options en passent un deuxiéme argument a la fonction `createChecker`. Les options seront donné a la fonction passe plat en trosiéme argument.

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
- Un **chercker** nomé `compareDate` a étais créer avec comme options l'interface `OptionsCompareDate`.
- La valeur pars défaut de l'option `compareType` est `lower`.
- La **valuer d'entré** nomé `input` a étais définit sur `InputCompareDate`.
- L'option `compareType` nous indique qu'elle type de comparaison faire.
></div>

Implémentation du checker [ici](#implémentation-dun-checker-avec-options).

### Multiple entrés
{: .no_toc }
Pour rendre un checker plus flexible, il est possible d'assigner plusieur type a l'argument `input` d'un checker. Pour optimisé cette pratique **Duplo** met a disposition la fonction `createTypeInput`. Cette fonction prend en généric un type objet et renvoi un objet avec des méthodes. Le nom des méthodes correspond au clef du type objet donner en généric et le premier argument des méthodes correspond au type des clef. Les méthodes de votre input renvois un object avec une propriéter `inputName` corespondant au nom de la méthod et une autre propriéter `value` corespondant a l'argument passé a la méthod.

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
- Un input a étais créer avec les méthodes `id` et `email`.
- la méthode `id` a comme premier argument un `number`.
- la méthode `id` renvoi un objet de type `{ inputName: "id", value: number }`.
- la méthode `email` a comme premier argument une `string`.
- la méthode `email` renvoi un objet de type `{ inputName: "email", value: string }`.
></div>

Pour utilisé l'input il suffit d'utilisé l'interface `GetTypeInput` et lui donner votre input.
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
- L'input `inputUserExist` est utiliser comme **input** de la fonction passe plat.
- si `inputName` est égale a `id`, la recherche se fera pars l'id.
- si `inputName` est égale a `email`, la recherche se fera pars l'email.
></div>

Implémentation du checker [ici](#utilisé-une-checker-avec-un-multi-input).

## Implémentation d'un checker dans une route
Les **checkers** une fois créer peuvent étre implémenter dans des **routes** ou des **processes**. Pour cela, les **[builder](../../required/design-patern-builder)** propose la méthode `check`. Cette Méthode a pour effet direct d'ajouter une `CheckerStep` aux **étapes** de la **route** en cours de création. Elle prend en premier argument le **checker** que vous voulez implémenter et en seconde argument les paramétre contextuel. Les propriéter importante des paramétre sont :
- `input`: fonction qui envoi la valeur d'entré du **checker**. Elle a en premier argument la méthode `pickup` du **floor**.
- `result`: `string` qui correspond a l'informations de sortie du **checker** attendu.
- `indexing`: clef d'indexation de la donner dans le **floor**.
- `catch`: callback appler dans le cas ou le résulta du **checker** ne correspond pas au `result` indiqué.

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
- Le checker `userExist` est implémenter dans la **route**.
- Le resulta attendu pour passer l'**étape** suivante est `user.exist`.
- Si Le resulta de `userExist` correspond au resulta attendu, les donner renvoyer pars le **chekcer** seront indéxer dans le **floor** a la clef `user` et la **route** passera a l'étape **suivante**.
- Si le result ne correspond pas, l'exécution s'arrétera ici et la **route** renvera la réponse retourné par la fonction `catch`.
></div>

### Implémentation d'un checker avec options
{: .no_toc }
Dans il paramétre d'implémentation d'un **checker** il éxiste une propriéter `options`. Cette propriéter permet de modifier les options par défaut d'un **checker** de façon **local**.

```ts
import { ConflictHttpResponse, CreatedHttpResponse, useBuilder, zod } from "@duplojs/core";

useBuilder()
    .createRoute("POST", "/events")
    .extract({
        body: zod.object({
            name: zod.string(),
            date: zod.coerce.date(),
        }).strip(),
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
- Le checker `compareDate` est implémenter dans la **route**.
- L'option `compareType` du checker a étais définit sur `greater`
- Le resulta attendu pour passer l'**étape** suivante est `valid`.
- Si Le resulta de `compareDate` correspond au resulta attendu, la **route** passera a l'étape **suivante** et aucune donné ne sera indéxé dans le floor car le clef `indexing` n'a pas étais spécifier.
- Si le result ne correspond pas, l'exécution s'arrétera ici et la **route** renvera la réponse retourné par la fonction `catch`.
></div>

### Utilisé une checker avec un multi input
{: .no_toc }
Les entrés multiple rende vos **checker** trés flexible. Il facilite l'adaptabilité des votre **checker** dans des context diférent. Pour cela il suffit d'appler les method de votre objet que vous avez créer avec la fonction `createTypeInput`.

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
        }).strip(),
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
- Le checker `userExist` a étais implémenter dans deux **route**.
- La method `email` et `id` de l'objet `inputUserExist` son utilisé dans les fonction input aux endroit ou est implémenter le checker `userExist`.
- l'utilisation de `inputUserExist.email` permetera de chercher un utilisateur pars son address email.
- l'utilisation de `inputUserExist.id` permetera de chercher un utilisateur pars son indentifant.
></div>

## Les presets checkers
Pour simplifier l'implémentation des **checkers** vous pouvez en faire des **presets checkers**. Les **presets checkers** sont tout simplement des **checker** avec des paramétre d'implémentations prés configuré. Pour créer des **presets checkers** il vous suffit d'utilisé la fonction `createPresetChecker`. Cette fonction prend en premier argument un **checker** et en seconde ses paramétre d'implémentation. Les paramétre sont similaire a ce vue précédement. Vous y trouverais le praramétre `transformInput` en plus qui permet de changer le type de l'entré du **checker** avec une fonction interface.

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
- Des **presets Checkers** sont créer avec le **checker** `userExist` de cette [exemple](#multiple-entrés) (**checker** avec entrés multiple).
- Le **presets Checkers** `iWantUserExist` prédéfinit les 3 paramétre d'implémentation de base.
- Le **presets Checkers** `iWantUserExistById` fait la même chose de `iWantUserExist` mais transform le type d'entré en `number`.
- Le **presets Checkers** `iWantUserExistByEmail` fait la même chose de `iWantUserExist` mais utilise une methode d'un multi input pour transform le type d'entré en `string`.
></div>

## Implémentation d'un preset checker dans une route
L'implémentation des **preset checker** est trés simple, il suffit d'utilisé la méthode `presetCheck` du **[builder](../../required/design-patern-builder)** des **Routes** ou des **Processes**. Cette méthode prend 2 arguments, le premier argument doit étre un `presetCheck` et le seconde est une fonction qui renvois la valeur d'entré du **preset checker**. Cette fonction a en premier argument la méthode `pickup` du **floor**.

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
- Une route avec un **preset checker** implémenté a étais créer.
- En survolant rapidement la déclaration de la **route** nous pouvont déduire qu'elle renvois la variable `user`. Cepandent, pour cela il faut que la **requéte** posséde un paramétre `userId` de type `number` et que a partire de ce paramétre il faut qu'un utilisateur éxiste.
></div>

## Les cuts
Les **cuts** son des **étapes** (`CutStep`) au même titre que les **checker**. Dans le meilleur des monde, les **checker** suffise a faire toute les vérification. Cependant, dans la réaliter il arrive tout le temp de devoir produire du code qui est complaitement arbitraire a un cas unique. C'est donc pour ces exeptions que les **cuts** on étais dévloppé.

### Implémentation d'un cut dans une route
{: .no_toc }
Pour Implémenter un **cut** il suffit d'utilisais la method `cut` du **[builder](../../required/design-patern-builder)** des **Routes** ou des **Processes**. En premier argument la method `cut` prend une fonction et en seconde argument un tablau. La fonction prend en argument un objet contenant la method `pickup` du **floor** et la method `dropper`. La fonction doit contenir une vérification et doit renvoyer une **réponse** ou le resulta de la fonction `dropper`. Dans le cas de renvoi d'un objet **réponse**, l'éxécution de la route ce stoppera a cette étape. La méthode `dropper` permet d'indexé dans le **floor** des donner obtenu dans la `CutStep`. Cette méthode prend en argument le type `null | Record<string, unknown>`. Dans le cas d'un argument `null`, cela indique que rien ne veux étre indéxé. Mais dans le cas d'un argument `Record<string, unknown>`, chaque clef de l'objet pourrais étre indéxer dans le **floor**. Pour cela il suffit de les indiqué das le tableau passé en second argument de la method `cut` du **builder**.

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
- Une route avec un **cut** implémenté a étais créer.
- Le **cut** vérifi un cas particulier avant la suppression d'un utilisateur.
- Le **cut** ne renvoi pas de donné car il appele la fonction `dropper` avec `null`.
- Aucune clef n'est indéxé dans le **floor** a le suite de ce **cut**.
></div>

<br>

[\<\< Obtenir de la donnée d'une requête](../getting-data-from-request){: .btn .mr-4 }
[Définir une réponse >\>\>](../define-response){: .btn .btn-yellow } 