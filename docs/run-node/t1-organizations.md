# Tier 1 Organizations

To help with Diamante’s decentralization, the most advanced teams building on Diamante run validators and strive to join the ranks of “Tier 1 organizations.”

Remember that the Diamante network consists of organizations that each run validators, and each organization decides for itself, by configuring a quorum set, which and how many other organizations it requires agreement from in order to commit to a particular new ledger. Tier 1 organizations are a group of organizations that, due to the fact that most other organizations require agreement from them, bear the safety and liveness of the Diamante network on their shoulders.

To become a Tier 1 organization, a team running validators must convince enough other organizations in the Diamante network to trust them by including them in their quorum sets. As part of this process, they must meet some requirements that are accepted by the community of Diamante validators. For example, Tier 1 organizations generally run three validators, coordinate any changes to their quorum sets with each other, and hold themselves to a higher standard of uptime and responsiveness.

As a steward of the Diamante network, the DDF works closely with Tier 1 organizations to ensure the health of the network, maintain robust quorum intersection, and build in redundancy to minimize network disruptions. This guide outlines the minimum requirements recommended by the DDF in order to be a Tier 1 organization. However, in the end, the DDF on its own cannot add or remove a Tier 1 organization; this depends on the quorum sets of many other organizations in the network.

## Why Three Validators

The most important recommendation for a Tier 1 organization is to set up and maintain three full validators. Why three?

On Diamante, validators choose to trust organizations when they configure their quorum set. If you are a trustworthy organization, you want your presence on the network to persist even if a node fails or you take it down for maintenance. A trio of validating nodes allows that to happen: when configuring their quorum sets, other participants can requires ⅔ of your validating nodes to agree. If 1 has issues, no big deal: the other two still vote on your organization’s behalf, so the show goes on. To ensure redundancy, it's also important that those three full validators be geographically dispersed: if they're in the same data center, they run the risk of going down at the same time.

## What Tier 1 organizations should expect of one another:

- **Publish History Archives**: In addition to participating in the Diamante Consensus Protocol, a full validator publishes an archive of network transactions. To do that, you need to configure Diamante Core to record history to a publicly accessible archive, and add the location of that archive to your diamante.toml. We recommend that, as a Tier 1 organization, you should set each of your nodes to record history to a separate archive.

- **Set Up a Safe Quorum Set**: For simplicity, we’re recommending that every Tier 1 node use the same quorum set configuration, which is made up of inner quorum sets representing each Tier 1 organization.

- **Declare Your Node**: DEP-20 is an open spec that explains how self-verification of validator nodes works. The fields it specifies are pretty simple: you set the home domain of your validator’s Diamante account to your website, where you publish information about your node and your organization in a diamante.toml file.

- **Keep Your Nodes Up To Date**: Running a validator requires vigilance. You need to keep an eye on your nodes, keep them up to date with the latest version of Diamante Core, and check in on public channels for information about what’s currently happening with other validators. As organizations join or leave the network, you might need to update the quorum set configuration of your validators to ensure that your validators have robust quorum intersection with Tier 1 and robust quorum availability.

- **Coordinate With Other Validators**: Whether you run a trio of validators or a single node, it’s important that you coordinate with other validators when you make a significant change or notice something wrong.

- **Monitor your quorum set**: We recommend using Prometheus to scrape and store your diamante-core metrics, and Grafana to render that data for human consumption.

## Get in touch

If you think you can be a Tier 1 organization, let us know on the #validators channel on the Diamante Developers Discord. We can help you through the process, and once you’re up and running, we’ll help you join Tier 1 so that you can take your rightful place as a pillar of the network. Once you’ve proven that you are responsive, reliable, and maintain good uptime, we will recommend that other validators adjust their quorum set to include your validators.

As Diamante grows, and more and more businesses build on the network, Tier 1 organizations will be crucial to a healthy expansion of the network.
