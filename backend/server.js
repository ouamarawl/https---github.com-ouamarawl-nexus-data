const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const path = require("path");
const app = express();
app.use(express.json());
app.use(cors());
const multer = require("multer");

// Configuration de la base de données
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "nexus-data",
});

// Connexion à MySQL
db.connect((err) => {
  if (err) {
    console.error("❌ Erreur de connexion à la base de données:", err.message);
    process.exit(1); // Stoppe le serveur si la BDD ne fonctionne pas
  } else {
    console.log("✅ Connecté à MySQL !");
  }
});

// Middleware pour vérifier si la connexion est active avant d'exécuter une requête
const checkDBConnection = (req, res, next) => {
  if (!db || db.state === "disconnected") {
    return res
      .status(500)
      .json({ message: "Erreur : base de données non connectée" });
  }
  next();
};

// gestion des images

// 📌 Servir les images depuis "Assets"
app.use("/images", express.static(path.join(__dirname, "Assets")));

// 📌 Configurer Multer pour stocker les fichiers dans "Assets"
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "Assets");
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith("image/")) {
    cb(null, true);
  } else {
    cb(new Error("❌ Seuls les fichiers images sont autorisés !"), false);
  }
};

const upload = multer({ storage, fileFilter });

app.post("/api/upload", upload.array("images", 5), (req, res) => {
  console.log("Requête reçue !");
  console.log("Headers :", req.headers);
  console.log("Body :", req.body);
  console.log("Fichiers reçus :", req.files);

  if (!req.files || req.files.length === 0) {
    console.log("❌ Aucun fichier reçu !");
    return res.status(400).json({ error: "Aucun fichier envoyé" });
  }

  // ✅ Créer un tableau d'URLs pour les images uploadées
  const imageUrls = req.files.map(
    (file) => `http://localhost:5050/images/${file.filename}`
  );
  console.log("✅ Images enregistrées :", imageUrls);

  res.json({ imageUrls });
});

// gestion des produits

// Route pour récupérer tous les produits
app.get("/api/produits", checkDBConnection, async (req, res) => {
  try {
      const { categorie } = req.query;
      let query = "SELECT * FROM produits";
      let values = [];

      if (categorie) {
          query += " WHERE categorie = ?";
          values.push(categorie);
      }

      const [rows] = await db.promise().query(query, values);
      res.status(200).json(rows);
  } catch (err) {
      console.error("Erreur lors de la récupération des produits:", err);
      res.status(500).json({ message: "Erreur serveur", erreur: err.message });
  }
});

// Route pour récupérer un produit par son ID
app.get("/api/produits/:id", checkDBConnection, (req, res) => {
  const { id } = req.params;

  db.query("SELECT * FROM produits WHERE id = ?", [id], (err, result) => {
    if (err) {
      console.error("Erreur lors de la récupération du produit:", err);
      return res
        .status(500)
        .json({ message: "Erreur serveur", erreur: err.message });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "Produit non trouvé" });
    }
    res.status(200).json(result[0]);
  });
});

// Route pour ajouter un produit
app.post("/api/produits", async (req, res) => {
  try {
    const { titre, description, prix, images, categorie } = req.body;

    // Vérifier si tous les champs sont remplis
    if (!titre || !description || !prix || !images || !categorie) {
      return res.status(400).json({ message: "Tous les champs sont requis !" });
    }

    // Convertir les images en tableau JSON si ce n'est pas déjà un tableau
    const imagesArray = Array.isArray(images) ? images : [images];
    const imagesJson = JSON.stringify(imagesArray); // Convertir en JSON

    // Insérer le produit dans la base de données
    const sql =
      "INSERT INTO produits (titre, description, prix, images, categorie) VALUES (?, ?, ?, ?, ?)";
    db.query(
      sql,
      [titre, description, prix, imagesJson, categorie],
      (err, result) => {
        if (err) {
          console.error("Erreur SQL :", err);
          return res
            .status(500)
            .json({ message: "Erreur lors de l'ajout du produit." });
        }
        res.status(201).json({
          id: result.insertId,
          titre,
          description,
          prix,
          images: imagesArray,
          categorie,
        });
      }
    );
  } catch (error) {
    console.error("Erreur serveur :", error);
    res.status(500).json({ message: "Erreur interne du serveur." });
  }
});

