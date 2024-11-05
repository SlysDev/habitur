const admin = require('firebase-admin');
const dotenv = require("dotenv");
const serviceAccount = require("../config/serviceAccountKey.json");

dotenv.config();

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL,
});

const db = admin.firestore();

async function updateLastUpdated() {
  const usersRef = db.collection('users');
  const snapshot = await usersRef.get();

  snapshot.forEach(async (doc) => {
    await doc.ref.update({
      lastUpdated: new Date('4000-01-01T00:00:00Z')
    });
    console.log(`Updated lastUpdated for user ${doc.id}`);
  });

  console.log('All users updated.');
}

updateLastUpdated().catch(console.error);