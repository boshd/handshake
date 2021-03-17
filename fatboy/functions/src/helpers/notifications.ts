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
export function constructNotificationPayload(rawFcmTokens: any, messageId: string, channelId: string, senderName: string, channelName: string, fromId: string) {
    var title: string = ''
    var text: string = ''

    if (senderName && channelName) {
        title = senderName + ' @ ' + channelName
    } else if (channelName) {
        title = channelName
    } else {
        title = 'Event'
    }


    if (text) {
        text = text
    } else {
        text = 'Could not retrieve notification text'
    }

    const fcmTokens = Object.keys(rawFcmTokens)
        .filter(key => key !== fromId)
        .map(key => rawFcmTokens[key]);

    var fcmTokensArr = Array.from(fcmTokens.values()).filter((tokenUserId: string) => tokenUserId !== fromId)

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
                    sound: 'push.aiff',
                    category: 'QuickReply',
                    badge: 0,
                    'mutable-content': 1,
                },
                messageID: messageId,
                channelID: channelId,
                // message: data,
            },
        },
        tokens: fcmTokensArr,
    };
}