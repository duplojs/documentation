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
Les **checkers** sont des interfaces. Ils utilise du code **impératif** pour le transformer en code **déclaratif**. Leur utilisation doit permettre de faire une **vérification**. Les **checkers** ne doive pas étre penssé pour un usage unique, ils doivent pouvoir étre réutilisable en étand le plus neutre possible. Une foit créer, un **checker** peut étre implémenter dans des **routes** ou des **processes**. Les **checkers** vous permette de créer une **vérification explicite** au endroit ou vous les implémenter. En plus de cela il vont **normalisé** votre code, ce qui le rendra robuste au passage de différente developeur.

## Création d'un checker
Le **checker** fait partie des objets complexes qui nécessitent un [builder](../../required/design-patern-builder). Pour cela, on utilise `createChecker`. 

```ts
import { createChecker } from "@duplojs/core";

export const userExistCheck = createChecker("userExist")
    .handler(
        (input: number, output) => {
            const user = getUser({ id: input });

            if (user) {
                return output("user.exist", user);
            } else {
                return output("user.notfound", user);
            }
        },
    );
```

{: .highlight }
>Dans cet exemple :
><div markdown="block">
- Un **checker** a été créé avec le nom `userExist`
- La methode **handler** définit la fonction passe plat.
></div>

{: .note }
Les **checkers** prennent une ou plusieurs **valeurs d'entrée** et retournent **plusieurs sorties**. Je précise bien "**plusieurs**" car une **vérification** peut donner lieu à des résultats valides ou invalides, au minimum. La validité du résulta du dépend du **contexte** dans lequel vous vous trouvez. Par exemple, le **checker** ci-dessus peut être utilisé pour **vérifier** qu'un utilisateur existe dans le cadre d'une authentification. Mais vous pouvez également souhaiter qu'un utilisateur n'existe pas dans le cas de la création d'un compte utilisateur. Le **checker** peut donc effectuer des vérifications selon le besoin que vous avez.

## Création d'un checker

<br>

[\<\< Obtenir de la donnée d'une requête](../getting-data-from-request){: .btn .mr-4 }
[Définir une réponse >\>\>](../define-response){: .btn .btn-yellow } 