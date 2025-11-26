const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const multer = require("multer");
const cors = require("cors")({ origin: true });

admin.initializeApp();
const app = express();
app.use(cors);

// Para recibir archivos
const upload = multer({ storage: multer.memoryStorage() });

// Ruta: recibir imagen y subir a Storage
app.post("/detectCar", upload.single("file"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "No file provided" });
    }

    const bucket = admin.storage().bucket();

    const filename = `cars/${Date.now()}.jpg`;
    const file = bucket.file(filename);

    await file.save(req.file.buffer, {
      metadata: { contentType: req.file.mimetype },
    });

    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${filename}`;

    return res.json({
      success: true,
      imageUrl: publicUrl,
      message: "Imagen subida correctamente"
    });

  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: e.toString() });
  }
});

exports.api = functions.https.onRequest(app);
exports.detectCarModel = require("./carModel").detectCarModel;
