---
layout: default
title: Introduction
nav_order: 2
---
# Introduction

## Raison d'être
Comme beaucoup de développeurs **Node**, j’ai commencé à créer des serveurs **HTTP** avec **Express**. Tout me paraissait simple : **JavaScript** et **Express** forment un combo très flexible. **Express** offre une **liberté** totale dans la gestion des points d’entrée. Il met entre nos mains un objet représentant la **requête** et un autre représentant la **réponse**. Avec cela, et grâce à son système de **middleware**, il est très simple de lancer des projets.

Cependant, au fur et à mesure que mes projets évoluaient, j’avais de plus en plus de mal à avancer. La codebase devenait trop grande et mon code manquait de **lisibilité**. Malheureusement, **JavaScript** et **Express**, en offrant tellement de **liberté**, ne proposent rien qui incite à bien **structurer** son code. Tout dépend uniquement du bon vouloir du développeur, l’être le plus **faillible** de tous les humains !

Puis un jour, comme beaucoup de développeurs **JavaScript**, j’ai découvert **TypeScript**. Au début, j’étais indifférent. J’étais persuadé que « moi, je sais ce qu’il y a dans mes variables, les développeurs TypeScript sont juste mauvais ». Finalement, j’avais simplement peur du changement : peur de remettre en question tout ce que j’avais appris et peur d’admettre qu’il manquait **TypeScript** à tous mes projets !

Après cette crise existentielle et d’égo inutile, j’ai appris à utiliser **TypeScript**. J’ai rapidement remarqué que le typage **d’Express**, avec ses **middlewares** **implicites**, était complètement **incompatible** avec **TypeScript**. J’ai alors testé plusieurs bibliothèques. **D’Express**, je suis passé à **Fastify**, puis à **Adonis**, et enfin à **Nest**.

**Adonis** et **Nest** me semblaient être de bons choix, mais ils n’exploitaient pas **TypeScript** à son plein potentiel. Ces **frameworks** proposer un typage **statique** basique et laissent encore trop d’actions **implicites** où le typage ne suit qu’au bon vouloir du développeur. Dans ce cas, autant utiliser **Symfony** ou **Laravel**, non ?

C’est donc dans une optique d’obtenir un typage **continu**, de ne plus avoir de code **implicite**, de faciliter la **collaboration**, et de créer des **routes** **robustes** et **incassables** que **Duplo** est né. Ce sont ces problématiques que **Duplo** tente de résoudre. **Duplo** n’a pas pour objectif d’être une "nouvelle techno". Duplo n’invente rien. Même si vous ne l’utilisez pas avec toutes ses fonctionnalités, il vous simplifiera la vie.

## Philosophie du framework

**Duplo** met d'abord l'accent sur la **lisibilité**. Toutes les solutions que vous mettrez en place avec lui seront **explicites** et **claires**, dans le but de créer un code **auto-documenté**.

Ensuite, **Duplo** est très **opiniâtre**. Si vous l'adoptez complètement, vous n'aurez plus à vous soucier des aspects techniques liés aux vérifications dans vos **routes** (authentification, validation des données de la requête, vérification en base de données, etc.). Une seule solution simple et précise se présentera à vous dès que vous créerez une nouvelle **route**.

Toutes les ressources que vous créerez avec **Duplo** seront **réutilisables**. La construction de routes ressemblera à un **assemblage** de **blocs** de code, comme un grand jeu de briques pour enfants : `Duplo`.

**Duplo** est entièrement **typesafe**[^4]. Tout le code que vous **imbriquerez** ensemble sera automatiquement compatible. Si vous modifiez quelque chose, **TypeScript** vous indiquera immédiatement l'impact de cette modification sur l'ensemble de votre application. Et cela, avec très peu de code supplémentaire en **TypeScript**, ce qui ne vous demandera pas plus de travail.

Enfin, **Duplo** se veut **agnostique**[^2]. Son **core** ne dépend d'aucune plateforme **JavaScript** spécifique et n'utilise que des **API**s natives du langage. Cela le rend utilisable aussi bien avec **Node**, **Deno**, **Bun** qu'en environnement navigateur.

## Le scope

**Duplo** est comparable a un **Express** ou un **Fastify**, il se branche directement au **API**s natives des platforms. **Duplo** ne prend pas en charge la couche **ORM**[^6] et gestion des **services**. Cependant il met des solutions pour intégrer ce que vous souhaitez. Le rôle de **Duplo** est de vous **inciter** a faire le plus de **vérification** possible pour vous **garantir** la **fiabilité** des données.

[^1]: Helpers : Fonctions utilitaires et assistantes au typage.
[^2]: Agnostique : Qui n'est pas lié à une technologie particulière.
[^3]: Opiniâtre : vision tranchée sur les solutions possibles.
[^4]: Typesafe : Qui garantit la sécurité des types.
[^5]: Middleware : Fonction intermédiaire qui peut être utilisée pour effectuer des tâches supplémentaires avant ou après le traitement de la requête.
[^6]: ORM : Object-Relational Mapping, permet de manipuler des données de la base de données en utilisant des objets.

[Retour au Références](..)
