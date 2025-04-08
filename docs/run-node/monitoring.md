# Monitoring

Once your Diamante node is up and running, it's important to keep an eye on it to ensure it stays operational and contributes to the health of the overall network. To assist with this, Diamante Core exposes vital information that you can use to monitor your node and diagnose potential problems.

You can access this information using commands and inspecting Diamante Core's output, as covered in the first half of this document. Alternatively, you can connect Prometheus to facilitate monitoring, combine it with Alertmanager to automate notifications, and use pre-built Grafana dashboards to create visual representations of your node's well-being.

However you decide to monitor, the most important thing is to have a system in place to ensure that your integration keeps functioning seamlessly.

## General Node Information

If you run `$ diamante-core http-command 'info'`, the output will look something like this:

```json5
{
      "build" : "v11.1.0",
      "history_failure_rate" : "0",
      "ledger" : {
         "age" : 3,
         "baseFee" : 100,
         "baseReserve" : 5000000,
         "closeTime" : 1560350852,
         "hash" : "40d884f6eb105da56bea518513ba9c5cda9a4e45ac824e5eac8f7262c713cc60",
         "maxTxSetSize" : 1000,
         "num" : 24311579,
         "version" : 11
      },
      "network" : "Diamante MainNet; DEP 2022",
      "peers" : {
         "authenticated_count" : 5,
         "pending_count" : 0
      },
      "protocol_version" : 10,
      "quorum" : {
         "qset" : {
            "agree" : 6,
            "delayed" : 0,
            "disagree" : 0,
            "fail_at" : 2,
            "hash" : "d5c247",
            "ledger" : 24311579,
            "missing" : 1,
            "phase" : "EXTERNALIZE"
         },
         "transitive" : {
            "critical" : null,
            "intersection" : true,
            "last_check_ledger" : 24311536,
            "node_count" : 21
         }
      },
      "startedOn" : "2019-06-10T17:40:29Z",
      "state" : "Catching up",
      "status" : [ "Catching up: downloading and verifying buckets: 30/30 (100%)" ]
   }
}
```

Some notable fields in the `info` command output are:

- **`build`**: the build number for this Diamante Core instance
- **`ledger`**: the local state of your node, which may differ from the network state if your node was disconnected. Some important sub-fields include:
  - **`age`**: time elapsed since this ledger closed (typically less than 10 seconds during normal operation)
  - **`num`**: ledger number
  - **`version`**: protocol version supported by this ledger
- **`network`**: the [Encyclopedia -> network passphrase](/encyclopedia/network-passphrases) that this core instance is using to decide whether to connect to the testnet or the public network
- **`peers`**: information on the connectivity to the network, including:
  - **`authenticated_count`**: the number of live connections
  - **`pending_count`**: the number of connections that are not fully established yet
  - **`protocol_version`**: the maximum version of the protocol that this instance recognizes
- **`state`**: the node's synchronization status relative to the network
- **`quorum`**: summarizes the state of the DCP protocol participants, the same as the information returned by the `quorum` command (see below).

## Overlay information

The `peers` command returns information on the peers your node is connected to.

This list is the result of both inbound connections from other peers and outbound connections from this node to other peers.

```json
$ diamante-core http-command 'peers'
```

```json
{
  "authenticated_peers": {
    "inbound": [
      {
        "address": "54.161.82.181:11625",
        "elapsed": 6,
        "id": "sdf1",
        "olver": 5,
        "ver": "v9.1.0"
      }
    ],
    "outbound": [
      {
        "address": "54.211.174.177:11625",
        "elapsed": 2303,
        "id": "sdf2",
        "olver": 5,
        "ver": "v9.1.0"
      },
      {
        "address": "54.160.175.7:11625",
        "elapsed": 14082,
        "id": "sdf3",
        "olver": 5,
        "ver": "v9.1.0"
      }
    ]
  },
  "pending_peers": {
    "inbound": ["211.249.63.74:11625", "45.77.5.118:11625"],
    "outbound": ["178.21.47.226:11625", "178.131.109.241:11625"]
  }
}
```

## Quorum Health

To help node operators monitor their quorum sets and maintain the health of the overall network, Diamante Core also provides metrics on other nodes in your quorum set. You should monitor them to make sure they're up and running, and that your quorum set is maintaining good overlap with the rest of the network.

