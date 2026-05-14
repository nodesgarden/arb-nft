nodes.garden
Funding Ask

25,000 USD

Current implementation handoff:

- Milestone 1 has been completed, submitted to Arbitrum, and accepted.
- Milestone 1 deployed `NodeNFT` on Arbitrum Sepolia at `0x1e678Ced5Ff9571a5C4337D4742D4AF0C8830392`.
- Milestone 2 fixed-price marketplace contract has been implemented, deployed, and verified on Arbitrum Sepolia at `0xEf7c2Cc4c60f4cc7B4C3cC4f69E02C486075CC2A`.
- Milestone 2 Rails marketplace backend/UI/indexer foundation has been merged into `/Users/ilyalebedev/projects/nodes.garden` `main` via PR #264.
- Milestone 2 target Rails env configuration/live sync and KPI event generation are completed.
- Milestone 2 still needs final screenshot/export evidence packaging.

What was implemented in `nodes.garden`:

- marketplace tables for listings, events, and sync cursors
- on-chain owner tracking on `node_nfts`
- idempotent event applier for listing creation, cancellation, purchase, and NFT transfer sync
- JSON-RPC Arbitrum Sepolia log poller
- GoodJob cron entry for marketplace sync
- hardcoded tester-gated `/dashboard/marketplace` UI
- transaction prep/status endpoints
- MetaMask calls for `createListing`, `cancelListing`, and `buy`
- purchase event handling that finds/creates buyer by wallet address and transfers Rails `Node#user`

Recorded marketplace-branch verification in `nodes.garden`:

- RSpec: `446 examples, 0 failures, 3 pending`
- targeted RuboCop: no offenses
- JS build: passed

Latest production marketplace sync counts:

- `ListingCreated`: `300`
- `ListingPurchased`: `100`
- `ListingCancelled`: `200`
- marketplace listings: `300`
- active listings: `0`

Submitted on

26 Sep, 2025

Milestones

4

Category

Consumer App

Details

 is a subscription-based infrastructure platform that simplifies node deployment and management. Our next step is to go fully on-chain on Arbitrum. Each node subscription will be represented by a tradable NFT, giving users and small projects transparent ownership and liquidity. This model turns infrastructure into a composable digital asset, enabling minting, renewals, payments, and secondary trading natively on Arbitrum. By financializing infra access, we generate recurring on-chain transactions, expand participation, and strengthen decentralization while positioning Arbitrum as a hub for innovative on-chain infrastructure solutions.
What innovation or value will your project bring to Arbitrum? What previously unaddressed problems is it solving? Is the project introducing genuinely new mechanisms.

Our project introduces a unique mechanism by bringing node infrastructure fully on-chain in the Arbitrum ecosystem. Each node will be tied to an NFT, representing both ownership and subscription rights. This model transforms nodes into tradable, composable digital assets—something not yet seen in Arbitrum. It lowers technical barriers for users and small projects to access reliable infrastructure, while generating continuous on-chain activity (payments, renewals, NFT transfers). By merging infrastructure with NFTs, we unlock new use cases that combine DeFi, ownership, and marketplace dynamics directly within Arbitrum.

What is the current stage of your project.

raising funds

Do you have a target audience? If so, which one.

Our core audience is everyday crypto enthusiasts attracted by the simple idea “Run Nodes, Get Airdrops.” We focus on retail users who want to earn from network participation without technical barriers, as well as small projects and developers seeking easy, subscription-based infrastructure.

Do you know about any comparable protocol, event, game, tool or project within the Arbitrum ecosystem.

We are not aware of a directly comparable project in the Arbitrum ecosystem. While there are infrastructure providers and node services, none have brought node ownership fully on-chain by tying nodes to NFTs and enabling a tradable marketplace. This mechanism is unique to nodes.garden and would introduce a new layer of composability and user engagement for Arbitrum.

Have you received a grant from the DAO, Foundation, or any Arbitrum ecosystem related program or conducted any IRL like a hackathon or workshop.

No

Have you received a grant from any other entity in other blockchains that are not Arbitrum.

$120k (Techstars Web3 ’25)

What is the idea/project for which you are applying for a grant.

Our project is to bring nodes.garden fully on-chain on Arbitrum. Today, nodes.garden operates as a subscription-based platform where users can deploy and manage blockchain nodes in one click. We want to move this model natively to Arbitrum by introducing NFT-bound nodes, where each node is minted as a tradable NFT representing ownership and subscription rights.
Implementation Plan:

