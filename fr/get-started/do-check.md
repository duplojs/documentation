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

Les `Checker` prenne une ou plusieur valeur d'entré et retourne plusieur sortie. Je présise bien plusieur car dans une vérification il une possibilité de resulta valide ou invalide au minimume. Pour précisé, tout depend du context dans le qu'elle vous éte. Dans l'exemple du `Checker` ci dessus, vous pouvez souhaiter qu'un utilisateur éxiste dans le cas d'une authentification. Mais vous pouvez égalment souhaiter qu'un utilisateur n'existe pas dans le cas de la création d'un utilisateur. Le `Checker` peux donc vous effectuer les vérification quen vous voulez dans le sens que vous souhaiter.

<br>

[\<\< Obtenir de la donnée d'une requête](../getting-data-from-request){: .btn .mr-4 }
[Définir une réponse >\>\>](../define-response){: .btn .btn-yellow } 