---
layout: default
parent: Commencer
title: Faire une vérification
nav_order: 3
---

# Faire une vérification
{: .no_toc }
Dans cette section, nous allons voir comment faire des vérifications explicites.
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/do-check).

1. TOC
{:toc}

## Les checkers
Les checkers sont des interfaces. Ils transforment du code impératif en actions de vérification explicites pour DuploJS. Le `Checker` fait partie des objets complexes qui nécessitent un builder. Pour cela, on utilise `createChecker`.

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
- Un checker a été créé avec le nom `userExist`
- La methode handler définit la fonction passe plat.
></div>

{: .note }
Les `Checker` prennent une ou plusieurs valeurs d'entrée et retournent plusieurs sorties. Je précise bien "plusieurs" car une vérification peut donner lieu à des résultats valides ou invalides, au minimum. Tout dépend du contexte dans lequel vous vous trouvez. Par exemple, le `Checker` ci-dessus peut être utilisé pour vérifier qu'un utilisateur existe dans le cadre d'une authentification. Mais vous pouvez également souhaiter qu'un utilisateur n'existe pas dans le cas de la création d'un compte utilisateur. Le `Checker` peut donc effectuer des vérifications selon le besoin que vous avez.

<br>

[\<\< Obtenir de la donnée d'une requête](../getting-data-from-request){: .btn .mr-4 }
[Définir une réponse >\>\>](../define-response){: .btn .btn-yellow } 