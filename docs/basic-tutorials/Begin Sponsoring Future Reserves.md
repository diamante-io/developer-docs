# Begin Sponsoring Future Reserves

The `Begin Sponsoring Future Reserves` operation establishes a relationship where one account sponsors the base reserves of another account. This enables the sponsor account to pay for reserve requirements (e.g., base reserves for entries such as trustlines, offers, data, etc.) on behalf of the sponsored account. It is particularly useful in scenarios where the sponsored account cannot afford the reserves or is designed to have minimal upfront balance.

### Key Characteristics

1. **Sponsorship Relationship**:

- The operation creates a sponsorship relationship, where the sponsor account is responsible for paying reserve requirements for a designated account.

2. **Paired with End Sponsorship**:

- The sponsorship must be explicitly ended using the End Sponsoring Future Reserves operation in the same transaction. This ensures that the relationship is temporary and confined to specific operations or entries.

3. **Threshold**:

- Requires a medium threshold, as it impacts the sponsor's balance and creates a critical blockchain relationship.

4. **Reserve Coverage**:

- The sponsoring account provides funds for the sponsored account's base reserve requirements, which are needed for entries like trustlines, offers, or data entries.

5. **Result**:

- Returns a BeginSponsoringFutureReservesResult, indicating whether the operation was successful.

### Use Cases

1. **Onboarding New Accounts**: Sponsoring entities (e.g., exchanges or custodians) can fund the base reserve requirements for new users to onboard them onto the network seamlessly.
2. **Decentralized Applications (DApps)**: Applications can sponsor reserve requirements for user accounts, making it easier for users to interact with the app without needing to fund the account initially.
3. **Simplifying Operations**: In scenarios where users cannot afford the base reserve requirements, a third-party sponsor can temporarily cover the costs.
4. **Organizations Supporting Others**: Nonprofits, grant programs, or DAOs can sponsor accounts for individuals or projects that require financial assistance to get started on the blockchain.

### Key Components

1. `SponsoredID`: The Account ID of the account that will have its reserves sponsored. This is the recipient of the sponsorship.
2. `Sponsor Account`: The source account initiating the operation. This account pays for the base reserve requirements of the sponsored account.
3. `Transaction Pairing`: The operation must be paired with an End Sponsoring Future Reserves operation within the same transaction to complete the sponsorship process.

# End Sponsoring Future Reserves

The `End Sponsoring Future Reserves` operation terminates the active sponsorship relationship established by the `Begin Sponsoring Future Reserves operation`. Once this operation is executed, the sponsoring account no longer pays for the base reserves of the sponsored account, and the sponsored account assumes full responsibility for its reserve requirements.

### Key Characteristics

1. **Termination of Sponsorship**:

- Ends the sponsorship relationship where one account pays for another's base reserves.

2. **Paired Operation**:

- Must always be paired with the Begin Sponsoring Future Reserves operation in the same transaction. This ensures that sponsorship is initiated and terminated within a single atomic operation.

3. **Account Responsibility**:

- After termination, the sponsored account becomes fully responsible for its reserve requirements.

4. **Threshold**:

- Requires a medium threshold since it modifies account-level relationships and reserve coverage.

5. **Result**:

- Returns an EndSponsoringFutureReservesResult, indicating whether the operation was successful.

### Use Cases

1. `Completing Sponsorship Transactions`: Used at the end of transactions where temporary sponsorship was provided to fund specific operations or entries.
2. `Encouraging Self-Sufficiency`: Ensures that the sponsored account transitions to managing its own reserves after the necessary entries are funded.
3. `Atomic Transactions`: Guarantees that the sponsorship relationship is limited to specific operations or entries, preventing indefinite sponsorship.
4. `DApp Interactions`: Useful in decentralized applications that temporarily sponsor users for specific interactions and then terminate the sponsorship immediately.

### Key Components

1. `Begin Sponsor` : The Account ID of the sponsoring account that initiated the sponsorship. This ensures the relationship is correctly terminated.
2. `Source Account`: The sponsored account that terminates the relationship, taking responsibility for its reserves.
3. `Transaction Pairing`: Must always follow a Begin Sponsoring Future Reserves operation in the same transaction.

