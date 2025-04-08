# List of Operations

Operations are objects that represent a desired change to the ledger and are submitted to the network grouped in a transaction. For each operation, there is a successful or failed result type. In the case of success, the user can gather information about the effect of the operation. In the case of failure, the user can learn more about the error.

Learn more about transactions and operations in our [Transaction and Operations section](/fundamentals/datastructures?id=operations-and-transactions-how-they-work).

There are currently 23 operations you can use on the Diamante network, and the details for each operation are listed below.

## Create Account

Creates and funds a new account with the specified starting balance.

**SDK:** Go  
**Threshold:** Medium  
**Result:** `CreateAccountResult`  
**Parameters:**

| Parameter        | Type       | Description                                                                                   |
| ---------------- | ---------- | --------------------------------------------------------------------------------------------- |
| Destination      | Account ID | Account address that is created and funded.                                                   |
| Starting Balance | integer    | Amount of DIAM to send to the newly created account. This DIAM comes from the source account. |

**Possible errors:**

| Error Code                   | Description                                                                                                                                                                                                             |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CREATE_ACCOUNT_MALFORMED     | The `destination` is invalid.                                                                                                                                                                                           |
| CREATE_ACCOUNT_UNDERFUNDED   | The source account performing the command does not have enough funds to give `destination` the `starting balance` amount of DIAM and still maintain its minimum DIAM reserve plus satisfy its DIAM selling liabilities. |
| CREATE_ACCOUNT_LOW_RESERVE   | This operation would create an account with fewer than the minimum number of DIAM an account must hold.                                                                                                                 |
| CREATE_ACCOUNT_ALREADY_EXIST | The `destination` account already exists.                                                                                                                                                                               |

## Payment

Sends an amount in a specific asset to a destination account.

**SDKs:** Go  
**Threshold:** Medium  
**Result:** `PaymentResult`  
**Parameters:**

| Parameter   | Type       | Description                                 |
| ----------- | ---------- | ------------------------------------------- |
| Destination | Account ID | Account address that receives the payment.  |
| Asset       | Asset      | Asset to send to the destination account.   |
| Amount      | integer    | Amount of the aforementioned asset to send. |

**Possible errors:**

| Error Code                 | Description                                                                                                                                                                                                            |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PAYMENT_MALFORMED          | The input to the payment is invalid.                                                                                                                                                                                   |
| PAYMENT_UNDERFUNDED        | The source account (sender) does not have enough funds to send the `amount` and still satisfy its selling liabilities. Note that if sending DIAM, then the sender must additionally maintain its minimum DIAM reserve. |
| PAYMENT_SRC_NO_TRUST       | The source account does not trust the issuer of the asset it is trying to send.                                                                                                                                        |
| PAYMENT_SRC_NOT_AUTHORIZED | The source account is not authorized to send this payment.                                                                                                                                                             |
| PAYMENT_NO_DESTINATION     | The receiving account does not exist. Note that this error will not be returned if the receiving account is the issuer of the `asset`.                                                                                 |
| PAYMENT_NO_TRUST           | The receiver does not trust the issuer of the asset being sent. For more information, see the [Assets section](/fundamentals/datastructures?id=assets).                                                                |
| PAYMENT_NOT_AUTHORIZED     | The destination account is not authorized by the asset's issuer to hold the asset.                                                                                                                                     |
| PAYMENT_LINE_FULL          | The destination account (receiver) does not have sufficient limits to receive the `amount` and still satisfy its buying liabilities.                                                                                   |

## Path Payment Strict Send

A payment where the asset sent can be different than the asset received; allows the user to specify the amount of the asset to send.

Learn more about path payments in the [Encyclopedia -> Path Payments Encyclopedia Entry](/encyclopedia/path-payments).

**SDKs:** Go  
**Threshold:** Medium  
**Result:** `PathPaymentStrictSendResult`  
**Parameters:**

| Parameter         | Type           | Description                                                                                                                                                                                                                                                                      |
| ----------------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Send asset        | Asset          | The asset deducted from the sender's account.                                                                                                                                                                                                                                    |
| Send amount       | integer        | The amount of `send asset` to deduct (excluding fees).                                                                                                                                                                                                                           |
| Destination       | Account ID     | Account ID of the recipient.                                                                                                                                                                                                                                                     |
| Destination asset | Asset          | The asset the destination account receives.                                                                                                                                                                                                                                      |
| Destination min   | integer        | The minimum amount of `destination asset` the destination account can receive.                                                                                                                                                                                                   |
| Path              | list of assets | The assets (other than `send asset` and `destination asset`) involved in the offers the path takes. For example, if you can only find a path from USD to EUR through DIAM and BTC, the path would be USD -> DIAM -> BTC -> EUR, and the `path` field would contain DIAM and BTC. |

**Possible errors:**

| Error Code                                  | Description                                                                                                                                                                                               |
| ------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PATH_PAYMENT_STRICT_SEND_MALFORMED          | The input to this path payment is invalid.                                                                                                                                                                |
| PATH_PAYMENT_STRICT_SEND_UNDERFUNDED        | The source account (sender) does not have enough funds to send and still satisfy its selling liabilities. Note that if sending DIAM, then the sender must additionally maintain its minimum DIAM reserve. |
| PATH_PAYMENT_STRICT_SEND_SRC_NO_TRUST       | The source account does not trust the issuer of the asset it is trying to send.                                                                                                                           |
| PATH_PAYMENT_STRICT_SEND_SRC_NOT_AUTHORIZED | The source account is not authorized to send this payment.                                                                                                                                                |
| PATH_PAYMENT_STRICT_SEND_NO_DESTINATION     | The destination account does not exist.                                                                                                                                                                   |
| PATH_PAYMENT_STRICT_SEND_NO_TRUST           | The destination account does not trust the issuer of the asset being sent. For more, see the [Assets section](/fundamentals/datastructures?id=assets).                                                    |
| PATH_PAYMENT_STRICT_SEND_NOT_AUTHORIZED     | The destination account is not authorized by the asset's issuer to hold the asset.                                                                                                                        |
| PATH_PAYMENT_STRICT_SEND_LINE_FULL          | The destination account does not have sufficient limits to receive the `destination amount` and still satisfy its buying liabilities.                                                                     |
| PATH_PAYMENT_STRICT_SEND_TOO_FEW_OFFERS     | There is no path of offers connecting the `send` asset and `destination asset`. Diamante only considers paths of length 5 or shorter.                                                                     |
| PATH_PAYMENT_STRICT_SEND_OFFER_CROSS_SELF   | The payment would cross one of its own offers.                                                                                                                                                            |
| PATH_PAYMENT_STRICT_SEND_UNDER_DESTMIN      | The paths that could send the `destination amount` of `destination asset` would fall short of `destination min`.                                                                                          |

