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

;; Post boost stakes
(define-map post-boosts
  { post-id: uint, booster: principal }
  { amount: uint, boosted-at: uint }
)

;; Read-only functions

;; Get profile by ID
(define-read-only (get-profile (profile-id uint))
  (map-get? profiles { profile-id: profile-id })
)

;; Get profile by username
(define-read-only (get-profile-by-username (username (string-ascii 50)))
  (match (map-get? username-to-profile username)
    profile-id (get-profile profile-id)
    none
  )
)

;; Get profile by principal
(define-read-only (get-profile-by-principal (user principal))
  (match (map-get? principal-to-profile user)
    profile-id (get-profile profile-id)
    none
  )
)

;; Check if username is available
(define-read-only (is-username-available (username (string-ascii 50)))
  (is-none (map-get? username-to-profile username))
)

;; Check if following
(define-read-only (is-following (follower-id uint) (following-id uint))
  (match (map-get? following { follower: follower-id, following: following-id })
    follow-data (get is-active follow-data)
    false
  )
)

;; Get post
(define-read-only (get-post (post-id uint))
  (map-get? posts { post-id: post-id })
)

;; Get next profile ID
(define-read-only (get-next-profile-id)
  (var-get next-profile-id)
)

;; Get next post ID
(define-read-only (get-next-post-id)
  (var-get next-post-id)
)

;; Calculate reputation score
(define-read-only (calculate-reputation-score (profile-id uint))
  (match (get-profile profile-id)
    profile-data
    (let
      (
        (base-score (get staked-amount profile-data))
        (follower-bonus (* (get follower-count profile-data) u1000))
        (endorsement-bonus (* (get total-endorsements profile-data) u2000))
        (post-bonus (* (get post-count profile-data) u500))
      )
      (+ base-score (+ follower-bonus (+ endorsement-bonus post-bonus)))
    )
    u0
  )
)

;; Public functions

;; Create user profile
(define-public (create-profile 
  (username (string-ascii 50))
  (bio (string-utf8 280))
  (avatar-url (string-ascii 200))
)
  (let
    (
      (profile-id (var-get next-profile-id))
      (current-block stacks-block-height)
    )
    ;; Check if profile already exists for this principal
    (asserts! (is-none (map-get? principal-to-profile tx-sender)) ERR_PROFILE_EXISTS)
    
    ;; Check if username is available
    (asserts! (is-username-available username) ERR_PROFILE_EXISTS)
    
    ;; Check minimum stake
    (asserts! (>= (stx-get-balance tx-sender) MIN_PROFILE_STAKE) ERR_INSUFFICIENT_FUNDS)
    
    ;; Transfer stake to contract
    (try! (stx-transfer? MIN_PROFILE_STAKE tx-sender (as-contract tx-sender)))
    
    ;; Create profile
    (map-set profiles
      { profile-id: profile-id }
      {
        owner: tx-sender,
        username: username,
        bio: bio,
        avatar-url: avatar-url,
        created-at: current-block,
        staked-amount: MIN_PROFILE_STAKE,
        reputation-score: MIN_PROFILE_STAKE,
        follower-count: u0,
        following-count: u0,
        post-count: u0,
        total-endorsements: u0,
        is-active: true
      }
    )
    
    ;; Set mappings
    (map-set username-to-profile username profile-id)
    (map-set principal-to-profile tx-sender profile-id)
    (map-set profile-stakes 
      { profile-id: profile-id, staker: tx-sender }
      { amount: MIN_PROFILE_STAKE, staked-at: current-block }
    )
    
    ;; Increment next profile ID
    (var-set next-profile-id (+ profile-id u1))
    
    (ok profile-id)
  )
)

