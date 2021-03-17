import * as admin_ from 'firebase-admin'

admin_.initializeApp({
    credential: admin_.credential.applicationDefault(),
})


export const admin = admin_
export const db = admin_.firestore()