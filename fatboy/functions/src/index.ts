import { firestore } from 'firebase-admin'
import { constructNotificationPayload } from './helpers/notifications'
import * as functions from 'firebase-functions'
import { db, admin } from './core/admin'
import { constants } from './core/constants'

const LOGGER = functions.logger

/**
 * Returns users given prepaerd phone numbers.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
exports.getUsersWithPreparedNumbers = functions.https.onRequest((req, res) => {
	try {
		const preparedNumbers: Array<string> = req.body.data.preparedNumbers
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

exports.notifyOnMessageCreation = functions.firestore
.document(constants.MESSAGES_COLLECTION + '/{messageId}')
.onCreate((snapshot, context) => {

    // having this as a trggered function will ensure asynchronicity

    const userId: string = context.params['userId']
    const messageId: string = context.params['messageId']
    const channelId: string = context.params['channelId']

    if (snapshot.exists) {
        const messageData = snapshot.data()
        // const timestamp = messageData['timestamp']
        const fromId = messageData['fromId']
        const fcmTokens = messageData['fcmTokens']
        const senderName = messageData['senderName']
        const text = messageData['text']
        const channelName = messageData['channelName']

        delete fcmTokens[fromId]

        const tokens = Object.keys(fcmTokens).map(key => fcmTokens[key])

        const messagePayload = constructNotificationPayload(
            tokens,
            messageId,
            channelId,
            senderName,
            channelName,
            fromId,
            text,
            0,
        )

        if (fromId != userId) {
            return admin
            .messaging()
            .sendMulticast(messagePayload)
            .then((res) => { functions.logger.info('Successfully sent notification // ', res) })
            .catch((error) => { functions.logger.error('Error sending notification // ', error) })
        } else {
            return null
        }
    } else {
        return null
    }

})

exports.addMessageReferenceToParticipantsOnMessageCreation = functions.firestore
.document(constants.MESSAGES_COLLECTION + '/{messageId}')
.onCreate((snapshot, context) => {
   const messageId: string = context.params['messageId']

    if (snapshot.exists) {
        const messageData = snapshot.data()
        const channelId = messageData['toId']
        const timestamp = messageData['timestamp']
        const fromId = messageData['fromId']

        const fcmTokens = messageData['fcmTokens']
        const participantIds = Object.keys(fcmTokens)

        participantIds.forEach(participantId => {
            if (participantId !== fromId) {
                LOGGER.log('writing for id: ', participantId)

                const batch = admin.firestore().batch()
                const userChannelReference = admin.firestore().collection(constants.USERS_COLLECTION).doc(participantId).collection('channelIds').doc(channelId)

                // set msg reference
                batch.set((
                userChannelReference
                .collection('messageIds')
                .doc(messageId)
                ), {
                    'fromId': fromId,
                    'timestamp': timestamp,
                }, { merge: true })

                // set last msg
                batch.set((
                    userChannelReference
                ), {
                    'lastMessageId': messageId,
                }, { merge: true })

                // atomically increment the channel's badge by 1.
                batch.update(userChannelReference, {
                    badge: admin.firestore.FieldValue.increment(1),
                })

                // update badge
                try {
                    batch.commit()
                    .then(() => { LOGGER.log('SUCCESSFUL OPREATIONS for ', participantId) })
                    .catch((err) => { LOGGER.error(err) })
                } catch (err) { LOGGER.error(participantId, ' -- one of the addMessageReferenceToParticipantsOnMessageCreation operations failed: ', err) }
            }
        })
    }
})

// exports.incrementBadgeOnUserMessageCreation = functions.firestore
// .document(constants.USERS_COLLECTION + '/{userId}/channelIds/{channelId}/messageIds/{messageId}')
// .onCreate((snapshot, context) => {
//     const userId: string = context.params['userId']
//     const channelId: string = context.params['channelId']
//     if (snapshot.exists && userId) {
//        const messageData = snapshot.data()
//        const fromId = messageData['fromId']
//         if (fromId != userId) {
//             const userChannelRef = db
//             .collection('users')
//             .doc(userId)
//             .collection('channelIds')
//             .doc(channelId)

//             try {
//                 return db.runTransaction(async (updateFunction) => {
//                     const userChannelDoc: FirebaseFirestore.DocumentData = await updateFunction.get(userChannelRef)

//                     LOGGER.info('user channel doc ', userChannelDoc.data())
//                     const newUserChannelBadgeValue = (userChannelDoc.data()['badge'] || 0) + 1
//                     updateFunction.update(userChannelRef, {
//                         'badge': newUserChannelBadgeValue,
//                     })
//                 })
//                 .then(_ => { LOGGER.info('success incrementing badge') })
//                 .catch(err => { LOGGER.error('error in incrementing badge // ', err) })
//             } catch (err) {
//                 LOGGER.error('Transaction failure:', err)
//                 return null
//             }
//         } else {
//             return null
//         }
//     } else {
//         return null
//     }

// })

/**
 * Returns users given prepaerd phone numbers.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
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

/**
 * Returns users given prepaerd phone numbers.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
exports.updateChannelParticipantIdsUponDelete = functions.firestore
    .document(constants.USERS_COLLECTION + '/{userId}/channelIds/{channelId}')
    .onDelete((snapshot, context) => {

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

    })


/**
 * ...
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
exports.channelCreationHandler = functions.firestore
    .document(constants.CHANNELS_COLLECTION + '/{channelId}')
    .onCreate((snapshot, context) => {

        functions.logger.log('channelCreationHandler')


        const channelId = context.params.channelId
        const channel = snapshot.data()
        const participantIds = channel.participantIds as [string]
        const authorId = channel.author as string

        const channelReference = admin.firestore().collection(constants.CHANNELS_COLLECTION).doc(channelId)

        var fcmTokens: {[k: string]: any} = {}

        var batch = admin.firestore().batch()

        try {
            return Promise.all(
                participantIds.map((participantId) => {
                    const newChannelForParticipantReference = admin.firestore().collection(constants.USERS_COLLECTION).doc(participantId).collection('channelIds').doc(channelId)
                    const newParticipantForChannelReference = channelReference.collection('participantIds').doc(participantId)

                    if (participantId != authorId) {
                        batch.create(newChannelForParticipantReference, {})
                        batch.create(newParticipantForChannelReference, {})
                    }

                    // retrieve fcm token for user
                    return admin
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
            )
            .then(() => {
                LOGGER.info('Promise completed')

                batch.update(channelReference, {
                    'fcmTokens': fcmTokens,
                })

                batch.commit()
                .then(() => {
                    LOGGER.info('Batch commit successful')
                })
                .catch(err => {
                    LOGGER.error(err)
                })
            })
            .catch((error) => {
                LOGGER.error(error)
            })

        } catch (error) {
            LOGGER.error(error)
            return null
        }

    })

// Create a new function which is triggered on changes to /status/{uid}
// Note: This is a Realtime Database trigger, *not* Firestore.
exports.onUserStatusChangedInRealtimeDB = functions.database.ref('/status/{uid}').onUpdate(
    async (change, context) => {

        // Get the data written to Realtime DatabasE
        const eventStatus = change.after.val()

        // Then use other event data to create a reference to the
        // corresponding Firestore document.
        const userStatusFirestoreRef = admin.firestore().doc(`status/${context.params.uid}`)

        // It is likely that the Realtime Database change that triggered
        // this event has already been overwritten by a fast change in
        // online / offline status, so we'll re-read the current data
        // and compare the timestamps.
        const statusSnapshot = await change.after.ref.once('value')
        const status = statusSnapshot.val()
        LOGGER.log(status, eventStatus)
        LOGGER.log(status.state)
        LOGGER.log(eventStatus.state)
        // If the current timestamp for this data is newer than
        // the data that triggered this event, we exit this function.
        if (status.last_changed > eventStatus.last_changed) {
            return null;
        }

        // Otherwise, we convert the last_changed field to a Date
        eventStatus.last_changed = new Date(eventStatus.last_changed);

        // ... and write it to Firestore.
        return userStatusFirestoreRef.set(eventStatus);
    }
)

exports.onUserStatusChangedInFirestore = functions.firestore
.document('status/{uid}')
.onUpdate((_, context) => {

    const userId = context.params.uid

    admin.firestore().collection(constants.USERS_COLLECTION+'/'+userId+'/channelIds').get()
    .then(snapshot => {
        if (!snapshot.empty) {
            snapshot.docs.forEach(doc => {
                const typingIndReference = admin.firestore().doc(constants.CHANNELS_COLLECTION + '/' + doc.id + '/typingUserIds/' + userId)
                typingIndReference.delete()
                .then(() => {
                    LOGGER.log('successfuly removed typing reference')
                })
                .catch(err => {
                    LOGGER.log('Failed to remove typing reference: ', err)
                })

            })
        }
    })
    .catch(err => {
        LOGGER.log('Failed to fetch user channels: ', err)
    })

})