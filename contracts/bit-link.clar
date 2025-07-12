;; BitLink - Bitcoin-Native Social Reputation Protocol
;;
;; Summary:
;; A decentralized, stake-based social graph and reputation layer 
;; built on Stacks for Bitcoin. Users establish identity, follow 
;; peers, create content, and earn trust  all powered by Clarity 
;; smart contracts with Bitcoin finality.

;; Description:
;; BitLink reimagines social identity by leveraging Bitcoin's 
;; security and Stacks programmability. Every user profile, 
;; follow, post, or endorsement is recorded on-chain, backed by 
;; stake, and contributes to a transparent reputation score. 
;; The protocol supports profile staking, content boosting, and 
;; cross-profile endorsements. This framework lays the foundation 
;; for decentralized influence, trust graphs, and social-financial 
;; applications, all secured by Bitcoin and governed by Clarity.

;; Key Features:
;; - Decentralized profile creation with staking
;; - Follow/unfollow logic with active state tracking
;; - Post creation and STX-based boosting
;; - Profile and post endorsements tied to stake
;; - On-chain social reputation score calculation
;; - Flexible protocol fee management by contract owner
;; - Mappings for usernames, principals, follows, and content

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROFILE_EXISTS (err u101))
(define-constant ERR_PROFILE_NOT_FOUND (err u102))
(define-constant ERR_INSUFFICIENT_FUNDS (err u103))
(define-constant ERR_INVALID_AMOUNT (err u104))
(define-constant ERR_ALREADY_FOLLOWING (err u105))
(define-constant ERR_NOT_FOLLOWING (err u106))
(define-constant ERR_SELF_FOLLOW (err u107))
(define-constant ERR_ALREADY_ENDORSED (err u108))
(define-constant ERR_POST_NOT_FOUND (err u109))
(define-constant ERR_INVALID_POST_ID (err u110))

;; Minimum stake amounts
(define-constant MIN_PROFILE_STAKE u1000000) ;; 1 STX in microSTX
(define-constant MIN_POST_BOOST u100000)     ;; 0.1 STX in microSTX
(define-constant MIN_ENDORSEMENT_STAKE u500000) ;; 0.5 STX in microSTX

;; Data Variables
(define-data-var next-profile-id uint u1)
(define-data-var next-post-id uint u1)
(define-data-var protocol-fee-rate uint u100) ;; 1% = 100 basis points

;; Profile Data Structure
(define-map profiles
  { profile-id: uint }
  {
    owner: principal,
    username: (string-ascii 50),
    bio: (string-utf8 280),
    avatar-url: (string-ascii 200),
    created-at: uint,
    staked-amount: uint,
    reputation-score: uint,
    follower-count: uint,
    following-count: uint,
    post-count: uint,
    total-endorsements: uint,
    is-active: bool
  }
)

;; Username to Profile ID mapping
(define-map username-to-profile (string-ascii 50) uint)

;; Principal to Profile ID mapping
(define-map principal-to-profile principal uint)

;; Following relationships
(define-map following
  { follower: uint, following: uint }
  { followed-at: uint, is-active: bool }
)

;; Posts data
(define-map posts
  { post-id: uint }
  {
    author: uint,
    content: (string-utf8 500),
    created-at: uint,
    boosted-amount: uint,
    endorsement-count: uint,
    is-active: bool
  }
)

;; Post endorsements
(define-map post-endorsements
  { post-id: uint, endorser: uint }
  { endorsed-at: uint, stake-amount: uint }
)

;; Profile endorsements
(define-map profile-endorsements
  { endorser: uint, endorsed: uint }
  { endorsed-at: uint, stake-amount: uint, message: (string-utf8 140) }
)

;; Staking pools for reputation
(define-map profile-stakes
  { profile-id: uint, staker: principal }
  { amount: uint, staked-at: uint }
)