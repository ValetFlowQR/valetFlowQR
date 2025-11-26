const functions = require("firebase-functions");
const admin = require("firebase-admin");
const multer = require("multer");
const express = require("express");
const cors = require("cors");

admin.initializeApp();

const app = express();
app.use(cors({ origin: true }));

// Multer para recibir el archivo
const upload = multer({ storage: multer.memoryStorage() });

app.post("/", upload.single("file"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "No se envió ninguna imagen" });
    }

    const imageBuffer = req.file.buffer;

    if (imageBuffer.length < 50) {
      return res.status(400).json({ error: "Imagen inválida" });
    }

    // TODO: Aquí procesas la imagen con tu modelo real
    // Ejemplo temporal:
    return res.json({
      brand: "Demo Brand",
      model: "Demo Model",
      confidence: 0.95
    });

  } catch (err) {
    console.error("Error:", err);
    return res.status(500).json({ error: "Error interno" });
  }
});

// Export V2 compatible
exports.detectCarModel = functions.https.onRequest(app);
