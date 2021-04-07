import { admin } from '../core/admin'

export function sendMessageToMember(memberId: string, channelId: string, senderID: string, messageId: string) {
    admin
    .firestore()
    .collection('users')
    .doc(memberId)
    .collection('channelIds')
    .doc(channelId)
    .collection('messageIds')
    .doc(messageId)
    .set({})
}

export function updateChannelLastMessage(memberId: string, channelId: string, lastMessageId: string) {
    admin
    .firestore()
    .collection('users')
    .doc(memberId)
    .collection('channelIds')
    .doc(channelId)
    .update({
        'lastMessageID': lastMessageId
    })
}

export function incrementBadge(memberId: string, channelId: string, lastMessageId: string) {
    admin
    .firestore()
    .collection('users')
    .doc(memberId)
    .collection('channelIds')
    .doc(channelId)
    .update({
        'badge': lastMessageId
    })
}