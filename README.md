# ClinicFlow API

Backend REST API pour la gestion d'une clinique médicale, développée avec **Node.js**, **Express**, **Prisma ORM** et **PostgreSQL**.

---

## Technologies utilisées

* Node.js
* Express.js
* PostgreSQL
* Prisma ORM
* JWT (JSON Web Token)
* bcrypt
* Zod

---

## Fonctionnalités

* Authentification par email/mot de passe
* Autorisation basée sur les rôles (`admin` et `staff`)
* Gestion des patients
* Gestion des rendez-vous
* Gestion des utilisateurs
* Journal d'audit (Audit Log)
* Validation des requêtes avec Zod
* Hashage des mots de passe avec bcrypt
* API REST sécurisée avec JWT

---



---

## Installation

### 1. Cloner le projet

```bash
git clone <repository-url>

```

---

### 2. Installer les dépendances

```bash
npm install
```

---

### 3. Configurer les variables d'environnement

Créer un fichier `.env`.

```env
DATABASE_URL=

JWT_SECRET=
```

---

### 4. Générer Prisma

Si la base existe déjà :

```bash
npx prisma db pull

npx prisma generate
```

---

### 5. Lancer le serveur

```bash
npm run dev
```

ou

```bash
node src/server.js
```

Le serveur démarre sur :

```
http://localhost:3000
```

---

# Authentification

Toutes les routes protégées nécessitent un JWT.

Ajouter le header suivant :

```http
Authorization: Bearer <token>
```

Le token est obtenu après connexion.

---

# Comptes de démonstration

| Nom           | Email                                                             | Mot de passe | Rôle  |
| ------------- | ----------------------------------------------------------------- | ------------ | ----- |
| Amine Admin   | [admin@clinicflow.ma](mailto:admin@clinicflow.ma)                 | password123  | admin |
| Sara Staff    | [sara.staff@clinicflow.ma](mailto:sara.staff@clinicflow.ma)       | password123  | staff |
| Youssef Staff | [youssef.staff@clinicflow.ma](mailto:youssef.staff@clinicflow.ma) | password123  | staff |

---

# Endpoints

## Authentification

| Méthode | Endpoint          | Description                            |
| ------- | ----------------- | -------------------------------------- |
| POST    | `/api/auth/login` | Connexion utilisateur                  |
| GET     | `/api/auth/me`    | Informations de l'utilisateur connecté |

---

## Patients

| Méthode | Endpoint        |
| ------- | --------------- |
| GET     | `/patients`     |
| GET     | `/patients/:id` |
| POST    | `/patients`     |
| PUT     | `/patients/:id` |
| DELETE  | `/patients/:id` |

---

## Utilisateurs

| Méthode | Endpoint     |
| ------- | ------------ |
| GET     | `/users`     |
| GET     | `/users/:id` |
| POST    | `/users`     |
| PUT     | `/users/:id` |
| DELETE  | `/users/:id` |

---

## Rendez-vous

| Méthode | Endpoint            |
| ------- | ------------------- |
| GET     | `/appointments`     |
| GET     | `/appointments/:id` |
| POST    | `/appointments`     |
| PUT     | `/appointments/:id` |
| DELETE  | `/appointments/:id` |

---

## Audit Log

| Méthode | Endpoint     |
| ------- | ------------ |
| GET     | `/audit`     |
| GET     | `/audit/:id` |

---

# Authentification & Autorisation

Deux rôles sont disponibles :

### Admin

* Gestion complète des utilisateurs
* Gestion des patients
* Gestion des rendez-vous
* Accès aux journaux d'audit

### Staff

* Consultation et gestion des patients
* Gestion des rendez-vous
* Accès limité aux fonctionnalités administrateur

---

# Validation

Les données envoyées au backend sont validées avec **Zod**.

Exemple :

```json
{
    "email": "admin@clinicflow.ma",
    "password": "password123"
}
```

En cas d'erreur :

```json
{
    "errors": [
        {
            "path": ["email"],
            "message": "Invalid email address"
        }
    ]
}
```

---

# Sécurité

* JWT Authentication
* bcrypt Password Hashing
* Validation des entrées avec Zod
* Middleware d'authentification
* Middleware de gestion des rôles
* Protection des routes sensibles

---

# Codes HTTP

| Code | Description           |
| ---- | --------------------- |
| 200  | Succès                |
| 201  | Ressource créée       |
| 400  | Requête invalide      |
| 401  | Non authentifié       |
| 403  | Accès interdit        |
| 404  | Ressource introuvable |
| 500  | Erreur serveur        |

---

# Base de données

Le projet utilise PostgreSQL avec Prisma ORM.

Les principales tables sont :

* users
* patients
* appointments
* audit_log

---

# Développement

Pour régénérer Prisma après modification du schéma :

```bash
npx prisma generate
```

Pour synchroniser le schéma avec une base existante :

```bash
npx prisma db pull
```

Pour ouvrir Prisma Studio :

```bash
npx prisma studio
```

## Schéma base de données

![alt text](image.png)

