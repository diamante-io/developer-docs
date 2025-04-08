# Clawback

The `Clawback` operation to the process of recovering or burning a specified amount of an asset from a receiving account. This operation can be used to `"reclaim"` or `"burn"` tokens or assets that were previously transferred to an account, either due to certain conditions or as part of a policy enforcement.

### Key Characteristics:

- `Purpose`: The main purpose of the Clawback operation is to burn (i.e., remove or destroy) a specific amount of an asset from an account. This operation is typically used in cases where an account's assets need to be reclaimed or canceled.
- `Accountability`: The operation can only be performed by an account that has been authorized to perform a clawback on the asset. This often involves a special permission or a governance rule in place.
- `Irreversible`: Once an asset has been burned through a Clawback operation, it cannot be restored. It is a permanent and irreversible process.
- `Asset Control`: The operation is often used to manage the control and distribution of tokens, ensuring that only valid or authorized transactions can burn or reclaim assets.

### Use Case

- **Token Burns**: The Clawback operation is used by token issuers or organizations to burn tokens from an account, for example, as part of a token distribution or reward scheme where tokens need to be revoked or burned under certain conditions.
- **Fraud Prevention**: It can be used to reverse fraudulent transfers of tokens or assets by reclaiming them from a specific account.
- **Compliance and Regulation**: It may be used to comply with regulatory requirements, such as reclaiming tokens in specific scenarios or burning them due to changes in token issuance rules or guidelines.
- **Recovery**: The operation can be useful for recovering assets if tokens were erroneously transferred or if an account was compromised.

### Key Components

1. **From (Account ID)**:

- Type: account ID : The receiving account from which the asset is being clawed back (i.e., the account from which the tokens will be burned). This is the address of the account where the asset resides.

2. **Asset**:

- Type: asset: The specific asset to be burned. It could be any type of token or digital asset that is part of the blockchain's asset list. In most blockchain implementations, assets can represent various forms of currency, tokens, or other types of digital goods.

3. **Amount**:

- Type: integer: The amount of the specified asset that is to be burned. This is the quantity of tokens or assets that will be reclaimed from the account and permanently destroyed.

implementation of a Clawback operation using the Diamante . Clawback allows an issuer of a token to reclaim (burn) a specified amount of tokens from a recipient account. Below is a breakdown explanation

<!-- tabs:start -->

#### **Javascript**

```js
// Import necessary modules from the Diamante SDK
const {
  Asset,
  Aurora,
  BASE_FEE,
  Keypair,
  Operation,
  TransactionBuilder,
  StrKey,
} = require("diamnet-sdk");

// Secret key for the source account that will initiate the clawback
const secret = "SBNSPB4X3YHFYSXOPLBXY4D63HUJ7X73PZKPAPTNYT5SSGAC56VLGJZU";

// Initialize server connection to the Diamante test network
const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");

// Function to perform the clawback operation
async function clawback(
  fromAccountId,
  assetCode,
  distributorPublicKey,
  amount,
  server
) {
  // Create Keypair object for the source account from the provided secret key
  const sourceKeypair = Keypair.fromSecret(secret);

  // Load the source account from the blockchain using the public key
  const sourceAccount = await server.loadAccount(sourceKeypair.publicKey());

  // Validate the distributor's public key to ensure it is a valid Ed25519 key
  if (!StrKey.isValidEd25519PublicKey(distributorPublicKey)) {
    throw new Error("Invalid distributor public key");
  }

  // Fetch the assets issued by the distributor from the server
  const assets = await server.assets().forIssuer(distributorPublicKey).call();

  // Search for the asset with the specified assetCode
  const asset = assets.records.find((a) => a.asset_code === assetCode);

  // If the asset is not found, throw an error
  if (!asset) {
    throw new Error(`Asset ${assetCode} not found for the given distributor`);
  }

  // Check if clawback is enabled for this asset
  if (!asset.flags.clawback_enabled) {
    throw new Error(`Clawback is not enabled for asset ${assetCode}`);
  }

  // Create a transaction to perform the clawback operation
  const clawbackTx = new TransactionBuilder(sourceAccount, {
    fee: BASE_FEE, // Transaction fee
    networkPassphrase: "Diamante Testnet 2024", // Network passphrase for testnet
  })
    // Add the clawback operation to the transaction
    .addOperation(
      Operation.clawback({
        from: fromAccountId, // The account from which the asset will be clawed back
        asset: new Asset(assetCode, distributorPublicKey), // The asset being clawed back
        amount: amount.toString(), // The amount to burn
      })
    )
    // Set transaction timeout (in seconds)
    .setTimeout(30)
    // Build the transaction
    .build();

  // Sign the transaction using the source account's keypair
  clawbackTx.sign(sourceKeypair);

  try {
    // Submit the transaction to the blockchain
    const clawbackResponse = await server.submitTransaction(clawbackTx);
    console.log("Clawback response:", clawbackResponse);
    return clawbackResponse;
  } catch (error) {
    // Log any error if the transaction fails
    console.error(
      "Detailed error:",
      JSON.stringify(error.response.data, null, 2)
    );
    throw error;
  }
}

// Function to apply the clawback operation using specific details
async function applyClawback() {
  const assetCode = "WSI"; // Asset code to claw back
  const distributorPublicKey =
    "GB5ICLJ6DY6V5QKKUGTF6BXTCDP53PFIPTML4Z6HSHI66CT2DHUDN3F7"; // Public key of the distributor (issuer)
  const fromAccountId =
    "GBPF47DP3V6PEQKTBGFWW7V46MJZX6FZXHPNI34ROWXUZVBPTAEFIS64"; // Account ID from which to claw back the asset
  const amountToBurn = "100"; // Amount of asset to burn/reclaim

  try {
    // Perform the clawback operation
    await clawback(
      fromAccountId,
      assetCode,
      distributorPublicKey,
      amountToBurn,
      server
    );
    console.log("Clawback operation completed successfully");
  } catch (error) {
    // Log any error that occurs during the clawback
    console.error("Error during clawback operation:", error.message);
  }
}

// Execute the clawback operation
(async () => {
  await applyClawback();
})();
```

<!-- tabs:end -->

This implements a clawback mechanism on the Diamante blockchain, enabling a distributor to reclaim tokens from an account. It first verifies if the asset and clawback features are available and then constructs and submits a transaction to burn the specified amount of tokens from the account.
