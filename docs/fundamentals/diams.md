# DIAM

DIAM is the native currency of the Diamante network. The diam is the only token that doesn’t require an issuer or trustline, and it is used to pay all transaction fees and rent, and to cover minimum balance requirements on the network.

## Transaction Fees

Diamante requires a small fee for all transactions to prevent ledger spam and prioritize transactions during surge pricing. Transaction fees are paid in diams.

To learn about fees on Diamante, see our [Encyclopedia -> Fees, Surge Pricing, and Fee Strategies Encyclopedia Entry](/encyclopedia/fee-surge-pricing-strategies).

## Base Reserves

A unit of measurement used to calculate an account’s minimum balance. One base reserve is currently 0.5 DIAM.

Validators can vote to change the base reserve, but that’s uncommon and should only happen every few years.

## Minimum Balance

Diamante accounts must maintain a minimum balance to exist, which is calculated using the base reserve. An account must always maintain a minimum balance of two base reserves (currently 1 DIAM). Every subentry after that requires an additional base reserve (currently 0.5 DIAM) and increases the account’s minimum balance. Subentries include trustlines (for both traditional assets and pool shares), offers, signers, and data entries. An account cannot have more than 1,000 subentries.

Data also lives on the ledger as ledger entries. Ledger entries include claimable balances (which require a base reserve per claimant) and liquidity pool deposits and withdrawals.

For example, an account with one trustline, two offers, and a claimable balance with one claimant has a minimum balance of:

2 base reserves (1 DIAM) + 3 subentries/base reserves (1.5 DIAM) + 1 ledger entry/base reserve (1 DIAM) = 3.5 DIAM

When you close a subentry, the associated base reserve will be added to your available balance. An account must always pay its own minimum balance unless a subentry is being sponsored by another account. For information about this, see our [Encyclopedia -> Sponsored Reserves Encyclopedia Entry](/encyclopedia/sponsored-reserves).
