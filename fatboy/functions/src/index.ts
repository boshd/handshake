import { constructNotificationPayload } from './helpers/notifications'
import * as functions from 'firebase-functions'
import * as express from 'express'
// import * as cors from 'cors'
import { admin } from './core/admin'

import {
    getUsersWithPreparedNumbers,
} from './handlers/users/getUsers'

const app = express()
// app.use((req, res) => {}, cors({maxAge: 84600}));

// API
app.get('/users', getUsersWithPreparedNumbers)

exports.api = functions.https.onRequest(app)

// console.log(db)

// ------------------------------------------------------------------------------------I'm waiting ono

export const sendNotificationToAllChannelDevices = functions.firestore
	.document('channels/{channelId}/thread/{messageId}')
	.onCreate((snapshot, context) => {
        try {
            const channelId: string = context.params['channelId']
            const messageId = context.params['messageId']
            const data = snapshot.data()
            const historicChannelName = data['historicChannelName']
            const historicSenderName = data['historicSenderName']
            const fromId: string = data['fromId']

            const messagePayload = constructNotificationPayload(
                snapshot.data().fcmTokens,
                messageId,
                channelId,
                historicSenderName,
                historicChannelName,fromId
            )

            return admin.messaging().sendMulticast(messagePayload)
            .then((res) => {
                console.log('Successfully sent message // ', res);
            })
            .catch((error) => {
                console.log('Error sending message // ', error)
            })
        } catch (error) {
            console.log('Error sending message // ', error)
            return
        }
    })

// export const updateEventFCMTokenIdsArrayOnUpdate = functions.firestore
// 	.document('/fcmTokens/{userId}')
// 	.onUpdate((change, context) => {
//         const userId = context.params['userId']

//         const before = change.before.data()
//         const oldToken = before['fcmToken']
//         const after = change.after.data()
//         const newToken = after['fcmToken']

//         if (oldToken != newToken) {
//             db
//             .collection('users')
//             .doc(userId)
//             .collection('channelIds')
//             .get()
//             .then(docs => {
//                 if (!docs.empty) {
//                     docs.forEach(doc => {

//                         admin.firestore().collection('channels').doc(doc.id).update({
//                             [`fcmTokens.${userId}`]: newToken,
//                         })
//                         .then(() => {
//                             console.log('successfully updated fcm token for', userId)
//                         })
//                         .catch(error => {
//                             console.log(error)
//                         })
//                     })
//                 }
//             })
//             .catch(error => {
//                 console.error(error)
//             })
//         }

//     })