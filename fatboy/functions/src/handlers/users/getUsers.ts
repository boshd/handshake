import { db } from '../../core/admin'
import { constants } from '../../core/constants'

/**
	* given a list of phone numbers, we want to return a list of users that have this number
	*
	* @remarks
	* res: any is just to make the linter STFU about being any.
	*
	* @param rawFcmTokens - FCM tokens of all channel/event subscribers
	* @returns payload to be used by notification sender
	*
	* @beta
*/

export const getUsersWithPreparedNumbers = (req: any, res: any) => {
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
				[res.send({ users: users })]
			)
		})
		.catch((error) => {
			console.log(error)
		})

	} catch (error) {
		console.log(error)
		res.status(400).send(`Malformed request.. we need some schema validators up in this bish`)
	}
}

//  function getUser(number: string) {
//     const snapshot =  db
// 	.collection(constants.USERS_COLLECTION)
// 	.where('phoneNumber', '==', number)
// 	.get()
//     snapshot.docs.map(doc => {
// 		console.log(doc)
// 		doc.data()
// 	});
// }

/*

const objectSnapshot = await admin.firestore().collection('object').get();

// Creates an array of promises that can be awaited later
// You can use the docs property which is an array, and then you can use map on it
const promises = objectSnapshot.docs.map(async (objectDoc) => {
    // This will execute in parallel but will create a promise and add it to promises
    const valueSnapshot = await admin.firestore().collection('object').doc(objectDoc.id).collection('value').get();
    return valueSnapshot.docs.map((valueDoc) => valueDoc.data());
});

// Wait for all promises created before returning
return await Promise.all(promises);
*/



// exports.getUsersWithPreparedNumbers = async (request, response) => {
	// const preparedNumbers: Array<string> = request.body.data.preparedNumbers
	// const users: FirebaseFirestore.DocumentData = []

	// Promise.all(
	// 	preparedNumbers.map((preparedNumber) => {
	// 		return db
	// 			.collection('users')
	// 			.where('phoneNumber', '==', preparedNumber)
	// 			.get()
	// 			.then((snapshot) => {
	// 				if (!snapshot.empty) {
	// 					snapshot.forEach((doc) => {
	// 						users.push(doc.data())
	// 					})
	// 				}
	// 			})
	// 	})
	// )
	// .then(() => {
	// 	return Promise.all(
	// 		[response.send({ data: users })]
	// 	)
	// })
	// .catch((error) => {
	// 	functions.logger.error(error)
	// })
// }

// export const getUsersWithPreparedNumbers = functions.https.onRequest(
// 	(request, response) => {
// 		const preparedNumbers: Array<string> = request.body.data.preparedNumbers
// 		const users: FirebaseFirestore.DocumentData = []

// 		Promise.all(
// 			preparedNumbers.map((preparedNumber) => {
// 				return db
//                     .collection('users')
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