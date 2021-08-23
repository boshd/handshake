// import { firestore } from 'firebase-admin'
// import { constructNotificationPayload } from './helpers/notifications'
// import * as functions from 'firebase-functions'
// import { db, admin } from './core/admin'
// import { constants } from './core/constants'

// const LOGGER = functions.logger


//  exports.handleNewMessageCreatedInMessages = functions.firestore
//  .document(constants.MESSAGES_COLLECTION + '/{messageId}')
//  .onCreate((snapshot, context) => {

//     // add message to user, will trigger below function

//     const messageId: string = context.params['messageId']

//     if (snapshot.exists) {
//         const messageData = snapshot.data()
//         const channelId = messageData['toId']
//         const timestamp = messageData['timestamp']
//         const fromId = messageData['fromId']
//         const senderName = messageData['senderName']
//         const text = messageData['text']
//         const channelName = messageData['channelName']
//         const fcmTokens = messageData['fcmTokens']

//         return admin
//         .firestore()
//         .collection(constants.CHANNELS_COLLECTION + '/'+ channelId + '/participantIds')
//         .get()
//         .then(participantSnapshot => {
//             if (!participantSnapshot.empty) {
//                 const batch = admin.firestore().batch()
//                 const members = participantSnapshot.docs

//                 members.forEach(member => {
//                     if (member.id !== fromId) {
//                         const userChannelReference = admin.firestore().collection(constants.USERS_COLLECTION ).doc(member.id).collection('channelIds').doc(channelId)
//                         batch.set((
//                             userChannelReference
//                             .collection('messageIds')
//                             .doc(messageId)
//                         ), {
//                                 'fromId': fromId,
//                                 'timestamp': timestamp,
//                                 'text': text,
//                                 'senderName': senderName,
//                                 'channelName': channelName,
//                                 'fcmTokens': fcmTokens
//                         }, { merge: true, })

//                         batch.set((
//                             userChannelReference
//                         ), {
//                             'lastMessageId': messageId,
//                         }, { merge: true, })
//                     }
//                 })

//                 try {
//                     return batch.commit()
//                     .then(() => { LOGGER.log('SUCCESS setting id for each user') })
//                     .catch((err) => { LOGGER.error(err) })
//                 } catch (err) {
//                     LOGGER.error(err)
//                     return null
//                 }
//             }
//             return null
//         })
//         .catch((error) => { functions.logger.error('Error sending message // ', error) })
//     }
//     return null

//  })

//  exports.handleNewMessageCreatedInUser = functions.firestore
//  .document(constants.USERS_COLLECTION + '{userId}/channelIds/{channelId}/messageIds/{messageId}')
//  .onCreate((snapshot, context) => {


//     // having this as a trggered function will ensure asynchronicity

//     const userId: string = context.params['userId']
//     const messageId: string = context.params['messageId']
//     const channelId: string = context.params['channelId']
//     var badge = 0


//     if (snapshot.exists) {
//         const messageData = snapshot.data()
//         // const timestamp = messageData['timestamp']
//         const fromId = messageData['fromId']
//         const fcmTokens = messageData['fcmTokens']
//         const senderName = messageData['senderName']
//         const text = messageData['text']
//         const channelName = messageData['channelName']

//         const fcmToken = fcmTokens[userId]

//         incrementBadge(userId)
//         ?.then(() => {
//             LOGGER.log('SUCCESS incrementing badge for user')
//             LOGGER.log('notifying...')

//             const messagePayload = constructNotificationPayload(
//                 fcmToken,
//                 messageId,
//                 channelId,
//                 senderName,
//                 channelName,
//                 fromId,
//                 text,
//                 badge,
//             )

//             if (fromId !== userId) {
//                 return admin
//                 .messaging()
//                 .sendMulticast(messagePayload)
//                 .then((res) => { functions.logger.info('Successfully sent notification // ', res) })
//                 .catch((error) => { functions.logger.error('Error sending notification // ', error) })
//             }

//         })
//         .catch((err) => { LOGGER.error(err) })


//     }

//     function incrementBadge(id: string) {
//         const userChannelRef = db
//         .collection('users')
//         .doc(id)
//         .collection('channelIds')
//         .doc(id)

//         const userRef = db
//         .collection('users')
//         .doc(id)

//         try {
//             return db.runTransaction(async (updateFunction) => {
//                 const userChannelDoc: FirebaseFirestore.DocumentData = await updateFunction.get(userChannelRef)
//                 const userDoc: FirebaseFirestore.DocumentData = await updateFunction.get(userRef)

//                 const newUserChannelBadgeValue = (userChannelDoc.data()['badge'] || 0) + 1
//                 const newUserBadgeValue = (userDoc.data()['badge'] || 0) + 1

//                 updateFunction.update(userRef, {
//                     'badge': newUserBadgeValue
//                 })

//                 updateFunction.update(userChannelRef, {
//                     'badge': newUserChannelBadgeValue
//                 })

//                 badge = newUserBadgeValue
//             })
//             .then(_ => { LOGGER.info('success incrementing badges') })
//             .catch(err => { LOGGER.error('error in incrementing badges // ', err); badge = 0 })
//         } catch (err) {
//             LOGGER.error('Transaction failure:', err)
//             return null
//         }
//     }

//  })

//  // helper mthds