## Path Payment Strict Receive

A payment where the asset received can be different from the asset sent; allows the user to specify the amount of the asset received.

Learn more about path payments in the [Encyclopedia -> Path Payments Encyclopedia Entry](/encyclopedia/path-payments).

**SDKs:** Go  
**Threshold:** Medium  
**Result:** `PathPaymentStrictReceiveResult`  
**Parameters:**

| Parameter          | Type           | Description                                                                                                                                                                                                                                                                    |
| ------------------ | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Send asset         | Asset          | The asset deducted from the sender's account.                                                                                                                                                                                                                                  |
| Send max           | integer        | The maximum amount of `send asset` to deduct (excluding fees).                                                                                                                                                                                                                 |
| Destination        | Account ID     | Account ID of the recipient.                                                                                                                                                                                                                                                   |
| Destination asset  | Asset          | The asset the destination account receives.                                                                                                                                                                                                                                    |
| Destination amount | integer        | The amount of `destination asset` the destination account receives.                                                                                                                                                                                                            |
| Path               | list of assets | The assets (other than `send asset` and `destination asset`) involved in the offers the path takes. For example, if you can only find a path from USD to EUR through DIAM and BTC, the path would be USD -> DIAM -> BTC -> EUR, and the path field would contain DIAM and BTC. |

**Possible errors:**

| Error Code                                     | Description                                                                                                                                                                                               |
| ---------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| PATH_PAYMENT_STRICT_RECEIVE_MALFORMED          | The input to this path payment is invalid.                                                                                                                                                                |
| PATH_PAYMENT_STRICT_RECEIVE_UNDERFUNDED        | The source account (sender) does not have enough funds to send and still satisfy its selling liabilities. Note that if sending DIAM, then the sender must additionally maintain its minimum DIAM reserve. |
| PATH_PAYMENT_STRICT_RECEIVE_SRC_NO_TRUST       | The source account does not trust the issuer of the asset it is trying to send.                                                                                                                           |
| PATH_PAYMENT_STRICT_RECEIVE_SRC_NOT_AUTHORIZED | The source account is not authorized to send this payment.                                                                                                                                                |
| PATH_PAYMENT_STRICT_RECEIVE_NO_DESTINATION     | The destination account does not exist.                                                                                                                                                                   |
| PATH_PAYMENT_STRICT_RECEIVE_NO_TRUST           | The destination account does not trust the issuer of the asset being sent. For more, see the [Assets section](/fundamentals/datastructures?id=assets).                                                    |
| PATH_PAYMENT_STRICT_RECEIVE_NOT_AUTHORIZED     | The destination account is not authorized by the asset's issuer to hold the asset.                                                                                                                        |
| PATH_PAYMENT_STRICT_RECEIVE_LINE_FULL          | The destination account does not have sufficient limits to receive the destination amount and still satisfy its buying liabilities.                                                                       |
| PATH_PAYMENT_STRICT_RECEIVE_TOO_FEW_OFFERS     | There is no path of offers connecting the send asset and destination asset. diamcircle only considers paths of length 5 or shorter.                                                                       |
| PATH_PAYMENT_STRICT_RECEIVE_OFFER_CROSS_SELF   | The payment would cross one of its own offers.                                                                                                                                                            |
| PATH_PAYMENT_STRICT_RECEIVE_OVER_SENDMAX       | The paths that could send the destination amount of destination asset would exceed send max.                                                                                                              |

## Manage Buy Offer

Creates, updates, or deletes an offer to buy a specific amount of an asset for another.

**SDKs:** Go  
**Threshold:** Medium  
**Result:** `ManageBuyOfferResult`  
**Parameters:**

| Parameter | Type                     | Description                                                                                                                             |
| --------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| Selling   | Asset                    | Asset the offer creator is selling.                                                                                                     |
| Buying    | Asset                    | Asset the offer creator is buying.                                                                                                      |
| Amount    | integer                  | Amount of `buying` being bought. Set to 0 if you want to delete an existing offer.                                                      |
| Price     | {numerator, denominator} | Price of 1 unit of `buying` in terms of `selling`. For example, if you wanted to buy 30 DIAM and sell 5 BTC, the price would be {5,30}. |
| Offer ID  | unsigned integer         | The ID of the offer. 0 for a new offer. Set to an existing offer ID to update or delete.                                                |

**Possible errors:**

