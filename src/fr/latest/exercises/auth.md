---
parent: Exercices
nav_order: 2
layout: default
title: Authentification
---

# Création d'un service d'authentification
L'objectif de cet exercice est de créer une API d’authentification.
Une réalisation de cet exercice est disponible [ici](https://github.com/duplojs/examples/tree/1.x/exercises/auth).

## Cachier des charges 
Le grand Georges souhaite avoir une application qui permet de stocker des informations personnelles. Il veut partager son application avec toute sa famille pour qu'ils puissent eux aussi enregistrer ce qu'ils souhaitent. Cependant, il ne veut pas que les uns aient accès aux informations des autres.

Pour répondre à son besoin il faut :
- Pouvoir s’inscrire. 
- Pouvoir se connecter. 
- Pouvoir récupérer ses informations personelles.
- Pouvoir modifier ses informations personelles.

Pour la base de donnée, vous utiliserez ce [fichier](https://github.com/duplojs/examples/blob/1.x/exercises/auth/src/providers/myDataBase.ts).
Le mot de passe ne doit pas être stocké en claire dans la base de donnée, vous utiliserez la libraire [bcrypt](https://www.npmjs.com/package/bcrypt) pour cela.
L'authentification ce fera via un JWT obtenu lors de la connexion, vous utiliserez la libraire [jsonwebtoken](https://www.npmjs.com/package/jsonwebtoken) pour cela.

## Tâche à réaliser
Les tâches à réaliser sont les suivantes :
- Initialiser un projet Duplo et installer les librairies `jsonwebtoken` et `bcrypt`.
- Créer la route d'inscription.
- Créer le checker pour vérifier l'existence d'un utilisateur.
- Créer le process qui permet l'autentification.
- Créer les schémas des documents des informations personelles.
- Créer le CRUD pour les informations personelles.

[Retour au sommaire](../..)
