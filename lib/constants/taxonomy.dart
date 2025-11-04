class Taxonomy {
  // Extensive e-commerce categories and subcategories
  static const List<String> categories = [
    'Grocery',
    'Electronics',
    'Fashion',
    'Beauty & Personal Care',
    'Home & Kitchen',
    'Appliances',
    'Mobiles & Tablets',
    'Computers & Accessories',
    'TV & Entertainment',
    'Sports & Outdoors',
    'Automotive',
    'Toys & Baby',
    'Books & Media',
    'Health & Wellness',
    'Pet Supplies',
    'Stationery & Office',
    'Jewellery',
    'Footwear',
    'Bags & Luggage',
  ];

  static const Map<String, List<String>> subcategories = {
    'Grocery': [
      'Atta & Rice',
      'Pulses & Grains',
      'Oils & Ghee',
      'Spices & Masalas',
      'Snacks & Biscuits',
      'Beverages',
      'Dairy & Bakery',
      'Fruits & Vegetables',
      'Instant Foods',
      'Organic',
    ],
    'Electronics': [
      'Mobiles',
      'Laptops',
      'Accessories',
      'Audio',
      'Cameras',
      'Storage Devices',
      'Gaming',
    ],
    'Fashion': [
      'Men',
      'Women',
      'Kids',
      'Innerwear',
      'Ethnic Wear',
      'Winter Wear',
      'Watches',
      'Accessories',
    ],
    'Beauty & Personal Care': [
      'Skin Care',
      'Hair Care',
      'Fragrances',
      'Bath & Body',
      'Makeup',
      'Men Grooming',
      'Oral Care',
    ],
    'Home & Kitchen': [
      'Cookware',
      'Kitchen Storage',
      'Cleaning Supplies',
      'Home Décor',
      'Lighting',
      'Tools & Hardware',
      'Furniture',
    ],
    'Appliances': [
      'Refrigerators',
      'Washing Machines',
      'Air Conditioners',
      'Kitchen Appliances',
      'Vacuum Cleaners',
      'Water Purifiers',
      'Geysers',
    ],
    'Mobiles & Tablets': [
      'Smartphones',
      'Tablets',
      'Power Banks',
      'Chargers & Cables',
      'Cases & Covers',
    ],
    'Computers & Accessories': [
      'Desktops',
      'Monitors',
      'Keyboards & Mice',
      'Printers & Ink',
      'Networking',
      'Components',
    ],
    'TV & Entertainment': [
      'Televisions',
      'Streaming Devices',
      'Speakers & Soundbars',
      'Projectors',
      'Set Top Boxes',
    ],
    'Sports & Outdoors': [
      'Fitness Equipment',
      'Sportswear',
      'Cycling',
      'Camping & Hiking',
      'Cricket',
      'Football',
    ],
    'Automotive': [
      'Car Accessories',
      'Bike Accessories',
      'Lubricants & Fluids',
      'Helmets & Riding Gear',
      'Tyres & Parts',
    ],
    'Toys & Baby': [
      'Diapers & Wipes',
      'Baby Care',
      'Toys',
      'Baby Clothing',
      'Strollers & Gear',
    ],
    'Books & Media': [
      'Books',
      'Magazines',
      'Music',
      'Movies & TV Shows',
      'eBooks',
    ],
    'Health & Wellness': [
      'Supplements',
      'Medical Devices',
      'Personal Care',
      'Ayurveda & Herbal',
    ],
    'Pet Supplies': [
      'Dog Supplies',
      'Cat Supplies',
      'Fish & Aquatic',
      'Bird Supplies',
    ],
    'Stationery & Office': [
      'Notebooks',
      'Pens & Pencils',
      'Art Supplies',
      'Office Supplies',
      'Paper & Files',
    ],
    'Jewellery': [
      'Gold Jewellery',
      'Silver Jewellery',
      'Fashion Jewellery',
      'Bangles & Bracelets',
      'Necklaces & Chains',
    ],
    'Footwear': [
      'Men Footwear',
      'Women Footwear',
      'Kids Footwear',
      'Sports Shoes',
      'Sandals & Floaters',
    ],
    'Bags & Luggage': [
      'Backpacks',
      'Handbags',
      'Trolleys',
      'Wallets & Belts',
      'Travel Accessories',
    ],
  };

  // Units (global lists; can be filtered per category if needed)
  static const List<String> weightUnits = [
    '50g','100g','200g','250g','400g','500g','750g','1kg','2kg','5kg'
  ];
  static const List<String> volumeUnits = [
    '100ml','200ml','250ml','500ml','750ml','1L','1.5L','2L','5L'
  ];
  static const List<String> countUnits = [
    '1pc','2pc','3pc','5pc','6pc','8pc','10pc','12pc','24pc'
  ];

  // Variant attributes per broad category (suggested defaults)
  static const Map<String, List<String>> variantAttributes = {
    'Grocery': ['Flavor','Grade'],
    'Electronics': ['Color','Storage','RAM','Size'],
    'Fashion': ['Color','Size','Pattern'],
    'Beauty & Personal Care': ['Shade','Fragrance'],
    'Home & Kitchen': ['Color','Capacity','Material'],
    'Appliances': ['Color','Capacity','Energy Rating'],
    'Mobiles & Tablets': ['Color','Storage','RAM'],
    'Computers & Accessories': ['Color','Storage','RAM'],
    'TV & Entertainment': ['Size','Resolution'],
    'Sports & Outdoors': ['Size','Color'],
    'Automotive': ['Color','Size','Type'],
    'Toys & Baby': ['Color','Age Group'],
    'Books & Media': ['Language','Format'],
    'Health & Wellness': ['Flavor','Dosage'],
    'Pet Supplies': ['Flavor','Size'],
    'Stationery & Office': ['Color','Size'],
    'Jewellery': ['Color','Material'],
    'Footwear': ['Color','Size'],
    'Bags & Luggage': ['Color','Size'],
  };
}
