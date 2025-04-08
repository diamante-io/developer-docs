# Set Trustline Flags

The `Set Trustline` Flags operation allows the issuing account of an asset to configure or modify the authorization and trustline flags for a trustline. This is an important functionality for asset management on the Diamante .

### Key Characteristics:

- Trustline: A trustline is the relationship between an account and an asset. It defines how an account can hold and transact with the asset. Setting trustline flags allows controlling the permissions associated with this relationship.
- Flags: Flags are used to define specific actions or permissions associated with a trustline. These include whether an account is authorized to transact with the asset or whether the issuer can clawback the asset from the account.

### TrustLineAsset Type:

The `TrustLineAsset` type is used for specifying the asset whose trustline is being modified. If you are modifying a trustline to a regular asset (i.e., an asset that follows the `Code:Issuer` format), it is essentially the same as the Asset type. For a trustline to a `liquidity pool` share, the `TrustLineAsset` consists of the liquidity pool's unique ID.

### Flags Glossary:

- SetFlags: The flags that will be set for the trustline.
  1.  Authorizes the trustor (the account holding the trustline) to transact with the asset.
  2.  Authorizes the trustor to maintain offers (for example, to place sell orders) but not to perform other types of transactions.
- ClearFlags: The flags that will be cleared from the trustline.
  1.  Removes authorization for the trustor to transact with the asset.
  2.  Removes authorization for the trustor to maintain offers.
  3.  Prevents the issuer from clawing back the asset from the trustor's account or from claimable balances.

### Use Case

The `Set Trustline Flags` operation allows the issuing account to configure or modify the authorization and trustline flags on a specific asset for a trustor (account that has a trustline to the asset). This operation is useful in scenarios where the issuer wants to control the access or permissions of the trustor related to a specific asset or liquidity pool share.

### Key Components

1. Trustor: Type: `Account ID`: The account that has established a trustline for the specified asset. The trustor is the entity whose trustline flags are being modified.
2. Asset: Type: `TrustLineAsset` : The asset or pool share whose trustline flags are being modified. If the asset is a standard Code:Issuer type, it behaves like a regular Asset. For liquidity pool shares, it is represented by the pool's unique ID.
3. SetFlags: Type: `Integer`: Specifies one or more flags to set on the trustline. The flags are combined using a bitwise-OR operation. Available flags:
   1. Authorizes the trustor to transact with the asset.
   2. Authorizes the trustor to maintain offers but not perform other transactions.
4. ClearFlags: Type: `Integer` : Specifies one or more flags to clear on the trustline. The flags are combined using a bitwise-OR operation. Available flags:
   1. Revokes authorization to transact with the asset.
   2. Revokes authorization to maintain offers.
   3. Prevents the issuer from clawing back the asset from the trustor.

in the below example allows the trustor to interact with the newly created asset on the Diamante.

### Explanation of the Workflow

1. Create Trustor Account: The script generates a new trustor account by creating a new keypair and logging the public and secret keys for future use.
2. Fund Trustor Account: It then creates a transaction to fund the trustor account with an initial balance of 10 Diams (to allow the trustor to pay transaction fees and establish a trustline).
3. Establish Trustline: The trustor account establishes a trustline to the new asset (MYASSET) issued by the issuer. A trustline is essentially an agreement to hold a certain amount of the asset, with a specified limit (in this case, 1000 units).
4. Set Trustline Flags: After the trustline is established, the issuer sets trustline flags for the trustor. These flags determine the trustor's permissions with the asset (whether they are authorized to transact, maintain offers, etc.).

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Keypair,
  TransactionBuilder,
  Operation,
  BASE_FEE,
  Asset,
  Aurora,
} = require("diamnet-sdk");

// Set up the server connection to the Diamante Testnet
const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");

// The issuer's secret key to manage asset creation and transaction signing
const issuerSecret = "SAXQEQQXTL62LLI4ABW4OWZ3F6D736SO3FTA37YWQDIHOPITJYEMJY67";

// Define the new asset code that will be used in trustlines
const assetCode = "MYASSET"; // Replace with your asset code

