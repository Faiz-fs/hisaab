/// Categories offered in the app (order = picker order).
const List<String> kCategories = [
  'Food Delivery',
  'Quick Commerce',
  'Groceries',
  'Dining',
  'Cafe',
  'Shopping',
  'Transport',
  'Fuel',
  'Travel',
  'Utilities',
  'Bills & Recharge',
  'Entertainment',
  'Health',
  'Education',
  'Rent & EMI',
  'Social',
  'Transfers',
  'Other',
];

/// Built-in merchant → category rules.
///
/// Keys are lowercase words matched against the payee (UPI handle or name).
/// Short keys (≤ 4 chars) must match a whole word; longer keys match a word prefix.
const Map<String, String> kMerchantRules = {
  // Quick Commerce
  'blinkit': 'Quick Commerce', 'zepto': 'Quick Commerce', 'instamart': 'Quick Commerce',
  'bigbasket': 'Quick Commerce', 'dunzo': 'Quick Commerce', 'jiomart': 'Quick Commerce',

  // Groceries
  'dmart': 'Groceries', 'reliance fresh': 'Groceries', 'more retail': 'Groceries',
  'grocer': 'Groceries', 'supermarket': 'Groceries', 'kirana': 'Groceries',

  // Food Delivery
  'swiggy': 'Food Delivery', 'zomato': 'Food Delivery', 'eatsure': 'Food Delivery',
  'magicpin': 'Food Delivery',

  // Dining / Cafe
  'restaurant': 'Dining', 'dominos': 'Dining', 'pizza': 'Dining', 'kfc': 'Dining',
  'mcdonald': 'Dining', 'burger': 'Dining', 'biryani': 'Dining', 'hotel': 'Dining',
  'dhaba': 'Dining', 'bakery': 'Dining',
  'cafe': 'Cafe', 'starbucks': 'Cafe', 'chaayos': 'Cafe', 'coffee': 'Cafe',
  'third wave': 'Cafe', 'tea': 'Cafe', 'chai': 'Cafe',

  // Shopping
  'amazon': 'Shopping', 'flipkart': 'Shopping', 'myntra': 'Shopping', 'ajio': 'Shopping',
  'meesho': 'Shopping', 'nykaa': 'Shopping', 'decathlon': 'Shopping', 'croma': 'Shopping',
  'lenskart': 'Shopping', 'ikea': 'Shopping', 'tatacliq': 'Shopping',

  // Transport
  'uber': 'Transport', 'ola': 'Transport', 'rapido': 'Transport', 'metro': 'Transport',
  'namma': 'Transport', 'fastag': 'Transport', 'parking': 'Transport', 'bmtc': 'Transport',
  'redbus': 'Travel', 'irctc': 'Travel', 'makemytrip': 'Travel', 'goibibo': 'Travel',
  'indigo': 'Travel', 'airindia': 'Travel', 'cleartrip': 'Travel', 'yatra': 'Travel',
  'oyo': 'Travel',

  // Fuel
  'petrol': 'Fuel', 'diesel': 'Fuel', 'hpcl': 'Fuel', 'bpcl': 'Fuel', 'iocl': 'Fuel',
  'indianoil': 'Fuel', 'bharat petroleum': 'Fuel', 'shell': 'Fuel', 'fuel': 'Fuel',

  // Utilities / Bills
  'airtel': 'Bills & Recharge', 'jio': 'Bills & Recharge', 'bsnl': 'Bills & Recharge',
  'vodafone': 'Bills & Recharge', 'vi': 'Bills & Recharge', 'recharge': 'Bills & Recharge',
  'tatasky': 'Bills & Recharge', 'dth': 'Bills & Recharge', 'act fibernet': 'Bills & Recharge',
  'electricity': 'Utilities', 'bescom': 'Utilities', 'water': 'Utilities',
  'gas': 'Utilities', 'broadband': 'Utilities', 'bbps': 'Bills & Recharge',

  // Entertainment
  'netflix': 'Entertainment', 'hotstar': 'Entertainment', 'spotify': 'Entertainment',
  'prime': 'Entertainment', 'youtube': 'Entertainment', 'bookmyshow': 'Entertainment',
  'pvr': 'Entertainment', 'inox': 'Entertainment', 'sonyliv': 'Entertainment',
  'steam': 'Entertainment', 'google play': 'Entertainment', 'apple': 'Entertainment',

  // Health
  'pharmacy': 'Health', 'apollo': 'Health', 'medplus': 'Health', 'pharmeasy': 'Health',
  '1mg': 'Health', 'hospital': 'Health', 'clinic': 'Health', 'diagnostic': 'Health',
  'netmeds': 'Health', 'cult': 'Health', 'gym': 'Health',

  // Education
  'udemy': 'Education', 'coursera': 'Education', 'byju': 'Education', 'unacademy': 'Education',
  'school': 'Education', 'college': 'Education',

  // Rent & EMI
  'rent': 'Rent & EMI', 'emi': 'Rent & EMI', 'nobroker': 'Rent & EMI', 'loan': 'Rent & EMI',
  'insurance': 'Rent & EMI', 'lic': 'Rent & EMI',
};
