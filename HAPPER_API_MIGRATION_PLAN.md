# Happer App — API Migration Plan
**Total Duration:** 45 Days + 7 Days Grace Period  
**Start Date:** Once APIs are received from backend  
**End Date:** 45 days from start  
**Grace Period:** 7 days after end date  
**Architecture Target:** Clean Architecture (Data / Domain / Presentation layers)

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Current API Inventory](#2-current-api-inventory)
3. [Clean Architecture Structure](#3-clean-architecture-structure)
4. [45-Day Migration Timeline](#4-45-day-migration-timeline)
5. [Module-by-Module Breakdown](#5-module-by-module-breakdown)
6. [All API Endpoints Reference](#6-all-api-endpoints-reference)
7. [Authentication Flow](#7-authentication-flow)
8. [Risk & Grace Period Plan](#8-risk--grace-period-plan)

---

## 1. Project Overview

The Happer App is a Flutter application that connects fashion creators with their audience. It includes:
- Social feed (selfies/outfits discovery)
- Creator profiles & brand shops
- Shopping cart & Stripe payments
- Wishlist, promo codes, won products
- Push notifications & real-time updates
- Google & Apple Sign-In (iOS + Android)

**Base URL (Production):** `https://newapi.happer.fr/api`  
**Auth Method:** JWT tokens  
**Token Refresh:** Automatic on session expiry

---

## 2. Current API Inventory

### Summary

| Category | # Endpoints |
|----------|-------------|
| Authentication | 13 |
| Creator / Feed | 14 |
| Profile | 18 |
| Cart | 6 |
| Payments (Stripe) | 3 |
| Camera / Upload | 5 |
| Notifications | 3 |
| Wishlist | 3 |
| Promo / Credits | 3 |
| Categories | 2 |
| Won Products | 1 |
| **TOTAL** | **~76 endpoints** |

---

## 3. Clean Architecture Structure

The app will be reorganized into three clear layers per feature:

```
Presentation Layer   →   UI screens and state management
Domain Layer         →   Business logic and use cases
Data Layer           →   API calls and data models
```

### Folder Organization

```
core/
  network/           → Central HTTP client with interceptors
  error/             → Typed error and failure handling
  utils/             → Token management, helpers

features/
  auth/              → Login, register, OTP, Google, Apple
  feed/              → Discover selfies, creator feed, search
  cart/              → Cart, addresses, checkout
  profile/           → Profile, follow, password, deletion
  wishlist/          → Wishlist management
  notifications/     → Push and in-app notifications
  camera/            → Selfie upload, categories
  payments/          → Stripe integration
```

Each feature contains:
- `data/`         — remote data sources, API models, repository implementations
- `domain/`       — entities, repository interfaces, use cases
- `presentation/` — screens, providers/controllers

---

## 4. 45-Day Migration Timeline

### PHASE 1 — Foundation (Days 1–7)
**Goal:** Set up clean architecture skeleton and central network layer

| Day | Task |
|-----|------|
| 1–2 | Build central HTTP client with unified auth header and auto token refresh |
| 3 | Build typed error and failure handling |
| 4 | Build token manager — single source of truth for auth tokens |
| 5 | Define all endpoint constants in one place |
| 6 | Write tests for token handling and interceptor logic |
| 7 | Review and buffer |

**Deliverable:** Core network layer ready. No screen changes yet.

---

### PHASE 2 — Authentication Module (Days 8–14)
**Goal:** Migrate all auth APIs to clean architecture

| Day | Task |
|-----|------|
| 8–9 | Build auth remote data source — all 13 endpoints with new response structure |
| 10 | Build auth repository interface and implementation |
| 11 | Build use cases: Login, Register, Refresh Token |
| 12 | Update Login and Signup screens |
| 13 | Update Google Sign-In and Apple Sign-In (iOS & Android) |
| 14 | Test all auth flows on real devices |

**Deliverable:** Login / Register / Apple / Google all working with new API.

---

### PHASE 3 — Feed & Creator Module (Days 15–21)
**Goal:** Migrate creator and discover feed APIs

| Day | Task |
|-----|------|
| 15–16 | Build feed remote data source — selfies, likes, discover, search |
| 17 | Build feed repository and use cases |
| 18 | Update Creator feed screen and Discover feed screen |
| 19 | Update Selfie details screen and Product details screen |
| 20 | Update Brand details screen with pagination |
| 21 | Test feed, likes, and product details on device |

**Deliverable:** Entire feed section on new API.

---

### PHASE 4 — Cart & Payments Module (Days 22–27)
**Goal:** Migrate cart, address, and Stripe payment APIs

| Day | Task |
|-----|------|
| 22–23 | Build cart remote data source — add, get, delete, addresses |
| 24 | Build Stripe data source — customer, ephemeral key, payment intent |
| 25 | Build cart repository and use cases |
| 26 | Update Cart screen, Address screen, Checkout screen |
| 27 | Test add to cart, remove, and full checkout on device |

**Deliverable:** Cart and payment fully on new API.

---

### PHASE 5 — Profile Module (Days 28–35)
**Goal:** Migrate all profile-related APIs (largest module — 18 endpoints)

| Day | Task |
|-----|------|
| 28–29 | Build profile remote data source — profile CRUD, follow/unfollow, password change |
| 30 | Build notifications data source — fetch, mark read, delete |
| 31 | Build wishlist data source and won products data source |
| 32 | Build promo code and credits data source |
| 33 | Build profile picture upload data source |
| 34 | Update all profile screens (grid, edit, password, delete account, notification settings) |
| 35 | Test all profile flows |

**Deliverable:** Profile section fully migrated.

---

### PHASE 6 — Camera & Notifications Module (Days 36–39)
**Goal:** Migrate selfie upload and push notification APIs

| Day | Task |
|-----|------|
| 36 | Build camera data source — selfie upload, check can post, categories |
| 37 | Update camera upload screen |
| 38 | Update notifications screen with new response structure |
| 39 | Test camera upload and notifications end-to-end |

**Deliverable:** Camera and notifications on new API.

---

### PHASE 7 — Integration Testing & Polish (Days 40–45)
**Goal:** Full app test, fix regressions, remove old code

| Day | Task |
|-----|------|
| 40 | Full app walkthrough — auth → feed → cart → checkout |
| 41 | Full app walkthrough — profile → wishlist → notifications → camera |
| 42 | Fix any regressions found |
| 43 | Remove all old service layers |
| 44 | Remove old URL references, clean up dead code |
| 45 | Final release build for iOS and Android |

**Deliverable:** Production-ready build on clean architecture.

---

### GRACE PERIOD (Days 46–52)
**Goal:** Bug fixes only — no new features

| Day | Task |
|-----|------|
| 46–47 | Monitor production for crashes and errors |
| 48–49 | Fix any critical issues found post-launch |
| 50 | Edge case regression fixes |
| 51 | Final QA pass |
| 52 | Submit to App Store and Play Store |

---

## 5. Module-by-Module Breakdown

### AUTH Module — 13 Endpoints

| # | Method | Endpoint | Purpose |
|---|--------|----------|---------|
| 1 | POST | `/users/login` | Email and password login |
| 2 | POST | `/users/register` | New user registration |
| 3 | POST | `/users/email_verification` | Send OTP to email |
| 4 | POST | `/users/verify?id={id}` | Verify OTP code |
| 5 | POST | `/users/token` | Refresh access token |
| 6 | POST | `/users/loginGoogle` | Google OAuth login |
| 7 | POST | `/users/loginApple` | Apple OAuth login |
| 8 | GET | `/users/profile/{userId}` | Get user profile |
| 9 | GET | `/users/email_verification?email={email}` | Check email verified |
| 10 | POST | `/users/get_password_code` | Request password reset code |
| 11 | PUT | `/users/reset_password` | Reset password with code |
| 12 | POST | `/callbacks/sign_in_with_apple` | Apple callback for Android |
| 13 | GET | `/happer_var` | Fetch app configuration |

---

### FEED Module — 14 Endpoints

| # | Method | Endpoint | Purpose |
|---|--------|----------|---------|
| 1 | GET | `/selfies?page={page}` | Fetch discover selfies |
| 2 | GET | `/selfies/{selfieId}` | Get selfie details |
| 3 | GET | `/selfies/influencer?category={id}&page={p}&validated=VALIDATED` | Creator feed by category |
| 4 | GET | `/selfies/influencer?page={page}&searchTerm={term}` | Search creator selfies |
| 5 | GET | `/selfies/me` | My selfies |
| 6 | GET | `/selfies/user/{userId}` | Selfies by user |
| 7 | GET | `/selfies/profile/{userId}?page={page}` | Profile selfies paginated |
| 8 | GET | `/selfies/liked` | Liked selfies |
| 9 | POST | `/likes` | Like a selfie |
| 10 | DELETE | `/likes/user` | Unlike a selfie |
| 11 | GET | `/items/{itemId}` | Get item details |
| 12 | GET | `/products/{productId}` | Get product details |
| 13 | GET | `/items/brand-items?brand_id={id}` | Get brand items |
| 14 | GET | `/items/brand-items?brand_id={id}&page={p}&limit={l}` | Brand items paginated |

---

### CART Module — 6 Endpoints

| # | Method | Endpoint | Purpose |
|---|--------|----------|---------|
| 1 | POST | `/carts/add` | Add items to cart |
| 2 | GET | `/carts/me` | Get current cart |
| 3 | DELETE | `/carts/item` | Remove item from cart |
| 4 | GET | `/carts/me/all` | Get all user orders / purchases |
| 5 | PUT | `/carts/addresses` | Update billing and shipping address |
| 6 | POST | `/carts/stripe` | Create Stripe payment intent |

---

### PROFILE Module — 18 Endpoints

| # | Method | Endpoint | Purpose |
|---|--------|----------|---------|
| 1 | GET | `/users/me` | Get current user data |
| 2 | PUT | `/users/{userId}` | Update profile |
| 3 | POST | `/users/upload` | Upload profile picture |
| 4 | GET | `/users/picture/delete` | Delete profile picture |
| 5 | PUT | `/users/modify_password` | Change password |
| 6 | POST | `/users/logout` | Logout |
| 7 | GET | `/users/{userId}/delete_procedure` | Get account deletion code |
| 8 | DELETE | `/users/{userId}` | Delete account |
| 9 | GET | `/follows/user/{userId}` | Get follower count |
| 10 | POST | `/follows` | Follow a user |
| 11 | DELETE | `/follows/user` | Unfollow a user |
| 12 | GET | `/notifications/user` | Get notifications |
| 13 | PUT | `/notifications/{id}/read` | Mark notification as read |
| 14 | DELETE | `/notifications/user` | Delete notification |
| 15 | GET | `/options/me` | Get notification settings |
| 16 | PUT | `/options/me` | Update notification settings |
| 17 | DELETE | `/selfies/users/{selfieId}` | Delete my selfie |
| 18 | GET | `/wishes/me` | Get wishlist |

---

### PAYMENTS Module — 3 Endpoints

| # | Method | Endpoint | Purpose |
|---|--------|----------|---------|
| 1 | POST | `/carts/stripe/create-customer` | Create Stripe customer |
| 2 | POST | `/carts/stripe/ephemeral-keys` | Create ephemeral key |
| 3 | POST | `/carts/stripe` | Create payment intent |

---

### CAMERA Module — 5 Endpoints

| # | Method | Endpoint | Purpose |
|---|--------|----------|---------|
| 1 | GET | `/selfies/check` | Check if user can post |
| 2 | GET | `/categories` | Get all categories |
| 3 | GET | `/item_users/me` | Get user's linked items |
| 4 | POST | `/selfies` | Upload selfie |
| 5 | GET | `/users/me` | Get user data |

---

### PROMO / CREDITS Module — 3 Endpoints

| # | Method | Endpoint | Purpose |
|---|--------|----------|---------|
| 1 | GET | `/promo_codes/me` | Get user promo code info |
| 2 | PUT | `/promo_codes/me` | Apply or verify promo code |
| 3 | GET | `/products/win` | Get won products |

---

### NOTIFICATIONS Module — 3 Endpoints

| # | Method | Endpoint | Purpose |
|---|--------|----------|---------|
| 1 | POST | `/notifications` | Send notification |
| 2 | GET | `/notifications/user` | Get user notifications |
| 3 | GET | `/notifications/{id}` | Get notification by ID |

---

### CATEGORIES Module — 2 Endpoints

| # | Method | Endpoint | Purpose |
|---|--------|----------|---------|
| 1 | GET | `/api/categories` | Fetch all categories |
| 2 | GET | `/api/categories/{id}` | Get category by ID |

---

## 6. All API Endpoints Reference

Complete flat list of all 76 unique endpoints:

```
AUTH (13)
  POST   /users/login
  POST   /users/register
  POST   /users/email_verification
  POST   /users/verify?id={id}
  POST   /users/token
  POST   /users/loginGoogle
  POST   /users/loginApple
  GET    /users/profile/{userId}
  GET    /users/email_verification?email={email}
  POST   /users/get_password_code
  PUT    /users/reset_password
  POST   /callbacks/sign_in_with_apple
  GET    /happer_var

FEED (14)
  GET    /selfies?page={page}
  GET    /selfies/{selfieId}
  GET    /selfies/influencer?category={id}&page={p}&validated=VALIDATED
  GET    /selfies/influencer?page={page}&searchTerm={term}
  GET    /selfies/me
  GET    /selfies/user/{userId}
  GET    /selfies/profile/{userId}?page={page}
  GET    /selfies/liked
  POST   /likes
  DELETE /likes/user
  GET    /items/{itemId}
  GET    /products/{productId}
  GET    /items/brand-items?brand_id={id}
  GET    /items/brand-items?brand_id={id}&page={p}&limit={l}

CART (6)
  POST   /carts/add
  GET    /carts/me
  DELETE /carts/item
  GET    /carts/me/all
  PUT    /carts/addresses
  POST   /carts/stripe

PROFILE (18)
  GET    /users/me
  PUT    /users/{userId}
  POST   /users/upload
  GET    /users/picture/delete
  PUT    /users/modify_password
  POST   /users/logout
  GET    /users/{userId}/delete_procedure
  DELETE /users/{userId}
  GET    /follows/user/{userId}
  POST   /follows
  DELETE /follows/user
  GET    /notifications/user
  PUT    /notifications/{id}/read
  DELETE /notifications/user
  GET    /options/me
  PUT    /options/me
  DELETE /selfies/users/{selfieId}
  GET    /wishes/me

PAYMENTS (3)
  POST   /carts/stripe/create-customer
  POST   /carts/stripe/ephemeral-keys
  POST   /carts/stripe

CAMERA (5)
  GET    /selfies/check
  GET    /categories
  GET    /item_users/me
  POST   /selfies
  GET    /users/me

PROMO/CREDITS (3)
  GET    /promo_codes/me
  PUT    /promo_codes/me
  GET    /products/win

NOTIFICATIONS (3)
  POST   /notifications
  GET    /notifications/user
  GET    /notifications/{id}

CATEGORIES (2)
  GET    /api/categories
  GET    /api/categories/{id}
```

---

## 7. Authentication Flow

```
User taps Login
     │
     ▼
POST /users/login → { id, token, refresh_token }
     │
     ▼
Save tokens securely on device
     │
     ▼
Every API call → send token in Authorization header
     │
   Session expired?
     │
    YES ──▶ POST /users/token with refresh token
     │              │
     NO           Success? ──YES──▶ Save new token → Retry request
     │              │
     ▼             NO
  Continue    Clear all tokens → Navigate to Login screen
```

---

## 8. Risk & Grace Period Plan

### High-Risk Areas

| Area | Risk | Mitigation |
|------|------|-----------|
| Apple Sign-In Android | Complex redirect flow | Test on real Android device only |
| Stripe Payments | API version must match backend | Confirm version with backend team before integration |
| Selfie Upload | Large file multipart encoding | Test with various image sizes |
| Token Refresh | Concurrent requests may trigger double refresh | Use a lock/queue mechanism |
| Cart Badge Count | May not update on tab switch | Refresh cart count on every tab navigation |

### Grace Period Rules
- No new features during grace period
- Only fix: crashes, auth failures, payment failures
- Each fix requires a new build submission

### Rollback Plan
- Keep current working code on a separate branch
- All new migration work on a dedicated branch
- If critical failure occurs after release: revert to previous build and investigate

---

## Daily Checklist Template

For each module migration, complete before marking done:

- [ ] Remote data source written with new response structure
- [ ] Repository interface defined
- [ ] Repository implementation done
- [ ] Use cases written
- [ ] Screens updated
- [ ] Tested on iOS device
- [ ] Tested on Android device
- [ ] Old service layer removed
- [ ] No old API URL references remaining

---

*Document prepared: April 2026*  
*App: Happer — Flutter (iOS + Android)*  
*Backend: Node.js Express — `https://newapi.happer.fr`*
