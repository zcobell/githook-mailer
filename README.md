
# Githook Mailer

Githook Mailer is a Ruby application which distributes Git Webhooks to a user specified email address. In my case, this is a development group mailing list, though, it can be anything you'd like. This mostly replicates the normal emails that Github would send to a "watching" user but the address where the email is sent can be arbitrary.

## Background
Some people just prefer getting detailed emails instead of following along with projects on Github. For admins, this can present a challenge. Github doesn't really provide the ability to send out commit, issue, and pull request notifications to a mailing list. However, the webhooks api serves as a solution to this, provided you're willing to do a little work. Hopefully I've done that for you.

I am by no means an experienced Ruby or Heroku developer, so please feel free to fix my many mistakes with the correct way to do things or make enhancements.

# Setup

The application can be deployed to a Heroku app assuming a number of environment variables are defined. The application uses Sinatra and receives webhooks to the address `myserver.com/githook`

## Environment Variables

The Heroku app should be completely configurable through the use of environment variables. The table below describes these configuration variables.

|  Variable Name   |                 Description                    |
|------------------|------------------------------------------------|
|`EMAIL_TO`        | Destination address. Send to multiple addresses by separating with a comma. |
|`EMAIL_FROM`      | From address for the email being sent          |
|`EMAIL_USER`      | Username of the email account to use           |
|`EMAIL_PASSWORD`  | Password for specified email account           |
|`EMAIL_SERVER`    | Mail server to use for sending mail            |
|`EMAIL_PORT`      | Port to use for mail server                    |
|`EMAIL_SSL`       | Set to 1 to use SSL, 0 to disable SSL          |

Environment variables are defined via Heroku using:
```
heroku config:set VAR=value
```
