# Endpoints

## Accounts

Users interact with the Diamante network through accounts. Everything else in the ledger—assets, offers, trustlines, etc.—are owned by accounts, and accounts must authorize all changes to the ledger through signed transactions.

Learn more about [accounts](/glossary/glossary?id=account).

<div class="endpoint-box">
  <p><strong>GET</strong> /accounts</p>
  <p><strong>GET</strong> /accounts/:account_id</p>
  <p><strong>GET</strong> /accounts/:account_id/transactions</p>
  <p><strong>GET</strong> /accounts/:account_id/operations</p>
  <p><strong>GET</strong> /accounts/:account_id/payments</p>
  <p><strong>GET</strong> /accounts/:account_id/effects</p>
  <p><strong>GET</strong> /accounts/:account_id/offers</p>
  <p><strong>GET</strong> /accounts/:account_id/trades</p>
  <p><strong>GET</strong> /accounts/:account_id/data</p>
</div>

## Assets

Assets are representations of value issued on the Diamante network. An asset consists of a type, code, and issuer.

Learn more about [assets](/glossary/glossary?id=asset).

<div class="endpoint-box">
  <p><strong>GET</strong> /assets</p>
</div>

## Claimable Balances

A Claimable Balance represents the transfer of ownership of some amount of an asset. Claimable balances provide a mechanism for setting up a payment which can be claimed in the future. This allows you to make payments to accounts which are currently not able to accept them.

<div class="endpoint-box">
  <p><strong>GET</strong> /claimable_balances</p>
  <p><strong>GET</strong> /claimable_balances/:claimable_balance_id</p>
  <p><strong>GET</strong> /claimable_balances/:claimable_balance_id/transactions</p>
  <p><strong>GET</strong> /claimable_balances/:claimable_balance_id/operations</p>
</div>

## Ledgers

Each ledger stores the state of the network at a point in time and contains all the changes - transactions, operations, effects, etc. - to that state.

Learn more about [ledgers](/glossary/glossary?id=ledger).

<div class="endpoint-box">
  <p><strong>GET</strong> /ledgers/:ledger_sequence</p>
  <p><strong>GET</strong> /ledgers/:ledger_sequence/transactions</p>
  <p><strong>GET</strong> /ledgers/:ledger_sequence/operations</p>
  <p><strong>GET</strong> /ledgers/:ledger_sequence/payments</p>
  <p><strong>GET</strong> /ledgers/:ledger_sequence/effects</p>
  <p><strong>GET</strong> /ledgers</p>
</div>

## Liquidity Pools

Liquidity Pools provide a simple, non-interactive way to trade large amounts of capital and enable high volumes of trading.

<div class="endpoint-box">
  <p><strong>GET</strong> /liquidity_pools</p>
  <p><strong>GET</strong> /liquidity_pools/:liquidity_pool_id</p>
  <p><strong>GET</strong> /liquidity_pools/:liquidity_pool_id/effects</p>
  <p><strong>GET</strong> /liquidity_pools/:liquidity_pool_id/trades</p>
  <p><strong>GET</strong> /liquidity_pools/:liquidity_pool_id/transactions</p>
  <p><strong>GET</strong> /liquidity_pools/:liquidity_pool_id/operations</p>
</div>

## Offers

Offers are statements about how much of an asset an account wants to buy or sell.

<div class="endpoint-box">
  <p><strong>GET</strong> /offers</p>
  <p><strong>GET</strong> /offers/:offer_id</p>
  <p><strong>GET</strong> /offers/:offer_id/trades</p>
</div>

## Operations

Operations are objects that represent a desired change to the ledger: payments, offers to exchange currency, changes made to account options, etc. Operations are submitted to the Diamante network grouped in a Transaction.

Each of Diamante’s operations have a unique operation object.

<div class="endpoint-box">
  <p><strong>GET</strong> /operations/:operation_id</p>
  <p><strong>GET</strong> /operations/:operation_id/effects</p>
  <p><strong>GET</strong> /operations</p>
  <p><strong>GET</strong> /payments</p>
</div>

## Trades

When an offer is fully or partially fulfilled, a trade happens. Trades can also be caused by successful path payments, because path payments involve fulfilling offers.

A trade occurs between two parties—base and counter. Which is which is either arbitrary or determined by the calling query.

Learn more about [trades](/glossary/glossary?id=decentralized-exchange).

<div class="endpoint-box">
  <p><strong>GET</strong> /trades</p>
</div>

## Transactions

Transactions are commands that modify the ledger state and consist of one or more operations.

Learn more about [transactions](/glossary/glossary?id=transaction).

<div class="endpoint-box">
  <p><strong>GET</strong> /transactions/:transaction_id</p>
  <p><strong>GET</strong> /transactions/:transaction_id/operations</p>
  <p><strong>GET</strong> /transactions/:transaction_id/effects</p>
  <p><strong>GET</strong> /transactions</p>
  <p><strong>POST</strong> /transactions</p>

</div>