| Error Code                           | Description                                                                                                                                                                                                                                                                                                   |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MANAGE_BUY_OFFER_MALFORMED           | The input is incorrect and would result in an invalid offer.                                                                                                                                                                                                                                                  |
| MANAGE_BUY_OFFER_SELL_NO_TRUST       | The account creating the offer does not have a trustline for the asset it is selling.                                                                                                                                                                                                                         |
| MANAGE_BUY_OFFER_BUY_NO_TRUST        | The account creating the offer does not have a trustline for the asset it is buying.                                                                                                                                                                                                                          |
| MANAGE_BUY_OFFER_BUY_NOT_AUTHORIZED  | The account creating the offer is not authorized to sell this asset.                                                                                                                                                                                                                                          |
| MANAGE_BUY_OFFER_SELL_NOT_AUTHORIZED | The account creating the offer is not authorized to buy this asset.                                                                                                                                                                                                                                           |
| MANAGE_BUY_OFFER_LINE_FULL           | The account creating the offer does not have sufficient limits to receive `buying` and still satisfy its buying liabilities.                                                                                                                                                                                  |
| MANAGE_BUY_OFFER_UNDERFUNDED         | The account creating the offer does not have sufficient limits to send `selling` and still satisfy its selling liabilities. Note that if selling DIAM, then the account must additionally maintain its minimum DIAM reserve, which is calculated assuming this offer will not completely execute immediately. |
| MANAGE_BUY_OFFER_CROSS_SELF          | The account has the opposite offer of equal or lesser price active, so the account creating this offer would immediately cross itself.                                                                                                                                                                        |
| MANAGE_BUY_OFFER_NOT_FOUND           | An offer with that `offerID` cannot be found.                                                                                                                                                                                                                                                                 |
| MANAGE_BUY_OFFER_LOW_RESERVE         | The account creating this offer does not have enough DIAM to satisfy the minimum DIAM reserve increase caused by adding a subentry and still satisfy its DIAM selling liabilities. For every offer an account creates, the minimum amount of DIAM that account must hold will increase.                       |

## Manage Sell Offer

Creates, updates, or deletes an offer to sell a specific amount of an asset for another.

**SDKs:** Go  
**Threshold:** Medium
**Result:** `ManageSellOfferResult`  
**Parameters:**

| Parameter | Type                     | Description                                                                                                                             |
| --------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| Selling   | Asset                    | Asset the offer creator is selling.                                                                                                     |
| Buying    | Asset                    | Asset the offer creator is buying.                                                                                                      |
| Amount    | integer                  | Amount of `selling` being sold. Set to 0 if you want to delete an existing offer.                                                       |
| Price     | {numerator, denominator} | Price of 1 unit of `selling` in terms of `buying`. For example, if you wanted to sell 30 DIAM and buy 5 BTC, the price would be {5,30}. |
| Offer ID  | unsigned integer         | The ID of the offer. `0` for a new offer. Set to an existing offer ID to update or delete.                                              |

**Possible errors:**

| Error Code                            | Description                                                                                                                                                                                                                                                                                                   |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MANAGE_SELL_OFFER_MALFORMED           | The input is incorrect and would result in an invalid offer.                                                                                                                                                                                                                                                  |
| MANAGE_SELL_OFFER_SELL_NO_TRUST       | The account creating the offer does not have a trustline for the asset it is selling.                                                                                                                                                                                                                         |
| MANAGE_SELL_OFFER_BUY_NO_TRUST        | The account creating the offer does not have a trustline for the asset it is buying.                                                                                                                                                                                                                          |
| MANAGE_SELL_OFFER_SELL_NOT_AUTHORIZED | The account creating the offer is not authorized to sell this asset.                                                                                                                                                                                                                                          |
| MANAGE_SELL_OFFER_BUY_NOT_AUTHORIZED  | The account creating the offer is not authorized to buy this asset.                                                                                                                                                                                                                                           |
| MANAGE_SELL_OFFER_LINE_FULL           | The account creating the offer does not have sufficient limits to receive `buying` and still satisfy its buying liabilities.                                                                                                                                                                                  |
| MANAGE_SELL_OFFER_UNDERFUNDED         | The account creating the offer does not have sufficient limits to send `selling` and still satisfy its selling liabilities. Note that if selling DIAM, then the account must additionally maintain its minimum DIAM reserve, which is calculated assuming this offer will not completely execute immediately. |
| MANAGE_SELL_OFFER_CROSS_SELF          | The account has the opposite offer of equal or lesser price active, so the account creating this offer would immediately cross itself.                                                                                                                                                                        |
| MANAGE_SELL_OFFER_NOT_FOUND           | An offer with that `offerID` cannot be found.                                                                                                                                                                                                                                                                 |
| MANAGE_SELL_OFFER_LOW_RESERVE         | The account creating this offer does not have enough DIAM to satisfy the minimum DIAM reserve increase caused by adding a subentry and still satisfy its DIAM selling liabilities. For every offer an account creates, the minimum amount of DIAM that account must hold will increase.                       |

## Create Passive Sell Offer

Creates an offer to sell one asset for another without taking a reverse offer of equal price.

**SDKs:** Go  
**Threshold:** Medium  
**Result:** `ManageSellOfferResult`  
**Parameters:**

| Parameter | Type                     | Description                                                                                                                             |
| --------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| Selling   | Asset                    | Asset the offer creator is selling.                                                                                                     |
| Buying    | Asset                    | Asset the offer creator is buying.                                                                                                      |
| Amount    | integer                  | Amount of `selling` being sold.                                                                                                         |
| Price     | {numerator, denominator} | Price of 1 unit of `selling` in terms of `buying`. For example, if you wanted to sell 30 DIAM and buy 5 BTC, the price would be {5,30}. |

**Possible errors:**

| Error Code                            | Description                                                                                                                                                                                                                                                                                                   |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MANAGE_SELL_OFFER_MALFORMED           | The input is incorrect and would result in an invalid offer.                                                                                                                                                                                                                                                  |
| MANAGE_SELL_OFFER_SELL_NO_TRUST       | The account creating the offer does not have a trustline for the asset it is selling.                                                                                                                                                                                                                         |
| MANAGE_SELL_OFFER_BUY_NO_TRUST        | The account creating the offer does not have a trustline for the asset it is buying.                                                                                                                                                                                                                          |
| MANAGE_SELL_OFFER_SELL_NOT_AUTHORIZED | The account creating the offer is not authorized to sell this asset.                                                                                                                                                                                                                                          |
| MANAGE_SELL_OFFER_BUY_NOT_AUTHORIZED  | The account creating the offer is not authorized to buy this asset.                                                                                                                                                                                                                                           |
| MANAGE_SELL_OFFER_LINE_FULL           | The account creating the offer does not have sufficient limits to receive `buying` and still satisfy its buying liabilities.                                                                                                                                                                                  |
| MANAGE_SELL_OFFER_UNDERFUNDED         | The account creating the offer does not have sufficient limits to send `selling` and still satisfy its selling liabilities. Note that if selling DIAM, then the account must additionally maintain its minimum DIAM reserve, which is calculated assuming this offer will not completely execute immediately. |
| MANAGE_SELL_OFFER_CROSS_SELF          | The account has the opposite offer of equal or lesser price active, so the account creating this offer would immediately cross itself.                                                                                                                                                                        |
| MANAGE_SELL_OFFER_NOT_FOUND           | An offer with that `offerID` cannot be found.                                                                                                                                                                                                                                                                 |
| MANAGE_SELL_OFFER_LOW_RESERVE         | The account creating this offer does not have enough DIAM to satisfy the minimum DIAM reserve increase caused by adding a subentry and still satisfy its DIAM selling liabilities. For every offer an account creates, the minimum amount of DIAM that account must hold will increase.                       |