#### Quorum set diagnostics

The quorum command allows to diagnose problems with the quorum set of the local node.

If you run:

`$ diamante-core http-command 'quorum'`

The output will look something like:

```json
{
  "node": "GCTSFJ36M7ZMTSX7ZKG6VJKPIDBDA26IEWRGV65DVX7YVVLBPE5ZWMIO",
  "qset": {
    "agree": 6,
    "delayed": null,
    "disagree": null,
    "fail_at": 2,
    "fail_with": ["sdf_watcher1", "sdf_watcher2"],
    "hash": "d5c247",
    "ledger": 24311847,
    "missing": ["stronghold1"],
    "phase": "EXTERNALIZE",
    "value": {
      "t": 3,
      "v": [
        "sdf_watcher1",
        "sdf_watcher2",
        "sdf_watcher3",
        {
          "t": 3,
          "v": ["stronghold1", "eno", "tempo.eu.com", "satoshipay"]
        }
      ]
    }
  },
  "transitive": {
    "critical": [["GDM7M262ZJJPV4BZ5SLGYYUTJGIGM25ID2XGKI3M6IDN6QLSTWQKTXQM"]],
    "intersection": true,
    "last_check_ledger": 24311536,
    "node_count": 21
  }
}
```

This output has two main sections: `qset` and `transitive`. The former describes the node and its quorum set; the latter describes the transitive closure of the node's quorum set.

#### Per-node Quorum-set Information

Entries to watch for in the `qset` section — which describe the node and its quorum set — are:

- **`agree`**: the number of nodes in the quorum set that agree with this instance.
- **`delayed`**: the nodes that are participating in consensus but seem to be behind.
- **`disagree`**: the nodes that are participating but disagreed with this instance.
- **`fail_at`**: the number of failed nodes that would cause this instance to halt.
- **`fail_with`**: an example of such potential failure.
- **`missing`**: the nodes that were missing during this consensus round.
- **`value`**: the quorum set used by this node (t is the threshold expressed as a number of nodes).

If a node is stuck in the state `Joining DCP`, this command allows you to quickly find the reason:

- Too many validators missing (down or without good connectivity), solutions are:
  - [Adjust your quorum set](/run-node/configuring) based on the nodes that are not missing.
  - Try to establish a [better connectivity path](/run-node/configuring?id=quorum-and-overlay-network) to the missing validators.
- Network split would cause DCP to stick because of nodes that disagree. This would happen if either there is a bug in DCP, the network does not have quorum intersection, or the disagreeing nodes are misbehaving (compromised, etc).

Note that the node not being able to reach consensus does not mean that the network as a whole will not be able to reach consensus (and the opposite is true: the network may fail because of a different set of validators failing).

You can get a sense of the quorum set health of a different node using:

`$ diamante-core http-command 'quorum?node=sdf1'` or `diamante-core http-command 'quorum?node=@GABCDE`

Overall network health can be evaluated by walking through all nodes and looking at their health. Note that this is only an approximation, as remote nodes may not have received the same messages (in particular: missing for other nodes is not reliable).

#### Transitive Closure Summary Information

When showing quorum-set information about the local node, a summary of the transitive closure of the quorum set is also provided in the `transitive` field. This has several important sub-fields:

- **`last_check_ledger`**: the last ledger in which the transitive closure was checked for quorum intersection. This will reset when the node boots and whenever a node in the transitive quorum changes its quorum set. It may lag behind the last-closed ledger by a few ledgers depending on the computational cost of checking quorum intersection.
- **`node_count`**: the number of nodes in the transitive closure, which are considered when calculating quorum intersection.
- **`intersection`**: whether or not the transitive closure enjoyed quorum intersection at the most recent check. This is of **utmost importance** in preventing network splits. It should always be true. If it is ever false, one or more nodes in the transitive closure of the quorum set are currently misconfigured, and the network is at risk of splitting. Corrective action should be taken immediately. Two additional sub-fields will be present to help suggest remedies:
  - **`last_good_ledger`**: this will note the last ledger for which the `intersection` field was evaluated as true. If some node reconfigured at or around that ledger, reverting that configuration change is the easiest corrective action to take.
  - **`potential_split`**: this will contain a pair of lists of validator IDs, which is a potential pair of disjoint quorums allowed by the current configuration. In other words, a possible split in consensus allowed by the current configuration. This may help narrow down the cause of the misconfiguration: likely it involves too-low a consensus threshold in one of the two potential quorums and/or the absence of a mandatory trust relationship that would bridge the two.
