# BitLink Protocol

A decentralized, stake-based social reputation protocol built on Stacks for Bitcoin. BitLink enables users to establish identity, build social connections, create content, and earn trust through transparent on-chain interactions backed by STX staking.

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [System Components](#system-components)
- [Data Flow](#data-flow)
- [Smart Contract Functions](#smart-contract-functions)
- [Economic Model](#economic-model)
- [Getting Started](#getting-started)
- [API Reference](#api-reference)
- [Security Considerations](#security-considerations)

## Overview

BitLink reimagines social identity by leveraging Bitcoin's security through the Stacks blockchain. Every user profile, social connection, post, and endorsement is recorded on-chain and backed by STX stakes, creating a transparent and trustworthy social reputation system.

The protocol establishes a foundation for decentralized influence networks, trust graphs, and social-financial applications, all secured by Bitcoin's consensus mechanism and governed by Clarity smart contracts.

## Key Features

- **Decentralized Identity**: Stake-backed profile creation with unique usernames
- **Social Graph**: On-chain follow/unfollow relationships with active state tracking
- **Content Creation**: Post publishing with STX-based boosting mechanisms
- **Reputation System**: Multi-factor reputation scoring based on stakes, followers, and endorsements
- **Endorsement Economy**: Profile and post endorsements backed by STX stakes
- **Transparent Governance**: Protocol fee management by contract owner
- **Bitcoin Security**: All interactions secured by Bitcoin through Stacks

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        BitLink Protocol                         │
├─────────────────────────────────────────────────────────────────┤
│  Frontend Applications (Web, Mobile, Desktop)                  │
├─────────────────────────────────────────────────────────────────┤
│  Protocol API Layer                                            │
├─────────────────────────────────────────────────────────────────┤
│  Stacks Blockchain (L2)                                        │
│  ├─ BitLink Smart Contract (Clarity)                           │
│  ├─ STX Token Management                                       │
│  └─ Transaction Processing                                     │
├─────────────────────────────────────────────────────────────────┤
│  Bitcoin Blockchain (L1)                                       │
│  └─ Final Settlement & Security                               │
└─────────────────────────────────────────────────────────────────┘
```

### Contract Architecture

The BitLink smart contract is organized into several key components:

#### Core Data Structures

1. **Profiles Map**: Stores user profile information including identity, reputation metrics, and social stats
2. **Username & Principal Mappings**: Enable efficient lookups by username or wallet address
3. **Following Map**: Tracks social connections between users with timestamps
4. **Posts Map**: Stores content with boost amounts and endorsement counts
5. **Endorsement Maps**: Records both post and profile endorsements with stake amounts
6. **Stake Maps**: Tracks STX stakes for profiles and post boosts

#### Function Categories

- **Profile Management**: Creation, updates, and reputation calculation
- **Social Interactions**: Following, unfollowing, and relationship queries
- **Content System**: Post creation, boosting, and endorsements
- **Staking Mechanism**: Reputation staking and economic incentives
- **Read-Only Queries**: Profile lookups, relationship checks, and data retrieval

## System Components

### 1. Identity Layer

Users create profiles by staking a minimum amount of STX (1 STX), establishing their on-chain identity with:

- Unique username (50 characters max)
- Bio (280 characters max)
- Avatar URL
- Immutable creation timestamp

### 2. Social Graph

The protocol maintains a directed graph of social relationships:

- Follow relationships are recorded on-chain
- Active state tracking prevents spam
- Follower/following counts are automatically maintained
- Self-following is prevented

### 3. Content System

Users can create posts (500 characters max) that support:

- STX-based boosting (minimum 0.1 STX)
- Stake-backed endorsements (minimum 0.5 STX)
- Automatic metrics tracking

### 4. Reputation Engine

Multi-factor reputation scoring considers:

- **Base Stake**: Initial and additional STX staked
- **Social Metrics**: Follower count (1000 points per follower)
- **Endorsements**: Profile endorsements (2000 points each)
- **Content Activity**: Post count (500 points per post)

### 5. Economic Model

The protocol implements several economic mechanisms:

- **Profile Staking**: Required 1 STX minimum stake
- **Post Boosting**: Minimum 0.1 STX per boost
- **Endorsement Staking**: Minimum 0.5 STX per endorsement
- **Protocol Fees**: Configurable fee rate (max 10%)

## Data Flow

### Profile Creation Flow

```
User Request → Validation → STX Transfer → Profile Creation → Mapping Updates → Profile ID Return
```

1. User initiates profile creation with username, bio, and avatar
2. Contract validates username availability and stake amount
3. STX stake is transferred to contract
4. Profile record is created with unique ID
5. Username and principal mappings are updated
6. Profile ID is returned to user

### Social Interaction Flow

```
Follow Request → Profile Validation → Relationship Check → State Update → Counter Updates
```

1. User initiates follow action
2. Contract validates both profiles exist
3. Checks prevent self-following and duplicate follows
4. Follow relationship is recorded with timestamp
5. Follower/following counts are updated

### Content & Endorsement Flow

```
Content Creation → Post Storage → Boost/Endorsement → Stake Transfer → Metrics Update
```

1. User creates post content
2. Post is stored with unique ID and metadata
3. Users can boost posts or endorse with STX stakes
4. Stakes are transferred to contract
5. Post and profile metrics are updated

## Smart Contract Functions

### Core Functions

#### Profile Management

- `create-profile`: Create new user profile with stake
- `update-profile`: Update bio and avatar
- `get-profile`: Retrieve profile by ID
- `get-profile-by-username`: Retrieve profile by username
- `get-profile-by-principal`: Retrieve profile by wallet address

#### Social Features

- `follow-user`: Follow another user
- `unfollow-user`: Unfollow a user
- `is-following`: Check follow relationship

#### Content System

- `create-post`: Create new post
- `boost-post`: Boost post with STX
- `endorse-post`: Endorse post with stake
- `endorse-profile`: Endorse profile with stake

#### Reputation & Staking

- `stake-for-reputation`: Add additional stake for reputation
- `calculate-reputation-score`: Calculate user reputation

### Read-Only Functions

- `is-username-available`: Check username availability
- `get-post`: Retrieve post by ID
- `get-next-profile-id`: Get next available profile ID
- `get-next-post-id`: Get next available post ID

## Economic Model

### Stake Requirements

| Action | Minimum Stake | Purpose |
|--------|---------------|---------|
| Profile Creation | 1 STX | Identity establishment |
| Post Boosting | 0.1 STX | Content promotion |
| Endorsements | 0.5 STX | Trust signaling |

### Reputation Calculation

```
Reputation = Base Stake + (Followers × 1000) + (Endorsements × 2000) + (Posts × 500)
```

### Economic Incentives

- **Quality Content**: Higher stakes signal higher quality
- **Trust Building**: Endorsements create reputation networks
- **Community Growth**: Social metrics boost overall reputation
- **Long-term Commitment**: Staking encourages platform loyalty

## Getting Started

### Prerequisites

- Stacks wallet (Hiro Wallet recommended)
- STX tokens for staking
- Understanding of Clarity smart contracts

### Deployment

1. Deploy the BitLink smart contract to Stacks testnet/mainnet
2. Verify contract deployment and initialization
3. Set up frontend application to interact with contract
4. Configure protocol parameters if needed

### Basic Usage

1. **Create Profile**: Call `create-profile` with username, bio, and avatar
2. **Build Network**: Use `follow-user` to connect with others
3. **Create Content**: Use `create-post` to share content
4. **Boost & Endorse**: Support quality content with STX stakes
5. **Monitor Reputation**: Track reputation growth over time

## API Reference

### Profile Creation

```clarity
(create-profile (username (string-ascii 50)) (bio (string-utf8 280)) (avatar-url (string-ascii 200)))
```

### Social Interactions

```clarity
(follow-user (following-id uint))
(unfollow-user (following-id uint))
(is-following (follower-id uint) (following-id uint))
```

### Content Management

```clarity
(create-post (content (string-utf8 500)))
(boost-post (post-id uint) (amount uint))
(endorse-post (post-id uint) (stake-amount uint))
```

### Reputation & Staking

```clarity
(stake-for-reputation (amount uint))
(calculate-reputation-score (profile-id uint))
```

## Security Considerations

### Access Control

- Profile ownership is tied to Stacks principal
- Only profile owners can update their profiles
- Contract owner controls protocol parameters

### Economic Security

- Minimum stake requirements prevent spam
- Stake-backing ensures skin in the game
- Protocol fees provide sustainability

### Data Integrity

- All data is stored on-chain for transparency
- Immutable creation timestamps prevent manipulation
- Relationship states are carefully managed

### Best Practices

- Validate all inputs before processing
- Use proper error handling for edge cases
- Implement rate limiting for high-frequency actions
- Regular security audits recommended

## Contributing

BitLink is an open protocol. Contributions are welcome through:

- Smart contract improvements
- Frontend applications
- Protocol documentation
- Security audits
- Community building

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions, issues, or contributions:

- Create an issue in the repository
- Join the community discussions
- Review the documentation
- Contact the development team

---

## BitLink Protocol - Building the future of decentralized social reputation on Bitcoin