On-chain Payments – Integrate Arbitrum-native payments (ETH, stablecoins) for node subscriptions and renewals.
NFT Smart Contracts – Deploy ERC-721 contracts on Arbitrum, binding each deployed node to an NFT that carries usage rights and enables secondary trading.
Marketplace Integration – Launch an internal marketplace where users can buy, sell, or transfer node NFTs.
Monitoring & Automation – Provide dashboards, alerts, and automated updates for all nodes tied to NFTs, ensuring reliability.
Community Campaigns – Run adoption initiatives to onboard more retail users into Arbitrum through simplified node ownership. This approach transforms infrastructure into a composable on-chain asset, generating continuous transactional activity (payments, minting, renewals, trades) and positioning Arbitrum as the first L2 where node infrastructure itself is financialized and accessible to all.
Outline the major deliverables you will obtain with this grant.

Major Deliverables:

On-Chain Payment System – Full integration of subscription and renewal payments in ETH and stablecoins on Arbitrum.
NFT Node Contracts – Smart contracts enabling each node to be minted and managed as an NFT on Arbitrum.
Node Marketplace – A marketplace for trading and transferring node NFTs (buy/sell/lease functionality).
User Dashboard & Monitoring – On-chain integrated dashboard with uptime metrics, alerts, and renewal tracking.
Adoption Campaigns – Community-facing campaigns (airdrops, loyalty points, more users adoption) to drive first 1,000+ active node NFT holders.
Please explain how your idea/project aligns with the Arbitrum ecosystem goals.

Our project directly supports Arbitrum’s ecosystem goals by transforming infrastructure access into a new financial primitive: each deployed node will be represented as an NFT with ownership and subscription rights, enabling trading, DeFi integration, and seamless use within dApps. This strengthens Arbitrum’s DeFi dominance by creating a novel asset class and generating sustainable transaction flows (payments, renewals, transfers), while also expanding developer tooling by allowing any project or user to access reliable nodes without technical barriers. At the same time, it drives ecosystem growth and adoption by onboarding new participants through simplified infrastructure ownership and positioning Arbitrum as the leading hub where infrastructure, NFTs, and DeFi converge.

What is your requested grant.

25k

Website.

https://nodes.garden

Please provide a detailed breakdown of the budget in term of utilizations, costs and other relevant information.

Milestone 1 — Node NFT Smart Contract (Testnet)
$7,000 — Smart-contract development (ERC-721), metadata & subscription logic, testing, deployment, documentation.

Milestone 2 — NFT Marketplace Backend & UI (Testnet)
$8,000 — Backend for listings, marketplace UI, wallet integration, indexing, testnet infra, QA.

Milestone 3 — Mainnet Deployment & User Onboarding
$6,250 — Mainnet deployment, integration with nodes.garden flows, user onboarding, analytics dashboard, security review.

Milestone 4 — Final Report & Success Validation
$3,750 — Final documentation, 90-day analytics, maintenance, roadmap planning, reporting.

Total Budget: $25,000

Provide a list of the milestones, with the USD amount of the grant associated to it, the deliverables that will be provided, and the estimated completion time.

Milestone 1 — Node NFT Smart Contract (Arbitrum Testnet)

Timeline: 4 weeks
Budget: $7,000

Deliverables:
• ERC-721 Node NFT contract deployed on Arbitrum Testnet
• Metadata encoding for node type, lifecycle state, subscription expiry
• Ownership transfer logic
• Subscription extension function
• Internal test suite + documentation

Success Criteria:
• ≥100 Node NFTs minted on testnet
• Transfers tested across multiple wallets

Milestone 2 — NFT Marketplace Backend & UI (Testnet)

Timeline: 4 weeks
Budget: $8,000

Deliverables:
• Listing backend (create/cancel/execute listing)
• Basic UI for browsing and listing Node NFTs
• MetaMask wallet connection
• Ownership & pricing indexing

Success Criteria:
• Marketplace deployed in staging
• ≥300 listings created
• ≥100 buy/sell events executed
• Integration with NFT contract

Milestone 3 — Mainnet Deployment & Initial User Onboarding

Timeline: 4 weeks
Budget: $6,250

Deliverables:
• Deploy Node NFT contract + marketplace to Arbitrum Mainnet
• Integrate with nodes.garden user flow (“Mint Node NFT” + “Burn to Reveal Key” flow)
• Onboard initial active user cohort
• Basic analytics dashboard (NFT mints, trades, MAUs)

