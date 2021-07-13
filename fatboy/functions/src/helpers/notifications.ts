/**
* Returns notification payload object.
*
* @remarks
* none.
*
* @param rawFcmTokens - FCM tokens of all channel/event subscribers
* @param senderName - sender's name
* @param channelName - channel/event name
* @param fromId - user id of sender
* @param channelId - id of destination channel
* @param messageId - id of message
* @returns payload to be used by notification sender
*
* @beta
*/
export function constructNotificationPayload(currentUserFCMToken: string, messageId: string, channelId: string, senderName: string, channelName: string, fromId: string, text: string, badge: number) {
    let title: string = ''
    // var text: string = ''

    if (senderName && channelName) {
        title = senderName + ' @ ' + channelName
    } else if (channelName) {
        title = channelName
    } else {
        title = 'Event'
    }

    return {
        priority: 'high',
        sound: 'default',
        notification: {
            title: title,
            body: text,
        },
        apns: {
            headers: {
                'apns-priority': '10',
            },
            payload: {
                aps: {
                    'content-available': 0,
                    sound: 'push.aiff',
                    category: 'QuickReply',
                    badge: badge,
                    'mutable-content': 1,
                },
                messageId: messageId,
                channelId: channelId,
            },
        },
        tokens: [currentUserFCMToken],
    };
}