---
layout: default
parent: Commencer
title: Routine de vérification
nav_order: 6
---

# Routine de vérification
{: .no_toc }
Tous les exemples présentés dans ce cours sont disponibles en entier [ici](https://github.com/duplojs/examples/tree/main/get-started/verification-routine).

1. TOC
{:toc}

## Les process
Les processes font partie des objet complexe de DuploJS. Leurs création passe aussi par le bier d'un **[builder](../../required/design-patern-builder)**. L'objet `Route` et l'objet `Process` sont tout les deux étendu de l'objet `Duplose`. Un **process** n'est donc pas diférent dans ça structure est ça déclaration pars rapport a une route. Cependant, le builder des **process** ne propose pas de method `handler` car ceux-ci ne doivent pas avoir de d'étape `HandlerStep`. Les `HandlerStep` pour les **Routes**, ont pour role de contenire l'actions de la route. Dans le cas des **Process**, il ne doivent pas avoir d'action car ils sont uniquement la pour faire des vérification routiniére. Les **Process** son parfait pour :
- l’authentification
- la vérificarion de role
- factoriser quelconque suite de vérification.

## Créer un process
La créaction d'un **Process** est semblable a c'elle d'une **Route**. Il faut applé la fonction `useBuiler` pour utilisé la méthode `createProcess`.

## Implémentation d'un process

## Créer ses propres builders

<br>

[\<\< Aborder une nouvelle route](../how-to-approach-new-road){: .btn .mr-4 } 