Success Criteria:
• ≥300 NFTs minted on Arbitrum Mainnet
• ≥100 marketplace trades
• ≥200 MAUs interacting with contracts
• Public launch announcement coordinated with Arbitrum

*With Arbitrum ecosystem support, we expect significantly higher traction after launch.

Milestone 4 — Final Report & Quantitative Success Validation

Timeline: 3 months after Milestone 3 completion
Budget: $3,750 (15% withheld tranche)

Deliverables:
• Final documentation package (contracts, architecture, flows, SDK examples)
• 90-day analytics report (NFT activity, users, volume, retention)
• Post-launch maintenance plan + next-phase roadmap

Success Criteria:

On-Chain Activity Metrics
• ≥1000 total NFTs minted on Arbitrum Mainnet
• ≥300 marketplace trades executed on-chain
• ≥500 unique wallets interacting with the contracts
• ≥300 Monthly Active Users interacting with the contracts
• ≥50 repeat traders (wallets that transacted >1 time)

Are milestones clearly defined, time-bound, and measurable with quantitative metrics where applicable? What are your reference KPI, if applicable, for each milestone.

Milestone 1 (4 weeks): Deploy Node NFT contract on Arbitrum testnet.
KPIs: ≥100 testnet mints, transfers tested across multiple wallets.

Milestone 2 (4 weeks): Launch testnet marketplace backend + UI.
KPIs: ≥300 listings, ≥100 buy/sell events, full integration with NFT contract.

Milestone 3 (4 weeks): Deploy contracts to Arbitrum mainnet + onboarding flow.
KPIs: ≥300 mainnet mints, ≥100 trades, ≥200 MAUs.

Milestone 4 (3 months): Final report + 90-day analytics.
KPIs: ≥1000 total mints, ≥300 trades, ≥500 unique wallets, ≥300 MAUs, ≥50 repeat traders.

What is the estimated maximum time for the completion of the project.

6 months

How should the Arbitrum community measure the success of this grant.

The success of this grant can be measured by a combination of quantitative and qualitative metrics, including the number of active NFT node holders (target ≥1,000), the volume and frequency of subscription payments, renewals, and secondary trades executed on Arbitrum, and the number of developers and projects deploying nodes via NFT-based infrastructure. Additional indicators include engagement in community campaigns, adoption of node NFTs in DeFi or dApp integrations, system reliability with ≥90% uptime, completion of security audits with zero critical vulnerabilities, and overall growth in recurring on-chain activity, demonstrating that the project expands participation, lowers technical barriers, and strengthens Arbitrum’s position as a hub for innovative, composable infrastructure.

What is the economic plan for maintaining operations or continuing the growth of your project after the grant period.

Our economic plan for sustaining operations and driving growth beyond the grant period relies on a self-sustaining subscription model, secondary marketplace fees, and strategic partnerships within the Arbitrum ecosystem. Users will pay recurring fees for node access, ensuring a steady revenue stream that covers infrastructure, development, and support costs. A small percentage of fees from secondary NFT trades will further contribute to funding continuous improvements. Additionally, collaborations with DeFi protocols and dApps will create new use cases for node NFTs, expanding adoption and ecosystem utility. Revenue reinvestment will focus on scaling infrastructure, ongoing security audits, and developer incentives, ensuring that the project remains both financially viable and aligned with Arbitrum’s long-term growth.

Protocol Performance.

22000+ nodes, 8500+ signs up, 59+ protocols

Audit History & Security Vendors.

NA

Is your project composable with other projects on Arbitrum.

NA

Is the proposal scope realistic and well-defined given the team, resources, and deliverables.

Yes

Instagram.

NA

LinkedIn.

https://www.linkedin.com/company/nodes-garden

Discord.

https://discord.nodes.garden

Others.

https://github.com/cryptoklosh

Do you acknowledge that your team will be subject to a KYC requirement.

Yes

Do you acknowledge that, in case of approval, you will have to provide a report at the completion of the grant and, three months later, complete a survey about your experience.

Yes

Team experience and completeness.

