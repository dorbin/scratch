# Expose Spinnaker

### Configure OAuth consent screen

Go to the [OAuth consent screen](https://console.developers.google.com/apis/credentials/consent?project=$PROJECT_ID).

Enter a *Product name*, enter your *Email address*, and add **$TOP_PRIVATE_DOMAIN** as an *Authorized domain*.

### Create OAuth credentials

Go to the [Credentials page](https://console.developers.google.com/apis/credentials/oauthclient?project=$PROJECT_ID) and create an *OAuth client ID*.

Use *Application type: Web application*, and add **https://$DOMAIN_NAME/_gcp_gatekeeper/authenticate** as an *Authorized redirect URI*.

Ensure that you note the generated *Client ID* and *Client secret* for your new credentials, as you will need to provide them to the script in the next step.

```bash
./expose/configure_iap.sh
```

This phase could take 30-60 minutes.

## Conclusion

Connect to your Spinnaker installation [here](https://$DOMAIN_NAME).