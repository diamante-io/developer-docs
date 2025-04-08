# Running

## Starting Diamante Core

Once you've [set up your environment](/run-node/prerequisites), [configured your node](/run-node/configuring), set up your quorum set, and selected archives to get history from, you're ready to start Diamante Core.

Use a command equivalent to:

```bash
$ diamante-core run
```

At this point, you're ready to observe your node's activity as it joins the network.

You may want to skip ahead and review the logging section to familiarize yourself with Diamante Core's output.

## Interacting With Your Instance

When your Diamante node is running, you can interact with Diamante Core via an administrative HTTP endpoint. Commands can be submitted using command-line HTTP tools such as curl, or by running a command such as

```bash
$ diamante-core http-command <http-command>
```

That HTTP endpoint is not intended to be exposed to the public internet. It's typically accessed by administrators, or by a mid-tier application to submit transactions to the Diamante network.

See [commands](/run-node/commands) for a description of the available commands.

## Joining the Network

Your node will go through the following phases as it joins the network:

#### Establishing Connection to Other Peers.

You should see `authenticated_count` increase.

```json5
"peers" : {
   "authenticated_count" : 3,
   "pending_count" : 4
},
```

#### Observing Consensus

Until the node sees a quorum, it will say:

```json5
"state" : "Joining DCP"
```

After observing consensus, a new field `quorum` will display information about network decisions. At this point the node will switch to "Catching up":

```json5
"quorum" : {
   "qset" : {
      "ledger" : 22267866,
      "agree" : 5,
      "delayed" : 0,
      "disagree" : 0,
      "fail_at" : 3,
      "hash" : "980a24",
      "missing" : 0,
      "phase" : "EXTERNALIZE"
   },
   "transitive" : {
      "intersection" : true,
      "last_check_ledger" : 22267866,
      "node_count" : 21
   }
},
"state" : "Catching up",
```

#### Catching up

This is a phase where the node downloads data from archives. The state will start with something like:

```json5
"state" : "Catching up",
"status" : [ "Catching up: Awaiting checkpoint (ETA: 35 seconds)" ]
```

And then go through the various phases of downloading and applying state such as

```json5
"state" : "Catching up",
"status" : [ "Catching up: downloading ledger files 20094/119803 (16%)" ]
```

You can specify how far back your node goes to catch up in your config file. If you set`CATCHUP_COMPLETE` to `true`, your node will replay the entire history of the network, which can take a long time. Weeks. Satoshipay offers a parallel catchup script to speed up the process, but you only need to replay the complete network history if you're setting up a Full Validator. Otherwise, you can specify a starting point for catchup using `CATCHUP_RECENT`. See the complete example configuration for more details.

#### Synced

When the node is done catching up, its state will change to:

```json5
"state" : "Synced!"
```

## Logging

Diamante Core sends logs to standard output and `diamante-core.log`by default, configurable as `LOG_FILE_PATH`.

Log messages are classified by progressive priority levels: `TRACE`, `DEBUG`, `INFO`, `WARNING`, `ERROR`, and `FATAL`. The logging system only emits those messages at or above its configured logging level.

The log level can be controlled by configuration, the `-ll` command-line flag, or adjusted dynamically by administrative (HTTP) commands. To do so, run:

```bash
$ diamante-core http-command "ll?level=debug"
```

while your system is running.

Log levels can also be adjusted on a partition-by-partition basis through the administrative interface. For example, the history system can be set to DEBUG-level logging by running:

```bash
$ diamante-core http-command "ll?level=debug&partition=history"
```

Against a running system.

The default log level is `INFO`, which is moderately verbose and should emit progress messages every few seconds under normal operation.

## Validator maintenance

Maintenance here refers to anything involving taking your validator temporarily out of the network (to apply security patches, system upgrade, etc).

As an administrator of a validator, you must ensure that the maintenance you are about to apply to the validator is safe for the overall network and for your validator.

Safe means that the other validators that depend on yours will not be affected too much when you turn off your validator for maintenance and that your validator will continue to operate as part of the network when it comes back up.

If you are changing some settings that may impact network-wide settings such as protocol version, [review the section on network configuration](/run-node/running).

If you're changing your quorum set configuration, also read the [section on what to do](/run-node/running?id=recommended-steps-to-perform-as-part-of-maintenance).

#### Recommended steps to perform as part of maintenance:

1. Advertise your intention to others that may depend on you. Some coordination is required to avoid situations where too many nodes go down at the same time.
2. Dependencies should assess the health of their quorum, refer to the section "Understanding quorum and reliability".
3. If there is no objection, take your instance down.
4. When done, start your instance that should rejoin the network.
5. The instance will be completely caught up when it's both Synced and there is no backlog in uploading history.

**Special considerations during quorum set updates:**

Sometimes an organization needs to make changes that impact others' quorum sets:

- Taking a validator down for a long period of time
- Adding new validators to their pool

In both cases, it's crucial to stage the changes to preserve quorum intersection and general good health of the network:

- Removing too many nodes from your quorum set before the nodes are taken down: If different people remove different sets, the remaining sets may not overlap between nodes and may cause network splits.
- Adding too many nodes in your quorum set at the same time: If not done carefully, it can cause those nodes to overpower your configuration.

Recommended steps are for the entity that adds/removes nodes to do so first between their own nodes, and then have people reflect those changes gradually (over several rounds) in their quorum configuration.