## Set Options

Set options for an account such as flags, inflation destination, signers, home domain, and master key weight.

Learn more about flags in the [Flags Encyclopedia Entry](/glossary/glossary?id=flags).  
Learn more about signers operations and key weight in the [Encyclopedia -> Signature and Multisignature Encyclopedia Entry](/encyclopedia/sig-multisig?id=signatures-and-multisig).

**SDKs:** Go  
**Threshold:** High (when updating signers or other thresholds) or Medium (when updating everything else)  
**Result:** `SetOptionsResult`  
**Parameters:**

| Parameter             | Type                 | Description                                                                                                                                                                                                                                                                                      |
| --------------------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Inflation Destination | account ID           | Account of the inflation destination.                                                                                                                                                                                                                                                            |
| Clear flags           | integer              | Indicates which flags to clear. For details about the flags, please refer to the [Accounts section](/fundamentals/datastructures?id=accounts). The bit mask integer subtracts from the existing flags of the account. This allows for setting specific bits without knowledge of existing flags. |
| Set flags             | integer              | Indicates which flags to set. For details about the flags, please refer to the [Accounts section](/fundamentals/datastructures?id=accounts). The bit mask integer adds onto the existing flags of the account. This allows for setting specific bits without knowledge of existing flags.        |
| Master weight         | integer              | A number from 0-255 (inclusive) representing the weight of the master key. If the weight of the master key is updated to 0, it is effectively disabled.                                                                                                                                          |
| Low threshold         | integer              | A number from 0-255 (inclusive) representing the threshold this account sets on all operations it performs that have a low threshold.                                                                                                                                                            |
| Medium threshold      | integer              | A number from 0-255 (inclusive) representing the threshold this account sets on all operations it performs that have a medium threshold.                                                                                                                                                         |
| High threshold        | integer              | A number from 0-255 (inclusive) representing the threshold this account sets on all operations it performs that have a high threshold.                                                                                                                                                           |
| Home domain           | string               | Sets the home domain of an account. See Federation.                                                                                                                                                                                                                                              |
| Signer                | {Public Key, weight} | Add, update, or remove a signer from an account. Signer weight is a number from 0-255 (inclusive). The signer is deleted if the weight is 0.                                                                                                                                                     |

**Possible errors:**

| Error Code                         | Description                                                                                                                                                                                                                                                             |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SET_OPTIONS_LOW_RESERVE            | This account does not have enough DIAM to satisfy the minimum DIAM reserve increase caused by adding a subentry and still satisfy its DIAM selling liabilities. For every new signer added to an account, the minimum reserve of DIAM that account must hold increases. |
| SET_OPTIONS_TOO_MANY_SIGNERS       | 20 is the maximum number of signers an account can have, and adding another signer would exceed that.                                                                                                                                                                   |
| SET_OPTIONS_BAD_FLAGS              | The flags set and/or cleared are invalid by themselves or in combination.                                                                                                                                                                                               |
| SET_OPTIONS_INVALID_INFLATION      | The destination account set in the inflation field does not exist.                                                                                                                                                                                                      |
| SET_OPTIONS_CANT_CHANGE            | This account can no longer change the option it wants to change.                                                                                                                                                                                                        |
| SET_OPTIONS_UNKNOWN_FLAG           | The account is trying to set a flag that is unknown.                                                                                                                                                                                                                    |
| SET_OPTIONS_THRESHOLD_OUT_OF_RANGE | The value for a key weight or threshold is invalid.                                                                                                                                                                                                                     |
| SET_OPTIONS_BAD_SIGNER             | Any additional signers added to the account cannot be the master key.                                                                                                                                                                                                   |
| SET_OPTIONS_INVALID_HOME_DOMAIN    | Home domain is malformed.                                                                                                                                                                                                                                               |

## Change Trust

Creates, updates, or deletes a trustline.

Learn more about trustlines in the [Trustlines section](/fundamentals/datastructures?id=trustlines).

**SDKs:** Go  
**Threshold:** Medium  
**Result:** `ChangeTrustResult`  
**Parameters:**

| Parameter | Type             | Description                                                                                                                   |
| --------- | ---------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Line      | ChangeTrustAsset | The asset of the trustline. For example, if a user extends a trustline of up to 200 USD to an anchor, the line is USD:anchor. |
| Limit     | integer          | The limit of the trustline. In the previous example, the limit would be 200.                                                  |

**Possible errors:**