async function createAndSetTrustlineFlags() {
  try {
    // Step 1: Create a new Trustor account (a user who will hold the asset)
    // Generate a new keypair for the trustor (the account that will establish the trustline)
    const trustorKeypair = Keypair.random(); // Generates a random public/private key pair
    const trustorPublicKey = trustorKeypair.publicKey(); // The public key of the trustor
    const trustorSecret = trustorKeypair.secret(); // The private secret key of the trustor

    // Log the new trustor's credentials for future reference
    console.log("New Trustor Account Created:");
    console.log("Public Key:", trustorPublicKey);
    console.log("Secret Key:", trustorSecret);

    // Step 2: Load the issuer account (the account that will issue the asset)
    const issuerKeypair = Keypair.fromSecret(issuerSecret); // Load the issuer's keypair from the secret key
    const issuerAccount = await server.loadAccount(issuerKeypair.publicKey()); // Load the issuer's account details from the server

    // Step 3: Fund the trustor account
    // Create a transaction to fund the trustor's account with a small starting balance (e.g., 10 diams)
    const fundTx = new TransactionBuilder(issuerAccount, {
      fee: BASE_FEE, // Set the base fee for the transaction
      networkPassphrase: "Diamante Testnet 2024", // Specify the network for the transaction
    })
      .addOperation(
        Operation.createAccount({
          destination: trustorPublicKey, // The public key of the trustor being funded
          startingBalance: "10", // Amount of diams to fund the trustor's account with
        })
      )
      .setTimeout(30) // Set the transaction timeout (in seconds)
      .build(); // Build the transaction

    fundTx.sign(issuerKeypair); // Sign the transaction with the issuer's keypair

    // Submit the transaction to the server to fund the trustor account
    const fundResult = await server.submitTransaction(fundTx);
    console.log("Trustor account funded successfully:", fundResult.hash); // Log the result of the fund transaction

    // Step 4: Trustor establishes a trustline for the new asset
    // The trustor must establish a trustline to the asset they want to transact with
    const trustorAccount = await server.loadAccount(trustorPublicKey); // Load the trustor's account details
    const newAsset = new Asset(assetCode, issuerKeypair.publicKey()); // Create a new asset instance with the issuer's public key

    // Create a transaction to establish the trustline for the asset
    const trustlineTx = new TransactionBuilder(trustorAccount, {
      fee: BASE_FEE, // Set the transaction fee
      networkPassphrase: "Diamante Testnet 2024", // Specify the network for the transaction
    })
      .addOperation(
        Operation.changeTrust({
          asset: newAsset, // Specify the asset for which the trustline is being established
          limit: "1000", // Set the trustline limit (maximum amount the trustor can hold of the asset)
        })
      )
      .setTimeout(30) // Set the transaction timeout
      .build(); // Build the transaction

    trustlineTx.sign(trustorKeypair); // Sign the transaction with the trustor's keypair

    // Submit the transaction to the server to establish the trustline
    const trustlineResult = await server.submitTransaction(trustlineTx);
    console.log("Trustline established successfully:", trustlineResult.hash); // Log the result of the trustline transaction

    // Step 5: Set trustline flags for the trustor account
    // After establishing the trustline, we can configure flags for the trustor account regarding the asset
    const issuerAccountAfterFunding = await server.loadAccount(
      issuerKeypair.publicKey()
    ); // Reload the issuer account after funding

    // Create a transaction to set trustline flags
    const setFlagsTx = new TransactionBuilder(issuerAccountAfterFunding, {
      fee: BASE_FEE, // Set the transaction fee
      networkPassphrase: "Diamante Testnet 2024", // Specify the network for the transaction
    })
      .addOperation(
        Operation.setTrustLineFlags({
          trustor: trustorPublicKey, // The trustor whose flags are being set
          asset: newAsset, // The asset for which the trustline flags are being set
          flags: {
            authorized: true, // Authorize the trustor to transact with the asset
            authorizedToMaintainLiabilities: false, // Optional: Disallow the trustor to maintain liabilities for the asset
          },
        })
      )
      .setTimeout(30) // Set the transaction timeout
      .build(); // Build the transaction

    setFlagsTx.sign(issuerKeypair); // Sign the transaction with the issuer's keypair

    // Submit the transaction to the server to set the trustline flags
    const setFlagsResult = await server.submitTransaction(setFlagsTx);
    console.log("Trustline flags set successfully:", setFlagsResult.hash); // Log the result of the flag setting transaction
  } catch (error) {
    // Catch and log any errors that occur during the process
    console.error(
      "Error during operation:",
      error.response?.data || error.message
    );
  }
}

// Run the function to create and set trustline flags
createAndSetTrustlineFlags();
```

<!-- tabs:end -->
