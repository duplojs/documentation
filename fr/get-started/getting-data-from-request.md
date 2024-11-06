---
layout: default
parent: Commencer
title: Obtenir de la donnée d'une requête
nav_order: 2
---

# Obtenir de la donnée d'une requête
{: .no_toc }
Dans cette section, nous allons voir comment obtenir de la donnés typé d'une requet, tout en étand robuste et 100% fiable. Tous les exemples présent dans ce cours son disponible en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/getting-data-from-request).

1. TOC
{:toc}

## La method extract
La method `extract` fait partir du builder de l'objet `Route`. Elle a pour effet direct d'ajouter une `ExtractStep` au étape de la route en cours de création. Le butte d'une étape `ExtractStep` est de récupérer des donners provenent de la requéte courante. Pour cela, DuploJS utilise la librairy de parsing `Zod` qui permet de certifier la validité réel du type de la donner et aussi par la même ocasion, d'enrichire le `floor`.

```ts
import { CreatedHttpResponse, useBuilder, zod } from "@duplojs/core";

useBuilder()
    .createRoute("POST", "/user")
    .extract({
        body: zod.object({
            userName: zod.string(),
            email: zod.string(),
            age: zod.coerce.string(),
        }).strip(),
    })
    .handler(
        (pickup) => {
            const { userName, email, age } = pickup("body");

            const user = {
                id: 1,
                userName,
                email,
                age,
            };

            return new CreatedHttpResponse(
                "user.created",
                user,
            );
        },
    );
```

Dans cet exemple :
- La method `extract` est utilisé avant la method `handler` donc l'exécution de l'étape `ExtractStep` ce fera avand l'exécution de la `HandlerStep`.
- Le premier argument de `extract` est un objet qui a les même clefs que l'objet `Request`.
- Le schema `zod` sur la clef `body` de l'objet passé en premier argument, sera appliqué la valeur que porte l'objet `Request` sur ça clef `body`.
- La clef `body` est ajouté au `floor` et auras le type qui est renvoyer par le schema `zod`.
- En cas d'echec de parsing, la route renvera une réponse et l'execution s'arrétera a l'étape `ExtractStep`. Toute les étapes déclaré derrier notre cette `ExtractStep` ne seront donc pas éxécuter.
- La method `strip` sur le schema `zod` prévient d'une erreur typescript `ts(2589)`.



<br>

[\<\< Déclarer une route](../declare-route){: .btn .mr-4 }
[Faire une vérification >\>\>](../do-check){: .btn .btn-yellow } 