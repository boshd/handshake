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
export function constructNotificationPayload(tokens: string[], messageId: string, channelId: string, senderName: string, channelName: string, fromId: string, text: string, badge: number) {
    var title: string = ''
    var textString: string = text

    if (senderName && channelName) {
        title =  channelName
        textString = senderName + ': ' + text
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
            body: textString,
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
                    // badge: badge,
                    'mutable-content': 1,
                },
                messageId: messageId,
                channelId: channelId,
            },
        },
        tokens: tokens,
    };
}

export function constructNotificationPayloadForReminder(tokens: string[], channelId: string, channelName: string, text: string, title: string) {
    // var title: string = ''
    // var textString: string = text



    // format date

    // var textString = "This is a reminder"

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
                    // badge: badge,
                    'mutable-content': 1,
                },
                channelId: channelId,
            },
        },
        tokens: tokens,
    };
}