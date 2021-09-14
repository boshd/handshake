import { firestore } from 'firebase-admin'
import { constructNotificationPayload, constructNotificationPayloadForReminder } from './helpers/notifications'
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

exports.onChannelUpdate = functions.firestore
.document(constants.CHANNELS_COLLECTION + '/{channelId}')
.onWrite(async (snapshot, context) => {

    const channelId = context.params['channelId']

    // Depending on the event type, we handle accrodingly

    // Only edit data when it is first created.
    // if (snapshot.before.exists)
    //     return

    // Exit when the data is deleted.
    if (!snapshot.after.exists)
        return



    const afterData = snapshot.after.data()
    const oldData = snapshot.before.data()

    if (afterData !== undefined && oldData !== undefined) {
        LOGGER.info('DATA AVAILABLE')


        const afterTimestamp = afterData['startTime']
        const oldTimestamp = oldData['startTime']

        LOGGER.info(afterTimestamp, oldTimestamp)

        if (afterTimestamp !== oldTimestamp) {
            LOGGER.info('DIFFEREENCE BETWEEN START TIMES')


            if ((afterTimestamp * 1000) < new Date().getTime()) {
                LOGGER.log('attempting to create task for start date before the current date; proof (leading w/ start date): ', (afterTimestamp * 1000), new Date().getTime())
                return
            }

            const tmpDate = afterTimestamp

            // const unixTimestamp = afterTimestamp

            const hours = 1

            const milliseconds = (tmpDate - (hours * 3600)) * 1000 // 1575909015000

            const dateObject = new Date(milliseconds)

            // const humanDateFormat = dateObject.toLocaleString() //2019-12-9 10:30:15

            const perfomAtDate = dateObject

            LOGGER.info(perfomAtDate)

            const query = db.collection('tasks').where('forId', '==', channelId);
            const tasks = await query.get();

            tasks.forEach(task => {
                db.collection('tasks').doc(task.id).delete()
                .then(() => { LOGGER.info('Destryed task for ', channelId) })
                .catch(err => { LOGGER.error('Failed to destroy task for ', channelId) })
            })

            db.collection(constants.TASKS_COLLECTION).doc()
            .set({
                'worker': 'sendReminderNotification',
                'status': 'scheduled',
                'performAt': firestore.Timestamp.fromDate(perfomAtDate),
                'options': {
                    'forId': channelId,
                },
                'forId': channelId,
            })
            .then(() => { LOGGER.info('Created task for ', channelId) })
            .catch(err => { LOGGER.error('Failed to create task for ', channelId) })
        }
    }

})

async function notifyEventAttendees(channelId: string) {

    return db.collection('channels').doc(channelId).get()
    .then((snapshot) => {

        if (snapshot.exists) {
            const data = snapshot.data()

            if (data !== undefined) {

                const fcmTokens = data['fcmTokens']
                // const startTimestamp = data['startTime']
                const channelName = data['name']
                // const text = 'Heads up! ' + hoursTillTimestamp(startTimestamp) + ' hour(s) till the event starts. 🚀'

                const text = 'Heads up! The event will be starting soon, open the app to view the event details.'

                const tokens = Object.keys(fcmTokens).map(key => fcmTokens[key])

                var title =  'It\'s nearly time for \"' + channelName + '\" 🚀'

                const messagePayload = constructNotificationPayloadForReminder(
                    tokens,
                    channelId,
                    channelName,
                    text,
                    title
                )

                admin
                .messaging()
                .sendMulticast(messagePayload)
                .then((res) => {
                    LOGGER.info('Successfully sent notification // ', res)
                    // update message to indicate delivery

                 })
                .catch((error) => { functions.logger.error('Error sending notification // ', error) })
            }

        }

    })
    .catch(err => { LOGGER.error('ERROR') })


}

// function hoursTillTimestamp(futureTimestamp: number) {
//     // get total seconds between the times
//     var delta = Math.abs(futureTimestamp - new Date().getTime() / 1000) / 1000;

//     // calculate (and subtract) whole days
//     var days = Math.floor(delta / 86400);
//     delta -= days * 86400;

//     // calculate (and subtract) whole hours
//     var hours = Math.floor(delta / 3600) % 24;
//     delta -= hours * 3600;

//     // calculate (and subtract) whole minutes
//     var minutes = Math.floor(delta / 60) % 60;
//     delta -= minutes * 60;

//     // what's left is seconds
//     // var seconds = delta % 60;  // in theory the modulus is not required
//     return hours
// }

/*
Taks runner
*/

// Optional interface, all worker functions should return Promise.
interface Workers {
    [key: string]: (options: any) => Promise<any>
}

// Business logic for named tasks. Function name should match worker field on task document.
const workers: Workers = {
    sendReminderNotification: async ({ forId }) => {
        await notifyEventAttendees(forId)
    },
}

exports.taskRunner = functions.runWith( { memory: '2GB' } )
.pubsub
.schedule('* * * * *')
.onRun(async context => {
    const now = firestore.Timestamp.now()
    // const f = (now.toDate().getTime)
    // const gg = f/1000
    // const threeHoursBeforeNow = firestore.Timestamp()

    // every 60 seconds, query firestore for all eligble scheduled tasks, push to jobs queue.

    // Query all documents ready to perform
    const query = db.collection('tasks').where('performAt', '<=', now).where('status', '==', 'scheduled');

    const tasks = await query.get();


    // Jobs to execute concurrently.
    const jobs: Promise<any>[] = [];

    // Loop over documents and push job.
    tasks.forEach(snapshot => {
        const { worker, options } = snapshot.data();

        const job = workers[worker](options)

            // Update doc with status on success or error
            .then(() => snapshot.ref.update({ status: 'complete' }))
            .catch((err) => snapshot.ref.update({ status: 'error' }));

        jobs.push(job);
    });

    // Execute all jobs concurrently
    return await Promise.all(jobs);
})

exports.notifyOnMessageCreation = functions.firestore
.document(constants.MESSAGES_COLLECTION + '/{messageId}')
.onCreate((snapshot, context) => {

    // having this as a trggered function will ensure asynchronicity

    const userId: string = context.params['userId']
    const messageId: string = context.params['messageId']
    // const channelId: string = context.params['channelId']

    if (snapshot.exists) {
        const messageData = snapshot.data()
        // const timestamp = messageData['timestamp']
        const fromId = messageData['fromId']
        const channelId = messageData['toId']
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

        // check if person is actually in channel, just in case

        if (fromId != userId) {
            return admin
            .messaging()
            .sendMulticast(messagePayload)
            .then((res) => {
                LOGGER.info('Successfully sent notification // ', res)
                // update message to indicate delivery
                const participantIds = Object.keys(fcmTokens)
                participantIds.forEach(participantId => {
                    db.collection('users').doc(participantId).collection('channelIds').doc(channelId).collection('messageIds').doc(messageId).set({
                        'notified': true,
                    }, {merge:true})
                    .then(() => { LOGGER.info('good') })
                    .catch(err => { LOGGER.error('Fbad') })
                });

             })
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