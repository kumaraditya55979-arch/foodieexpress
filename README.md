# FoodieExpress - Food Delivery App
## Zomato-style Flutter Food Delivery App (3 Apps)

### Apps included:
1. **customer_app** — Customer-facing app (Pizza, Burger, Chowmin ordering)
2. **delivery_app** — Delivery partner app
3. **admin_app** — Admin panel (orders, menu management)

---

## STEP 1: GitHub Secrets Setup

Go to your GitHub repo → Settings → Secrets and variables → Actions
Add these secrets:

| Secret Name | Value |
|---|---|
| `KEYSTORE_BASE64` | Content of `KEYSTORE_SAFE/keystore_base64.txt` |
| `KEYSTORE_PASSWORD` | `FoodApp@2024Secure` |
| `KEY_ALIAS` | `food-app-key` |
| `KEY_PASSWORD` | `FoodApp@2024Secure` |
| `GOOGLE_SERVICES_JSON` | Your Firebase google-services.json (customer) |
| `GOOGLE_SERVICES_JSON_DELIVERY` | Your Firebase google-services.json (delivery) |
| `GOOGLE_SERVICES_JSON_ADMIN` | Your Firebase google-services.json (admin) |

---

## STEP 2: Firebase Setup (FREE)

1. Go to https://console.firebase.google.com
2. Create 3 projects (or use 1 project with different apps):
   - FoodieExpress Customer
   - FoodieExpress Delivery
   - FoodieExpress Admin
3. Add Android app in each with the package names:
   - Customer: `com.foodapp.customer`
   - Delivery: `com.foodapp.delivery`
   - Admin: `com.foodapp.admin`
4. Download `google-services.json` for each
5. Paste content into GitHub Secrets (see above)

### Firebase Services to enable (all FREE tier):
- Authentication → Phone (enable)
- Firestore Database → Create in test mode
- Storage → Default bucket
- Cloud Messaging (FCM) → automatic

---

## STEP 3: Push to GitHub & Get APKs

```bash
git init
git add .
git commit -m "Initial commit - FoodieExpress"
git remote add origin https://github.com/YOUR_USERNAME/foodie-express.git
git push -u origin main
```

After push:
1. Go to GitHub → Actions tab
2. Watch 3 jobs run (each ~8-10 minutes)
3. Click any job → Artifacts section → Download signed APK

---

## Firestore Database Structure

```
/restaurants/{id}
  name, imageUrl, cuisineType, rating, deliveryTime, deliveryFee, address, lat, lng, isOpen, offers

/food_items/{id}
  name, description, price, category, isVeg, imageUrl, restaurantId, isBestseller, rating

/orders/{id}
  userId, restaurantId, items[], subtotal, deliveryFee, total, statusIndex, deliveryAddress
  statusIndex: 0=placed 1=confirmed 2=preparing 3=onTheWay 4=delivered 5=cancelled

/users/{uid}
  name, phone, addresses[], walletBalance

/delivery_boys/{uid}
  name, phone, isOnline, lat, lng
```

---

## Add Sample Data to Firestore

Run this in Firebase Console → Firestore → Add document:

**Collection: restaurants**
```json
{
  "name": "Pizza Palace",
  "cuisineType": "Pizza, Italian",
  "rating": 4.5,
  "ratingCount": 120,
  "deliveryTime": "25-35 min",
  "deliveryFee": 0,
  "minOrder": 199,
  "address": "Sector 15, Noida",
  "lat": 28.5921,
  "lng": 77.3410,
  "isOpen": true,
  "offers": ["50% off up to Rs 100"],
  "imageUrl": "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=600",
  "ownerId": "admin"
}
```

**Collection: food_items**
```json
{
  "name": "Margherita Pizza",
  "description": "Classic tomato sauce, mozzarella, fresh basil",
  "price": 299,
  "category": "Pizza",
  "isVeg": true,
  "isBestseller": true,
  "rating": 4.6,
  "ratingCount": 89,
  "restaurantId": "YOUR_RESTAURANT_ID",
  "imageUrl": "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=400"
}
```

---

## FREE Services Used

| Service | Free Limit | Use |
|---|---|---|
| Firebase Auth | Unlimited | OTP login |
| Firestore | 1GB + 50K reads/day | Database |
| Firebase Storage | 5GB | Images |
| FCM Notifications | Unlimited | Push alerts |
| Google Maps | $200 credit/month | Live tracking |
| GitHub Actions | 2000 min/month | APK builds |

---

## Upgrade Later (when users come)

| Service | Cost | When |
|---|---|---|
| Firebase Blaze | Pay as you go | 100+ daily users |
| Razorpay | 2% per txn | When adding UPI/card |
| Play Store | Rs 2000 one time | When publishing |
| Google Maps | $7/1000 requests | After $200 credit ends |

---

## Firestore Data — EK DUKAAN SETUP

### Collection: shop_info → Document: main
```json
{
  "name": "Meri Dukaan",
  "rating": 4.5,
  "deliveryTime": "20-30 min",
  "deliveryFee": 30,
  "isOpen": true,
  "address": "123, Main Road, Delhi"
}
```

### Collection: food_items
```json
{
  "name": "Margherita Pizza",
  "description": "Cheese aur tomato sauce ke saath",
  "price": 199,
  "category": "Pizza",
  "isVeg": true,
  "isBestseller": true,
  "rating": 4.6,
  "imageUrl": "https://images.unsplash.com/photo-1574071318508?w=400"
}
```

Categories jo use karo:
- Pizza
- Burger  
- Chowmin
- Biryani
- Snacks
- Desserts

### Firebase mein Google Sign In enable karo:
Authentication → Sign-in method → Google → Enable → Save