This code implements a workflow where a sponsor account creates a new account on the Diamante blockchain, sponsors its base reserves, establishes a trustline for a specific token ("CAT"), and then ends the sponsorship. Here's a detailed breakdown:

<!-- tabs:start -->

#### **Javascript**

```js
// Import required libraries and modules from the Diamnet SDK
const {
  Aurora,
  TransactionBuilder,
  Operation,
  Keypair,
  Networks,
  BASE_FEE,
  Asset,
} = require("diamnet-sdk");

// Connect to the Diamante Testnet server
const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");

// Function to create a new account, sponsor its reserves, and establish a trustline
async function CreateAndSponsorAccount(sponsorSecret) {
  // Keypair of the sponsor account (requires secret key for signing)
  const sponsorKeypair = Keypair.fromSecret(sponsorSecret);

  // Generate a random keypair for the new account to be created
  const newKeypair = Keypair.random();

  try {
    // Load the sponsor account to ensure it has enough balance and is valid
    const sponsorAccount = await server.loadAccount(sponsorKeypair.publicKey());

    // Define the custom token (asset) to establish a trustline for
    const tokenAsset = new Asset(
      "CAT", // Asset code
      "GBHHU65KNWOSXH3HWPADXMONMIVDH4V4PRXSNBWFKVCEW27HEESJXZIH" // Issuer's public key
    );

    // Build the transaction with multiple operations
    const transaction = new TransactionBuilder(sponsorAccount, {
      fee: BASE_FEE, // Fee per operation in the transaction
      networkPassphrase: Networks.TESTNET, // Specify the Testnet passphrase
    })
      // Operation 1: Create a new account with a starting balance
      .addOperation(
        Operation.createAccount({
          destination: newKeypair.publicKey(), // New account's public key
          startingBalance: "5.0000000", // Initial balance in DIAM for the new account
        })
      )
      // Operation 2: Begin sponsoring future reserves for the new account
      .addOperation(
        Operation.beginSponsoringFutureReserves({
          sponsoredId: newKeypair.publicKey(), // Account being sponsored
        })
      )
      // Operation 3: Establish a trustline for the CAT token
      .addOperation(
        Operation.changeTrust({
          source: newKeypair.publicKey(), // Trustline belongs to the new account
          asset: tokenAsset, // The token asset being trusted
        })
      )
      // Operation 4: End the sponsorship for the new account
      .addOperation(
        Operation.endSponsoringFutureReserves({
          source: newKeypair.publicKey(), // Ends sponsorship for this account
        })
      )
      // Set a timeout for the transaction to prevent it from being stuck
      .setTimeout(30)
      // Build the transaction
      .build();

    // Sign the transaction with the sponsor's and the new account's keys
    transaction.sign(sponsorKeypair); // Sponsor signs for creating and sponsoring
    transaction.sign(newKeypair); // New account signs for the trustline and ending sponsorship

    // Submit the transaction to the Diamante Testnet
    const transactionResult = await server.submitTransaction(transaction);

    // Log success and return new account details
    console.log("Account creation and sponsorship successful!");
    console.log("New account public key:", newKeypair.publicKey());
    console.log("New account secret:", newKeypair.secret());
    return {
      publicKey: newKeypair.publicKey(),
      secret: newKeypair.secret(),
      transactionResult,
    };
  } catch (error) {
    // Handle errors and log detailed information
    console.error(
      "Error during account creation and sponsorship:",
      error.response?.data?.extras?.result_codes || error.message
    );
    if (error.response?.data?.extras?.result_codes?.operations) {
      console.error(
        "Operation errors:",
        error.response.data.extras.result_codes.operations
      );
    }
    throw error; // Re-throw error to be handled by the calling function
  }
}

// Main function to execute the workflow
(async () => {
  // Secret key of the sponsor account (replace with the actual secret key)
  const sponsorSecret =
    "SCCBJCCIRBOU4SU7GIMGV5LUAIHTC7BSWVOSUCLZLA4OLKSCZLYZPG7R";

  // Call the CreateAndSponsorAccount function and log the transaction hash
  const newAccount = await CreateAndSponsorAccount(sponsorSecret);
  console.log(
    "Workflow completed successfully. Transaction Hash:",
    newAccount.transactionResult.hash
  );
})();
```
