# Commands

Diamante Core can be controlled via the following commands.

## Common Options

Common options can be placed at any place in the command line.

- `--conf <FILE-NAME>`: Specify a config file to use. You can use '-' and provide the config file via STDIN. Default 'diamante-core.cfg'
- `--ll <LEVEL>`: Set the log level. It is redundant with http-command ll but we need this form if you want to change the log level during test runs.
- `--metric <METRIC-NAME>`: Report metric METRIC on exit. Used for gathering a metric cumulatively during a test run.
- `--help`: Show help message for the given command.

## Command Line Options

Command options can only be placed after the command.

- `catchup <DESTINATION-LEDGER/LEDGER-COUNT>`: Perform catchup from history archives without connecting to the network. For new instances (with empty history tables - only ledger 1 present in the database) it will respect LEDGER-COUNT configuration and it will perform bucket application on such a checkpoint that at least LEDGER-COUNT entries are present in history table afterwards. For instances that already have some history entries, all ledgers since last closed ledger will be replayed.
- `check-quorum`: Check quorum intersection from history to ensure there is closure over all the validators in the network.
- `convert-id <ID>`: Will output the passed ID in all known forms and then exit. Useful for determining the public key that corresponds to a given private key.

```
$ diamante-core convert-id SDQVDISRYN2JXBS7ICL7QJAEKB3HWBJFP2QECXG7GZICAHBK4UNJCWK2


```

- `dump-xdr <FILE-NAME>`: Dumps the given XDR file and then exits.
- `force-dcp`: This command is used to start a network from scratch or when a network has lost quorum because of failed nodes or otherwise. It sets a flag in the database. The next time diamante-core is run, diamante-core will start emitting DCP messages based on its last known ledger. Without this flag diamante-core waits to hear a ledger close from the network before starting DCP.
  - `force-dcp` doesn't change the requirements for quorum so although this node will emit DCP messages DCP won't complete until there are also a quorum of other nodes also emitting DCP messages on this same ledger. Value of `force-dcp` can be reset with `--reset` flag.
- `fuzz <FILE-NAME>`: Run a single fuzz input and exit.
- `gen-fuzz <FILE-NAME>`: Generate a random fuzzer input file.
- `gen-seed`: Generate and print a random public/private key and then exit.
- `help`: Print the available command line options and then exit.
- `http-command <COMMAND>`: Send an HTTP command to an already running local instance of diamante-core and then exit.

```
$ diamante-core http-command info
```

- `infer-quorum`: Print a potential quorum set inferred from history.
- `load-xdr <FILE-NAME>`: Load an XDR bucket file, for testing.
- `new-db`: Clears the local database and resets it to the genesis ledger. If you connect to the network after that, it will catch up from scratch.
- `new-hist <HISTORY-LABEL> ...`: Initialize the named history archives HISTORY-LABEL. HISTORY-LABEL should be one of the history archives you have specified in the diamante-core.cfg. This will write a `.well-known/diamante-history.json` file in the archive root.
- `offline-info`: Returns output similar to --c info for an offline instance.
- `print-xdr <FILE-NAME>`: Pretty-print a binary file containing an XDR object. If FILE-NAME is "-", the XDR object is read from standard input.
  - Option `--filetype [auto|ledgerheader|meta|result|resultpair|tx|txfee]` controls type used for printing (default: auto).
  - Option `--base64` alters the behavior to work on base64-encoded XDR rather than raw XDR.
- `publish`: Execute publish of all items remaining in the publish queue without connecting to the network. May not publish the last checkpoint if the last closed ledger is on a checkpoint boundary.
- `report-last-history-checkpoint`: Download and report the last history checkpoint from a history archive.
- `run`: Runs diamante-core service.
- `sec-to-pub`: Reads a secret key on standard input and outputs the corresponding public key. Both keys are in Diamante's standard base-32 ASCII format.
- `sign-transaction <FILE-NAME>`: Add a digital signature to a transaction envelope stored in binary format in <FILE-NAME>, and send the result to standard output (which should be redirected to a file or piped through a tool such as base64). The private signing key is read from standard input unless <FILE-NAME> is "-", in which case the transaction envelope is read from standard input, and the signing key is read from /dev/tty. In either event, if the signing key appears to be coming from a terminal, diamante-core disables echo. Note that if you do not have a DIAMANTE_NETWORK_ID environment variable, then before this argument you must specify the `--netid` option.
  - For example, the production diamante network is "Public Global Diamante MainNet; SEP 2022,"
  - Option `--base64` alters the behavior to work on base64-encoded XDR rather than raw XDR.
