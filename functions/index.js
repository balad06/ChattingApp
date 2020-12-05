const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
exports.myFunction = functions.firestore
    .document('chat/{message}')
    .onCreate((_snapshot, _context) => {
        return admin.messaging().sendToTopic('chat', {
            notification: {
                title: _snapshot.data().username,
                body: _snapshot.data().Text,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            },
        });

    })