- **`critical`**: an "advance warning" field that lists nodes that could cause the network to fail to enjoy quorum intersection if they were misconfigured sufficiently badly. In a healthy transitive network configuration, this field will be `null`. If it is non-`null`, then the network is essentially "one misconfiguration" (of the quorum sets of the listed nodes) away from no longer enjoying quorum intersection, and again, corrective action should be taken: careful adjustment to the quorum sets of nodes that depend on the listed nodes, typically to strengthen quorums that depend on them.

#### Detailed Transitive Quorum Analysis

The `quorum` endpoint can also retrieve detailed information for the transitive quorum. This is a format that's easier to process than what DCP returns as it doesn't contain all DCP messages.

```shell
$ diamante-core http-command 'quorum?transitive=true'
```

The output looks something like:

```json
{
  "critical": null,
  "intersection": true,
  "last_check_ledger": 121235,
  "node_count": 4,
  "nodes": [
    {
      "distance": 0,
      "heard": 121235,
      "node": "GB7LI",
      "qset": {
        "t": 2,
        "v": ["sdf1", "sdf2", "sdf3"]
      },
      "status": "tracking",
      "value": "[ txH: d99591, ct: 1557426183, upgrades: [ ] ]",
      "value_id": 1
    },
    {
      "distance": 1,
      "heard": 121235,
      "node": "sdf2",
      "qset": {
        "t": 2,
        "v": ["sdf1", "sdf2", "sdf3"]
      },
      "status": "tracking",
      "value": "[ txH: d99591, ct: 1557426183, upgrades: [ ] ]",
      "value_id": 1
    },
    {
      "distance": 1,
      "heard": 121235,
      "node": "sdf3",
      "qset": {
        "t": 2,
        "v": ["sdf1", "sdf2", "sdf3"]
      },
      "status": "tracking",
      "value": "[ txH: d99591, ct: 1557426183, upgrades: [ ] ]",
      "value_id": 1
    },
    {
      "distance": 1,
      "heard": 121235,
      "node": "sdf1",
      "qset": {
        "t": 2,
        "v": ["sdf1", "sdf2", "sdf3"]
      },
      "status": "tracking",
      "value": "[ txH: d99591, ct: 1557426183, upgrades: [ ] ]",
      "value_id": 1
    }
  ]
}
```

The output begins with the same summary information as in the transitive block of the non-transitive query (if queried for the local node), but also includes a `nodes` array that represents a walk of the transitive quorum centered on the query node.

Fields are:

- **`node`**: the identity of the validator
- **`distance`**: how far that node is from the root node (i.e., how many quorum set hops)
- **`heard`**: the latest ledger sequence number that this node voted on
- **`qset`**: the node's quorum set
- **`status`**: one of `behind`, `tracking`, `ahead` (compared to the root node) or `missing`, `unknown` (when there are no recent DCP messages for that node)
- **`value_id`**: a unique ID for what the node is voting for (allows to quickly tell if nodes are voting for the same thing)
- **`value`**: what the node is voting for

## Using Prometheus

Monitoring `diamante-core` using Prometheus is by far the simplest solution, especially if you already have a Prometheus server within your infrastructure. Prometheus is a free and open-source time-series database with a simple yet incredibly powerful query language `PromQL`. Prometheus is also tightly integrated with Grafana, so you can render complex visualizations with ease.

To enable Prometheus to scrape `diamante-core` application metrics, you will need to install the diamante-core-prometheus-exporter (`apt-get install diamante-core-prometheus-exporter`) and configure your Prometheus server to scrape this exporter (default port: `9473`). Additionally, Grafana can be used to visualize metrics.

#### Install a Prometheus server within your infrastructure