• Ilia Lebedev (CEO) – Developer and crypto entrepreneur since 2016. He built and managed large-scale GPU mining farms with hundreds of GPUs, later shifting focus to blockchain node operations. With over 8 years in software engineering, he has grown nodes.garden into a platform with 22,000+ nodes across 59+ protocols. Mining crypto since 2017, Ilia brings both deep technical expertise and community-driven insights.
• Petr Stroganov (CTO) – Master of Applied Mathematics and BS in Computer Science. Petr is a software engineer with 8+ years of experience and a strong background in DevOps and Site Reliability Engineering. Having known Ilia since their high school days, he has collaborated on multiple startups and now leads technical architecture, automation, and infrastructure security at nodes.garden.
• Pavel Talianov (BD) – Business development lead with over a decade of experience working alongside Ilia and Petr on startups. He drives partnerships, growth, and ecosystem adoption, focusing on funds and collaborations.
• Engineering Team – Supported by 4 full-time DevOps engineers specializing in containerized infrastructure, monitoring, and scaling distributed systems.

Discussion


Chilla

Admin

10 Oct

Thanks for sending your application over. Before we can move forward, we’ll need a few more details. Please resubmit with the following updates.

Product and Technical Clarity

• Clarify whether your product only targets testnet use or whether it might move to production-grade RPC nodes.

• Is it a decentralized network of providers or a centralized infrastructure managed by your team that operates the nodes?

• Explain what happens to node subscriptions when NFTs are traded. How are ownership and access rights transferred?

• Describe how uptime and SLA compliance are measured, verified, and enforced. Is there an on-chain monitoring or oracle mechanism?

• Provide more details on what has already been built and what will be newly developed as part of this proposal.

• Indicate what activities will take place on-chain on Arbitrum, beyond NFT minting and transfers.

• What’s the current state of development? On which chains have you built already?

Differentiation and Competition

• Clearly outline how this differs from similar services such as NodeOps, Ankr, QuickNode, or Chainstack.

• In particular, explain how your NFT-based node model expands on or differs from NodeOps, which also uses NFTs to represent nodes.

• Explain your defensible moat if established providers begin to adopt NFT-based subscription mechanisms.

Team and Links

• Do team members have twitter profiles?

• Share details on past projects or companies that team members have worked on, and include their names.

• The GitHub link provided appears to be personal. Please share the official project GitHub repository instead.

Milestones and KPIs

• Your milestones and KPIs are well structured, but we’d like to see more growth-oriented KPIs, such as volume of NFT nodes traded or the number of active subscriptions over time.

Arbitrum Alignment

• Clarify what you mean by “a partnership with the Arbitrum ecosystem”.

• Why Arbitrum instead of other chains?

Overall

This is an interesting and potentially impactful use case, particularly in how it democratizes infrastructure access through NFT-based ownership. Once you clarify the technical mechanisms, differentiation, team details, Arbitrum integration, and measurable KPIs, we’ll be happy to take another look at your updated submission.

Looking forward


Chilla

Admin

27 Oct

Gentle reminder to check on these questions. Thank you


Ilya Lebedev

Builder

06 Nov

Thanks a lot for the detailed feedback and for taking a look at our application! We really appreciate you flagging these points.

We've received your questions and are currently working on gathering all the necessary details to provide a thorough update. We'd like to take a couple of days to really dig into these and give you the best possible answers.

To ensure we address everything comprehensively, we'll be preparing a detailed response in a message rather than attempting to edit the application directly within the form, as some of these points require more explanation.


Ilya Lebedev

Builder

13 Nov

Product and Technical Clarity

Thank you for reviewing our initial submission and providing detailed feedback.

Before we address each point raised in detail, we thought it would be helpful to provide some additional context with a brief overview of what we've already built at nodes.garden.

This should give you a full picture of what we plan to achieve with this grant and where we’re headed.

This submission enhances nodes.garden by integrating our projects with Arbitrum smart-contracts, creating the first on-chain Node-as-a-Service platform built on the Arbitrum ecosystem.

Currently, we provide one click node deployment for over 45+ projects on our platform, including L1 & L2s, DePIN and AI protocols. We help thousands of users to participate in early stage protocols & incentivized campaigns by running nodes. We are expanding into mainnet & plan to run mainnet RPCs in Q1 2026.

Our idea is to move node ownership & coordination fully on-chain on Arbitrum. This will make node ownership and operations fully transparent, secure and robust. Plus, we will open a new avenue for users who want to transfer or sell their nodes, which is not possible at the moment.

All core smart contracts and the SDK will be open-source on GitHub, enabling community contributions and verifiable security. Specifically, we'll deploy ERC-721 NFT contracts for node ownership, integrate ETH/ARB/stablecoin payments, and develop an SDK for dApp integrations, driving recurring on-chain activity and ecosystem growth on Arbitrum.

Below, we address each point raised and we've also updated relevant sections of the original application for completeness.