// Route pour modifier un produit
app.put("/api/produits/:id", checkDBConnection, (req, res) => {
  const { id } = req.params;
  const { titre, categorie, description, prix, images } = req.body;

  if (!id) {
    return res.status(400).json({ message: "L'ID du produit est requis !" });
  }
  if (!titre || !categorie || !description || !prix || !images) {
    return res.status(400).json({ message: "Tous les champs sont requis" });
  }

  // Convertir images en JSON si nécessaire
  const imagesArray = Array.isArray(images) ? images : [images];
  const imagesJson = JSON.stringify(imagesArray);

  // Mettre à jour le produit
  db.query(
    "UPDATE produits SET titre = ?, description = ?, prix = ?, images = ?, categorie = ? WHERE id = ?",
    [titre, description, prix, imagesJson, categorie, id],
    (err, result) => {
      if (err) {
        console.error("Erreur lors de la modification du produit:", err);
        return res
          .status(500)
          .json({ message: "Erreur serveur", erreur: err.message });
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ message: "Produit non trouvé." });
      }
      res.status(200).json({ message: "Produit modifié avec succès !" });
    }
  );
});

// Route pour supprimer un produit
app.delete("/api/produits/:id", checkDBConnection, (req, res) => {
  const { id } = req.params;

  db.query("DELETE FROM produits WHERE id = ?", [id], (err, result) => {
    if (err) {
      console.error("Erreur lors de la suppression du produit:", err);
      return res
        .status(500)
        .json({ message: "Erreur serveur", erreur: err.message });
    }
    res.status(200).json({ message: "Produit supprimé avec succès !" });
  });
});

// gestion des utilisateurs
// 🔹 1. Récupérer tous les administrateurs
app.get("/api/admin_membre", checkDBConnection, (req, res) => {
  db.query("SELECT * FROM admin_membre", (err, result) => {
    if (err) {
      console.error(
        "Erreur lors de la récupération des administrateurs :",
        err
      );
      return res
        .status(500)
        .json({ message: "Erreur serveur", erreur: err.message });
    }
    res.status(200).json(result);
  });
});

// 🔹 2. Récupérer un administrateur par ID
app.get("/api/admin_membre/:id", checkDBConnection, (req, res) => {
  const { id } = req.params;

  db.query("SELECT * FROM admin_membre WHERE id = ?", [id], (err, result) => {
    if (err) {
      console.error(
        "Erreur lors de la récupération de l'administrateur :",
        err
      );
      return res
        .status(500)
        .json({ message: "Erreur serveur", erreur: err.message });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "Administrateur non trouvé" });
    }
    res.status(200).json(result[0]);
  });
});
// 🔹 3. route pour ajouter un administrateur
app.post("/api/admin_membre", (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res
      .status(400)
      .json({ message: "Nom, Email et Mot de passe sont requis." });
  }

  const sql =
    "INSERT INTO admin_membre (name, email, password) VALUES (?, ?, ?)";
  db.query(sql, [name, email, password], (err, result) => {
    if (err) {
      console.error("Erreur d'insertion dans la base de données:", err);
      return res
        .status(500)
        .json({ message: "Erreur serveur lors de l'insertion." });
    }
    res.status(201).json({ message: "Administrateur ajouté avec succès !" });
  });
});

// 🔹 4. route pour supprimer un administrateur
app.delete("/api/admin_membre/:id", checkDBConnection, (req, res) => {
  console.log("🔍 Requête DELETE reçue avec ID :", req.params.id);
  let { id } = req.params;
  console.log("🔍 ID reçu pour suppression :", id);
  console.log("Type de l'ID reçu :", typeof id); // Vérification du type

  // Convertir l'ID en Number si nécessaire
  const adminId = parseInt(id, 10);
  if (isNaN(adminId)) {
    return res.status(400).json({ message: "ID invalide" });
  }

  db.query("SELECT * FROM admin_membre WHERE id = ?", [adminId], (err, result) => {
    if (err) {
      console.error("❌ Erreur SQL :", err);
      return res.status(500).json({ message: "Erreur serveur" });
    }

    if (result.length === 0) {
      console.log("⚠️ Aucun admin trouvé avec cet ID :", adminId);
      return res.status(404).json({ message: "Aucun administrateur trouvé avec cet ID." });
    }

    db.query("DELETE FROM admin_membre WHERE id = ?", [adminId], (err, result) => {
      if (err) {
        console.error("❌ Erreur SQL :", err);
        return res.status(500).json({ message: "Erreur serveur" });
      }

      console.log("✅ Administrateur supprimé avec succès !");
      res.status(200).json({ message: "Administrateur supprimé avec succès !" });
    });
  });
});


