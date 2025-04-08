# Revoke Sponsorship

The `Revoke Sponsorship` operation allows the sponsoring account to remove or transfer sponsorship of specific ledger entries or signers. Here's a detailed explanation of the two types of Revoke Sponsorship operations:

### Key Characteristics:

- `Purpose`: The Revoke Sponsorship operation allows a sponsoring account to remove or transfer sponsorships of ledger entries or account signers.
- `Functionality`: This operation modifies the sponsorship state of a ledger entry or a signer.
- `Threshold Level`: Requires a medium threshold for execution, which means it needs sufficient authorization.
- `Result`: Returns a RevokeSponsorshipResult object indicating the success or failure of the operation.
- Flexibility: Operates in two ways, based on the type of sponsorship being modified:
  1.  Ledger Entry Sponsorship
  2.  Signer Sponsorship

### Use Case

- **Removing Sponsorship**:
  - When a sponsoring account no longer wants to sponsor a ledger entry or signer, it can revoke the sponsorship.
  - This is useful in scenarios where the sponsoring account wants to reduce its reserve liabilities.
- **Transferring Sponsorship**:
  - The sponsorship can also be reassigned to another account, enabling flexible sponsorship changes.

### Key Components

1. **Revoke Sponsorship for Ledger Entry**

- Parameter:
  - ledgerKey: Identifies the specific ledger entry whose sponsorship is being revoked.
  - Example: Revoking sponsorship of a trustline or a claimable balance.
- LedgerKey Types:
  - Account
  - Trustline
  - Offer
  - Data Entry
  - Claimable Balance

2. **Revoke Sponsorship for Signer**

- Parameter:
  - {account ID, Signer Key}: Specifies the account and signer key being modified.
- Example: Revoking sponsorship of a specific signer's key for an account.

This code demonstrates a workflow for creating a new account on the Diamante testnet, sponsoring its reserve, and then revoking the sponsorship of a trustline. Below is a detailed explanation of what is happening in the code, along with comments added for clarity:

<!-- tabs:start -->

#### **Javascript**

```js
// Import required libraries and components from the Diamnet SDK
const {
  Aurora,
  TransactionBuilder,
  Operation,
  Keypair,
  Networks,
  BASE_FEE,
  Asset,
} = require("diamnet-sdk");

// Initialize the Aurora server connection for the Diamante testnet
const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");

// Function to create a new account, sponsor it, and establish a trustline
async function CreateAndSponsorAccount(sponsorSecret) {
  const sponsorKeypair = Keypair.fromSecret(sponsorSecret); // Load the sponsor's keypair using their secret key
  const newKeypair = Keypair.random(); // Generate a new random keypair for the account being created

  try {
    // Load the sponsor's account from the blockchain
    const sponsorAccount = await server.loadAccount(sponsorKeypair.publicKey());

    // Define a token asset (e.g., "CAT" token issued by a specific issuer)
    const tokenAsset = new Asset(
      "CAT",
      "GBHHU65KNWOSXH3HWPADXMONMIVDH4V4PRXSNBWFKVCEW27HEESJXZIH"
    );

    // Build a transaction to create a new account, sponsor it, and establish a trustline
    const transaction = new TransactionBuilder(sponsorAccount, {
      fee: BASE_FEE, // Specify the base transaction fee
      networkPassphrase: Networks.TESTNET, // Use the Diamante testnet network passphrase
    })
      // Add operation to create a new account with an initial balance
      .addOperation(
        Operation.createAccount({
          destination: newKeypair.publicKey(), // Public key of the new account
          startingBalance: "5.0000000", // Minimum starting balance for the new account
        })
      )
      // Add operation to begin sponsoring future reserves for the new account
      .addOperation(
        Operation.beginSponsoringFutureReserves({
          sponsoredId: newKeypair.publicKey(), // The account being sponsored
        })
      )
      // Add operation to establish a trustline for the "CAT" token
      .addOperation(
        Operation.changeTrust({
          source: newKeypair.publicKey(), // Trustline is being created by the new account
          asset: tokenAsset, // The "CAT" token asset
        })
      )
      .setTimeout(30) // Set transaction timeout
      .build();

    // Sign the transaction with both the sponsor and the new account's keypairs
    transaction.sign(sponsorKeypair, newKeypair);

    // Submit the transaction to the blockchain
    const transactionResult = await server.submitTransaction(transaction);

    console.log("Account creation and sponsorship successful!");
    console.log("New account public key:", newKeypair.publicKey());
    console.log("New account secret:", newKeypair.secret());

    // Return details about the new account and the transaction result
    return {
      publicKey: newKeypair.publicKey(),
      secret: newKeypair.secret(),
      transactionResult,
      trustlineAsset: tokenAsset,
    };
  } catch (error) {
    console.error(
      "Error during account creation and sponsorship:",
      error.response?.data?.extras?.result_codes || error.message
    );
    throw error;
  }
}

// Function to revoke sponsorship of a trustline
async function RevokeSponsorship(sponsorSecret, accountId, trustlineAsset) {
  const sponsorKeypair = Keypair.fromSecret(sponsorSecret); // Load the sponsor's keypair using their secret key

  try {
    // Load the sponsor's account from the blockchain
    const sponsorAccount = await server.loadAccount(sponsorKeypair.publicKey());

    // Build a transaction to revoke the sponsorship of the trustline
    const transaction = new TransactionBuilder(sponsorAccount, {
      fee: BASE_FEE, // Specify the base transaction fee
      networkPassphrase: Networks.TESTNET, // Use the Diamante testnet network passphrase
    })
      // Add operation to revoke sponsorship of the specified trustline
      .addOperation(
        Operation.revokeSponsorship({
          ledgerKey: {
            trustline: {
              account: accountId, // Public key of the account with the trustline
              asset: trustlineAsset, // The "CAT" token trustline asset
            },
          },
        })
      )
      .setTimeout(30) // Set transaction timeout
      .build();

    // Sign the transaction with the sponsor's keypair
    transaction.sign(sponsorKeypair);

    // Submit the transaction to the blockchain
    const transactionResult = await server.submitTransaction(transaction);

    console.log("Sponsorship successfully revoked!");
    return transactionResult;
  } catch (error) {
    console.error(
      "Error revoking sponsorship:",
      error.response?.data?.extras?.result_codes || error.message
    );
    throw error;
  }
}

// Main function to execute the workflow
(async () => {
  // Sponsor account secret key
  const sponsorSecret =
    "SCCBJCCIRBOU4SU7GIMGV5LUAIHTC7BSWVOSUCLZLA4OLKSCZLYZPG7R";

  // Create and sponsor a new account
  const newAccount = await CreateAndSponsorAccount(sponsorSecret);

  console.log("New account created and sponsored:", newAccount.publicKey);

  // Revoke sponsorship of the trustline created earlier
  const revocationResult = await RevokeSponsorship(
    sponsorSecret,
    newAccount.publicKey,
    newAccount.trustlineAsset
  );

  console.log("Sponsorship revoked transaction hash:", revocationResult.hash);
})();
```

<!-- tabs:end -->

This example demonstrates account creation, trustline establishment, and sponsorship revocation, useful in managing sponsored accounts and trustlines in the Diamante blockchain ecosystem.
