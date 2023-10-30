---
title: Support Notifications - How To Configure Email Notifications
---

# Support Notifications - How To Configure Email Notifications

## Gmail Configuration Example

Before using Gmail to send alerts and notifications, configure the
sign-in security settings through one of the following two methods:

1.  Enable 2-Step Verification and use an App Password (Recommended). An
    App password is a 16-digit passcode that gives an app or device
    permission to access your Google Account. For more detail about this
    topic, please refer to this
    [Google official document](https://support.google.com/accounts/answer/185833?hl=en).
2.  Allow less secure apps: If the 2-Step Verification is not enabled,
    you may need to allow less secure apps to access the Gmail account.
    Please see the instruction from this
    [Google official document](https://support.google.com/accounts/answer/6010255?hl=en).


Then, use the following settings for the mail server properties:

    Smtp Port=25
    Smtp Host=smtp.gmail.com
    Smtp Sender=${Gmail account}
    Smtp Password=${Gmail password or App password}

## Yahoo Mail Configuration Example

Similar to Gmail, configure the sign-in security settings for Yahoo
through one of the following two methods:

1.  Enable 2-Step Verification and use an App Password (Recommended).
    Please see this Yahoo official document for more detail:
    <https://help.yahoo.com/kb/SLN15241.html>.
2.  Allow apps that use less secure sign in. Please see this Yahoo
    official document for more detail on this topic:
    <https://help.yahoo.com/kb/SLN27791.html>.

Then, use the following settings for the mail server properties:

    Smtp Port=25
    Smtp Host=smtp.mail.yahoo.com
    Smtp Sender=${Yahoo account}
    Smtp Password=${Yahoo password or App password}