- `test`: Run all the unit tests.
  - Sub-options specific to diamante-core:
    - `--all-versions`: Run with all possible protocol versions.
    - `--version <N>`: Run tests for protocol version N, can be specified multiple times (default latest).
    - `--base-instance <N>`: Run tests with instance numbers offset by N, used to run tests in parallel. For further info on possible options for test.
    - For example, this will run just the tests tagged with `[tx]` using protocol versions 9 and 10 and stop after the first failure: diamante-core test -a --version 9 --version 10 "[tx]"
- `upgrade-db`: Upgrades the local database to the current schema version. This is usually done automatically during diamante-core run or other commands.
- `version`: Print version info and then exit.
- `write-quorum`: Print a quorum set graph from history.

## HTTP Commands

By default, diamante-core listens for connections from localhost on port 11626. You can send commands to diamante-core via a web browser, curl, or using the --c command line option (see above). Most commands return their results in JSON format.

- **bans**: List current active bans.
- **checkdb**: Triggers the instance to perform a background check of the database's state.
- **checkpoint**: Triggers the instance to write an immediate history checkpoint and uploads it to the archive. -**connect** `connect?peer=NAME&port=NNN`: Triggers the instance to connect to peer NAME at port NNN. -**dropcursor\*\* `dropcursor?id=ID`: Deletes the tracking cursor identified by id. See setcursor for more information. -**droppeer** `droppeer?node=NODE_ID[&ban=D]`: Drops peer identified by NODE_ID. When D is 1, the peer is also banned. -**info** `info`: Returns information about the server in JSON format (sync state, connected peers, etc). -**ll\*\* `ll?level=L[&partition=P]`: Adjusts the log level for partition P where P is one of Bucket, Database, Fs, Herder, History, Ledger, Overlay, Process, DCP, Tx (or all if no partition is specified). Level is one of FATAL, ERROR, WARNING, INFO, DEBUG, VERBOSE, TRACE.
- **logrotate** Rotate log files.
- **maintenance** `maintenance?[queue=true]`: Performs maintenance tasks on the instance. Queue performs deletion of queue data. See setcursor for more information. -**metrics** `metrics`: Returns a snapshot of the metrics registry (for monitoring and debugging purposes).
- **clearmetrics** `clearmetrics?[domain=DOMAIN]`: Clears metrics for a specified domain. If no domain is specified, clear all metrics (for testing purposes).
- **peers?[&fullkeys=true]**: Returns the list of known peers in JSON format. If fullkeys is set, outputs unshortened public keys.
- **quorum** `quorum?[node=NODE_ID][&compact=true][&fullkeys=true][&transitive=true]`: Returns information about the quorum for NODE_ID (local node by default). If transitive is set, information is for the transitive quorum centered on NODE_ID, otherwise only for nodes in the quorum set of NODE_ID. NODE_ID is either a full key (GABCD...), an alias ($name) or an abbreviated ID (@GABCD). If compact is set, only returns a summary version. If fullkeys is set, outputs unshortened public keys.
- **setcursor** `setcursor?id=ID&cursor=N`: Sets or creates a cursor identified by ID with value N. ID is an uppercase AlphaNum, N is a uint32 that represents the last ledger sequence number that the instance ID processed. Cursors are used by dependent services to tell diamante-core which data can be safely deleted by the instance. The data is historical data stored in the SQL tables such as txhistory or ledgerheaders. When all consumers processed the data for ledger sequence N the data can be safely removed by the instance. The actual deletion is performed by invoking the maintenance endpoint or on startup. See also dropcursor. -**getcursor** `getcursor?[id=ID]`: Gets the cursor identified by ID. If ID is not defined then all cursors will be returned.
- **dcp** `dcp?[limit=n][&fullkeys=true]`: Returns a JSON object with the internal state of the DCP engine for the last n (default 2) ledgers. Outputs unshortened public keys if fullkeys is set.
- **tx** `tx?blob=Base64`: Submit a transaction to the network. blob is a base64 encoded XDR serialized 'TransactionEnvelope', and it returns a JSON object with the following properties status:
  - "PENDING" - transaction is being considered by consensus
  - "DUPLICATE" - transaction is already PENDING
  - "ERROR" - transaction rejected by transaction engine error: set when status is "ERROR". Base64 encoded, XDR serialized 'TransactionResult'.
