# Phase 19: Advanced Trading & Economy System
## 取引・経済システム（高度な取引と経済シミュレーション）

## System Overview

Phase 19 implements a comprehensive trading and economy system that simulates a realistic marketplace with:

- **Player-to-Player Marketplace**: Players can list items for sale and purchase from others
- **NPC Merchant System**: Fixed-price traders with specializations and reputation
- **Auction System**: Bidding mechanics with buyout options and automatic resolution
- **Dynamic Pricing**: Supply/demand economics that influence market prices
- **Price Tracking**: Historical price data with trend analysis
- **Transaction History**: Complete audit trail of all economic activity

### Core Architecture

The system uses a **singleton pattern** for two main managers:

1. **TradingEconomySystem**: Manages marketplace, merchants, pricing, and transactions
2. **AuctionSystem**: Manages auctions, bidding, and auction resolution

Both systems use **HashMap-based O(1) lookups** for maximum performance with large datasets.

## Trading Economy System

### Key Classes

#### TradingEconomySystem (Singleton)
Main manager for all trading and economy operations.

**Key Data Structures:**
```
_marketplaceListings    Map<String, MarketplaceListing>  // All player listings
_merchants             Map<String, Merchant>             // 4 predefined merchants
_transactionHistory    Map<String, List<Transaction>>    // Transaction history per player
_priceHistories        Map<String, PriceHistory>         // Historical price data
_supplyDemandData      Map<String, SupplyDemandData>     // Supply/demand ratios
_playerListings        Map<String, List<String>>         // Player's listing IDs
```

#### MarketplaceListing
Represents an item listed for sale on the marketplace.

```dart
class MarketplaceListing {
  final String listingId;        // Unique listing ID
  final String sellerId;         // Player selling the item
  final String itemId;           // Item ID
  final int quantity;            // Quantity for sale
  final int askingPrice;         // Price per unit
  final MarketplaceStatus status;// active, sold, cancelled, expired
  final int createdAt;           // Timestamp in milliseconds
  final int expiresAt;           // Listing expiration
}

enum MarketplaceStatus {
  active,
  sold,
  cancelled,
  expired,
}
```

#### Merchant
Represents an NPC merchant with inventory and pricing.

```dart
class Merchant {
  final String id;               // Merchant ID
  final String name;             // Merchant name
  final String specialty;        // Specialization (magical, weapon, armor, general)
  final MerchantType type;       // Type of merchant
  int level;                     // Merchant level
  int reputation;                // Reputation (0-100)
  double markupRate;             // Markup percentage on items
  int maxInventory;              // Maximum inventory slots
  int currentGold;               // Available gold
  Map<String, int> buyPrices;    // Item ID -> Buy price
  Map<String, int> sellPrices;   // Item ID -> Sell price
}

enum MerchantType {
  general,
  specialist,
  rare,
  blackmarket,
}
```

#### Transaction
Audit trail for all economic activity.

```dart
class Transaction {
  final String id;               // Transaction ID
  final String buyerId;          // Buyer player ID
  final String sellerId;         // Seller player ID
  final String itemId;           // Item ID
  final int quantity;            // Quantity traded
  final int pricePerItem;        // Price per item
  final int totalValue;          // Total transaction value
  final int timestamp;           // Transaction timestamp
  final TransactionType type;    // Type of transaction
}

enum TransactionType {
  marketplace,
  npc_trade,
  player_trade,
  auction,
}
```

#### PriceHistory
Tracks price changes over time for trend analysis.

```dart
class PriceHistory {
  final String itemId;           // Item ID
  final List<int> prices;        // Historical prices
  int minPrice;                  // Minimum price seen
  int maxPrice;                  // Maximum price seen
  double averagePrice;           // Average price
  PriceTrend trend;              // Current trend direction
}

enum PriceTrend {
  rising,
  falling,
  stable,
}
```

#### SupplyDemandData
Tracks supply/demand ratio for dynamic pricing.

```dart
class SupplyDemandData {
  final String itemId;           // Item ID
  double supplyRatio;            // Supply/demand ratio
  double priceMultiplier;        // Price adjustment (0.5 - 2.0)
  int lastUpdated;               // Last update timestamp
}
```

