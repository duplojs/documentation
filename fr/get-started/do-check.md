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
Les **checkers** sont des interfaces. Ils utilise du code **impératif** pour le transformer en code **déclaratif**. Leur utilisation doit permettre de faire une **vérification**. Les **checkers** ne doive pas étre penssé pour un usage unique, ils doivent pouvoir étre réutilisable en étand le plus neutre possible. Une foit créer, un **checker** peut étre implémenter dans des **routes** ou des **processes**. Les **checkers** vous permette de créer une **vérification explicite** au endroit ou vous les implémenter. En plus de cela il vont **normalisé** votre code, ce qui le rendra **robuste** au passage de différente developeur.

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

<br>

[\<\< Obtenir de la donnée d'une requête](../getting-data-from-request){: .btn .mr-4 }
[Définir une réponse >\>\>](../define-response){: .btn .btn-yellow } 