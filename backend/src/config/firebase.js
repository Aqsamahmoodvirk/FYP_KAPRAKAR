const admin = require("firebase-admin");

let serviceAccount;

if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  try {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  } catch (error) {
    console.error("Error parsing FIREBASE_SERVICE_ACCOUNT env variable:", error.message);
  }
} else {
  try {
    serviceAccount = require("./firebaseServiceAccount.json");
  } catch (error) {
    console.warn("Warning: firebaseServiceAccount.json not found and FIREBASE_SERVICE_ACCOUNT env is not set.");
  }
}

if (serviceAccount) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} else {
  console.error("Firebase Admin initialization failed: No service account provided.");
}

module.exports = admin;