### Core Methods

#### Marketplace Operations

**listItemForSale()**
```dart
bool listItemForSale(
  String sellerId,
  String itemId,
  int quantity,
  int askingPrice,
)
```
- Seller lists items on marketplace
- Creates MarketplaceListing with 7-day expiration
- Adds listing to player's tracking
- Updates supply/demand data

**removeListingFromMarketplace()**
```dart
bool removeListingFromMarketplace(String listingId, String playerId)
```
- Player can remove their own active listings
- Sets status to cancelled
- Updates supply/demand

**buyFromMarketplace()**
```dart
bool buyFromMarketplace(
  String buyerId,
  String itemId,
  int quantity,
  int playerGold,
)
```
- Player purchases from marketplace
- Finds cheapest available listing
- Updates listing status
- Records transaction
- Updates supply/demand ratio

#### Merchant Operations

**buyFromMerchant()**
```dart
bool buyFromMerchant(
  String buyerId,
  String merchantId,
  String itemId,
  int quantity,
  int playerGold,
)
```
- Player buys from NPC merchant
- Price = merchant's sell price × merchant markup rate
- Merchant gains gold, player loses gold
- Records NPC_TRADE transaction

**sellToMerchant()**
```dart
bool sellToMerchant(
  String sellerId,
  String merchantId,
  String itemId,
  int quantity,
)
```
- Player sells to NPC merchant
- Price = merchant's buy price
- Player gains gold, merchant loses gold
- Records NPC_TRADE transaction

#### Player-to-Player Trading

**tradeWithPlayer()**
```dart
bool tradeWithPlayer(
  String playerId1,
  String playerId2,
  String itemId1,
  int quantity1,
  String itemId2,
  int quantity2,
)
```
- Direct item exchange between players
- Records PLAYER_TRADE transaction for both
- Does not affect supply/demand or price

#### Price Management

**getCurrentPrice()**
```dart
int getCurrentPrice(String itemId)
```
- Returns current market price for item
- Calculated as: basePrice × priceMultiplier
- Multiplier ranges from 0.5 to 2.0

**_updateSupplyDemand()**
- Called after marketplace/merchant transactions
- Calculates supply ratio (quantity available / quantity sold)
- Updates price multiplier:
  - Ratio > 1.2: multiplier decreases (lower prices)
  - Ratio < 0.8: multiplier increases (higher prices)
  - Else: multiplier stays same (stable)
- Updates trend:
  - Ratio > 1.2: rising trend
  - Ratio < 0.8: falling trend
  - Else: stable trend

### Merchant System

#### 4 Predefined Merchants

1. **Aria - Magical Specialist**
   - Type: specialist
   - Level: 15
   - Reputation: 75/100
   - Specialty: Magical items, potions, enchantments
   - Markup: 20%

2. **Kai - Weapon Specialist**
   - Type: specialist
   - Level: 20
   - Reputation: 85/100
   - Specialty: Weapons, combat items
   - Markup: 25%

3. **Zephyr - General Merchant**
   - Type: general
   - Level: 18
   - Reputation: 80/100
   - Specialty: General supplies, materials
   - Markup: 15%

4. **Luna - Armor Specialist**
   - Type: specialist
   - Level: 19
   - Reputation: 90/100
   - Specialty: Armor, protective gear
   - Markup: 22%

## Auction System

### Key Classes

#### AuctionSystem (Singleton)
Manages auction creation, bidding, and resolution.

**Key Data Structures:**
```
_auctions              Map<String, Auction>              // All auctions
_auctionBids          Map<String, List<Bid>>             // Bids per auction
_playerAuctions       Map<String, List<String>>          // Auctions seller created
_playerBids           Map<String, List<String>>          // Auctions bidder participated in
_auctionHistory       Map<String, AuctionResult>         // Completed auction results
```

#### Auction
Represents an active or completed auction.

