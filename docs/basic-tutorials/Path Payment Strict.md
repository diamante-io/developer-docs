# Path Payment Strict Send and Receive

The `Path Payment Strict Send` and `Path Payment Strict Receive` operations are advanced payment methods in the Diamante blockchain. These operations are used when you want to send a specific amount of a source asset and receive the best possible amount of a destination asset or ensure the receiver gets a specific amount of the destination asset, respectively. Here's a breakdown of how each works and their use cases:

## Path Payment Strict Send

The primary purpose of Path Payment Strict Send is to ensure that the sender can transfer a specific amount of a source asset and receive the best possible amount of the destination asset. This mechanism is particularly useful in scenarios where the sender is more concerned with the exact amount they are sending rather than the exact amount the receiver will get.

### Use Case

Path Payment Strict Send is ideal for situations where the sender knows exactly how much of a source asset they want to send but is flexible about the amount of the destination asset the receiver will get. This can be useful in various financial transactions, such as:

- Cross-border payments : Where the sender wants to send a fixed amount in their local currency and is open to the receiver getting the best possible amount in their local currency.
- Decentralize Exchanges : Where the sender wants to convert a specific amount of one cryptocurrency to another, aiming to get the best possible conversion rate.
- Investment transfers: Where the sender wants to invest a fixed amount in one asset and is flexible about the amount received in another asset.

#### Key Attributes

1. **Send Amount**:

- This is the fixed amount of the source asset that the sender wants to transfer. It is specified by the sender and remains constant throughout the transaction.

2. **Destination Minimum Amount**:

- This is the minimum acceptable amount of the destination asset that the receiver should get. While the sender is flexible about the exact amount, they can set a minimum threshold to ensure that the receiver gets at least this much of the destination asset.

3. **Path**:

- This is an optional list of intermediate assets that the transaction can trade through to achieve the best possible conversion rate. The path can include multiple assets, allowing for complex multi-hop transactions that can optimize the conversion process.

#### Example:

the `pathPaymentStrictSend` operation is used to facilitate the swap functionality on a exchange platform of DIAM (the native asset) for WOLF (a custom token asset). Here's a detailed explanation of how `pathPaymentStrictSend` works in this context:

The `pathPaymentStrictSend` operation ensures that a specific amount of a source asset is sent, and the best possible amount of the destination asset is received. The sender specifies the exact amount of the source asset to send and a minimum acceptable amount of the destination asset to receive.

#### Key Components

1. `sendAsset`: The asset being sent (DIAM in this case).

2. `sendAmount`: The exact amount of the source asset to send.

