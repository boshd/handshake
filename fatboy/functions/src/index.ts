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

/**
 * Returns users given prepaerd phone numbers.
 *
 * @param {!express:Request} req HTTP request context.
 * @param {!express:Response} res HTTP response context.
 */
exports.handleNewMessage = functions.firestore
.document(constants.MESSAGES_COLLECTION + '/{messageId}')
.onCreate((snapshot, context) => {
    const messageId: string = context.params['messageId']

    if (snapshot.exists) {
        const messageData = snapshot.data()

        const historicChannelName = messageData['historicChannelName']
        const historicSenderName = messageData['historicSenderName']
        const text: string = messageData['text']
        const channelId = messageData['toId']
        const timestamp = messageData['timestamp']
        const fromId = messageData['fromId']
        var badge = 0
        var fcmTokens = messageData['fcmTokens']

        fcmTokens = Object.keys(fcmTokens).map(key => fcmTokens[key])

        const messagePayload = constructNotificationPayload(
            fcmTokens,
            messageId,
            channelId,
            historicSenderName,
            historicChannelName,
            fromId,
            text,
            badge,
        )

        try {

            sendMessageToAllButSender()
            .then(() => {
                LOGGER.log('sendMessageToAllButSender is done')
                notifyAllButSender()
            })
            .catch(err => {
                functions.logger.error('whole thing failed')
            })

            /*

            what needs to happen after message is created?
                - add message id to all members of group
                - increment badge for each meember for group and global?
                - notify
            */


        } catch (err) {
            functions.logger.error(err)
        }

        function notifyAllButSender() {
            admin
            .messaging()
            .sendMulticast(messagePayload)
            .then((res) => { functions.logger.info('Successfully sent message // ', res) })
            .catch((error) => { functions.logger.error('Error sending message // ', error) })
        }

        async function sendMessageToAllButSender() {
            return await admin
            .firestore()
            .collection(constants.CHANNELS_COLLECTION + '/'+ channelId + '/participantIds')
            .get()
            .then(participantSnapshot => {
                if (!participantSnapshot.empty) {
                    const members = participantSnapshot.docs

                    // members.forEach(member => {
                    //     if (member.id !== fromId) {
                    //         batchSetEverything(member.id)
                    //         incrementBadge(member.id)
                    //     }
                    // })
                }
            })
            .catch((error) => { functions.logger.error('Error sending message // ', error) })
        }

        async function setMessageIdInUserMessagsAndInChannel(members: any[]) {
            const batch = admin.firestore().batch()

            members.forEach(member => {
                if (member.id !== fromId) {

                    const ref = admin.firestore().collection('users').doc(member.id).collection('channelIds').doc(channelId)

                    batch.set((

                        .collection('messageIds')
                        .doc(messageId)
                    ), {
                            'fromId': fromId,
                            'timestamp': timestamp,
                    }, {
                        merge: true,
                    })

                    batchSetEverything(member.id)
                    incrementBadge(member.id)
                }
            })



            batch.set((
                admin.firestore()
                .collection('users')
                .doc(memberId)
                .collection('channelIds')
                .doc(channelId)
                .collection('messageIds')
                .doc(messageId)
            ), {
                    'fromId': fromId,
                    'timestamp': timestamp,
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

            try {
                return await batch
                .commit()
                .then(() => {
                    functions.logger.info('successful batchSetEverything')
                })
                .catch(err => {
                    functions.logger.error('error in batchSetEverything', err)
                })
            } catch (err) {

            }

        }

        function incrementBadges(memberId: string) {
            const userChannelRef = db
            .collection('users')
            .doc(memberId)
            .collection('channelIds')
            .doc(channelId)

            const userRef = db
            .collection('users')
            .doc(memberId)

            try {
                return db
                .runTransaction(async (updateFunction) => {
                    const userChannelDoc: FirebaseFirestore.DocumentData = await updateFunction.get(userChannelRef)
                    const userDoc: FirebaseFirestore.DocumentData = await updateFunction.get(userRef)

                    const newUserChannelBadgeValue = (userChannelDoc.data()['badge'] || 0) + 1
                    const newUserBadgeValue = (userDoc.data()['badge'] || 0) + 1

                    updateFunction.update(userRef, {
                        'badge': newUserBadgeValue
                    })

                    updateFunction.update(userChannelRef, {
                        'badge': newUserChannelBadgeValue
                    })

                    badge = newUserBadgeValue
                })
                .then(_ => { functions.logger.info('success incrementing badges') })
                .catch(err => { functions.logger.error('error in incrementing badges // ', err); badge = 0 })
            } catch (err) {
                LOGGER.error('Transaction failure:', err)
            }
        }

        // function incrementBadge(memberId: string) {


        //     try {



        //         db.runTransaction(async (t) => {
        //             const doc: FirebaseFirestore.DocumentData = await t.get(userRef)
        //             const newValue = (doc.data()['badge'] || 0) + 1
        //             t.update(userRef, {
        //                 'badge': newValue,
        //             })
        //         })
        //         .then(_ => { functions.logger.info('success incrementBadge') })
        //         .catch(err => { functions.logger.error('error in incrementBadge // ', err) })

        //         db.runTransaction(async (t) => {
        //             const doc: FirebaseFirestore.DocumentData = await t.get(userChannelRef)
        //             const newValue = (doc.data()['badge'] || 0) + 1
        //             t.update(userChannelRef, {
        //                 'badge': newValue,
        //             })

        //             badge = newValue
        //         })
        //         .then(_ => { functions.logger.info('success incrementBadge') })
        //         .catch(err => { functions.logger.error('error in incrementBadge // ', err); badge = 0 })
        //     } catch (e) {
        //         functions.logger.error('Transaction failure:', e)
        //     }

        // }

    }

    return null
})

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


/**
 * Returns users given prepaerd phone numbers.
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