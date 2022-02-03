# SSH grant/revoke via OptScale webhooks
This folder contains sample scripts for setting up automation around granting/revoking SSH access to some shared hosts by aquire/release webhooks of the corresponding IT Environments entities in [OptScale](https://my.optscale.com)

## Scripts included
**grant_access.sh** - put provided public key to the target host

**revoke_access_sh** - revoke access to the target host

Check scripts to tune them for your specific case.

## Sample Jenkins job setup

### Grant access job
* Create parametrized job with the following string parameters

   * SSH_KEY

   * IP

   * BOOKING_OWNER

* Set **Generic Webhook Trigger** with the following JSONPath Variables and Expressions
   
   * SSH_KEY : `$.description.booking_details.ssh_key`

   * IP : `$.description.environment.env_properties.IP`

   * BOOKING_OWNER : `$.description.booking_owner.name`

* Set **Token** `grant_access` for the **Generic Webhook Trigger** 

* Add **Execute Shell** action to **Build** section with the following call

```
KEY_FILE=$WORKSPACE/key_file.pub
echo $SSH_KEY > $KEY_FILE
bash grant_access.sh --key_file $KEY_FILE --ip $IP
```

### Revoke access job
* Create parametrized job with the following string parameters

   * IP

* Set **Generic Webhook Trigger** with the following JSONPath Variables and Expressions
   
   * IP : `$.description.environment.env_properties.IP`

* Set **Token** `revoke_access` for the **Generic Webhook Trigger** 

* Add **Execute Shell** action to **Build** section with the following call

```
bash revoke_access.sh --ip $IP
```

## Set up OptScale IT Environment Webhook

* Turn on **Require SSH key** property of environment on **Bookings** tab

* Set **Acquire webhook** URL to `<JENKINS_URL>/generic-webhook-trigger/invoke?token=grant_access`

* Set **Release webhook** URL to `<JENKINS_URL>/generic-webhook-trigger/invoke?token=revoke_access`