```dart
class Auction {
  final String id;               // Unique auction ID
  final String sellerId;         // Auction creator
  final String itemId;           // Item being auctioned
  final int quantity;            // Quantity available
  final int startingBid;         // Minimum starting bid
  int currentHighBid;            // Current highest bid
  final int? buyoutPrice;        // Optional immediate purchase price
  final int createdAt;           // Auction start time
  final int endsAt;              // Auction end time
  AuctionStatus status;          // active, sold, unsold, cancelled
  String? highestBidderId;       // Current highest bidder
}

enum AuctionStatus {
  active,
  sold,
  unsold,
  cancelled,
}
```

#### Bid
Represents a single bid in an auction.

```dart
class Bid {
  final String id;               // Unique bid ID
  final String auctionId;        // Auction ID
  final String bidderId;         // Player who bid
  final int bidAmount;           // Bid amount
  final int bidTime;             // Timestamp
}
```

#### AuctionResult
Represents the result of a completed auction.

```dart
class AuctionResult {
  final String auctionId;        // Auction ID
  final String sellerId;         // Seller
  final String? winnerId;        // Winning bidder (null if unsold)
  final int finalPrice;          // Final sale price
  final String itemId;           // Item ID
  final int quantity;            // Quantity
  final int endedAt;             // Completion timestamp
  final AuctionResultStatus status; // sold, unsold, cancelled
  final int? commission;         // System commission (5%)
  final int? sellerPayout;       // Amount seller receives
  final bool wasBuyout;          // Whether it was buyout
}

enum AuctionResultStatus {
  sold,
  unsold,
  cancelled,
}
```

### Core Methods

#### Auction Creation and Management

**createAuction()**
```dart
bool createAuction(
  String sellerId,
  String itemId,
  int quantity,
  int startingBid,
  int durationHours,
  int? buyoutPrice,
)
```
- Seller creates new auction
- Duration can be 1-48 hours
- Buyout price is optional
- Returns unique auction ID

**placeBid()**
```dart
bool placeBid(
  String bidderId,
  String auctionId,
  int bidAmount,
  int playerGold,
)
```
- Player places bid on active auction
- Validates:
  - Auction exists and is active
  - Auction not expired
  - Bid meets minimum requirement
  - Player has sufficient gold
- If bid ≥ buyout price: immediately completes auction
- Otherwise: records Bid object

**Minimum Bid Calculation:**
```
If currentHighBid == 0:
  minimumNextBid = startingBid
Else:
  minimumNextBid = currentHighBid + (startingBid / 10)
```

#### Auction Resolution

**checkExpiredAuctions()**
```dart
List<String> checkExpiredAuctions()
```
- Scans all active auctions
- Identifies expired ones (endTime passed)
- Calls _endAuction() for each
- Returns list of expired auction IDs

**_endAuction()**
- Called when auction expires
- If no bidder: status = unsold
- If bidder exists: status = sold
- Calculates commission (5% of final price)
- Calculates seller payout (finalPrice - commission)
- Records AuctionResult

**_executeAuctionBuyout()**
- Called when bid reaches buyout price
- Immediately sets status = sold
- Sets winner to current bidder
- Final price = buyout price
- Calculates commission and payout

#### Auction Queries

**getActiveAuctions()**
- Returns all active, non-expired auctions

**searchAuctionsByItem()**
- Returns all active auctions for specific item

**getPlayerAuctions()**
- Returns all auctions created by a player

**getPlayerBids()**
- Returns all auctions where player has bid

**getAuctionResult()**
- Returns final result of completed auction

## Integration Patterns

### With Inventory System
- When player lists item on marketplace: remove from inventory
- When player buys from marketplace: add to inventory
- When player sells to merchant: remove from inventory
- When player receives auction win: add to inventory

### With Character System
- Merchant reputation affects prices (higher reputation = lower prices)
- Player trading level affects transaction fees
- Achievement tracking for trading milestones

### With Quest System
- Quest rewards can be items to sell for gold
- Some quests require trading with specific merchants
- Auction mechanics can be used for quest item exchanges

## Economic Dynamics

### Price Multiplier Calculation
```
priceMultiplier = 0.5 + (1.5 × (demand / (demand + supply)))
// Ranges from 0.5 to 2.0
// 0.5 = massive surplus (demand:1, supply:3)
// 1.0 = balanced market (demand:1, supply:1)
// 2.0 = massive shortage (demand:3, supply:1)
```

