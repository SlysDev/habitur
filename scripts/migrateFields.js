const admin = require("firebase-admin");
const dotenv = require("dotenv");
const serviceAccount = require("../config/serviceAccountKey.json");

dotenv.config();

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: process.env.FIREBASE_DATABASE_URL,
});

const db = admin.firestore();

async function migrateHabits(userDoc) {
    console.log(`Starting migration of habits for user ${userDoc.id}`);
    const habitsRef = userDoc.ref.collection('habits');
    const habitsSnapshot = await habitsRef.get();
    const batch = db.batch();

    habitsSnapshot.forEach((habitDoc) => {
        const data = habitDoc.data();
        console.log(`Migrating habit ${habitDoc.id} for user ${userDoc.id} with data:`, data);

        const updatedData = {
            targetGoal: data['requiredCompletions'],
            currentProgress: data['completionsToday'],
            totalProgress: data['totalCompletions'],
        };

        // Log the values to ensure they are not undefined
        console.log(`targetGoal: ${updatedData.targetGoal}`);
        console.log(`currentProgress: ${updatedData.currentProgress}`);
        console.log(`totalProgress: ${updatedData.totalProgress}`);

        // Remove undefined values
        Object.keys(updatedData).forEach(key => {
            if (updatedData[key] === undefined) {
                delete updatedData[key];
            }
        });

        // Add deletion of old fields
        updatedData['requiredCompletions'] = admin.firestore.FieldValue.delete();
        updatedData['completionsToday'] = admin.firestore.FieldValue.delete();
        updatedData['totalCompletions'] = admin.firestore.FieldValue.delete();

        batch.update(habitDoc.ref, updatedData);
    });

    await batch.commit();
    console.log(`Migration of habits for user ${userDoc.id} completed.`);
}

async function migrateUsers() {
    console.log("Starting migration of users");
    const usersRef = db.collection('users');
    const usersSnapshot = await usersRef.get();

    for (const userDoc of usersSnapshot.docs) {
        await migrateHabits(userDoc);
    }
    console.log("Migration of users completed.");
}

async function migrate() {
    try {
        console.log("Starting migration process");
        await migrateUsers();
        console.log("Migration completed successfully.");
    } catch (error) {
        console.error("Error during migration:", error);
    }
}

migrate();