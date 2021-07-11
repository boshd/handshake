/*

app.use((req, res) => {}, cors({maxAge: 84600}));
https://github.com/dch133/Social-Media-App/blob/master/socialmedia-server/functions/index.js
https://github.com/dalenguyen/serverless-rest-api/blob/master/functions/src/index.ts

*/

// import { doc, updateDoc, arrayUnion, arrayRemove } from "firebase/firestore";
import { firestore } from 'firebase-admin'
import { constructNotificationPayload } from './helpers/notifications'
import * as functions from 'firebase-functions'
// import * as express from 'express'
import { db, admin } from './core/admin'
// import {
//     getUsersWithPreparedNumbers,
// } from './handlers/users/getUsers'
import { constants } from './core/constants'
// import { incrementBadge, sendMessageToMember, updateChannelLastMessage } from './helpers/messaging'

// API routes
// const app = express()
// app.get('/users', getUsersWithPreparedNumbers)
// app.post('/users', getUsersWithPreparedNumbers)
// app.put('/users', getUsersWithPreparedNumbers)
// exports.api = functions.https.onRequest(app)

// exports.getUsersWithPreparedNumbers = getUsersWithPreparedNumbers


exports.getUsersWithPreparedNumbers = functions.https.onRequest((req, res) => {
	try {
		const preparedNumbers: Array<string> = req.body.data.preparedNumbers
		console.log(preparedNumbers)
		const users: Array<FirebaseFirestore.DocumentData> = []

		Promise.all(
			preparedNumbers.map((number) => {
				return db
				.collection(constants.USERS_COLLECTION)
				.where('phoneNumber', '==', number)
				.get()
				.then((snapshot) => {
					if (!snapshot.empty) {
						snapshot.forEach((doc) => {
							users.push(doc.data())
						})
					}
				})
			})
		)
		.then(() => {
			return Promise.all(
				[res.send({ data: users })]
			)
		})
		.catch((error) => {
			console.log(error)
		})

	} catch (error) {
		console.log(error)
		res.status(400).send(`Malformed request.. we need some schema validators up in this bish`)
	}
})

export const sendNotificationToDevice = functions.firestore
    .document('users/{userId}/channelIds/{channelId}/messageIds/{messageId}')
    .onCreate((userMessageSnapshot, context) => {
        const userId: string = context.params['userId']
        const channelId: string = context.params['toId']
        const messageId: string = context.params['messageId']

        if (userMessageSnapshot.exists) {
            const userMessageData = userMessageSnapshot.data()
            if (userMessageData !== undefined && userMessageData !== null) {
                const fromId = userMessageData['fromId']
                if (fromId !== userId) {
                    try {
                        admin
                        .firestore()
                        .doc('messages/'+messageId)
                        .get()
                        .then(async snapshot => {
                            if (snapshot.exists) {
                                const data = snapshot.data()
                                if (data !== undefined && data !== null) {
                                    const historicChannelName = data['historicChannelName']
                                    const historicSenderName = data['historicSenderName']
                                    const text: string = data['text']
                                    const fcmTokens = data['fcmTokens']
                                    let badge = 0

                                    admin
                                    .firestore()
                                    .doc('users/'+userId)
                                    .get()
                                    .then(userChannelSnapshot => {
                                        if (userChannelSnapshot.exists) {
                                            const userData = userChannelSnapshot.data()
                                            if (userData !== undefined && userData !== null) {
                                                badge = userData['badge']
                                            }
                                        }

                                        functions.logger.info(badge)
                                        functions.logger.info(fcmTokens)
                                        const currentUserFCMToken = fcmTokens[userId]

                                        const messagePayload = constructNotificationPayload(
                                            currentUserFCMToken,
                                            messageId,
                                            channelId,
                                            historicSenderName,
                                            historicChannelName,
                                            fromId,
                                            text,
                                            badge,
                                        )

                                        return admin.messaging().sendMulticast(messagePayload)
                                        .then((res) => {
                                            functions.logger.info('Successfully sent message // ', res);
                                        })
                                        .catch((error) => {
                                            functions.logger.error('Error sending message // ', error)
                                        })
                                    })
                                    .catch((error) => {
                                        functions.logger.error(error)
                                    })
                                }
                            }
                            return null
                        })
                        .catch(err => {
                            functions.logger.error(err)
                        })
                    } catch (err) {
                        functions.logger.error(err)
                    }
                }
            }
        }
    })