| Error Code                                 | Description                                                                                                                                                                                                                                                                |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CHANGE_TRUST_MALFORMED                     | The input to this operation is invalid.                                                                                                                                                                                                                                    |
| CHANGE_TRUST_NO_ISSUER                     | The issuer of the asset cannot be found.                                                                                                                                                                                                                                   |
| CHANGE_TRUST_INVALID_LIMIT                 | The `limit` is not sufficient to hold the current balance of the trustline and still satisfy its buying liabilities. This error occurs when attempting to remove a trustline with a non-zero asset balance.                                                                |
| CHANGE_TRUST_LOW_RESERVE                   | This account does not have enough DIAM to satisfy the minimum DIAM reserve increase caused by adding a subentry and still satisfy its DIAM selling liabilities. For every new trustline added to an account, the minimum reserve of DIAM that account must hold increases. |
| CHANGE_TRUST_SELF_NOT_ALLOWED              | The source account attempted to create a trustline for itself, which is not allowed.                                                                                                                                                                                       |
| CHANGE_TRUST_TRUST_LINE_MISSING            | The asset trustline is missing for the liquidity pool.                                                                                                                                                                                                                     |
| CHANGE_TRUST_CANNOT_DELETE                 | The asset trustline is still referenced by a liquidity pool.                                                                                                                                                                                                               |
| CHANGE_TRUST_NOT_AUTH_MAINTAIN_LIABILITIES | The asset trustline is deauthorized.                                                                                                                                                                                                                                       |

## Allow Trust

Updates the authorized flag of an existing trustline.

**This operation is deprecated as of Protocol 17 - prefer SetTrustlineFlags instead**

Learn more about trustlines in the [Trustlines section](/fundamentals/datastructures?id=trustlines).

**SDKs:** Go  
**Threshold:** Low  
**Result:** `AllowTrustResult`  
**Parameters:**

| Parameter | Type       | Description                                                                                                                                                                                                 |
| --------- | ---------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Trustor   | account ID | The account of the recipient of the trustline.                                                                                                                                                              |
| Type      | asset code | The 4 or 12 character-maximum asset code of the trustline the source account is authorizing. For example, if an issuing account wants to allow another account to hold its USD credit, the `type` is `USD`. |
| Authorize | integer    | Flag indicating whether the trustline is authorized. 1 if the account is authorized to transact with the asset. 2 if the account is authorized to maintain offers, but not to perform other transactions.   |

**Possible errors:**

| Error Code                     | Description                                                                                                                                       |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| ALLOW_TRUST_MALFORMED          | The asset specified in `type` is invalid. In addition, this error happens when the native asset is specified.                                     |
| ALLOW_TRUST_NO_TRUST_LINE      | The `trustor` does not have a trustline with the issuer performing this operation.                                                                |
| ALLOW_TRUST_TRUST_NOT_REQUIRED | The source account (issuer performing this operation) does not require trust. In other words, it does not have the flag `AUTH_REQUIRED_FLAG` set. |
| ALLOW_TRUST_CANT_REVOKE        | The source account is trying to revoke the trustline of the `trustor`, but it cannot do so.                                                       |
| ALLOW_TRUST_SELF_NOT_ALLOWED   | The source account attempted to allow a trustline for itself, which is not allowed because an account cannot create a trustline with itself.      |
| ALLOW_TRUST_LOW_RESERVE        | Claimable balances can't be created on revocation of asset (or pool share) trustlines associated with a liquidity pool due to low reserves.       |

## Account Merge

Transfers the DIAM balance of an account to another account and removes the source account from the ledger.

**SDKs:** Go  
**Threshold:** High  
**Result:** `AccountMergeResult`  
**Parameters:**

| Parameter   | Type       | Description                                                                 |
| ----------- | ---------- | --------------------------------------------------------------------------- |
| Destination | account ID | The account that receives the remaining DIAM balance of the source account. |

**Possible errors:**

| Error Code                    | Description                                                                                                                    |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| ACCOUNT_MERGE_MALFORMED       | The operation is malformed because the source account cannot merge with itself. The `destination` must be a different account. |
| ACCOUNT_MERGE_NO_ACCOUNT      | The `destination` account does not exist.                                                                                      |
| ACCOUNT_MERGE_IMMUTABLE_SET   | The source account has `AUTH_IMMUTABLE` flag set.                                                                              |
| ACCOUNT_MERGE_HAS_SUB_ENTRIES | The source account has trustlines/offers.                                                                                      |
| ACCOUNT_MERGE_SEQNUM_TOO_FAR  | Source's account sequence number is too high. It must be less than `(ledgerSeq << 32) = (ledgerSeq \* 0x100000000)`.           |
| ACCOUNT_MERGE_DEST_FULL       | The `destination` account cannot receive the balance of the source account and still satisfy its diam buying liabilities.      |
| ACCOUNT_MERGE_IS_SPONSOR      | The source account is a sponsor.                                                                                               |

## Manage Data

Sets, modifies, or deletes a data entry (name/value pair) that is attached to an account.

Learn more about entries and subentries in the [Accounts section](/fundamentals/datastructures?id=accounts).

**SDKs:** Go  
**Threshold:** Medium  
**Result:** `ManageDataResult`  
**Parameters:**

| Parameter | Type        | Description                                                                                                                                                                           |
| --------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Name      | string      | String up to 64 bytes long. If this is a new Name, it will add the given name/value pair to the account. If this Name is already present, then the associated value will be modified. |
| Value     | binary data | (optional) If not present, then the existing Name will be deleted. If present, then this value will be set in the DataEntry. Up to 64 bytes long.                                     |

**Possible errors:**

| Error Code                    | Description                                                                                                                                                                                                                                                                |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MANAGE_DATA_NOT_SUPPORTED_YET | The network hasn't moved to this protocol change yet. This failure means the network doesn't support this feature yet.                                                                                                                                                     |
| MANAGE_DATA_NAME_NOT_FOUND    | Trying to remove a Data Entry that isn't there. This will happen if Name is set (and Value isn't) but the Account doesn't have a DataEntry with that Name.                                                                                                                 |
| MANAGE_DATA_LOW_RESERVE       | This account does not have enough DIAM to satisfy the minimum DIAM reserve increase caused by adding a subentry and still satisfy its DIAM selling liabilities. For every new DataEntry added to an account, the minimum reserve of DIAM that account must hold increases. |
| MANAGE_DATA_INVALID_NAME      | Name not a valid string.                                                                                                                                                                                                                                                   |

## Bump Sequence

