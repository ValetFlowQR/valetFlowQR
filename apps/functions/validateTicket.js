const express = require("express");
const {body, validationResult} = require("express-validator");
const admin = require("firebase-admin");

const router = express.Router();

// inicializa Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp();
}
const db = admin.firestore();

// Endpoint: validar y guardar ticket
router.post("/tickets/:id/validate", [
  body("name").trim().isLength({min: 2}).escape(),
  body("email").isEmail().normalizeEmail(),
  body("phone").trim().isMobilePhone("any"),
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({errors: errors.array()});
  }

  const {id} = req.params;
  const {name, email, phone} = req.body;

  try {
    await db.collection("tickets").doc(id).update({
      name,
      email,
      phone,
      validated: true,
      validationDate: admin.firestore.FieldValue.serverTimestamp(),
    });
    return res.json({success: true, message: "Ticket validado correctamente"});
  } catch (error) {
    console.error("Error al validar ticket:", error);
    return res.status(500).json({error: "Error interno del servidor"});
  }
});

module.exports = router;
