# Build DApps on Diamante

Operations are the fundamental building blocks for constructing transactions. Each operation defines a specific action that can be performed on the Diamante ledger.

The operations-based logic, contributes to faster transaction processing compared to other blockchain networks for several reasons:

1. **Simplicity of Operations**<br>
   Pre-defined Operations: Diamante uses a set of standardized operations (e.g., payments, trust lines) that streamline transaction creation. This reduces complexity and allows for quicker execution.
2. **Transaction Batching**<br>
   Combine Multiple Actions: Developers can batch multiple operations into a single transaction. This reduces the number of transactions that need to be processed individually, speeding up overall throughput.
3. **Consensus Mechanism**<br>
   Diamante Consensus Protocol (DCP): Diamante's unique consensus mechanism allows for faster finality without the need for extensive mining. Transactions can be confirmed in a matter of seconds.
4. **Low Latency**<br>
   Direct Transactions: Diamante facilitates direct transactions between accounts without intermediaries, reducing the time it takes for transactions to be validated and recorded.
5. **Efficient Asset Transfers**<br>
   Path Payment and Liquidity: Operations like path payments efficiently find the best route for asset transfers, minimizing delays associated with liquidity issues.
6. **Focus on Financial Applications**<br>
   Optimized for Payments: Diamante is designed specifically for financial applications and cross-border payments, which inherently streamlines many processes that other chains might complicate with broader functionality.
7. **Minimal Gas Fees**<br>
   Lower Costs: Diamante's fee structure is more predictable and often lower than other networks, allowing users to make transactions without waiting for gas prices to fluctuate.

Here’s a breakdown of the key operations and how they can be used to develop dApp

### Payment Operation

**Description:** Transfers a specified amount of a currency (e.g., Diams or any issued asset) from one account to another.<br>
**Use in dApps:** Can be used for payments between users, making it essential for any financial dApp, like wallets or payment gateways.

### Create Account Operation

**Description:** Creates a new account and allocates some initial balance.<br>
**Use in dApps:** Useful for onboarding new users by programmatically creating accounts when they register for a service.

### Change Trust Operation

**Description:** Allows an account to hold a specific asset by establishing a trust line to the asset's issuer.<br>
**Use in dApps:** Crucial for managing asset interactions, enabling users to accept and trade various tokens.

### Offer Create and Offer Remove Operations

**Description:** These operations allow users to create and remove offers for trading assets on the Diamante decentralized exchange.<br>
**Use in dApps:** Essential for building decentralized exchanges or marketplaces where users can trade assets.

### Path Payment Operation

**Description:** Facilitates payments between assets by finding the best conversion path.<br>
**Use in dApps:** Enhances user experience in applications that need to handle multi-currency transactions.

### Account Merge Operation

**Description:** Merges the funds of one account into another and effectively removes the merged account from the ledger.<br>
**Use in dApps:** Can be used in scenarios where users want to consolidate their accounts or reduce account management complexity.

### Asset Issuance

**Description:** Issuing new assets on the Diamante network.<br>
**Use in dApps:** Essential for creating new tokens or digital assets that users can trade or interact with within the application.
