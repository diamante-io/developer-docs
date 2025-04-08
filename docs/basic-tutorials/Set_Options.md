# Set Options

The `Set Options` operation in the Diamante allows you to modify various properties of an account. This includes changing flags, inflation destination, master key weight, thresholds, home domain, and signers. These settings are essential for configuring the account's behavior and security.

### Key Characteristics:

1. **Flags**:
   Flags are binary indicators that define different properties or behaviors of the account. They can control things like whether the account can be activated, frozen, or used in certain operations. Flags can be added or cleared using a bit mask integer.
2. **Signers**:
   Signers define the public keys allowed to authorize operations on the account. Each signer has a weight, and the account’s thresholds determine how many signers (with a certain weight) are required to approve an operation. This is part of multisignature functionality.
3. **Thresholds**:
   Thresholds control the minimum number of signers required to approve an operation at different levels: low, medium, and high. The master key weight and the total weight of the signers must meet or exceed the respective threshold to perform an operation.
4. **Inflation Destination**:
   This parameter defines the account to which newly minted tokens (inflation) will be sent.
5. **Home Domain**:
   The home domain is a string that represents a URL or domain associated with the account, often used in federation or for verification purposes.

### Use Case

The Set Options operation in the Diamante blockchain allows an account to configure various settings, including flags, inflation destination, key weights, thresholds, and signers. It is used to modify the account's behavior and security, such as enabling or disabling payments, defining the number of required signers, and setting the account's home domain. It supports flexible control over permissions, enabling features like multisignature and inflation redirection. This operation is important for maintaining account security and defining transaction thresholds. The operation requires careful management of account settings to ensure desired functionality and security. in the below rovided code snippet demonstrates the process of creating a new account on the Diamante testnet, setting options for the new account, and assigning custom settings such as thresholds, flags, and signers. Here's a step-by-step explanation:

### Detailed Explanation of Each Parameter:

1. **Inflation Destination**:

- Specifies the account where newly created tokens (inflation) will go. If no inflation destination is set, the inflation is not directed to any specific account.

2. **Clear Flags**:

- Flags are represented by a bitmask, so each flag corresponds to a specific bit. You can clear flags by providing a bit mask that removes certain flags.
- For example, clearing the "disallow incoming payments" flag would be done by subtracting the flag's bit value.

3. **Set Flags**:

- This sets specific flags on the account by adding corresponding bit values to the account's current flags.
- Example flags might include allowing payments, allowing trustlines, or enabling multisignature features.

4. **Master Key Weight**:

- The master key is typically the first key created for the account, and it can - have a weight that contributes to the signing threshold.
- If you set the master weight to 0, it effectively disables the master key, which may require using other signers for operations.

5. **Thresholds**:

- Low, Medium, High thresholds control the minimum number of signers required for each type of operation:
  - Low threshold: Used for operations like payments or simple transactions.
  - Medium threshold: Used for moderate operations like creating accounts or modifying assets.
  - High threshold: Used for more sensitive operations like updating signers or changing account settings.
- The threshold is the sum of signer weights that must meet or exceed the set threshold for the operation to succeed.

6. **Home Domain**:

- The home domain is a string that can be used for federation, which allows users to look up account addresses using human-readable names (like email addresses).
- Example: example.com could be the home domain for an account.

7. **Signer**:

- Signers are added, updated, or removed from the account.
- A signer is identified by its `public key`, and each signer has an associated `weight`. The weight determines the importance of the signer.
- If the signer’s weight is set to 0, it effectively removes the signer from the account.

##### Detailed Workflow

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Aurora,
  Keypair,
  Operation,
  BASE_FEE,
  TransactionBuilder,
} = require("diamnet-sdk");

const secret = "SBZM56J24QK7IHSUXXROFZSYFIIUG3IOWGXACML7DF42FRBNJWAY3VGS"; // Secret key of the source account that will fund the new account.

// Create an asynchronous function to create a new account.
async function CreateAccount(secret) {
  // Connect to the Diamante testnet using Aurora server.
  const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");

  // Create a keypair object from the secret of the source account.
  const sourceKeypair = Keypair.fromSecret(secret);

  // Load the account information from the Diamante testnet using the source public key.
  const account = await server.loadAccount(sourceKeypair.publicKey());

  // If the source account is not found, throw an error.
  if (!account) {
    throw new Error("Source account not found");
  }

  // Create a new keypair for the new account.
  const newKeypair = Keypair.random();
  const newAccountPublicKey = newKeypair.publicKey(); // Public key of the new account.

  // Create a new transaction to create a new account with a starting balance.
  const tx = new TransactionBuilder(account, {
    fee: BASE_FEE, // Set the transaction fee.
    networkPassphrase: "Diamante Testnet 2024", // Set the network passphrase.
  })
    .addOperation(
      Operation.createAccount({
        destination: newAccountPublicKey, // Set the destination (new account public key).
        startingBalance: "10.0000000", // Set the initial balance for the new account (10 DIAM).
      })
    )
    .setTimeout(30) // Set the transaction timeout (30 seconds).
    .build(); // Build the transaction.

  // Sign the transaction with the source account's secret key.
  tx.sign(sourceKeypair);

  // Submit the transaction to the Diamante testnet server.
  const response = await server.submitTransaction(tx);

  // If the transaction is successful, log the new account's details and proceed with setOption.
  if (response.successful) {
    console.log("New account public key:", newAccountPublicKey);
    console.log("New account secret:", newKeypair.secret());

    // Call the setOption function to set options for the new account.
    await setOption(secret, newKeypair);
  } else {
    console.error("Transaction failed:", response); // If the transaction fails, log the error.
  }
}

// Create an asynchronous function to set options for the new account.
async function setOption(secret, newKeypair) {
  // Connect to the Diamante testnet again using Aurora server.
  const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");

  // Load the new account using the new account's public key.
  const account = await server.loadAccount(newKeypair.publicKey());

  // If the new account is not found, throw an error.
  if (!account) {
    throw new Error("New account not found");
  }

  // Create a new transaction to set options for the new account.
  const tx = new TransactionBuilder(account, {
    fee: BASE_FEE, // Set the transaction fee.
    networkPassphrase: "Diamante Testnet 2024", // Set the network passphrase.
  })
    .addOperation(
      Operation.setOptions({
        clearFlags: 0, // No flags are cleared in this case.
        setFlags: 1, // Set specific flags (e.g., AUTH_REQUIRED_FLAG).
        masterWeight: 1, // Set the weight for the master key.
        lowThreshold: 1, // Set the low threshold for operations.
        medThreshold: 2, // Set the medium threshold for operations.
        highThreshold: 3, // Set the high threshold for operations.
        homeDomain: "example.com", // Set the home domain for the new account.
        signer: {
          ed25519PublicKey: Keypair.fromSecret(secret).publicKey(), // Add a new signer to the account.
          weight: 1, // Set the weight of the new signer.
        },
      })
    )
    .setTimeout(30) // Set the transaction timeout (30 seconds).
    .build(); // Build the transaction.

  // Sign the transaction with the new account's secret key.
  tx.sign(newKeypair);

  // Submit the transaction to the Diamante testnet server.
  const response = await server.submitTransaction(tx);

  // If the setOption operation is successful, log success message.
  if (response.successful) {
    console.log("setOption operation successful for new account");
  } else {
    console.error("setOption operation failed:", response); // If it fails, log the error.
  }
}

// Immediately invoke the CreateAccount function with the given secret.
(async () => {
  await CreateAccount(secret);
})();
```

<!-- tabs:end -->

This script demonstrates how to create a new account, configure its options, and interact with the Diamante testnet.
