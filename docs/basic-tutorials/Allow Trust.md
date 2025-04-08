# Allow Trust

The `Allow Trust` operation is used to update the authorization flags of an existing trustline. It allows an asset issuer to control how their asset is used by accounts that have created trustlines for it.

`Important: This operation is deprecated as of Protocol 17 and has been replaced by the SetTrustlineFlags operation, which provides more granular control.`

### Key Characteristics:

1. **Authorization Management**:

- This operation is specifically for asset issuers who want to control access to their issued assets.
- It updates the authorization state of a trustline between the issuing account and a trustor.

2. **Trustline Dependency**:

- The operation can only be performed if a trustline already exists between the issuer and the recipient account.

3. **Threshold**:

- It has a low threshold, meaning it requires fewer signatures to authorize compared to other operations like creating a trustline.

4. **Flags (Authorization Levels)**:

- 1 : Fully authorized - the account can transact with the asset without restrictions.
- 2 : Authorized to maintain offers - the account can place offers on the market but cannot perform other transactions with the asset.
- 0 : Not authorized - the account cannot transact with the asset or place offers.

### Use Case

The `Allow Trust` operation is mainly used by asset issuers in controlled environments, such as:

- `Compliance Requirements`: Ensuring accounts meet regulatory requirements before they can hold or transact with a particular asset.
- `Restricting Asset Usage`: Temporarily revoking or limiting an account’s ability to trade or hold an asset.
- `Whitelisting Accounts`: Enabling only authorized accounts to use specific assets.

### Key Components

1. Trustor (Account ID):

- The recipient account that holds the trustline for the asset.

2. Type(Asset Code)

- The asset’s code (e.g., USD, TSKON) that is linked to the trustline.

3. Authorize (Flag):

- Specifies the level of authorization (1, 2, or 0).

##### Detailed Workflow

Here is an example implementation of the Allow Trust operation.

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Keypair,
  Operation,
  TransactionBuilder,
  Networks,
  BASE_FEE,
  Aurora,
} = require("diamnet-sdk");

const issuingSecret = "SDXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // Issuer's secret key
const issuingKeypair = Keypair.fromSecret(issuingSecret);
const issuingPublicKey = issuingKeypair.publicKey();

const trustorPublicKey = "GXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // Trustor's public key
const assetCode = "USD";

const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");

async function allowTrust() {
  try {
    const issuerAccount = await server.loadAccount(issuingPublicKey);

    const transaction = new TransactionBuilder(issuerAccount, {
      fee: BASE_FEE,
      networkPassphrase: "Diamante Testnet 2024",
    })
      .addOperation(
        Operation.allowTrust({
          trustor: trustorPublicKey,
          assetCode: assetCode,
          authorize: 1, // Fully authorize
        })
      )
      .setTimeout(30)
      .build();

    transaction.sign(issuingKeypair);

    const result = await server.submitTransaction(transaction);
    console.log("Allow Trust operation successful:", result);
  } catch (error) {
    console.error("Error during Allow Trust operation:", error);
  }
}

allowTrust();
```

<!-- tabs:end -->

The Allow Trust operation was a foundational way to manage trustline authorization but is now deprecated. Use SetTrustlineFlags for modern implementations to benefit from more advanced trustline features.