Bumps forward the sequence number of the source account to the given sequence number, invalidating any transaction with a smaller sequence number.

**SDKs:** Go  
**Threshold:** Low  
**Result:** `BumpSequenceResult`  
**Parameters:**

| Parameter | Type           | Description                                                       |
| --------- | -------------- | ----------------------------------------------------------------- |
| bumpTo    | SequenceNumber | Desired value for the operation's source account sequence number. |

**Possible errors:**

| Error Code            | Description                                                                                                                                              |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BUMP_SEQUENCE_BAD_SEQ | The specified `bumpTo` sequence number is not a valid sequence number. It must be between 0 and `INT64_MAX` (9223372036854775807 or 0x7fffffffffffffff). |

## Create Claimable Balance

Moves an amount of asset from the operation source account into a new ClaimableBalanceEntry.

Learn more about claimable balances in the [Encyclopedia -> Claimable Balances Encyclopedia Entry](/encyclopedia/claimable-balances).

**Threshold:** Medium  
**Result:** `CreateClaimableBalanceResult`  
**Parameters:**

| Parameter | Type              | Description                                                                                                       |
| --------- | ----------------- | ----------------------------------------------------------------------------------------------------------------- |
| Asset     | asset             | Asset that will be held in the ClaimableBalanceEntry in the form `asset_code:issuing_address` or `native` (DIAM). |
| Amount    | integer           | Amount of `asset` stored in the ClaimableBalanceEntry.                                                            |
| Claimants | list of claimants | List of Claimants (account address and ClaimPredicate pair) that can claim this ClaimableBalanceEntry.            |

**Possible errors:**

| Error Code                              | Description                                                                                                                                                                                                                                                      |
| --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CREATE_CLAIMABLE_BALANCE_MALFORMED      | The input to this operation is invalid.                                                                                                                                                                                                                          |
| CREATE_CLAIMABLE_BALANCE_LOW_RESERVE    | The account creating this entry does not have enough DIAM to satisfy the minimum DIAM reserve increase caused by adding a ClaimableBalanceEntry. For every claimant in the list, the minimum amount of DIAM this account must hold will increase by baseReserve. |
| CREATE_CLAIMABLE_BALANCE_NO_TRUST       | The source account does not trust the issuer of the asset it is trying to include in the ClaimableBalanceEntry.                                                                                                                                                  |
| CREATE_CLAIMABLE_BALANCE_NOT_AUTHORIZED | The source account is not authorized to transfer this asset.                                                                                                                                                                                                     |
| CREATE_CLAIMABLE_BALANCE_UNDERFUNDED    | The source account does not have enough funds to transfer the amount of this asset to the ClaimableBalanceEntry.                                                                                                                                                 |

## Claim Claimable Balance

Claims a ClaimableBalanceEntry that corresponds to the BalanceID and adds the amount of an asset on the entry to the source account.

Learn more about claimable balances and view more parameters in the [Encyclopedia -> Claimable Balances Encyclopedia Entry](/encyclopedia/claimable-balances).

**Threshold:** Low  
**Result:** `ClaimClaimableBalanceResult`  
**Parameters:**

| Parameter | Type               | Description                                                                                                                                                                                                                                                                     |
| --------- | ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BalanceID | claimableBalanceID | BalanceID on the ClaimableBalanceEntry that the source account is claiming. The balanceID can be retrieved from a successful `CreateClaimableBalanceResult`. See [Encyclopedia -> Claimable Balance Encyclopedia](/encyclopedia/claimable-balances) Entry for more information. |

**Possible errors:**

| Error Code                             | Description                                                                                                                                                 |
| -------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CLAIM_CLAIMABLE_BALANCE_DOES_NOT_EXIST | There is no existing ClaimableBalanceEntry that matches the input BalanceID.                                                                                |
| CLAIM_CLAIMABLE_BALANCE_CANNOT_CLAIM   | There is no claimant that matches the source account, or the claimant's predicate is not satisfied.                                                         |
| CLAIM_CLAIMABLE_BALANCE_LINE_FULL      | The account claiming the ClaimableBalanceEntry does not have sufficient limits to receive the amount of the asset and still satisfy its buying liabilities. |
| CLAIM_CLAIMABLE_BALANCE_NO_TRUST       | The source account does not trust the issuer of the asset it is trying to claim in the ClaimableBalanceEntry.                                               |
| CLAIM_CLAIMABLE_BALANCE_NOT_AUTHORIZED | The source account is not authorized to claim the asset in the ClaimableBalanceEntry.                                                                       |

## Begin Sponsoring Future Reserves

Allows an account to pay the base reserves for another account; sponsoring account establishes the is-sponsoring-future-reserves relationship.

There must also be an end sponsoring future reserves operation in the same transaction.

Learn more about sponsored reserves in the [Encyclopedia -> Sponsored Reserves Encyclopedia Entry](/encyclopedia/sponsored-reserves).

**Threshold:** Medium  
**Result:** `BeginSponsoringFutureReservesResult`  
**Parameters:**

| Parameter   | Type       | Description                                    |
| ----------- | ---------- | ---------------------------------------------- |
| SponsoredID | account ID | Account that will have its reserves sponsored. |

**Possible errors:**

| Error Code                                         | Description                                                                                       |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| BEGIN_SPONSORING_FUTURE_RESERVES_MALFORMED         | Source account is equal to sponsoredID.                                                           |
| BEGIN_SPONSORING_FUTURE_RESERVES_ALREADY_SPONSORED | Source account is already sponsoring sponsoredID.                                                 |
| BEGIN_SPONSORING_FUTURE_RESERVES_RECURSIVE         | Either source account is currently being sponsored, or sponsoredID is sponsoring another account. |

## End Sponsoring Future Reserves

Terminates the current is-sponsoring-future-reserves relationship in which the source account is sponsored.

Learn more about sponsored reserves in the [Encyclopedia -> Sponsored Reserves Encyclopedia Entry](/encyclopedia/sponsored-reserves?id=sponsored-reserves).

