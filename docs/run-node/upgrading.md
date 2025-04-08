# Upgrading the Network

The network itself has network-wide settings that can be updated. This is performed by validators voting for and agreeing to new values, the same way that consensus is reached for transaction sets, etc.

A node can be configured to vote for upgrades using the `upgrades` endpoint. See [Commands](/run-node/commands) for more information.

The network settings include:

1. The version of the protocol used to process transactions.
2. The maximum number of transactions that can be included in a given ledger close.
3. The cost (fee) associated with processing operations.
4. The base reserve used to calculate the diam balance needed to store things in the ledger.

When the network time is later than the `upgradetime` specified in the upgrade settings, the validator will vote to update the network to the value specified in the upgrade setting. If the network time is past the `upgradetime` by more than 12 hours, the upgrade will be ignored.

When a validator is armed to change network values, the output of `info` will contain information about the vote.

For a new value to be adopted, the same level of consensus between nodes needs to be reached as for transaction sets.

## Important notes on network-wide settings

Changes to network-wide settings have to be orchestrated properly between validators as well as non-validating nodes:

1. A change is vetted between operators (changes can be bundled).
2. An effective date in the future is picked for the change to take effect (controlled by `upgradetime`).
3. If applicable, communication is sent out to all network users.

An improper plan may cause issues such as:

- Nodes missing consensus (aka "getting stuck") and having to use history to rejoin.
- Network reconfiguration taking effect at a non-deterministic time (causing fees to change ahead of schedule, for example).

## Example upgrade command

For example, here is how to upgrade the protocol version to version 9 on January 31, 2018.

```bash
$ diamante-core http-command 'upgrades?mode=set&upgradetime=2018-01-31T20:00:00Z&protocolversion=9'
$ diamante-core http-command info
```

At this point info will tell you that the node is setup to vote for this upgrade:

```
"status" : [
    "Armed with network upgrades: upgradetime=2018-01-31T20:00:00Z, protocolversion=9"
]
```