// 🔹 4. Modifier un administrateur
app.put("/api/admin_membre/:id", checkDBConnection, (req, res) => {
  const { id } = req.params;
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ message: "Tous les champs sont requis" });
  }

  db.query(
    "UPDATE admin_membre SET name = ?, email = ?, password = ? WHERE id = ?",
    [name, email, password, id],
    (err, result) => {
      if (err) {
        console.error(
          "Erreur lors de la modification de l'administrateur :",
          err
        );
        return res
          .status(500)
          .json({ message: "Erreur serveur", erreur: err.message });
      }
      res.status(200).json({ message: "Administrateur modifié avec succès !" });
    }
  );
});

// gestion des information des admins

// 🚀 Récupérer les administrateurs
app.get("/api/info_admin", (req, res) => {
  db.query(
    "SELECT id, nom, email, password, role, telephone, adresse, date_inscription FROM info_admin",
    (err, results) => {
      if (err) res.status(500).json({ error: err });
      else res.json(results);
    }
  );
});

// 🚀 Route pour ajouter un admin en attente
app.post("/api/info_admin", (req, res) => {
  const { nom, email, password, role, telephone, adresse, date_inscription } =
    req.body;

  // Vérification des champs obligatoires
  if (!nom || !email || !password || !role) {
    return res
      .status(400)
      .json({ error: "Veuillez remplir tous les champs obligatoires." });
  }

  // Vérifier si l'email existe déjà
  db.query(
    "SELECT * FROM info_admin WHERE email = ?",
    [email],
    (err, results) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      if (results.length > 0) {
        return res.status(400).json({ error: "Cet email est déjà utilisé." });
      }

      // Insérer l'utilisateur si l'email n'existe pas
      const date =
        date_inscription ||
        new Date().toISOString().slice(0, 19).replace("T", " ");
      const sql =
        "INSERT INTO info_admin (nom, email, password, role, telephone, adresse, date_inscription) VALUES (?, ?, ?, ?, ?, ?, ?)";
      const values = [nom, email, password, role, telephone, adresse, date];

      db.query(sql, values, (err, result) => {
        if (err) {
          return res.status(500).json({ error: err.message });
        }
        res.status(201).json({ message: "Admin ajouté avec succès !" });
      });
    }
  );
});

// 🚀 Route pour supprimer un admin en attente
app.delete("/api/info_admin/:id", (req, res) => {
  const { id } = req.params;
  const sql = "DELETE FROM info_admin WHERE id = ?";
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error("Erreur lors de la suppression :", err);
      res.status(500).json({ error: err.message });
    } else {
      res.json({ message: "Admin supprimé avec succès !" });
    }
  });
});

// gestion du panier

// Route pour récupérer tous les paniers
app.get("/api/panier", checkDBConnection, (req, res) => {
  db.query("SELECT * FROM panier", (err, result) => {
    if (err) {
      console.error("Erreur lors de la récupération des paniers:", err);
      return res
        .status(500)
        .json({ message: "Erreur serveur", erreur: err.message });
    }
    res.status(200).json(result);
  });
});

// Route pour récupérer un panier par ID
app.get("/api/panier/:id", checkDBConnection, (req, res) => {
  const { id } = req.params;

  db.query("SELECT * FROM panier WHERE id = ?", [id], (err, result) => {
    if (err) {
      console.error("Erreur lors de la récupération du panier:", err);
      return res
        .status(500)
        .json({ message: "Erreur serveur", erreur: err.message });
    }
    if (result.length === 0) {
      return res.status(404).json({ message: "Panier non trouvé" });
    }
    res.status(200).json(result[0]);
  });
});