- **upgrades**
  - `upgrades?mode=get`: Retrieves the currently configured upgrade settings.
  - `upgrades?mode=clear`: Clears any upgrade settings.
  - `upgrades?mode=set&upgradetime=DATETIME&[basefee=NUM]&[basereserve=NUM]&[maxtxsize=NUM]&[protocolversion=NUM]`
    - upgradetime is a required date (UTC) in the form 1970-01-01T00:00:00Z. It is the time the upgrade will be scheduled for. If it is in the past by less than 12 hours, the upgrade will occur immediately. If it's more than 12 hours, then the upgrade will be ignored.
    - fee (uint32) This is what you would prefer the base fee to be. It is in jots.
    - basereserve (uint32) This is what you would prefer the base reserve to be. It is in jots.
    - maxtxsize (uint32) This defines the maximum number of transactions to include in a ledger. When too many transactions are pending, surge pricing is applied. The instance picks the top maxtxsize transactions locally to be considered in the next ledger. Where transactions are ordered by transaction fee(lower fee transactions are held for later).
    - protocolversion (uint32) defines the protocol version to upgrade to. When specified it must match one of the protocol versions supported by the node and should be greater than ledgerVersion from the current ledger.
- **surveytopology** `surveytopology?duration=DURATION&node=NODE_ID`: Starts a survey that will request peer connectivity information from nodes in the backlog. DURATION is the number of seconds this survey will run for, and NODE_ID is the public key you will add to the backlog to survey. Running this command while the survey is running will add the node to the backlog and reset the timer to run for DURATION seconds. By default, this node will respond to/relay a survey message if the message originated from a node in its transitive quorum. This behavior can be overridden by adding keys to SURVEYOR_KEYS in the config file, which will be the set of keys to check instead of the transitive quorum. If you would like to opt-out of this survey mechanism, just set SURVEYOR_KEYS to $self or a bogus key.
- **stopsurvey** `stopsurvey`: Stops the survey if one is running. Noop if no survey is running.
- **getsurveyresult** `getsurveyresult`: Returns the current survey results. The results will be reset every time a new survey is started.

#### The following HTTP commands are exposed on test instances

- **generateload** `generateload[?mode=(create|pay)&accounts=N&offset=K&txs=M&txrate=R&batchsize=L&spikesize=S&spikeinterval=I]`
  Artificially generate load for testing; must be used with ARTIFICIALLY_GENERATE_LOAD_FOR_TESTING set to true. Depending on the mode, either creates new accounts or generates payments on accounts specified (where number of accounts can be offset). Additionally, allows batching up to 100 account creations per transaction via 'batchsize'. When a nonzero I is given, a spike will occur every I seconds injecting S transactions on top of txrate.

- **manualclose** If MANUAL_CLOSE is set to true in the .cfg file. This will cause the current ledger to close.

- **testacc** `testacc?name=N`
  Returns basic information about the account identified by name. Note that N is a string used as seed, but "root" can be used as well to specify the root account used for the test instance.

- **testtx** `testtx?from=F&to=T&amount=N&[create=true]`
  Injects a payment transaction (or a create transaction if "create" is specified) from the account F to the account T, sending N DIAM to the account. Note that F and T are seed strings but can also be specified as "root" as shorthand for the root account for the test instance.
