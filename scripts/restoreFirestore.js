const admin = require('firebase-admin');
const fs = require('fs');
const dotenv = require("dotenv");
const serviceAccount = require("../config/serviceAccountKey.json");

dotenv.config();

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL,
});

const db = admin.firestore();

/**
 * Restores a Firestore collection from a JSON backup file.
 *
 * This function reads a JSON file containing the backup data for a specified
 * Firestore collection, and then restores the data to the Firestore database
 * using a batch operation.
 *
 * @param {string} collectionName - The name of the Firestore collection to restore.
 * @returns {Promise<void>} A promise that resolves when the restore operation is complete.
 *
 * @throws {Error} If there is an issue reading the backup file or committing the batch.
 *
 * @example
 * // Restore the 'users' collection from the backup file located at '../backups/users.json'
 * restoreCollection('users')
 *   .then(() => console.log('Restore completed successfully.'))
 *   .catch(error => console.error('Error restoring collection:', error));
 */
async function restoreCollection(collectionName) {
  const data = JSON.parse(fs.readFileSync(`../backups/${collectionName}.json`));
  const batch = db.batch();

  data.forEach(doc => {
    const docRef = db.collection(collectionName).doc(doc.id);
    batch.set(docRef, doc);
  });

  await batch.commit();
  console.log(`Restore of ${collectionName} completed.`);
}

async function restoreCollections(collectionNames) {
  for (const collectionName of collectionNames) {
    await restoreCollection(collectionName);
  }
}

async function restore() {
  try {
    const collectionsToRestore = ['users', 'community-challenges'];
    await restoreCollections(collectionsToRestore);
    console.log('Restore of all collections completed successfully.');
  } catch (error) {
    console.error('Error during restore:', error);
  }
}

restore();