const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');
const dotenv = require("dotenv");
const serviceAccount = require("../config/serviceAccountKey.json");

dotenv.config();

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL,
});

const db = admin.firestore();
const backupsDir = path.join(__dirname, '../backups');

// Ensure the backups directory exists
if (!fs.existsSync(backupsDir)) {
  fs.mkdirSync(backupsDir);
}

/**
 * Backs up a Firestore collection by fetching all documents in the collection
 * and saving them to a JSON file.
 *
 * @param {string} collectionName - The name of the Firestore collection to back up.
 * @returns {Promise<void>} - A promise that resolves when the backup is complete.
 *
 * @example
 * // Backup the 'users' collection
 * backupCollection('users')
 *   .then(() => console.log('Backup successful'))
 *   .catch(error => console.error('Backup failed', error));
 *
 * @throws {Error} - Throws an error if the backup process fails.
 */
async function backupCollection(collectionName) {
  const snapshot = await db.collection(collectionName).get();
  const data = [];

  snapshot.forEach(doc => {
    data.push({ id: doc.id, ...doc.data() });
  });

  fs.writeFileSync(path.join(backupsDir, `${collectionName}.json`), JSON.stringify(data, null, 2));
  console.log(`Backup of ${collectionName} completed.`);
}

async function backupCollections(collectionNames) {
  for (const collectionName of collectionNames) {
    await backupCollection(collectionName);
  }
}

async function backup() {
  try {
    const collectionsToBackup = ['users', 'community-challenges'];
    await backupCollections(collectionsToBackup);
    console.log('Backup of all collections completed successfully.');
  } catch (error) {
    console.error('Error during backup:', error);
  }
}

backup();