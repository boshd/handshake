/*

app.use((req, res) => {}, cors({maxAge: 84600}));
https://github.com/dch133/Social-Media-App/blob/master/socialmedia-server/functions/index.js
https://github.com/dalenguyen/serverless-rest-api/blob/master/functions/src/index.ts

*/
import { constructNotificationPayload } from './helpers/notifications'
import * as functions from 'firebase-functions'
import * as express from 'express'
import { db, admin } from './core/admin'
import {
    getUsersWithPreparedNumbers,
} from './handlers/users/getUsers'
import { constants } from './core/constants'

// API routes
const app = express()
app.get('/users', getUsersWithPreparedNumbers)
app.post('/users', getUsersWithPreparedNumbers)
app.put('/users', getUsersWithPreparedNumbers)
exports.api = functions.https.onRequest(app)

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

export const updateEventFCMTokenIdsArrayOnUpdate = functions.firestore
	.document(constants.FCM_OKENS_COLLECTION + '/{userId}')
	.onUpdate((change, context) => {
        const userId = context.params['userId']

        const before = change.before.data()
        const oldToken = before['fcmToken']
        const after = change.after.data()
        const newToken = after['fcmToken']

        if (oldToken != newToken) {
            db
            .collection('users')
            .doc(userId)
            .collection('channelIds')
            .get()
            .then(docs => {
                if (!docs.empty) {
                    docs.forEach(doc => {

                        admin.firestore().collection('channels').doc(doc.id).update({
                            [`fcmTokens.${userId}`]: newToken,
                        })
                        .then(() => {
                            console.log('successfully updated fcm token for', userId)
                        })
                        .catch(error => {
                            console.log(error)
                        })
                    })
                }
            })
            .catch(error => {
                console.error(error)
            })
        }

    })

// import * as functions from 'firebase-functions'
// import * as admin from 'firebase-admin'

// admin.initializeApp({
// 	credential: admin.credential.applicationDefault(),
// 	// databaseURL: 'https://spaces-new-default-rtdb.firebaseio.com/',
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

// exports.updateEventFCMTokenIdsArrayOnUpdate = functions.firestore
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


// exports.sendNotificationToAllChannelDevices = functions.firestore
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

//         if (historicSenderName && historicChannelName) {
//             title = historicSenderName + ' @ ' + historicChannelName
//         } else if (historicChannelName) {
//             title = historicChannelName
//         } else {
//             title = 'Event'
//         }

//         var text: string
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

// exports.subscribeToChannelTopic = functions.firestore
// 	.document('users/{userId}/channelIds/{channelId}')
// 	.onCreate((_, context) => {

//         console.log('in 1')
//         const userId = context.params['userId']
//         const channelId = context.params['channelId']
//         return admin.firestore().collection('users').doc(userId).get()
//         .then((userSnapshot) => {
//             if (userSnapshot.exists) {
//                 const user = userSnapshot.data()
//                 if (user) {
//                     const fcmToken: string = user['fcmToken']
//                     if (fcmToken) {
//                         console.log('pre 2')
//                         subscribeToTopic(fcmToken, channelId, userId)
//                     }
//                 }
//             }
//         })
//         .catch (error => {
//             console.log(error)
//         })

//     })

// function subscribeToTopic(fcmToken: string, topicId: string, userId: string) {
//     console.log('in 2')
//     admin.messaging().subscribeToTopic(fcmToken, topicId)
//     .then(success => {
//         console.log('successfully subscribed')
//         updateUserTopicArray(topicId, userId)
//     })
//     .catch(err => console.log(err))
// }

// function updateUserTopicArray(channelId: string, userId: string) {
//     console.log('in 3')
//     admin.firestore()
//     .collection('users')
//     .doc(userId)
//     .update({
//         'topicSubscriptions': admin.firestore.FieldValue.arrayUnion(channelId),
//     })
//     .then(s => console.log(s))
//     .catch(err => console.log(err))
// }

// exports.deleteUserFromEverywhere = functions.auth.user().onDelete((user) => {
//     console.log('deleteUserFromEverywhere triggered')
//     return admin.firestore().collection('users').doc(user.uid).collection('channelIds').get().then(docs => {

//         var batch = admin.firestore().batch()

//         if (!docs.empty) {
//             // documents exist
//             docs.forEach(doc => {
//                 batch.delete(admin.firestore().collection('users').doc(user.uid).collection('channelIds').doc(doc.id))
//                 batch.delete(admin.firestore().collection('channels').doc(doc.id).collection('participantIds').doc(user.uid))
//                 batch.update(admin.firestore().collection('channels').doc(doc.id), {
//                     'participantIds': admin.firestore.FieldValue.arrayRemove(user.uid),
//                     'admins': admin.firestore.FieldValue.arrayRemove(user.uid),
//                     'goingIds': admin.firestore.FieldValue.arrayRemove(user.uid),
//                     'maybeIds': admin.firestore.FieldValue.arrayRemove(user.uid),
//                     'notGoingIds': admin.firestore.FieldValue.arrayRemove(user.uid),
//                 })
//             })
//             removeConnectionsBetweenDeletedUserAndOthers(user)
//         }