### Trend Analysis
- **Rising Trend**: High demand, low supply (shortages)
  - Price multiplier > 1.2
  - Good time to sell
  - Bad time to buy
- **Falling Trend**: Low demand, high supply (oversupply)
  - Price multiplier < 0.8
  - Bad time to sell
  - Good time to buy
- **Stable Trend**: Balanced supply/demand
  - Price multiplier 0.8 - 1.2
  - Normal market conditions

### Commission System (Auctions)
- 5% commission on all auction sales
- Commission goes to system (money sink)
- Seller payout = finalPrice - commission
- Incentivizes lower prices (more likely to win and earn more)

## Example Usage

### List Item for Sale
```dart
final system = TradingEconomySystem.getInstance();

final success = system.listItemForSale(
  'player_001',
  'iron_sword',
  2,
  150,  // 150 gold per sword
);
```

### Buy from Marketplace
```dart
final success = system.buyFromMarketplace(
  'buyer_001',
  'iron_sword',
  1,
  5000,  // 5000 gold available
);
```

### Create Auction
```dart
final auctionSystem = AuctionSystem.getInstance();

final success = auctionSystem.createAuction(
  'seller_001',
  'rare_artifact',
  1,
  500,    // Starting bid: 500 gold
  24,     // Duration: 24 hours
  1500,   // Buyout price: 1500 gold
);
```

### Place Bid
```dart
final success = auctionSystem.placeBid(
  'bidder_001',
  'auction_123',
  600,   // Bid amount
  5000,  // Available gold
);
```

## Performance Characteristics

### Time Complexity
- Create listing: O(1)
- Remove listing: O(1)
- Buy from marketplace: O(n) where n = listings for item
- Buy from merchant: O(1)
- Get current price: O(1)
- Create auction: O(1)
- Place bid: O(1)
- Check expired auctions: O(a) where a = active auctions
- Get player transactions: O(1)

### Space Complexity
- O(m) for marketplace listings
- O(a) for auctions and bids
- O(t) for transaction history
- O(p) for price histories
- Overall: O(m + a + t + p)

## Quality Metrics

### System Coverage
- ✅ Marketplace with 7-day listings
- ✅ 4 predefined merchants with specializations
- ✅ Auction system with bidding and buyout
- ✅ Dynamic pricing with supply/demand
- ✅ Transaction history for audit trail
- ✅ Price trend analysis
- ✅ Commission system for economy balancing

### Test Scenarios
1. **Marketplace Flow**: List → Browse → Purchase → Completion
2. **Auction Flow**: Create → Bid → Expire → Resolve
3. **Buyout Mechanics**: Create with buyout → Bid at/above buyout → Immediate completion
4. **Merchant Trading**: Buy → Sell → Reputation effects
5. **Price Dynamics**: Oversupply → Falling trend → Price decrease
6. **Transaction Audit**: Track all trades across all channels

## Expansion Patterns

### Adding New Merchants
1. Define new merchant in initialize()
2. Set specialization and type
3. Set buy/sell prices for items
4. Add reputation and markup rate

### Adding Dynamic Events
1. Market crashes: Force price multiplier reduction
2. Market booms: Force price multiplier increase
3. Merchant reputation changes: Affect markup rates
4. Item scarcity: Adjust baseline availability

### Advanced Features (Phase 20+)
- Tax system on transactions
- Market regulations and restrictions
- Seasonal price changes
- NPC merchant stock updates
- Player shop/stall rental
- Commodity futures trading
- Market manipulation detection
- Price fixing penalties

## Integration with Other Systems

### Combat & Loot System
- Defeated enemies drop items that can be sold
- Rare equipment appears in auctions
- Auction winners get combat advantage

### Quests & Missions
- Quest rewards include sellable items
- Merchants issue trading challenges
- Complete trades for gold rewards

### Character Progression
- Trading skill increases with transactions
- High trading skill = better prices
- Merchant reputation affects negotiations

## Testing Examples

See `lib/examples/trading_economy_example.dart` for:
- 5-tab Flutter UI demonstration
- Marketplace browsing and purchasing
- Auction creation and bidding
- Merchant interaction examples
- Price analysis visualization
- Transaction history tracking