**Threshold:** Medium  
**Result:** `EndSponsoringFutureReservesResult`  
**Parameters:**

| Parameter     | Type       | Description                                            |
| ------------- | ---------- | ------------------------------------------------------ |
| begin_sponsor | account ID | The id of the account which initiated the sponsorship. |

**Possible errors:**

| Error Code                                   | Description                      |
| -------------------------------------------- | -------------------------------- |
| END_SPONSORING_FUTURE_RESERVES_NOT_SPONSORED | Source account is not sponsored. |

## Revoke Sponsorship

Sponsoring account can remove or transfer sponsorships of existing ledgerEntries and signers; the logic of this operation depends on the state of the source account.

Learn more about sponsored reserves in the [Encyclopedia -> Sponsored Reserves Encyclopedia Entry](/encyclopedia/sponsored-reserves?id=sponsored-reserves).

**Threshold:** Medium  
**Result:** `RevokeSponsorshipResult`

This operation is a union with two possible types:

**1. Revoke Sponsorship Ledger Entry**

**Parameters:**

| Union Type                      | Parameters | Type      | Description                                                                                                                                                                         |
| ------------------------------- | ---------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| REVOKE_SPONSORSHIP_LEDGER_ENTRY | LedgerKey  | ledgerKey | Ledger key that holds information to identify a specific ledgerEntry that may have its sponsorship modified. See [LedgerKey](/glossary/glossary?id=ledgerkey) for more information. |

**Or**

**2. Revoke Sponsorship Signer**

**Parameters:**

| Union Type                | Parameters | Type                     | Description                                    |
| ------------------------- | ---------- | ------------------------ | ---------------------------------------------- |
| REVOKE_SPONSORSHIP_SIGNER | Signer     | {account ID, Signer Key} | Signer that may have its sponsorship modified. |

**Possible errors:**

| Error Code                           | Description                                                                                                                                                                                                                                                                                                          |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| REVOKE_SPONSORSHIP_DOES_NOT_EXIST    | The ledgerEntry for LedgerKey doesn’t exist, the account ID on signer doesn’t exist, or the Signer Key doesn’t exist on account ID’s account.                                                                                                                                                                        |
| REVOKE_SPONSORSHIP_NOT_SPONSOR       | If the ledgerEntry/signer is sponsored, then the source account must be the sponsor. If the ledgerEntry/signer is not sponsored, the source account must be the owner. This error will be thrown otherwise.                                                                                                          |
| REVOKE_SPONSORSHIP_LOW_RESERVE       | The sponsored account does not have enough DIAM to satisfy the minimum balance increase caused by revoking sponsorship on a ledgerEntry/signer it owns, or the sponsor of the source account doesn’t have enough DIAM to satisfy the minimum balance increase caused by sponsoring a transferred ledgerEntry/signer. |
| REVOKE_SPONSORSHIP_ONLY_TRANSFERABLE | Sponsorship cannot be removed from this ledgerEntry. This error will happen if the user tries to remove the sponsorship from a ClaimableBalanceEntry.                                                                                                                                                                |
| REVOKE_SPONSORSHIP_MALFORMED         | One or more of the inputs to the operation was malformed.                                                                                                                                                                                                                                                            |

## Clawback

Burns an amount in a specific asset from a receiving account.

**SDKs:** Go  
**Threshold:** Medium  
**Result:** ClawbackResult  
**Parameters:**

| Parameter | Type       | Description                                 |
| --------- | ---------- | ------------------------------------------- |
| From      | account ID | Account address that receives the clawback. |
| Asset     | asset      | Asset held by the destination account.      |
| Amount    | integer    | Amount of the aforementioned asset to burn. |

**Possible errors:**

| Error Code                    | Description                                                                                                            |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| CLAWBACK_MALFORMED            | The input to the clawback is invalid.                                                                                  |
| CLAWBACK_NOT_CLAWBACK_ENABLED | The trustline between From and the issuer account for this Asset does not have clawback enabled.                       |
| CLAWBACK_NO_TRUST             | The From account does not trust the issuer of the asset.                                                               |
| CLAWBACK_UNDERFUNDED          | The From account does not have a sufficient available balance of the asset (after accounting for selling liabilities). |

## Clawback Claimable Balance

Claws back an unclaimed ClaimableBalanceEntry, burning the pending amount of the asset.

Learn more about claimable balances in the [Encyclopedia -> Claimable Balances Encyclopedia Entry](/encyclopedia/claimable-balances).

**Threshold:** Medium  
**Result:** `ClaimClaimableBalanceResult`  
**Parameters:**

| Parameter | Type               | Description                                                                                                                                              |
| --------- | ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| BalanceID | claimableBalanceID | The BalanceID on the ClaimableBalanceEntry that the source account is claiming, which can be retrieved from a successful `CreateClaimableBalanceResult`. |

**Possible errors:**

| Error Code                                      | Description                                                                  |
| ----------------------------------------------- | ---------------------------------------------------------------------------- |
| CLAWBACK_CLAIMABLE_BALANCE_DOES_NOT_EXIST       | There is no existing ClaimableBalanceEntry that matches the input BalanceID. |
| CLAWBACK_CLAIMABLE_BALANCE_NOT_ISSUER           | The source account is not the issuer of the asset in the claimable balance.  |
| CLAWBACK_CLAIMABLE_BALANCE_NOT_CLAWBACK_ENABLED | The `CLAIMABLE_BALANCE_CLAWBACK_ENABLED_FLAG` is not set for this trustline. |

## Set Trustline Flags

Allows the issuing account to configure authorization and trustline flags to an asset.

The Asset parameter is of the TrustLineAsset type. If you are modifying a trustline to a regular asset (i.e., one in a Code:Issuer format), this is equivalent to the Asset type. If you are modifying a trustline to a pool share, however, this is composed of the liquidity pool's unique ID.

Learn more about flags in the [Flags Glossary Entry](/glossary/glossary?id=flags).

**Threshold:** Low  
**Result:** `SetTrustLineFlagsResult`  
**Parameters:**

