import { db } from '../../core/admin'
import { constants } from '../../core/constants'

/**
* given a list of phone numbers, we want to return a list of users that have this number
*
* @remarks
* res: any is just to make the linter STFU about being any.
*
* @param req - request
* @param res - response
* @returns - nada
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