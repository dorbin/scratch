# Authorize Spin via IAP

### Retrieve an Authorization Code for use in the subsequent script.

[Get Authorization Code](https://accounts.google.com/o/oauth2/v2/auth?client_id=$OTHER_IAP_CLIENT_ID&response_type=code&scope=openid%20email&access_type=offline&redirect_uri=urn:ietf:wg:oauth:2.0:oob)

### Use the Authorization Code to generate an IAP ID Token.

The IAP ID Token will be valid for about an hour.

```bash
./expose/configure_spin_iap.sh
```

## Conclusion

Connect to your Spinnaker installation [here](https://$DOMAIN_NAME).