Installing and configuring a Prometheus server is out of the scope of this document. However, it is a fairly simple process; Prometheus is a single Go binary that you can download from [Prometheus Installation](https://prometheus.io/docs/prometheus/latest/installation/).

#### Install the diamante-core-prometheus-exporter

The diamante-core-prometheus-exporter is an exporter that scrapes the `diamante-core` metrics endpoint (`http://localhost:11626/metrics`) and renders these metrics in the Prometheus text-based format available for Prometheus to scrape and store in its time-series database.

The exporter needs to be installed on every Diamante Core node you wish to monitor.

```bash
apt-get install diamante-core-prometheus-exporter
```

You will need to open up port `9473` between your Prometheus server and all your Diamante Core nodes for your Prometheus server to be able to scrape metrics.

#### Point Prometheus to diamante-core-prometheus-exporter

Pointing your Prometheus instance to the exporter can be achieved by manually configuring a scrape job; however, depending on the number of hosts you need to monitor, this can quickly become unwieldy. Luckily, the process can also be automated using Prometheus' various "service discovery" plugins. For example, with an AWS hosted instance, you can use the `ec2_sd_config` plugin.

**Manual**

```yaml
- job_name: "diamante-core"
  scrape_interval: 10s
  scrape_timeout: 10s
  static_configs:
    - targets: [
          "core-node-001.example.com:9473",
          "core-node-002.example.com:9473",
        ] # diamante-core-prometheus-exporter default port is 9473
    - labels:
      application: "diamante-core"
```

**Using Service Discovery (EC2)**

```yaml
- job_name: diamante-core
  scrape_interval: 10s
  scrape_timeout: 10s
  ec2_sd_configs:
    - region: eu-west-1
      port: 9473
  relabel_configs:
    # ignore stopped instances
    - source_labels: [__meta_ec2_instance_state]
      regex: stopped
      action: drop
    # only keep with `core` in the Name tag
    - source_labels: [__meta_ec2_tag_Name]
      regex: "(.*core.*)"
      action: keep
    # use Name tag as instance label
    - source_labels: [__meta_ec2_tag_Name]
      regex: "(.*)"
      action: replace
      replacement: "${1}"
      target_label: instance
    # set application label to diamante-core
    - source_labels: [__meta_ec2_tag_Name]
      regex: "(.*core.*)"
      action: replace
      replacement: diamante-core
      target_label: application
```

#### Create Alerting Rules

Once Prometheus scrapes metrics, you can add alerting rules. Recommended rules are provided below (require Prometheus 2.0 or later). Follow the steps to incorporate these rules into your Prometheus setup:

```yaml
rule_files:
  - "/etc/prometheus/diamante-core-alerting.rules"
```

#### Configure Notifications Using Alertmanager

Alertmanager is responsible for sending notifications. Installing and configuring an Alertmanager server is out of the scope of this document; however, it is a fairly simple process. Official documentation is available [here](https://prometheus.io/docs/alerting/latest/configuration/).

All recommended alerting rules have a "severity" label:

- **critical**: Normally requires immediate attention. They indicate an ongoing or very likely outage. We recommend that critical alerts notify administrators 24x7.
- **warning**: Normally can wait until working hours. Warnings indicate problems that likely do not have a production impact but may lead to critical alerts or outages if left unhandled.

The following example Alertmanager configuration demonstrates how to send notifications using different methods based on the severity label:

```yaml
global:
  smtp_smarthost: localhost:25
  smtp_from: alertmanager@example.com

route:
  receiver: default-receiver
  group_by: [alertname]
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  routes:
    - receiver: critical-alerts
      match:
        severity: critical
    - receiver: warning-alerts
      match:
        severity: warning

receivers:
  - name: critical-alerts
    pagerduty_configs:
      - routing_key: <PD routing key>

  - name: warning-alerts
    slack_configs:
      - api_url: https://hooks.slack.com/services/slack/warning/channel/webhook

  - name: default-receiver
    email_configs:
      - to: alerts-fallback@example.com
```

#### Visualize metrics using Grafana

Once you've configured Diamante to scrape and store your diamante-core metrics, you will want a nice way to render this data for human consumption. Diamante Grafana offers the simplest and most effective way to achieve this. Installing Diamante Grafana is out of the scope of this document but is a very simple process, especially when using the prebuilt apt packages.

We recommend that administrators import the following two dashboards into their Diamante Grafana deployments:

1. Diamante Core Monitoring: Shows the most important metrics, node status, and tries to surface common problems. It's a good troubleshooting starting point.
2. Diamante Core Full: Shows a simple health summary as well as all metrics exposed by the diamante-core-prometheus-exporter. It's much more detailed than the Diamante Core Monitoring and might be useful during in-depth troubleshooting.