3. `destination`: The account that will receive the destination asset (the sender's own account in this case).

4. `destAsset`: The asset to be received (WOLF in this case).

5. `destMin` : The minimum acceptable amount of the destination asset to receive.

6. `path`: An optional list of intermediate assets to trade through (DIAM in this case).

#### Detailed Workflow

1 - We'll start, as always, with our SDK and helper utilities and Network configuration

<!-- tabs:start -->

#### **Javascript**

```js
const {
  Keypair,
  Aurora,
  TransactionBuilder,
  Networks,
  Operation,
  Asset,
  BASE_FEE,
} = require("diamnet-sdk");
// Network configuration
const NETWORK_PASSPHRASE = "Diamante Testnet 2024";
const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");
```

<!-- tabs:end -->

2 - Function to perform a token swap and Generate keypair and extract the public key from the provided secret key and Define Assets. in this scenario `diamAsset`: Represents the native DIAM asset and `TokenAsset`: Represents the custom WOLF token asset.

<!-- tabs:start -->

#### **Javascript**

```js
// Function to perform a token swap
async function swapAssets(secretKey, sendAmount, poolId) {
  // Generate keypair and extract the public key from the provided secret key
  const keypair = Keypair.fromSecret(secretKey);
  const publicKey = keypair.publicKey();

  // Define the native DIAM asset and the custom token asset (WOLF)
  const diamAsset = Asset.native();
  const TokenAsset = new Asset(
    "WOLF",
    "GAUOYFQZUERFKOXKUCE2BBVYLR6C6NG2OBCGA4GU6X67C6OJKLFCHY5E"
  );
```

<!-- tabs:end -->

3 - Load the user's account data from the Diamnet server Checks if a trustline for the WOLF token exists. If not, creates one

<!-- tabs:start -->

#### **Javascript**

```js
// Load the user's account data from the Diamnet server
const questAccount = await server.loadAccount(publicKey);

// Check if the user has an existing trustline for the token asset
const accountLines = await server.loadAccount(publicKey);
let hasTrustline = false;
for (let line of accountLines.balances) {
  if (
    line.asset_code === TokenAsset.code &&
    line.asset_issuer === TokenAsset.issuer
  ) {
    hasTrustline = true;
    break;
  }
}

// If the trustline does not exist, create one
if (!hasTrustline) {
  const trustTransaction = new TransactionBuilder(questAccount, {
    fee: BASE_FEE,
    networkPassphrase: NETWORK_PASSPHRASE,
  })
    .addOperation(
      Operation.changeTrust({
        asset: TokenAsset,
      })
    )
    .setTimeout(0)
    .build();

  // Sign and submit the trustline transaction
  trustTransaction.sign(keypair);
  await server.submitTransaction(trustTransaction);
  console.log("Trustline created successfully");
}
```

<!-- tabs:end -->

4 - Fetch liquidity pool details using the provided pool ID and Extract reserves from the liquidity pool and Calculate the amount of tokens (WOLF) to be received based on the DIAM sent.

<!-- tabs:start -->

#### **Javascript**

```js
// Fetch liquidity pool details using the provided pool ID
const pool = await server.liquidityPools().liquidityPoolId(poolId).call();

// Extract reserves from the liquidity pool
const reserveA = parseFloat(pool.reserves[0].amount); // DIAM reserve
const reserveB = parseFloat(pool.reserves[1].amount); // WOLF reserve

// Calculate the amount of tokens (WOLF) to be received based on the DIAM sent
const swappedAmount = (sendAmount * reserveB) / (reserveA + sendAmount);
const minToken = (swappedAmount * 0.98).toFixed(7); // Apply a 98% buffer for minimum received amount
```

<!-- tabs:end -->

5 - Build the transaction for the swap `pathPaymentStrictSend` operation and Submit the transaction to the Diamnet server.

<!-- tabs:start -->

#### **Javascript**

```js
// Build the transaction for the swap operation
  const transaction = new TransactionBuilder(questAccount, {
    fee: BASE_FEE,
    networkPassphrase: NETWORK_PASSPHRASE,
  })
    .addOperation(
      Operation.pathPaymentStrictSend({
        sendAsset: diamAsset,
        sendAmount: sendAmount.toFixed(7), // Amount of DIAM to send
        destination: publicKey, // Destination is the sender's own account
        destAsset: TokenAsset, // Token to receive
        destMin: minToken, // Minimum token amount to receive (buffer applied)
        path: [diamAsset], // Path of the swap
      })
    )
    .setTimeout(0)
    .build();

  // Sign the transaction
  transaction.sign(keypair);

  // Submit the transaction to the Diamnet server
  try {
    const result = await server.submitTransaction(transaction);
    console.log("Swap successful:", result.hash);
    return { success: true, hash: result.hash }; // Return success and transaction hash
  } catch (error) {
    console.error("Swap failed:", error);
    return { success: false, error: error.message }; // Return failure and error message
  }
}

// Example usage of the swapAssets function
(async () => {
  const secretKey = "SBP3FOMXTZLF5ESD4D4QNYYMKRDHM4UWK75UEICJKBIOTZ6HJSDJFSZ6"; // Replace with the user's secret key
  const sendAmount = 5; // Amount of DIAM to send
  const poolId = "440027a4a8ce095f9f2c606dde7fd789fd7c2f7e5c1f1f681aef818bef417cac"; // replace Pool ID(https://diamtestnet.diamcircle.io/liquidity_pools )

  const result = await swapAssets(secretKey, sendAmount, poolId);
  if (result.success) {
    console.log("Swap successful:", result.hash);
  } else {
    console.error("Swap failed:", result.error);
  }
})();

```

<!-- tabs:end -->

The `pathPaymentStrictSend` operation in the Diamnet SDK can be used for more than just token swaps. It enables cross-asset payments, arbitrage opportunities, automated portfolio rebalancing, escrow services, and various DeFi applications. This versatility makes it a powerful tool for precise and reliable asset transfers in the blockchain ecosystem.

<!-- tabs:start -->

## Path Payment Strict Receive

The primary purpose of `Path Payment Strict Receive` is to ensure that the receiver gets exactly the specified amount of the destination asset, while allowing the network to determine the amount of the source asset the sender must pay. This mechanism is particularly useful in scenarios where the receiver needs a precise amount of the destination asset, and the sender is flexible about the amount of the source asset they will use for payment.

### Use Case

Path Payment Strict Receive is ideal for situations where the receiver requires a fixed amount of a specific asset, and the sender is willing to pay whatever amount of the source asset is necessary to fulfill that requirement. This can be useful in various financial transactions, such as:

- **Cross-border payments**: Where the receiver needs a fixed amount in their local currency, and the sender is willing to pay the equivalent amount in their local currency.
- **Decentralized Exchanges**: Where the receiver needs a specific amount of a cryptocurrency, and the sender is willing to pay the equivalent amount in another cryptocurrency.
- **Investment transfers**: Where the receiver needs a fixed amount in one asset for investment purposes, and the sender is willing to pay the equivalent amount in another asset.

#### Key Attributes

1. **Destination Amount**:

- This is the fixed amount of the destination asset that the receiver will get. It is specified by the sender and remains constant throughout the transaction.

2. **Source Maximum Amount**:

- This is the maximum amount of the source asset that the sender is willing to pay. While the sender is flexible about the exact amount, they can set a maximum threshold to ensure that they do not pay more than this amount of the source asset.

3. **Path**:

- This is an optional list of intermediate assets that the transaction can trade through to achieve the best possible conversion rate. The path can include multiple assets, allowing for complex multi-hop transactions that can optimize the conversion process.

#### Example:

The `pathPaymentStrictReceive` operation is used to facilitate the swap functionality on an exchange platform, allowing users to receive a specific amount of WOLF (a custom token asset) by sending DIAM (the native asset). Here's a detailed explanation of how `pathPaymentStrictReceive` works in this context:

The `pathPaymentStrictReceive` operation ensures that a specific amount of a destination asset is received, and the best possible amount of the source asset is sent. The sender specifies the exact amount of the destination asset to receive and a maximum acceptable amount of the source asset to send.

#### Key Components

1. `sendAsset`: The asset being sent (DIAM in this case).
2. `sendMax`: The maximum amount of the source asset to send, including a buffer to account for slippage.
3. `destination`: The account that will receive the destination asset (the sender's own account in this case).
4. `destAsset`: The asset to be received (WOLF in this case).
5. `destAmount`: The exact amount of the destination asset to receive.
6. `path`: An optional list of intermediate assets to trade through (DIAM in this case).

#### Detailed Workflow

1 - We'll start, as always, with our SDK and helper utilities and Network configuration

 <!-- tabs:start -->

#### **Javascript**

```Js
const {
  Keypair,
  Aurora,
  TransactionBuilder,
  Networks,
  Operation,
  Asset,
  BASE_FEE,
} = require("diamnet-sdk");
// Network configuration
const NETWORK_PASSPHRASE = "Diamante Testnet 2024";
const server = new Aurora.Server("https://diamtestnet.diamcircle.io/");
```

<!-- tabs:end -->

2 - The function `pathPaymentStrictReceive` takes three parameters: secretKey (the user's secret key), receiveAmount (the amount of the token to receive), and poolId (the liquidity pool ID for the swap). It Generate keypair from the secret key and extracts the public key.

<!-- tabs:start -->

#### **Javascript**

```js
async function pathPaymentStrictReceive(secretKey, receiveAmount, poolId) {
  const keypair = Keypair.fromSecret(secretKey);
  const publicKey = keypair.publicKey();

  // Define assets
  const diamAsset = Asset.native(); // DIAM (native asset)
  const NewToken = new Asset(
    "WOLF",
    "GAUOYFQZUERFKOXKUCE2BBVYLR6C6NG2OBCGA4GU6X67C6OJKLFCHY5E"
  );
```

  <!-- tabs:end -->

3 - Load the user's account data from the Diamnet server Checks if a trustline for the WOLF token exists. If not, creates one

<!-- tabs:start -->

#### **Javascript**

```js
// Load the sender's account details
const questAccount = await server.loadAccount(publicKey);

// Check if the account has a trustline for the destination token
const accountLines = await server.loadAccount(publicKey);
let hasTrustline = false;
for (let line of accountLines.balances) {
  if (
    line.asset_code === NewToken.code &&
    line.asset_issuer === NewToken.issuer
  ) {
    hasTrustline = true;
    break;
  }
}

// If no trustline exists, create it
if (!hasTrustline) {
  const trustTransaction = new TransactionBuilder(questAccount, {
    fee: BASE_FEE,
    networkPassphrase: NETWORK_PASSPHRASE,
  })
    .addOperation(
      Operation.changeTrust({
        asset: NewToken, // Destination token
      })
    )
    .setTimeout(0)
    .build();

  trustTransaction.sign(keypair);
  await server.submitTransaction(trustTransaction);
  console.log("Trustline created successfully");
}
```

<!-- tabs:end -->

4 - fetches the liquidity pool details and extracts the reserves for DIAM and the token. It calculates the amount of DIAM required to receive the specified amount of the token, adding a 2% buffer.

<!-- tabs:start -->

#### **Javascript**

```js
// Fetch liquidity pool details
const pool = await server.liquidityPools().liquidityPoolId(poolId).call();

// Extract reserves for DIAM and the token
const reserveA = parseFloat(pool.reserves[0].amount); // DIAM reserve
const reserveB = parseFloat(pool.reserves[1].amount); // WOLF token reserve

// Calculate the amount of DIAM required to receive the specified amount of the token
const sendAmount = (receiveAmount * reserveA) / (reserveB - receiveAmount);
const maxSend = (sendAmount * 1.02).toFixed(7); // Add a 2% buffer
```

<!-- tabs:end -->

5 - Build the transaction for the swap `pathPaymentStrictReceive` operation and Submit the transaction to the Diamnet server.

<!-- tabs:start -->

#### **Javascript**

```js
// Create the transaction for path payment
    const transaction = new TransactionBuilder(questAccount, {
      fee: BASE_FEE,
      networkPassphrase: NETWORK_PASSPHRASE,
    })
      .addOperation(
        Operation.pathPaymentStrictReceive({
          sendAsset: diamAsset, // Asset to send
          sendMax: maxSend, // Maximum amount to send (with buffer)
          destination: publicKey, // Destination account
          destAsset: NewToken, // Asset to receive
          destAmount: receiveAmount.toFixed(7), // Exact amount to receive
          path: [diamAsset], // Payment path (in this case, direct)
        })
      )
      .setTimeout(0)
      .build();

    // Sign and submit the transaction
    transaction.sign(keypair);

    const result = await server.submitTransaction(transaction);
    return { success: true, hash: result.hash };
  }
// Example usage of the function
(async () => {
  const secretKey = "SB4EHJXQGD3TDDJJ3MQKL5LZ2JOZSIKTBITFG6VHQ4XPVI42PCBZWBLU"; // Replace with the user's secret key
  const receiveAmount = 1; // Amount of the token to receive
  const poolId = "440027a4a8ce095f9f2c606dde7fd789fd7c2f7e5c1f1f681aef818bef417cac"; // Pool ID for the swap

  const result = await pathPaymentStrictReceive(secretKey, receiveAmount, Use CasepoolId);
  if (result.success) {
    console.log("Swap successful with hash:", result.hash);
  } else {
    console.error("Swap failed:", result.error);
  }
})();
```

<!-- tabs:end -->

The `pathPaymentStrictReceive` operation in the Diamnet SDK is used to facilitate the exchange of one asset for another through a specified path of assets, ensuring that the recipient receives exactly the specified amount of the destination asset. This operation is particularly useful in scenarios where you need to perform atomic swaps or cross-asset payments with guaranteed delivery of the destination asset.

### Comparison Table

| Feature                         | Path Payment Strict Send                | Path Payment Strict Receive               |
| ------------------------------- | --------------------------------------- | ----------------------------------------- |
| **Guarantees**                  | Fixed sending amount (`sendAmount`)     | Fixed receiving amount (`destAmount`)     |
| **Input flexibility**           | Receiver gets variable amount           | Sender may need to send variable amount   |
| **Use Case**                    | Sender wants to control sending amount  | Recipient requires exact receiving amount |
| **Failure Scenario**            | Fails if minimum receive amount unmet   | Fails if maximum send amount exceeded     |
| **Exchange Rate Dependency**    | Output (receive) amount depends on rate | Input (send) amount depends on rate       |
| **Liquidity Dependency**        | Receiver amount varies with liquidity   | Sender amount varies with liquidity       |
| **Risk**                        | Recipient gets less than expected       | Sender pays more than expected            |
| **Parameter for Fixed Control** | `sendAmount`                            | `destAmount`                              |
| **Parameter for Flexibility**   | `destMin`                               | `sendMax`                                 |
