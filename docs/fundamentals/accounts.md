# Accounts in Diamante

In the Diamante network, accounts are the central data structure that represent entities participating in the network. Each account holds a balance of at least one type of asset and has the ability to issue transactions. Accounts are identified by a unique 56-character string called a public key.

## Account Structure

Each account has several fields:

**Account ID**: The unique public key that identifies the account.

**Balance**: The amount of DIAM held by the account.

**Sequence Number**: A number that is incremented every time a transaction is submitted by the account.

**Trustlines**: Permissions to hold specific assets issued by other accounts.

**Balances of Other Assets**: The account can hold balances of other assets besides DIAM, through the establishment of trustlines.

**Signers**: Public keys that are authorized to sign transactions for the account.

**Thresholds**: Values that determine the level of authorization needed for various operations.

**Offers**: Active sell and buy offers that the account has placed in the Diamante decentralized exchange.

## Creating an Account

Accounts can be created in the Diamante network through the [`Create Account`](/fundamentals/operations?id=create-account) operation. The operation requires the following:

- **Destination**: The public key of the new account.
- **Starting Balance**: The initial amount of Diams to be transferred to the new account.

## Account Thresholds and Signers

Diamante accounts have thresholds and signers to provide flexible control over account authorization. This allows for multi-signature accounts and varied levels of transaction authorization.

**Master Weight**: The weight of the account’s master key.
**Low Threshold**: The threshold for low-security operations (e.g., bump sequence).
**Medium Threshold**: The threshold for medium-security operations (e.g., payment).
**High Threshold**: The threshold for high-security operations (e.g., account merge).

Each operation performed by an account has a specific threshold level. For example, a payment operation might require a medium threshold, whereas merging an account may require a high threshold.

Thresholds are used to add an extra layer of security and control over an account's operations. They allow account holders to define which operations require multiple signatures or higher levels of authorization. This helps in preventing unauthorized transactions and securing the account from potential malicious activities.

### Changing Thresholds and Signers

To change the thresholds or add/remove signers, the [`Set Options`](/fundamentals/operations?id=set-options) operation is used. This operation can modify the following:

- Master Weight
- Low Threshold
- Medium Threshold
- High Threshold
- Signer

## Managing Other Assets

Diamante accounts can hold balances of assets other than DIAM by establishing trustlines with the asset issuer. This allows for the creation of a diverse portfolio within a single account.To create trustline, the [`Change Trust`](/fundamentals/operations?id=change-trust) operation is used.

## Managing Offers

Diamante accounts can place buy and sell offers on the Diamante decentralized exchange. These offers are associated with the account and can be managed through specific operations.

- [**Manage Sell Offer**](/fundamentals/operations?id=manage-buy-offer): Create, update, or delete a sell offer.
- [**Manage Buy Offer**](/fundamentals/operations?id=manage-sell-offer): Create, update, or delete a buy offer.