1. Clarify whether your product only targets testnet use or whether it might move to production-grade RPC nodes.

Our current platform primarily focuses on early stage (pre-TGE) projects, where we've achieved strong traction (23,000+ nodes deployed in a year) across various blockchain nodes, DePIN and AI protocols. Recently, we have already launched mainnet RPC services (currently B2B only). By Q4 2026, we plan to launch a decentralized compute layer. The Arbitrum integration will support all types of nodes.

2. Is it a decentralized network of providers or a centralized infrastructure managed by your team that operates the nodes?

Currently, nodes.garden operates as a centralized infrastructure managed by our team, leveraging providers like OVH Cloud, Digital Ocean and others for reliable, scalable hosting.

We handle deployment, monitoring, and maintenance to ensure one-click simplicity for both non-technical users and those who want to save time. However, our long-term vision is to evolve into a decentralized model, incorporating community-provided hardware through a distributed cloud compute layer.

The Arbitrum grant will fund the on-chain foundation (NFTs, payments), which is designed to be composable and extensible for future decentralization. For now, the focus is on managed nodes to guarantee high uptime and compliance, with on-chain elements enabling transparency.

3. Explain what happens to node subscriptions when NFTs are traded. How are ownership and access rights transferred?

When a node NFT on Arbitrum is transferred, ownership and subscription rights automatically move on-chain to the new wallet.

Subscription time is preserved, and renewals are handled via on-chain payments. Crucially, the NFT can be burned to reveal the node’s private access key, enabling a verifiable, one-time access mechanism that guarantees both transparency and security — a novel model for decentralized node management on Arbitrum.

4. Describe how uptime and SLA compliance are measured, verified, and enforced. Is there an on-chain monitoring or oracle mechanism?

Uptime is measured using Prometheus and Grafana for real-time monitoring of node health, latency, and availability, with alerts sent via dashboard, email, or Telegram. We target ≥99.5% uptime SLA (mainnet only). On-chain monitoring & public access dashboards are in the roadmap.

5. Provide more details on what has already been built and what will be newly developed as part of this proposal.

Already built:

The core one click node as a service platform, including full deployment automation & monitoring. We support over 45+ projects (e.g., AI/DePIN/blockchains like Nexus, Gensyn, Drosera, Pipe Network). Backend uses containerized infrastructure (Docker/Kubernetes) for scaling.

Newly developed for this proposal:

On-chain components on Arbitrum, including ERC-721 NFT contracts for node ownership, subscription/renewal logic, payment integration (ETH/ARB/stablecoins), and SDK for dApp integrations. We’ll also integrate oracle-based on-chain monitoring and ensure EVM wallet compatibility to enable non-custodial access.

6. Indicate what activities will take place on-chain on Arbitrum, beyond NFT minting and transfers.

Beyond minting and transfers, on-chain activities include subscription payments and renewals (via smart contract calls settled in ETH or stablecoins), leasing and fractionalized ownership (NFTs for shared costs and rewards), staking and governance voting after the TGE in Q4 2026. The SDK will enable dApps to call contracts for node deployment/management directly, generating transactions for lifecycle events (e.g., upgrades, expirations).

7. What’s the current state of development? On which chains have you built already?

The nodes.garden platform is fully live and production-ready for off-chain operations. Since mid-2024, we’ve been operating our web application and API that allow users to deploy nodes for 40+ blockchain networks — including L1s, L2s, DePIN, and AI protocols — with a single click.

On the backend, we’ve built a custom infrastructure layer based on Kubernetes that manages over 1,000 VPS instances simultaneously, automating full lifecycle management (setup, monitoring, scaling, redeployment). Node deployments are completed in under 3–5 minutes, and to date we’ve successfully launched over 23,000 nodes for our users.

We’ve already integrated payments in both crypto and fiat and provide node data (like logs) directly within user dashboards. While most current operations are off-chain, our team has deep experience running and maintaining blockchain infrastructure across multiple ecosystems.

Our next development phase includes on-chain contracts for decentralized node management and payment settlements — evolving nodes.garden into a fully on-chain, autonomous infrastructure marketplace.

Differentiation and Competition
1. Clearly outline how this differs from similar services such as NodeOps, Ankr, QuickNode, or Chainstack.

Although Quicknode and NodeOps do provide similar service (one-click deployment), none of them are fully on-chain.

We differ by financializing access—turning nodes into the novel asset class while maintaining managed reliability.

This means, anyone can now accumulate a new type of on-chain commodity (with real utility).

