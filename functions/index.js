const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Notify admin when a new booking is created
exports.notifyAdminOnBooking = functions.firestore
  .document('bookings/{bookingId}')
  .onCreate(async (snap, context) => {
    const booking = snap.data();
    // Get admin FCM token
    const adminDoc = await admin.firestore().collection('users').doc('admin').get();
    const adminFcmToken = adminDoc.data().fcmToken;
    if (adminFcmToken) {
      await admin.messaging().send({
        token: adminFcmToken,
        notification: {
          title: 'New Booking Request',
          body: `Branch: ${booking.branch}, Name: ${booking.userName}, Slot: ${booking.timeSlot}`,
        },
        data: {
          bookingId: context.params.bookingId,
        },
      });
    }
  });

// Notify user when booking status changes
exports.notifyUserOnStatusChange = functions.firestore
  .document('bookings/{bookingId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before.status !== after.status) {
      // Get user FCM token
      const userDoc = await admin.firestore().collection('users').doc(after.userId).get();
      const userFcmToken = userDoc.data().fcmToken;
      if (userFcmToken) {
        await admin.messaging().send({
          token: userFcmToken,
          notification: {
            title: 'Booking Status Updated',
            body: `Your booking at ${after.branch} is now ${after.status}. Slot: ${after.timeSlot}`,
          },
          data: {
            bookingId: context.params.bookingId,
          },
        });
      }
    }
  });

app.post('/delete-user', async (req, res) => {
  const { uid } = req.body;
  if (!uid) {
    return res.status(400).json({ success: false, error: 'Missing uid' });
  }
  try {
    // Delete from Firebase Authentication
    await admin.auth().deleteUser(uid);
    // Delete from Firestore
    await admin.firestore().collection('users').doc(uid).delete();
    res.json({ success: true, message: `User ${uid} deleted from Auth and Firestore.` });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
}); 