| Parameter  | Type           | Description                                                                                                                                                                                                                                          |
| ---------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Trustor    | account ID     | The account that established this trustline.                                                                                                                                                                                                         |
| Asset      | TrustLineAsset | The asset trustline whose flags are being modified.                                                                                                                                                                                                  |
| SetFlags   | integer        | One or more flags (combined via bitwise-OR) indicating which flags to set. Possible flags are: 1 if the trustor is authorized to transact with the asset or 2 if the trustor is authorized to maintain offers but not to perform other transactions. |
| ClearFlags | integer        | One or more flags (combined via bitwise OR) indicating which flags to clear. Possibilities include those for SetFlags as well as 4, which prevents the issuer from clawing back its asset (both from accounts and claimable balances).               |

**Possible errors:**

| Error Code                         | Description                                                                                                                                                                                                                                                                      |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SET_TRUST_LINE_FLAGS_MALFORMED     | This can happen for several reasons: the asset specified by AssetCode and AssetIssuer is invalid; the asset issuer isn't the source account; the Trustor is the source account; the native asset is specified; or the flags being set/cleared conflict or are otherwise invalid. |
| SET_TRUST_LINE_FLAGS_NO_TRUST_LINE | The Trustor does not have a trustline with the issuer performing this operation.                                                                                                                                                                                                 |
| SET_TRUST_LINE_FLAGS_CANT_REVOKE   | The issuer is trying to revoke the trustline authorization of Trustor, but it cannot do so because AUTH_REVOCABLE_FLAG is not set on the account.                                                                                                                                |
| SET_TRUST_LINE_FLAGS_INVALID_STATE | If the final state of the trustline has both AUTHORIZED_FLAG (1) and AUTHORIZED_TO_MAINTAIN_LIABILITIES_FLAG (2) set, which are mutually exclusive.                                                                                                                              |
| SET_TRUST_LINE_FLAGS_LOW_RESERVE   | Claimable balances can't be created on revocation of asset (or pool share) trustlines associated with a liquidity pool due to low reserves.                                                                                                                                      |

## Liquidity Pool Deposit

Deposits assets into a liquidity pool, increasing the reserves of a liquidity pool in exchange for pool shares.

Parameters to this operation depend on the ordering of assets in the liquidity pool: "A" refers to the first asset in the liquidity pool, and "B" refers to the second asset in the liquidity pool.

If the pool is empty, then this operation deposits `maxAmountA` of A and `maxAmountB` of B into the pool. If the pool is not empty, then this operation deposits at most `maxAmountA` of A and `maxAmountB` of B into the pool. The actual amounts deposited are determined using the current reserves of the pool. You can use these parameters to control a percentage of slippage.

**Threshold:** Medium  
**Result:** LiquidityPoolDepositResult  
**Parameters:**

| Parameter         | Type                     | Description                                        |
| ----------------- | ------------------------ | -------------------------------------------------- |
| Liquidity Pool ID | liquidityPoolID          | The PoolID for the Liquidity Pool to deposit into. |
| Max Amount A      | integer                  | Maximum amount of the first asset to deposit.      |
| Max Amount B      | integer                  | Maximum amount of the second asset to deposit.     |
| Min Price         | {numerator, denominator} | Minimum depositA/depositB.                         |
| Max Price         | {numerator, denominator} | Maximum depositA/depositB.                         |

**Possible errors:**

| Error Code                            | Description                                                              |
| ------------------------------------- | ------------------------------------------------------------------------ |
| LIQUIDITY_POOL_DEPOSIT_MALFORMED      | One or more of the inputs to the operation was malformed.                |
| LIQUIDITY_POOL_DEPOSIT_NO_TRUST       | No trustline exists for one of the assets being deposited.               |
| LIQUIDITY_POOL_DEPOSIT_NOT_AUTHORIZED | The account does not have authorization for one of the assets.           |
| LIQUIDITY_POOL_DEPOSIT_UNDERFUNDED    | There is not enough balance of one of the assets to perform the deposit. |
| LIQUIDITY_POOL_DEPOSIT_LINE_FULL      | The pool share trustline does not have a sufficient limit.               |
| LIQUIDITY_POOL_DEPOSIT_BAD_PRICE      | The deposit price is outside of the given bounds.                        |
| LIQUIDITY_POOL_DEPOSIT_POOL_FULL      | The liquidity pool reserves are full.                                    |

## Liquidity Pool Withdraw

Withdraw assets from a liquidity pool, reducing the number of pool shares in exchange for reserves of a liquidity pool.

The `minAmountA` and `minAmountB` parameters can be used to control a percentage of slippage from the "spot price" on the pool.

**Threshold:** Medium  
**Result:** LiquidityPoolWithdrawResult  
**Parameters:**

| Parameter         | Type            | Description                                         |
| ----------------- | --------------- | --------------------------------------------------- |
| Liquidity Pool ID | liquidityPoolID | The PoolID for the Liquidity Pool to withdraw from. |
| Amount            | integer         | Amount of pool shares to withdraw.                  |
| Min Amount A      | integer         | Minimum amount of the first asset to withdraw.      |
| Min Amount B      | integer         | Minimum amount of the second asset to withdraw.     |

**Possible errors:**

| Error Code                            | Description                                                            |
| ------------------------------------- | ---------------------------------------------------------------------- |
| LIQUIDITY_POOL_WITHDRAW_MALFORMED     | One or more of the inputs to the operation was malformed.              |
| LIQUIDITY_POOL_WITHDRAW_NO_TRUST      | There is no trustline for one of the assets.                           |
| LIQUIDITY_POOL_WITHDRAW_UNDERFUNDED   | Insufficient balance for the pool shares.                              |
| LIQUIDITY_POOL_WITHDRAW_LINE_FULL     | The withdrawal would exceed the trustline limit for one of the assets. |
| LIQUIDITY_POOL_WITHDRAW_UNDER_MINIMUM | Unable to withdraw enough to satisfy the minimum price.                |