2. In particular, explain how your NFT-based node model expands on or differs from NodeOps, which also uses NFTs to represent nodes.

NodeOps uses NFTs (UNO) as utility licenses for holders, allowing them to access platform rewards, allowlists, and privileges such as token unlocks.

Our model differs by representing subscriptions to any type of node (Blockchain, AI, DePIN) with NFTs encoding ownership, renewals, and access to private keys & rewards.

We expand by adding leasing/fractionalized ownership, on-chain SLAs with public access dashboards and SDK for dApp integrations—creating composable infra primitives.

This lowers barriers for non-technical users, drives recurring transactions, strengthens decentralization, and positions nodes as DeFi assets, rather than just delegation tools.

3. Explain your defensible moat if established providers begin to adopt NFT-based subscription mechanisms.

Our moat includes:

Established traction (23,000+ nodes, 10,000+ users, $330K+ revenue captured) for rapid adoption;

Techstars backing and partnerships (Nexus, Drosera, Dria, Canopy, Tashi & others);

Focus on early stage (pre-TGE) protocols where support the largest number of projects (more than any competitor) + we provide custom tools & bots which are not available anywhere else.

Community-driven growth (organic 1,000+/month sign-ups, CAC ~$8);

Open-source SDK/portal for ecosystem lock-in.

We are actively expanding our platform beyond testnet to include RPC services and decentralized computing capabilities, positioning nodes.garden as a one-stop infrastructure hub that captures emerging opportunities in Web3+AI decentralized cloud compute space. We believe that our ongoing product expansion and growing customer base will secure a lasting competitive edge, even if competitors adopt NFT-based models.

Team and Links
1. Do team members have twitter profiles?

Yes, we’ve also provided linkedin profiles:

Ilia Lebedev (CEO):

X - https://x.com/ilyalebe_dev

Linkedin - https://www.linkedin.com/in/ilya-lebedev-554225102/

Petr Stroganov (CTO):

Linkedin - https://www.linkedin.com/in/petr-stroganov-646061171/

Pavel Talianov (BD):

