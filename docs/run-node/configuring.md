# Configuring

After you've [installed](/run-node/installing) Diamante Core, your next step is to complete a configuration file that specifies crucial things about your node — like whether it connects to the testnet or the public network, what database it writes to, and which other nodes are in its [quorum set](/run-node/configuring?id=choosing-your-quorum-set). You do that using [TOML](https://github.com/toml-lang/toml), and by default Diamante Core loads that file from ./diamante-core.cfg. You can specify a different file to load using the command line:

```bash
$ diamante-core --conf betterfile.cfg <COMMAND>
```

This section of the docs will walk you through the key fields you'll need to include in your config file to get your node up and runninig.

## Example Configurations

This document works best in conjunction with concrete config examples, so as you read through it, you may want to check out the following:

- The [complete example config](https://github.com/diamante-io/Diamante-Net-Core/blob/master/docs/DiamNet-core_example.cfg) documents all possible configuration elements, as well as their default values. It's got every knob you can twiddle and every setting you can tweak along with detailed explanations of how to twiddle and tweak them. You don't need to put everything from the complete example config into your config file — fields you omit will assume the default setting, and the default setting will generally serve you well — but there are a few required fields, and this doc will explain what they are.

- If you want to connect to the testnet, check out the [example test network config](#TODO). As you can see, most of the fields from the [complete example config](https://github.com/diamante-io/Diamante-Net-Core/blob/master/docs/DiamNet-core_example.cfg) are omitted since the default settings work fine. You can easily tailor this config to meet your testnet needs.

- If you want to connect to the public network, check out this [public network config](#TODO) for a Full Validator. It includes a properly crafted quorum set with all the current [Tier 1 validators](/run-node/t1-organizations), which is a good place to start for most configurations. This node is set up to both [validate](/run-node/configuring?id=validating) and write history to a [public archive](/run-node/pub-history-archives), but you can disable either feature by adjusting this config so it's a little lighter.

## Database

Diamante Core stores two copies of the ledger: one in a SQL database and one in XDR files on local disk called [buckets](/run-node/configuring?id=buckets). The database is consulted during consensus, and modified atomically when a transaction set is applied to the ledger. It's random access, fine-grained, and fast.

While a SQLite database works with Diamante Core, we generally recommend using a separate PostgreSQL server. A Postgres database is the bread and butter of Diamante Core.

You specify your node's database in the aptly named `DATABASE` field of your config file, which you can read more about in the [complete example config](https://github.com/diamante-io/Diamante-Net-Core/blob/master/docs/DiamNet-core_example.cfg). It defaults to an in-memory database, but you can specify a path as per the example.

If using PostgreSQL, We recommend you configure your local database to be accessed over a Unix domain socket as well as updating the below PostgreSQL configuration parameters:

```bash
# !!! DB connection should be over a Unix domain socket !!!
# shared_buffers = 25% of available system RAM
# effective_cache_size = 50% of available system RAM
# max_wal_size = 5GB
# max_connections = 150
```

## Buckets

Diamante Core also stores a duplicate copy of the ledger in the form of flat XDR files called "buckets." These files are placed in a directory specified in the config file as `BUCKET_DIR_PATH`, which defaults to `buckets`. The bucket files are used for hashing and transmission of ledger differences to history archives.

Buckets should be stored on a fast local disk with sufficient space to store several times the size of the current ledger.

For the most part, the contents of both the database and buckets directories can be ignored as they are managed by Diamante Core. However, when running Diamante Core for the first time, you must initialize both with the following command:

```bash
$ diamante-core new-db
```

This command initializes the database and bucket directories, and then exits. You can also use this command if your DB gets corrupted and you want to restart it from scratch.

## Network Passphrase

Use the `NETWORK_PASSPHRASE` field to specify whether your node connects to the testnet or the mainnet network. Your choices:

```bash
NETWORK_PASSPHRASE="Diamante Testnet 2024"
NETWORK_PASSPHRASE="Diamante MainNet; DEP 2022"

```

For more about the Network Passphrase and how it works, check out the [encyclopedia entry](/encyclopedia/network-passphrases).

## Validating

By default, Diamante Core isn't set up to validate. If you want your node to be a [Basic Validator](/run-node/overview?id=basic-validator) or a [Full Validator](/run-node/overview?id=full-validator), you need to configure it to do so, which means preparing it to take part in [DCP](/fundamentals/consensus) and sign messages pledging that the network agrees to a particular transaction set.

Configuring a node to participate in DCP and sign messages is a three-step process:

1. Create a keypair: `diamante-core gen-seed`
2. Add `NODE_SEED="SD7DN..."` to your configuration file, where `SD7DN...` is the secret key from the keypair
3. Add `NODE_IS_VALIDATOR=true` to your configuration file

If you want other validators to add your node to their quorum sets, you should also share your public key (`GDMTUTQ...`) by publishing a `diamante.toml` file on your homedomain following specs laid out in DEP-20

It's essential to store and safeguard your node's secret key: if someone else has access to it, they can send messages to the network, and they will appear to originate from your node. Each node you run should have its own secret key.

If you run more than one node, set the `HOME_DOMAIN` common to those nodes using the `NODE_HOME_DOMAIN` property. Doing so will allow your nodes to be grouped correctly during [quorum set generation](/run-node/configuring?id=home-domains-array).

## Choosing Your Quorum Set

No matter what kind of node you run — Basic Validator, Full Validator, or Archiver — you need to select a quorum set, which consists of validators (grouped by organization) that your node checks with to determine whether to apply a transaction set to a ledger.
A good quorum set:

- Aligns with your organization’s priorities
- Has enough redundancy to handle arbitrary node failures
- Maintains good quorum intersection

Since crafting a good quorum set is a difficult thing to do, diamante core automatically generates a quorum set for you based on structured information you provide in your config file. You choose the validators you want to trust; diamante core configures them into an optimal quorum set.

To generate a quorum set, diamante core:

- Groups validators run by the same organization into a subquorum
- Sets the threshold for each of those subquorums
- Gives weights to those subquorums based on quality

While this does not absolve you of all responsibility — you still need to pick trustworthy validators and keep an eye on them to ensure that they’re consistent and reliable — it does make your life easier and reduces the chances for human error.

#### Validator Discovery

When you add a validating node to your quorum set, it’s generally because you trust the organization running the node: you trust Diamante, not some anonymous Diamante public key.

In order to create a self-verified link between a node and the organization that runs it, a validator declares a home domain on-chain using a [`set_options` operation](/fundamentals/operations?id=set-options) and publishes organizational information in a `diamante.toml` file hosted on that domain.

As a result of that link, you can look up a node by its Diamante public key and check the `diamante.toml` to find out who runs it. If you decide to trust an organization, you can use that list to collect the information necessary to add their nodes to your configuration.

When you look at that list, you will discover that the most reliable organizations actually run more than one validator, and adding all of an organization’s nodes to your quorum set creates the redundancy necessary to sustain arbitrary node failure. When an organization with a trio of nodes takes one down for maintenance, for instance, the remaining two vote on the organization’s behalf, and the organization’s network presence persists.

One important thing to note: you need to either depend on exactly one entity OR have **at least 4 entities** for automatic quorum set configuration to work properly. At least 4 is the better option.

#### Home Domains Array

To create your quorum set, Diamante Core relies on two arrays of tables: `[[HOME_DOMAINS]]` and `[[VALIDATORS]]`. Check out the [example config](https://github.com/diamante-io/Diamante-Net-Core/blob/master/docs/DiamNet-core_example.cfg) to see those arrays in action.

`[[HOME_DOMAINS]]` defines a superset of validators: when you add nodes hosted by the same organization to your configuration, they share a home domain, and the information in the `[[HOME_DOMAINS]]` table, specifically the quality rating, will automatically apply to every one of those validators.

For each organization you want to add, create a separate `[[HOME_DOMAINS]]` table, and complete the following required fields:

| Field           | Requirements | Description                                           |
| --------------- | ------------ | ----------------------------------------------------- |
| **HOME_DOMAIN** | string       | URL of home domain linked to a group of validators    |
| **QUALITY**     | string       | Rating for organization's nodes: HIGH, MEDIUM, or LOW |

Here’s an example:

```toml
[[HOME_DOMAINS]]
HOME_DOMAIN="testnet.diamante.org"
QUALITY="HIGH"

[[HOME_DOMAINS]]
HOME_DOMAIN="some-other-domain"
QUALITY="LOW"
```

#### Validators Array

For each node you would like to add to your quorum set, complete a `[[VALIDATORS]]` table with the following fields:

| Field           | Requirements | Description                                                                                  |
| --------------- | ------------ | -------------------------------------------------------------------------------------------- |
| **NAME**        | string       | A unique alias for the node                                                                  |
| **QUALITY**     | string       | Rating for the node (required unless specified in `[[HOME_DOMAINS]]`): HIGH, MEDIUM, or LOW. |
| **HOME_DOMAIN** | string       | URL of home domain linked to the validator                                                   |
| **PUBLIC_KEY**  | string       | Diamante public key associated with the validator                                            |
| **ADDRESS**     | string       | Peer:port associated with the validator (optional)                                           |
| **HISTORY**     | string       | Archive GET command associated with the validator (optional)                                 |

If the node's `HOME_DOMAIN` aligns with an organization defined in the `[[HOME_DOMAINS]]` array, the quality rating specified there will apply to the node. If you’re adding an individual node that is not covered in that array, you’ll need to specify the `QUALITY` here.

Here’s an example:

```toml
[[VALIDATORS]]
NAME="sdftest1"
HOME_DOMAIN="testnet.diamante.org"
PUBLIC_KEY="GDKXE2OZMJIPOSLNA6N6F2BVCI3O777I2OOC4BV7VOYUEHYX7RTRYA7Y"
ADDRESS="core-testnet1.diamante.org"
HISTORY="curl -sf http://history.diamante.org/prd/core-testnet/core_testnet_001/{0} -o {1}"

[[VALIDATORS]]
NAME="sdftest2"
HOME_DOMAIN="testnet.diamante.org"
PUBLIC_KEY="GCUCJTIYXSOXKBSNFGNFWW5MUQ54HKRPGJUTQFJ5RQXZXNOLNXYDHRAP"
ADDRESS="core-testnet2.diamante.org"
HISTORY="curl -sf http://history.diamante.org/prd/core-testnet/core_testnet_002/{0} -o {1}"

[[VALIDATORS]]
NAME="rando-node"
QUALITY="LOW"
HOME_DOMAIN="rando.com"
PUBLIC_KEY="GC2V2EFSXN6SQTWVYA5EPJPBWWIMSD2XQNKUOHGEKB535AQE2I6IXV2Z"
ADDRESS="core.rando.com"
```

#### Validator Quality

`QUALITY` is a required field for each node you add to your quorum set. Whether you specify it for a suite of nodes in `[[HOME_DOMAINS]]` or for a single node in `[[VALIDATORS]]`, it means the same thing, and you have the same three rating options: HIGH, MEDIUM, or LOW.

- **HIGH quality validators** are given the most weight in automatic quorum set configuration. Before assigning a high quality rating to a node, make sure it has low latency and good uptime, and that the organization running the node is reliable and trustworthy.

  A high-quality validator:

  - Publishes an archive
  - Belongs to a suite of nodes that provide redundancy

  Choosing redundant nodes is good practice. The archive requirement is programmatically enforced.

- **MEDIUM quality validators** are nested below high quality validators, and their combined weight is equivalent to a single high-quality entity. If a node doesn't publish an archive, but you deem it reliable or have an organizational interest in including it in your quorum set, give it a medium quality rating.

- **LOW quality validators** are nested below medium quality validators, and their combined weight is equivalent to a single medium-quality entity. Should they prove reliable over time, you can upgrade their rating to medium to give them a bigger role in your quorum set configuration.

#### Automatic Quorum Set Generation

Once you add validators to your configuration, Diamante Core automatically generates a quorum set using the following rules:

- Validators with the same home domain are automatically grouped together and given a threshold requiring a simple majority (2f+1).
- Heterogeneous groups of validators are given a threshold assuming Byzantine failure (3f+1).
- Entities are grouped by `QUALITY` and nested from HIGH to LOW.
- HIGH quality entities are at the top and are given decision-making priority.
- The combined weight of MEDIUM quality entities equals a single HIGH quality entity.
- The combined weight of LOW quality entities equals a single MEDIUM quality entity.

#### Quorum and Overlay Network

It is generally a good idea to give information to your validator on other validators that you rely on. This is achieved by configuring `KNOWN_PEERS` and `PREFERRED_PEERS` with the addresses of your dependencies.

Additionally, configuring `PREFERRED_PEER_KEYS` with the keys from your quorum set might be a good idea to give priority to the nodes that allow you to reach consensus.

Without those settings, your validator depends on other nodes on the network to forward you the right messages, which is typically done as a best effort.

#### Updating and Coordinating Your Quorum Set ##TODO

When you join the ranks of node operators, it's also important to join the conversation. The best way to do that: get on the #validators channel on the Diamante Keybase and sign up for the Diamante Validators Google Group; You can also join the #validators channel on our Developer Discord. That way, you can coordinate changes with the rest of the network.

When you need to make changes to your validator or to your quorum set — say you take a validator down for maintenance or add new validators to your node's quorum set — it's crucial to stage the changes to preserve quorum intersection and general good health of the network:

- Don't remove too many nodes from your quorum set before the nodes are taken down. If different validators remove different sets, the remaining sets may not overlap, which could cause network splits.
- Don't add too many nodes in your quorum set at the same time. If not done carefully, the new nodes could overpower your configuration.

When you want to add or remove nodes, start by making changes to your own nodes' quorum sets, and then coordinate work with others to reflect those changes gradually.

## History

Diamante Core normally interacts with one or more history archives, configurable facilities where Full Validators and Archivers store flat files containing history checkpoints: bucket files and history logs. History archives are usually off-site commodity storage services such as Amazon S3, Google Cloud Storage, Azure Blob Storage, or custom DCP/SFTP/HTTP servers. To find out how to publish a history archive, consult [Publishing History Archives](/run-node/pub-history-archives).

No matter what kind of node you're running, you should configure it to get history from one or more public archives. You can configure any number of archives to download from: Diamante Core will automatically round-robin between them.

When you're [choosing your quorum set](/run-node/configuring?id=choosing-your-quorum-set), you should include high-quality nodes — which, by definition, publish archives — and add the location for each node's archive in the `HISTORY` field in the [validators array](/run-node/configuring?id=validators-array).

You can also use command templates in the config file to specify additional archives you'd like to use and how to access them. The [example config](https://github.com/diamante-io/Diamante-Net-Core/blob/master/docs/DiamNet-core_example.cfg) shows how to configure a history archive through command templates.

> If you notice a lot of errors related to downloading archives, you should check that all archives in your configuration are up to date.

## Automatic Maintenance

Some tables in Diamante Core's database act as a publishing queue for external systems such as Aurora and generate metadata for changes happening to the distributed ledger.

If not managed properly, those tables will grow without bounds. To avoid this, a built-in scheduler will delete data from old ledgers that are not used anymore by other parts of the system (external systems included).

The settings that control the automatic maintenance behavior are: `AUTOMATIC_MAINTENANCE_PERIOD`, `AUTOMATIC_MAINTENANCE_COUNT`, and `KNOWN_CURSORS`.

By default, Diamante Core will perform this automatic maintenance, so be sure to disable it until you have done the appropriate data ingestion in downstream systems (Aurora, for example, sometimes needs to reingest data).

If you need to regenerate the metadata, the simplest way is to replay ledgers for the range you're interested in after (optionally) clearing the database with `newdb`.

## Metadata Snapshots and Restoration

Some deployments of Diamante Core and Aurora will want to retain metadata for the entire history of the network. This metadata can be quite large and computationally expensive to regenerate anew by replaying ledgers in diamante-core from an empty initial database state, as described in the previous section.

This can be especially costly if run more than once. For instance, when bringing a new node online. Or even if running a single node with Aurora, having already ingested the metadata once: a subsequent version of Aurora may have a schema change that entails re-ingesting it again.

Some operators therefore prefer to shut down their diamante-core (and/or Aurora)