export const updateEventFCMTokenIdsArrayOnUpdate = functions.firestore
	.document(constants.FCM_TOKENS_COLLECTION + '/{userId}')
	.onUpdate((change, context) => {
        const userId = context.params['userId']

        const before = change.before.data()
        const oldToken = before['fcmToken']
        const after = change.after.data()
        const newToken = after['fcmToken']

        if (oldToken !== newToken) {
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

    /*
    CHANNEL OPERATIONS
    */

    exports.sendGroupMessage = functions.firestore
    .document(constants.CHANNELS_COLLECTION + '/{channelId}/messageIds/{messageId}')
    .onCreate((onCreateSnapshot, context) => {
        console.log('message created and triggered this cloud f\'n')
        const channelId = context.params.channelId
        const messageId = context.params.messageId
        const data = onCreateSnapshot.data()
        functions.logger.log(data['fromId'])
        const senderId = data['fromId']

        if (senderId === null || senderId === '') {
            return
        }

        console.log('pre-admin')

        return db
        .collection(constants.CHANNELS_COLLECTION + '/'+ channelId + '/participantIds')
        .get()
        .then(snapshot => {
            if (!snapshot.empty) {
                console.log('snapshot not empty')
                const members = snapshot.docs
                members.forEach(member => {
                    console.log('sender id: ' + senderId + ' // member id: ' + member.id)

                    if (member.id !== senderId) {
                        functions.logger.info('member id is // ', member.id)
                        batchSetEverything(member.id)
                        incrementBadge(member.id)
                    }
                })
            }
        })
        .then(snapshot => { functions.logger.info('success') })
        .catch(err => { functions.logger.error(err) })

        function batchSetEverything(memberId: string) {

            const batch = admin.firestore().batch()

            batch.set((
                admin.firestore()
                .collection('users')
                .doc(memberId)
                .collection('channelIds')
                .doc(channelId)
                .collection('messageIds')
                .doc(messageId)
            ), {
                    'fromId': senderId,
            }, {
                merge: true,
            })

            batch.set((
                admin.firestore()
                .collection('users')
                .doc(memberId)
                .collection('channelIds')
                .doc(channelId)
            ), {
                'lastMessageId': messageId,
            }, {
                merge: true,
            })

            batch
            .commit()
            .then(() => {
                functions.logger.info('successful batch commmit')
            })
            .catch(err => {
                functions.logger.error(err)
            })

        }

        function incrementBadge(memberId: string) {
            /*
            increment badge for channel + increment for user total
            */
            functions.logger.log('executing incrementBadge..')

            const channelRef = db
            .collection('users')
            .doc(memberId)
            .collection('channelIds')
            .doc(channelId)

            const userRef = db
            .collection('users')
            .doc(memberId)

            try {
                db.runTransaction(async (t) => {
                    const doc: FirebaseFirestore.DocumentData = await t.get(userRef)
                    const newthing = (doc.data()['badge'] || 0) + 1
                    t.update(userRef, {
                        'badge': newthing,
                    })
                })
                .then(snapshot => { functions.logger.info('success incrementBadge') })
                .catch(err => { functions.logger.error('error in incrementBadge // ', err) })

                db.runTransaction(async (t) => {
                    const doc: FirebaseFirestore.DocumentData = await t.get(channelRef)
                    const newthing = (doc.data()['badge'] || 0) + 1
                    t.update(channelRef, {
                        'badge': newthing,
                    })
                })
                .then(snapshot => { functions.logger.info('success incrementBadge') })
                .catch(err => { functions.logger.error('error in incrementBadge // ', err) })
            } catch (e) {
                functions.logger.error('Transaction failure:', e)
            }

        }
    })

// exports.updateChannelFCMTokens = functions.firestore
//     .document(constants.CHANNELS_COLLECTION + '/{channelId}/participantIds}')
//     .onWrite((snapshot, context) => {

//         functions.logger.log('updateChannelFCMTokens')

//         const userRef = db
//         .collection('users')
//         .doc(memberId)

//         try {
//             db.runTransaction(async (doc) => {
//                 const doc: FirebaseFirestore.DocumentData = await t.get(userRef)
//                 const newthing = (doc.data()['badge'] || 0) + 1

//                 snapshot.update(userRef, {
//                     'badge': newthing,
//                 })
//             })
//             .then(snapshot => { functions.logger.info('success incrementBadge') })
//             .catch(err => { functions.logger.error('error in incrementBadge // ', err) })
//         } catch (e) {
//             functions.logger.error('Transaction failure:', e)
//         }

//     })

exports.updateChannelParticipantIdsUponDelete = functions.firestore
    .document(constants.USERS_COLLECTION + '/{userId}/channelIds/{channelId}')
    .onDelete((_, context) => {

        /*
        This function takes care of removing the userid from the channel, abstracting away
        the need to do it locally. It's not the client's responsibility anymore.
        */

        functions.logger.log('updateChannelParticipantIdsUponDelete')

        // check if person is the only admin/author/etc.
        // remove user's fcm token for notifications thru transaction?

        const channelId = context.params.channelId
        const userId = context.params.userId

        const channelReference = admin.firestore().collection('channels').doc(channelId)
        const channelParticipantReference = channelReference.collection('participantIds').doc(userId)

        var batch = admin.firestore().batch()

        batch.update(channelReference, {
            'participantIds': firestore.FieldValue.arrayRemove(userId),
            'admins': firestore.FieldValue.arrayRemove(userId),
            'goingIds': firestore.FieldValue.arrayRemove(userId),
            'maybeIds': firestore.FieldValue.arrayRemove(userId),
            'notGoingIds': firestore.FieldValue.arrayRemove(userId),
        })

        batch.delete(channelParticipantReference)

        batch.commit()
        .then(() => {
            console.log('successful batch commit')
        })
        .catch(error => {
            console.log(error)
        })

        // fcm token transaction
        // admin.firestore().runTransaction()

    })

exports.updateChannelParticipantIdsUponCreate = functions.firestore
    .document(constants.USERS_COLLECTION + '/{userId}/channelIds/{channelId}')
    .onCreate((_, context) => {

        /*
        This function takes care of adding the userid to the channel, abstracting away
        the need to do it locally. It's not the client's responsibility anymore.
        */

        functions.logger.log('updateChannelParticipantIdsUponCreate')

        const channelId = context.params.channelId
        const userId = context.params.userId

        const channelReference = admin.firestore().collection('channels').doc(channelId)
        const channelParticipantReference = channelReference.collection('participantIds').doc(userId)

        var batch = admin.firestore().batch()

        batch.update(channelReference, {
            'participantIds': firestore.FieldValue.arrayUnion(userId),
        })

        batch.create(channelParticipantReference, {})

        batch.commit()
        .then(() => {
            console.log('successful batch commit')
        })
        .catch(error => {
            console.log(error)
        })

    })

exports.channelCreationHandler = functions.firestore
    .document(constants.CHANNELS_COLLECTION + '/{channelId}')
    .onCreate((snapshot, context) => {

        functions.logger.log('channelCreationHandler')

        const channelId = context.params.channelId
        const channel = snapshot.data()
        const participantIds = channel.participantIds as [string]

        const channelReference = admin.firestore().collection(constants.CHANNELS_COLLECTION).doc(channelId)

        const newParticipantReference = channelReference.collection('participantIds').doc(channelId)

        var fcmTokens: {[k: string]: any} = {}

        var batch = admin.firestore().batch()

        var dataFetchPromise = new Promise((resolve, reject) => {
            participantIds.forEach(participantId => {
                const newChannelReference = admin.firestore().collection(constants.USERS_COLLECTION).doc(participantId).collection('channelIds').doc(channelId)

                batch.create(newParticipantReference, {})
                batch.create(newChannelReference, {})

                admin
                .firestore()
                .collection(constants.FCM_TOKENS_COLLECTION)
                .doc(participantId)
                .get()
                .then(participantSnapshot => {
                    const token = participantSnapshot?.data()?.fcmToken as string
                    fcmTokens[participantId] = token
                })
                .catch(err => { functions.logger.error('Error getting data', err) })
            })
        })

        dataFetchPromise.then(() => {
            functions.logger.log('All done!', fcmTokens);
        })
        .catch(err => { functions.logger.error('Promise error?', err) })

        return dataFetchPromise

        // participantIds.forEach(participantId => {
        //     const newChannelReference = admin.firestore().collection(constants.USERS_COLLECTION).doc(participantId).collection('channelIds').doc(channelId)

        //     batch.create(newParticipantReference, {})
        //     batch.create(newChannelReference, {})

        //     admin
        //     .firestore()
        //     .collection(constants.FCM_TOKENS_COLLECTION)
        //     .doc(participantId)
        //     .get()
        //     .then(snapshot => {
        //         const token = snapshot?.data()?.fcmToken as string
        //         // fcmTokensMap.set(participantId, token)
        //         // fcmTokensMap = 'rf'
        //     })
        //     .catch(err => { functions.logger.error('Error getting data', err) })
        // })

        // batch.set(channelReference, {
        //     'fcmTokens': fcmTokensMap
        // })

        // batch.commit()

        // add channel to all participants
        // add participants to the channel
        // fetch user's fcm tokens and add to group

        // const channelRef = admin.firestore().collection(constants.CHANNELS_COLLECTION).doc(channelId)

        // try {
        //     db.runTransaction(async (transaction) => {
        //         const doc = await transaction.get(channelRef)
        //         const fcmTokens = doc?.data()?.fcmTokens as Map<string, string>
        //         fcmTokens.set(participantId, )
        //         fcmTokens[participantId] = 'df'

        //         transaction.update(channelRef, {
        //             'fcmTokens': newthing,
        //         })
        //     })
        //     .then(snapshot => { functions.logger.info('success incrementBadge') })
        //     .catch(err => { functions.logger.error('error in incrementBadge // ', err) })
        // } catch (e) {
        //     functions.logger.error('Transaction failure:', e)
        // }

    })