;; Follow a user
(define-public (follow-user (following-id uint))
  (let
    (
      (follower-profile-result (map-get? principal-to-profile tx-sender))
      (current-block stacks-block-height)
    )
    ;; Get follower profile ID
    (match follower-profile-result
      follower-id
      (begin
        ;; Check if not following self
        (asserts! (not (is-eq follower-id following-id)) ERR_SELF_FOLLOW)
        
        ;; Check if target profile exists
        (asserts! (is-some (get-profile following-id)) ERR_PROFILE_NOT_FOUND)
        
        ;; Check if not already following
        (asserts! (not (is-following follower-id following-id)) ERR_ALREADY_FOLLOWING)
        
        ;; Create follow relationship
        (map-set following
          { follower: follower-id, following: following-id }
          { followed-at: current-block, is-active: true }
        )
        
        ;; Update follower count for followed user
        (match (get-profile following-id)
          following-profile
          (map-set profiles
            { profile-id: following-id }
            (merge following-profile { follower-count: (+ (get follower-count following-profile) u1) })
          )
          false
        )
        
        ;; Update following count for follower
        (match (get-profile follower-id)
          follower-profile
          (map-set profiles
            { profile-id: follower-id }
            (merge follower-profile { following-count: (+ (get following-count follower-profile) u1) })
          )
          false
        )
        
        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Unfollow a user
(define-public (unfollow-user (following-id uint))
  (let
    (
      (follower-profile-result (map-get? principal-to-profile tx-sender))
    )
    ;; Get follower profile ID
    (match follower-profile-result
      follower-id
      (begin
        ;; Check if currently following
        (asserts! (is-following follower-id following-id) ERR_NOT_FOLLOWING)
        
        ;; Remove follow relationship
        (map-delete following { follower: follower-id, following: following-id })
        
        ;; Update follower count for unfollowed user
        (match (get-profile following-id)
          following-profile
          (map-set profiles
            { profile-id: following-id }
            (merge following-profile { follower-count: (- (get follower-count following-profile) u1) })
          )
          false
        )
        
        ;; Update following count for follower
        (match (get-profile follower-id)
          follower-profile
          (map-set profiles
            { profile-id: follower-id }
            (merge follower-profile { following-count: (- (get following-count follower-profile) u1) })
          )
          false
        )
        
        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Create a post
(define-public (create-post (content (string-utf8 500)))
  (let
    (
      (author-profile-result (map-get? principal-to-profile tx-sender))
      (post-id (var-get next-post-id))
      (current-block stacks-block-height)
    )
    ;; Get author profile ID
    (match author-profile-result
      author-id
      (begin
        ;; Create post
        (map-set posts
          { post-id: post-id }
          {
            author: author-id,
            content: content,
            created-at: current-block,
            boosted-amount: u0,
            endorsement-count: u0,
            is-active: true
          }
        )
        
        ;; Update author's post count
        (match (get-profile author-id)
          author-profile
          (map-set profiles
            { profile-id: author-id }
            (merge author-profile { post-count: (+ (get post-count author-profile) u1) })
          )
          false
        )
        
        ;; Increment next post ID
        (var-set next-post-id (+ post-id u1))
        
        (ok post-id)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Boost a post with STX
(define-public (boost-post (post-id uint) (amount uint))
  (let
    (
      (current-block stacks-block-height)
    )
    ;; Check minimum boost amount
    (asserts! (>= amount MIN_POST_BOOST) ERR_INVALID_AMOUNT)
    
    ;; Check if post exists
    (asserts! (is-some (get-post post-id)) ERR_POST_NOT_FOUND)
    
    ;; Check if user has sufficient balance
    (asserts! (>= (stx-get-balance tx-sender) amount) ERR_INSUFFICIENT_FUNDS)
    
    ;; Transfer STX to contract
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Record boost
    (map-set post-boosts
      { post-id: post-id, booster: tx-sender }
      { amount: amount, boosted-at: current-block }
    )
    
    ;; Update post boosted amount
    (match (get-post post-id)
      post-data
      (map-set posts
        { post-id: post-id }
        (merge post-data { boosted-amount: (+ (get boosted-amount post-data) amount) })
      )
      false
    )
    
    (ok true)
  )
)