import * as functions from 'firebase-functions'
import * as express from 'express'

const app = express()
app.get('/', (req, res) => res.status(200).send('Hey there!'))
exports.app = functions.https.onRequest(app)

// import * as functions from 'firebase-functions'
// import * as admin from 'firebase-admin'

// admin.initializeApp({
// 	credential: admin.credential.applicationDefault(),
// })

// export const getUsersWithPreparedNumbers = functions.https.onRequest(
// 	(request, response) => {
// 		const preparedNumbers: Array<string> = request.body.data.preparedNumbers
// 		const users: FirebaseFirestore.DocumentData = []

// 		Promise.all(
// 			preparedNumbers.map((preparedNumber) => {
// 				return admin
// 					.firestore()
// 					.collection('users')
// 					.where('phoneNumber', '==', preparedNumber)
// 					.get()
// 					.then((snapshot) => {
// 						if (!snapshot.empty) {
// 							snapshot.forEach((doc) => {
// 								users.push(doc.data())
// 							})
// 						}
// 					})
// 			})
// 		)
//         .then(() => {
//             return Promise.all(
//                 [response.send({ data: users })]
//             )
//         })
//         .catch((error) => {
//             functions.logger.error(error)
//         })
// 	}
// )

// export const updateEventFCMTokenIdsArrayOnUpdate = functions.firestore
// 	.document('/fcmTokens/{userId}')
// 	.onUpdate((change, context) => {
//         const userId = context.params['userId']

//         const before = change.before.data()
//         const oldToken = before['fcmToken']
//         const after = change.after.data()
//         const newToken = after['fcmToken']

//         if (oldToken != newToken) {
//             admin.
//             firestore()
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


// export const sendNotificationToAllChannelDevices = functions.firestore
// 	.document('channels/{channelId}/thread/{messageId}')
// 	.onCreate((snapshot, context) => {

//         const channelId: string = context.params['channelId']
//         const messageId = context.params['messageId']
//         const data = snapshot.data()
//         const historicChannelName = data['historicChannelName']
//         const historicSenderName = data['historicSenderName']
//         // const fcmTokenMap: Map<string, string> = data['fcmTokens']
//         const fromId: string = data['fromId']

//         var title: string
//         var text: string

//         if (historicSenderName && historicChannelName) {
//             title = historicSenderName + ' @ ' + historicChannelName
//         } else if (historicChannelName) {
//             title = historicChannelName
//         } else {
//             title = 'Event'
//         }


//         if (data['text']) {
//             text = data['text']
//         } else {
//             text = 'Could not retrieve notification text'
//         }

//         const fcmTokens = Object.keys(snapshot.data().fcmTokens)
//             .filter(key => key !== fromId)
//             .map(key => snapshot.data().fcmTokens[key]);

//         var fcmTokensArr = Array.from(fcmTokens.values()).filter((tokenUserId: string) => tokenUserId !== fromId)

//         const message = {
//             priority: 'high',
//             sound: 'default',
//             notification: {
//                 title: title,
//                 body: text,
//             },
//             apns: {
//                 headers: {
//                     'apns-priority': '10',
//                 },
//                 payload: {
//                     aps: {
//                         sound: 'push.aiff',
//                         category: 'QuickReply',
//                         badge: 0,
//                         'mutable-content': 1,
//                     },
//                     messageID: messageId,
//                     channelID: channelId,
//                     message: data,
//                 },
//             },
//             tokens: fcmTokensArr,
//         };

//         if (fcmTokensArr.length > 0) {
//             return admin.messaging().sendMulticast(message)
//             .then((response) => {
//                 console.log('sent to', fcmTokensArr)
//                 console.log('Successfully sent message: ', response);
//                 console.log(response.responses[0].error);
//             })
//             .catch((error) => {
//                 console.log('Error sending message: ', error);
//             })
//         } else {
//             return []
//         }
//     })