//         // delete user anyway
//         batch.delete(admin.firestore().collection('users').doc(user.uid))

//         batch.commit()
//         .then(() => {
//             console.log('successfully batch-deleted user ', user.uid)
//         })
//         .catch(error => {
//             console.log(error)
//         })
//     })
//     .catch(error => {
//         console.log(error)
//     })
// })

// function removeConnectionsBetweenDeletedUserAndOthers(user: admin.auth.UserRecord) {

//     admin
//     .firestore()
//     .collection('users')
//     .doc(user.uid)
//     .collection('connectionUserIds')
//     .get()
//     .then(snapshots => {
//         if (!snapshots.empty) {
//             snapshots.forEach(snapshot => {
//                 var batch = admin.firestore().batch()

//                 batch.delete(admin
//                     .firestore()
//                     .collection('users')
//                     .doc(snapshot.id)
//                     .collection('userIds')
//                     .doc(user.uid)
//                 )

//                 batch.delete(admin
//                     .firestore()
//                     .collection('users')
//                     .doc(user.uid)
//                     .collection('connectionUserIds')
//                     .doc(snapshot.id)
//                 )

//                 batch.commit()
//                 .then(() => {
//                     console.log('successfully batch-deleted connection ids and other stuff ', user.uid)
//                 })
//                 .catch(error => {
//                     console.log(error)
//                 })

//             })
//         }
//     })
//     .catch(error => {
//         console.log(error)
//     })


// }

// exports.unsubscribeFromChannelTopic = functions.firestore
// 	.document('users/{userId}/channelIds/{channelId}')
// 	.onDelete((_, context) => {
//         const userId = context.params['userId']
//         const channelId = context.params['channelId']

//         return admin.firestore().collection('users').doc(userId).get().then(doc => {
//             if (!doc.exists) {
//                 console.log('No such user doc')
//             } else {
//                 const data = doc.data()
//                 if (data) {
//                     const fcmToken: string = data['fcmToken']
//                     if (fcmToken) {
//                         admin.messaging().unsubscribeFromTopic(fcmToken, channelId).then(() => {
//                             console.log('successfully unsubscribed')
//                             admin.firestore()
//                             .collection('users')
//                             .doc(userId)
//                             .update({
//                                 'topicSubscriptions': admin.firestore.FieldValue.arrayRemove(channelId),
//                             })
//                             .then(s => console.log(s))
//                             .catch(err => console.log(err))
//                         }, error => {
//                             console.log('failed to unsubscribe')
//                         })
//                     }
//                 }
//             }
//         }, error => {
//             console.log(error)
//         })
//     })

// exports.notifyTopicSubscribersWithMessage = functions.firestore
// 	.document('channels/{channelId}/thread/{messageId}')
// 	.onCreate((snapshot, context) => {
//         console.log('this is trggered -- on create message')

//         const channelId: string = context.params['channelId']
//         const messageId = context.params['messageId']
//         const data = snapshot.data()
//         const historicChannelName = data['historicChannelName']
//         const historicSenderName = data['historicSenderName']

//         var title: string

//         if (historicSenderName && historicChannelName) {
//             title = historicSenderName + ' @ ' + historicChannelName
//         } else if (historicChannelName) {
//             title = historicChannelName
//         } else {
//             title = 'Event'
//         }

//         var text: string
//         if (data['text']) {
//             text = data['text']
//         } else {
//             text = 'Could not retrieve notification text'
//         }

//         const message = {
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
//             data: {
//                 messageID: messageId,
//                 channelID: channelId,
//             },
//             topic: channelId,
//         }

//         return admin.messaging().send(message)
//         .then((response) => {
//             console.log('Successfully sent message:', response);
//         })
//         .catch((error) => {
//             console.log('Error sending message:', error);
//         });
//     })

// exports.resubscribeToChannelTopicsAfterFcmUpdate = functions.firestore
//     .document('users/{userId}/fcmTokens/{fcmToken}')
//     .onCreate((snapshot, context) => {
//         console.log('re-subscribing after fcm token change')
//         const fcmToken = context.params['fcmToken']
//         const userId = context.params['userId']
//         return admin.firestore().collection('users').doc(userId).collection('channelIds').get().then(docs => {
//             if (!docs.empty) {
//                 docs.forEach(doc =>  {
//                     admin.messaging().subscribeToTopic(fcmToken, doc.id).then(() => {
//                         console.log('successfully re-subscribed')
//                         admin.firestore()
//                         .collection('users')
//                         .doc(userId)
//                         .update({
//                             'topicSubscriptions': admin.firestore.FieldValue.arrayUnion(doc.id),
//                         })
//                         .then(s => console.log(s))
//                         .catch(err => console.log(err))
//                     }, error => {
//                         console.log('failed to re-subscribe')
//                     })
//                 })
//             }
//         }, error => {
//             console.log(error)
//         })
//     })