// Route pour ajouter un panier
app.post("/api/panier", (req, res) => {
  const {
    produit_id,
    quantite,
    prix_unitaire,
    date_ajout,
    image_produit,
    titre_produit,
    en_stock,
  } = req.body;

  if (
    !produit_id ||
    quantite === undefined ||
    !prix_unitaire ||
    !date_ajout ||
    !image_produit ||
    !titre_produit ||
    en_stock === undefined
  ) {
    return res
      .status(400)
      .json({ message: "Tous les champs sont requis", data: req.body });
  }

  const sql =
    "INSERT INTO panier (produit_id, quantite, prix_unitaire, date_ajout, image_produit, titre_produit, en_stock) VALUES (?, ?, ?, ?, ?, ?, ?)";

  db.query(
    sql,
    [
      produit_id,
      quantite,
      prix_unitaire,
      date_ajout,
      image_produit,
      titre_produit,
      en_stock,
    ],
    (err, result) => {
      if (err) {
        console.error("Erreur lors de l'ajout au panier :", err);
        return res
          .status(500)
          .json({ message: "Erreur serveur", erreur: err.message });
      }
      res
        .status(201)
        .json({ message: "Produit ajouté au panier avec succès !" });
    }
  );
});

// Route pour modifier un panier
app.patch("/api/panier/:id", checkDBConnection, (req, res) => {
  const { id } = req.params;
  const { quantite } = req.body;

  console.log("Requête reçue :", req.body); // 🔍 Vérifie les données envoyées

  if (!quantite) {
    return res.status(400).json({ message: "La quantité est requise" });
  }

  // Récupérer le prix unitaire du produit avant de mettre à jour la table
  db.query(
    "SELECT prix_unitaire FROM panier WHERE id = ?",
    [id],
    (err, result) => {
      if (err) {
        console.error("Erreur lors de la récupération du prix:", err);
        return res
          .status(500)
          .json({ message: "Erreur serveur", erreur: err.message });
      }

      if (result.length === 0) {
        return res.status(404).json({ message: "Produit non trouvé" });
      }

      const prix_unitaire = result[0].prix_unitaire;
      const prix_total = quantite * prix_unitaire;

      console.log("Mise à jour :", { id, quantite, prix_total }); // 🔍 Vérifie les nouvelles valeurs

      // Mettre à jour la quantité et recalculer le prix total
      db.query(
        "UPDATE panier SET quantite = ?, prix_total = ? WHERE id = ?",
        [quantite, prix_total, id],
        (err, result) => {
          if (err) {
            console.error("Erreur lors de la mise à jour du panier:", err);
            return res
              .status(500)
              .json({ message: "Erreur serveur", erreur: err.message });
          }
          res.status(200).json({
            message: "Panier mis à jour avec succès !",
            quantite,
            prix_total,
          });
        }
      );
    }
  );
});

// Route pour supprimer un panier
app.delete("/api/panier/:id", checkDBConnection, (req, res) => {
  const { id } = req.params;

  db.query("DELETE FROM panier WHERE id = ?", [id], (err, result) => {
    if (err) {
      console.error("Erreur lors de la suppression du panier:", err);
      return res
        .status(500)
        .json({ message: "Erreur serveur", erreur: err.message });
    }
    res.status(200).json({ message: "Panier supprimé avec succès !" });
  });
});

// gestion des commandes
app.post("/api/commandes", (req, res) => {
  console.log("Données reçues :", req.body);

  const { nom, prenom, email, numero, produit, prix_total, lieu } = req.body;

  // Vérifier si tous les champs sont remplis
  if (!nom || !prenom || !email || !numero || !produit || !prix_total || !lieu) {
    return res.status(400).json({ message: "Tous les champs sont obligatoires." });
  }

  const sql =
    "INSERT INTO commandes (nom, prenom, email, numero, produit, prix_total, date_commande, lieu) VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)";

  db.query(
    sql,
    [nom, prenom, email, numero, produit, prix_total, lieu],
    (err, result) => {
      if (err) {
        console.error("Erreur MySQL :", err);
        return res.status(500).json({
          message: "Erreur lors de l'ajout de la commande",
          error: err.sqlMessage || err.message,
        });
      }
      res.status(200).json({ message: "Commande ajoutée avec succès", id: result.insertId });
    }
  );
});

app.get("/api/commandes", (req, res) => {
  const sql = "SELECT * FROM commandes";
  db.query(sql, (err, result) => {
    if (err) {
      return res.status(500).json({
        message: "Erreur lors de la récupération des commandes",
        error: err,
      });
    }
    res.status(200).json(result);
  });
});

// Lancer le serveur
const PORT = 5050;
app.listen(PORT, () => {
  console.log(`🚀 Serveur démarré sur http://localhost:${PORT}`);
});