X - [https://x.com/Arngolj

](https://x.com/Arngolj)Linkedin - https://www.linkedin.com/in/pavel-talianov-a51b71283/

2. Share details on past projects or companies that team members have worked on, and include their names.

Ilia Lebedev:

Master of Applied math, worked at worldquant.com, Joint Institute of Nuclear Research, yandex.ru, http://igooods.ru/, http://sputnik8.com/, http://rubyroidlabs.com/, xometry.eu

Petr Stroganov:

Bachelor of Computer Science, worked at paypay.ne.jp

Pavel Talianov:

PhD in Physical and Mathematical Sciences and worked as a research chemist with over 12 publications in materials science.

3.The GitHub link provided appears to be personal. Please share the official project GitHub repository instead.

Our platform is partly open-source. The official repo is currently private during development, but key components (e.g., SDK, contracts post-audit) will be released under MIT license upon mainnet launch. We'll share an access for review if needed.

Milestones and KPIs
1. Your milestones and KPIs are well structured, but we’d like to see more growth-oriented KPIs, such as volume of NFT nodes traded or the number of active subscriptions over time.

We've revised our milestones and enhanced our KPIs to include growth-oriented metrics:

Milestone 1 - MVP:

Budget: $15,000

Estimated completion: Month 1-2

Brief description: Integrate EVM-compatible wallets (e.g., MetaMask) for non-custodial payments and subscription management, implement Arbitrum smart contracts for handling payments and on-chain node operations where each node is represented as an NFT for ownership and subscription, enabling secure transactions and deployments.

KPIs: planned features implemented; ≥10 test nodes operational with NFT logic; ≥50 NFT mints in internal testing to validate early scalability.

Milestone 2 - Testnet:

Budget: $20,000

Estimated Completion: Month 3-4

Brief description: Develop Arbitrum contracts for minting and managing Node NFTs, including fractional ownership and integrate NFT features into the user dashboard with real-time metrics and pooled ownership tools. NFTs will be compatible for trading on existing marketplaces like OpenSea.

KPIs: ≥50 concurrent NFT nodes; ≥100 active subscriptions within 1 month post-Testnet launch; ≥200 NFT transfers in beta to demonstrate liquidity growth; ≥20% MoM increase in subscription renewals during testing.

Milestone 3 - Mainnet:

Budget: $15,000

Estimated Completion: Month 5-6

Brief description: Finalize Arbitrum smart contracts (Node NFTs) for Mainnet deployment, deploy the integration on Arbitrum Mainnet, onboard initial users/partners, and enable live payments/management. NFTs will be compatible for trading on existing marketplaces like OpenSea.

KPIs:

Users onboarded: ≥ 1000

NFTs minted: ≥ 2000

Transaction volume expected (monthly/quarterly): ≥ 1500/4500

Trading volume expected (monthly/quarterly): ≥ $11,000/$33,000

Arbitrum Alignment
1. Clarify what you mean by “a partnership with the Arbitrum ecosystem”.

We mean deep integration and collaboration:

Deploying contracts on Arbitrum, using its tools (e.g., Stylus for efficiency), integrating with existing marketplaces (e.g., OpenSea), and partnering with dApps/DAOs for co-marketing and promotion.

Demonstrating trust through partnerships is one of the stronger growth signals we can show our current and future users.

Post-launch, we'll contribute to ecosystem growth via open SDK and on-chain activity.

2. Why Arbitrum instead of other chains?

Arbitrum's low fees, high throughput, and EVM compatibility make it ideal for recurring transactions (payments/renewals). Its DeFi dominance aligns with our NFT/DeFi fusion, and strong developer community enables composability. Unlike Solana (non-EVM) or BNB (less DeFi focus), Arbitrum positions us as a growth force for infra primitives.


Chilla

Admin

25 Nov

Thank you for the info. Please book a spot here: https://calendar.app.google/Nf4SWJyHfGwdJF6o8, we're glad to have a chat.

Looking forward


Chilla

Admin

03 Dec

Thanks for the call, guys. We've had a chance to talk internally, and this is what we think:

The platform as a whole is interesting. It's something different than normal and could fit well into our "innovative ideas" pipeline, and we'd be happy to have it onchain on Arbitrum.

At the same time, however, there are some issues we're unsure about, such as the long-term sustainability of the current product, especially since your focus could shift to other verticals, like AI computing. That said, we'd like to offer you a $25,000 grant to promote your business, which already has initial traction and would benefit from an onchain implementation. We also understand that this price may not fully cover the project, and for this reason, we want to focus this grant on the NFT marketplace you want to build.

And then we could discuss expanding your verticals next year, should a similar grant program be re-proposed by Arbitrum.

Do you think it can be possible for you to reframe the milestones for this purpose?

We look forward to hearing from you soon.


Ilya Lebedev

Builder

05 Dec

Thanks for the call and the thoughtful follow-up.

We appreciate the opportunity and fully understand the committee’s request. We agree that focusing on the NFT marketplace as a stand-alone deliverable is the most practical way to demonstrate on-chain traction quickly, and we’re happy to proceed on that basis.

Below is the reframed set of milestones aligned with the proposed $25,000

Milestone 1: Node NFT Smart Contract (Arbitrum Testnet)

Timeline: 4 weeks

Deliverables:

• ERC-721 Node NFT contract deployed on Arbitrum Testnet

• Encode node metadata

• Ownership transfer logic and subscription extension function

• Internal testing scripts + documentation

Success Criteria: 50+ NFTs minted on testnet; transfers tested across multiple wallets

Budget: $8,000

Milestone 2: NFT Marketplace Backend + UI

Timeline: 4 weeks

Deliverables:

• Listing backend (create/cancel/execute listing)

• Basic UI for browsing and listing Node NFTs

• Wallet connection via MetaMask

• Ownership + pricing indexing

Success Criteria: Marketplace live in staging; ≥100 listings created; ≥50 testnet buy/sell events

Budget: $9,000

Milestone 3 — Mainnet Deployment + Initial User Onboarding

Timeline: 4 weeks

Deliverables:

• Deploy Node NFT contract + marketplace to Arbitrum Mainnet

• Integrate with nodes.garden user flow (mint & burn NFTs)

• Initial onboarding for a small group of users

• Basic analytics dashboard for mints/trades/user activity

Success Criteria: ≥200 NFTs minted; ≥50 marketplace trades; ≥100 MAU interacting with contracts*

Budget: $8,000

*With the support of Arbitrum ecosystem, we're expecting dramatically more NFTs & users after the initial release

We believe this MVP will allow us to demonstrate meaningful on-chain usage with NFT mints, transfers, marketplace volume, and MAUs, within a short timeframe. Once delivered, we would welcome the chance to expand into additional verticals (subscriptions, compute, RPC, etc.) as part of next year’s program.

Please let us know if this structure aligns with your expectations. We are ready to move forward.

Thanks again for your feedback and guidance.

Looking forward to collaborating more closely with the Arbitrum ecosystem.


Chilla

Admin

06 Dec

Looks good to us, though we'd like to see you guys overdelivering for the KPIs. Now please rephrase the milestones by resubmitting the proposal and update info + amounts.

Moreover, you have to add a final milestone with 15% of the total (and take away 15% from the others), which will be disbursed 3 months after grant completion, upon receiving the final report. This is something we have to ask each team.

Looking forward to your final version of the proposal!

Also, here you have your discord channel for smoother convos: https://discord.gg/SxGztmNb

https://discord.com/channels/847237372903030844/1446588126611902534


Ilya Lebedev

Builder

08 Dec

This proposal was resubmitted


Ilya Lebedev

Builder

08 Dec

This proposal was resubmitted


Chilla

Admin

09 Dec

Thanks for the discussion. This is an interesting concept that could improve the experience of end users on Arbitrum. Therefore, after evaluation, we decided to approve this proposal.

Domain Fit

There are partially similar projects in the sector, but this one stands out through its implementation of an NFT-based node service that can be used by anyone. The team intends for Arbitrum to be the sole onchain environment for trading these licenses as NFTs, demonstrating strong alignment and providing Arbitrum with a clear role as the primary execution layer for their marketplace.

Milestones & Clarifications

The team has already shown expertise in bringing up initial traction. After discussions, the milestones and KPIs are now well-structured and aligned with realistic delivery expectations. The roadmap reflects thoughtful planning and adaptability, supported by the traction the project has already demonstrated.

Sustainability & Monetization

The sustainability components provide a coherent path forward. The project’s model presents a monetization mechanism that does not rely heavily on speculative tokenomics and aligns incentives between builders and users.

Path Forward

After talking extensively with the team and significantly refining the goals and milestones of their grant proposal, we reached a consensus. This was made possible primarily due to the team’s experience, the traction already demonstrated, and the clear goals set for future expansion.

Looking forward to it.



FINAL MILESTONES
Milestones

01

Node NFT Smart Contract (Arbitrum Testnet)

7000 USD

Timeline: 4 weeks Budget: $7,000 Deliverables: • ERC-721 Node NFT contract deployed on Arbitrum Testnet • Metadata encoding for node type, lifecycle state, subscription expiry • Ownership transfer logic • Subscription extension function • Internal test suite + documentation Success Criteria: • ≥100 Node NFTs minted on testnet • Transfers tested across multiple wallets

Deadline: 10 Jan, 2026

02

NFT Marketplace Backend & UI (Testnet)

8000 USD

Timeline: 4 weeks Budget: $8,000 Deliverables: • Listing backend (create/cancel/execute listing) • Basic UI for browsing and listing Node NFTs • MetaMask wallet connection • Ownership & pricing indexing Success Criteria: • Marketplace deployed in staging • ≥300 listings created • ≥100 buy/sell events executed • Integration with NFT contract

Deadline: 10 Feb, 2026

03

Mainnet Deployment & Initial User Onboarding

6250 USD

Timeline: 4 weeks Budget: $6,250 Deliverables: • Deploy Node NFT contract + marketplace to Arbitrum Mainnet • Integrate with nodes.garden user flow (“Mint Node NFT” + “Burn to Reveal Key” flow) • Onboard initial active user cohort • Basic analytics dashboard (NFT mints, trades, MAUs) Success Criteria: • ≥300 NFTs minted on Arbitrum Mainnet • ≥100 marketplace trades • ≥200 MAUs interacting with contracts • Public launch announcement coordinated with Arbitrum *With Arbitrum ecosystem support, we expect significantly higher traction after launch.

Deadline: 10 Mar, 2026

04

Final Report & Quantitative Success Validation

3750 USD

Timeline: 3 months after Milestone 3 completion Budget: $3,750 (15% withheld tranche) Deliverables: • Final documentation package (contracts, architecture, flows, SDK examples) • 90-day analytics report (NFT activity, users, volume, retention) • Post-launch maintenance plan + next-phase roadmap Success Criteria: On-Chain Activity Metrics • ≥1000 total NFTs minted on Arbitrum Mainnet • ≥300 marketplace trades executed on-chain • ≥500 unique wallets interacting with the contracts • ≥300 Monthly Active Users interacting with the contracts • ≥50 repeat traders (wallets that transacted >1 time)

Deadline: 10 Jun, 2026
