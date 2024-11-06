---
layout: default
parent: Commencer
title: Faire une vérification
nav_order: 3
---

# Faire une vérification
{: .no_toc }
Dans cette section, nous allons voirs comment faire des vérifications explicite.
Tous les exemples présent dans ce cours son disponible en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/do-check).

1. TOC
{:toc}

## Les checkers
Les checkers sont des interface. Ils transforme du code impératife en action de vérificatiion explicite pour le DuploJS. Le `Checker` fait parti des objets complexe qui n'éccésite un builder. Pour cela ont utilise `createChecker`.

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

Dans cette exemple :
- Un checker a étais créer avec le nom `userExist`
- La method handler définit la fonction passe plat.

Les `Checker` prenne une ou plusieur valuer d'entré et retourn plusieur sortie. 

<br>

[\<\< Obtenir de la donnée d'une requête](../getting-data-from-request){: .btn .mr-4 }
[Définir une réponse >\>\>](../define-response){: .btn .btn-yellow } 