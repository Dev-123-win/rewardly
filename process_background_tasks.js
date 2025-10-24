const admin = require('firebase-admin');

const projectConfigs = [
    { id: 'rewardly-new', credentials: process.env.FIREBASE_ADMIN_SDK_PROD01 },
    { id: 'rewardly-9fe76', credentials: process.env.FIREBASE_ADMIN_SDK_PROD02 },
    // Add all 5 projects here, e.g.:
    // { id: 'rewardly-prod03', credentials: process.env.FIREBASE_ADMIN_SDK_PROD03 },
    // { id: 'rewardly-prod04', credentials: process.env.FIREBASE_ADMIN_SDK_PROD04 },
    // { id: 'rewardly-prod05', credentials: process.env.FIREBASE_ADMIN_SDK_PROD05 },
];

async function processProject(config) {
    let app;
    try {
        const serviceAccount = JSON.parse(config.credentials);
        app = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            databaseURL: `https://${config.id}-default-rtdb.firebaseio.com`
        }, config.id);

        const firestore = app.firestore();
        const messaging = app.messaging();

        console.log(`Processing project: ${config.id}`);

        // --- Hourly Coin Sync ---
        const syncUsersSnapshot = await firestore.collection('users')
            .where('fcmToken', '!=', null)
            .where('dailySyncStartTime', '!=', null)
            .get();

        const syncMessages = [];
        syncUsersSnapshot.forEach(doc => {
            const userData = doc.data();
            const uid = doc.id;
            const fcmToken = userData.fcmToken;
            const dailySyncStartTimeMillis = userData.dailySyncStartTime;

            if (fcmToken && dailySyncStartTimeMillis) {
                const dailySyncStartTime = new Date(dailySyncStartTimeMillis);
                const elapsedHours = (Date.now() - dailySyncStartTime.getTime()) / (1000 * 60 * 60);

                if (elapsedHours < 12) {
                    syncMessages.push({
                        token: fcmToken,
                        data: {
                            type: 'hourly_coin_sync',
                            uid: uid,
                            projectId: config.id,
                        },
                    });
                }
            }
        });

        if (syncMessages.length > 0) {
            console.log(`Sending ${syncMessages.length} FCM sync messages for project ${config.id}`);
            await messaging.sendAll(syncMessages);
        } else {
            console.log(`No FCM sync messages to send for project ${config.id}`);
        }

        // --- Referral Rewards ---
        const referralUsersSnapshot = await firestore.collection('users')
            .where('referredBy', '!=', null)
            .where('referralBonusAwarded', '==', false)
            .get();

        for (const referredUserDoc of referralUsersSnapshot.docs) {
            const referredUserData = referredUserDoc.data();
            const referredUid = referredUserDoc.id;
            const referrerCode = referredUserData.referredBy;

            if (referrerCode) {
                const referrerQuery = await firestore.collection('users')
                    .where('referralCode', '==', referrerCode)
                    .limit(1)
                    .get();

                if (!referrerQuery.empty) {
                    const referrerDoc = referrerQuery.docs[0];
                    const referrerUid = referrerDoc.id;

                    // Perform transaction for atomic update
                    await firestore.runTransaction(async (transaction) => {
                        const currentReferredUserDoc = await transaction.get(referredUserDoc.ref);
                        const currentReferrerDoc = await transaction.get(referrerDoc.ref);

                        if (currentReferredUserDoc.exists && currentReferrerDoc.exists && !currentReferredUserDoc.data().referralBonusAwarded) {
                            // Optional: Check referredUserData.daysActiveCount here if needed for referrer bonus
                            const referredUserCoins = (currentReferredUserDoc.data().coins || 0) + 5000;
                            const referrerCoins = (currentReferrerDoc.data().coins || 0) + 10000;

                            transaction.update(referredUserDoc.ref, {
                                coins: referredUserCoins,
                                referralBonusAwarded: true,
                            });
                            transaction.update(referrerDoc.ref, {
                                coins: referrerCoins,
                            });
                            console.log(`Awarded referral bonus: Referred ${referredUid}, Referrer ${referrerUid} in project ${config.id}`);
                        }
                    });
                } else {
                    console.warn(`Referrer with code ${referrerCode} not found for referred user ${referredUid} in project ${config.id}`);
                }
            }
        }

    } catch (error) {
        console.error(`Error in project ${config.id}:`, error);
    } finally {
        if (app) {
            await app.delete(); // Clean up Firebase app instance
        }
    }
}

async function main() {
    await Promise.all(projectConfigs.map(processProject));
    console.log('All background tasks complete.');
}

main().catch(console.error);
