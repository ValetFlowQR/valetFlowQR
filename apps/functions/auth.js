// functions/auth.js
const express = require("express");
const crypto = require("crypto");
const admin = require("firebase-admin");
const jwt = require("jsonwebtoken");

const router = express.Router();

// inicializa Firebase Admin SDK si no está activo
if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

// Función hash segura para tokens (evita guardar en texto plano)
function hash(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

// Función simple para generar un nuevo JWT (Access Token)
function generateJwt(user) {
  // ⚠️ En producción, el secreto debe estar en variables de entorno
  return jwt.sign(
      {uid: user.uid, role: user.role},
      process.env.JWT_SECRET,
      {expiresIn: "15m"}, // token corto (15 minutos)
  );
}

// Endpoint: refresh rotatorio (genera nuevo token)
router.post("/auth/refresh", async (req, res) => {
  try {
    const {refreshToken, uid} = req.body;
    if (!refreshToken || !uid) {
      return res.status(400).json({error: "Missing token or uid"});
    }

    // Buscar refresh token en Firestore (hash)
    const hashed = hash(refreshToken);
    const tokenDoc = await db.collection("refreshTokens").doc(hashed).get();
    if (!tokenDoc.exists) {
      return res.status(401).json({error: "Invalid or expired token"});
    }

    // Generar nuevos tokens
    const user = {uid}; // normalmente traerías más datos del usuario
    const newAccess = generateJwt(user);
    const newRefresh = crypto.randomBytes(64).toString("hex");

    // Guardar nuevo refresh y eliminar el anterior
    await db.collection("refreshTokens").doc(hash(newRefresh)).set({
      uid: user.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await db.collection("refreshTokens").doc(hashed).delete();

    res.json({
      access_token: newAccess,
      refresh_token: newRefresh,
    });
  } catch (error) {
    console.error("Error en refresh rotatorio:", error);
    res.status(500).json({error: "Server error"});
  }
});

module.exports = router;
