CREATE DATABASE IF NOT EXISTS ECommerceDB_1;
USE ECommerceDB_1;

CREATE TABLE USER(
    UserID INT AUTO_INCREMENT PRIMARY KEY,
    Username VARCHAR(50) NOT NULL,
    Password VARCHAR(200) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Phone VARCHAR(20)
);

CREATE TABLE CUSTOMER(
    UserID INT PRIMARY KEY,
    Name VARCHAR(100),
    Gender CHAR(1),
    BirthDate DATE,
    FOREIGN KEY (UserID) REFERENCES USER(UserID)
);

CREATE TABLE SELLER(
    UserID INT PRIMARY KEY,
    ShopName VARCHAR(100),
    ShopDescription VARCHAR(300),
    ShopLocation VARCHAR(200),
    Followers INT DEFAULT 0,
    SellerRating DECIMAL(3,2),
    FOREIGN KEY (UserID) REFERENCES USER(UserID)
);

CREATE TABLE ADDRESS(
    UserID INT,
    FullAddress VARCHAR(255),
    City VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(50),
    AddressLabel VARCHAR(100),
    PRIMARY KEY(UserID, FullAddress),
    FOREIGN KEY (UserID) REFERENCES USER(UserID)
);

CREATE TABLE CATEGORY (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL,
    CategoryDescription VARCHAR(300),
    ParentCategoryID INT,
    FOREIGN KEY (ParentCategoryID) REFERENCES CATEGORY(CategoryID)
);

CREATE TABLE CAMPAIGN(
    CampaignID INT AUTO_INCREMENT PRIMARY KEY,
    CampaignName VARCHAR(100) NOT NULL,
    CampaignDescription VARCHAR(300),
    DiscountRate DECIMAL(4,2),
    StartDate DATE,
    EndDate DATE
);

CREATE TABLE LOCALCAMPAIGN(
    CampaignID INT PRIMARY KEY,
    Region VARCHAR(50),
    LocalLanguageSupport VARCHAR(50),
    PaymentIncentives VARCHAR(200),
    RegionalLogisticsConstraints VARCHAR(200),
    FOREIGN KEY (CampaignID) REFERENCES CAMPAIGN(CampaignID)
);

CREATE TABLE GLOBALCAMPAIGN(
    CampaignID INT PRIMARY KEY,
    Regions VARCHAR(200),
    LanguageSupport VARCHAR(100),
    GlobalPricingPolicies VARCHAR(200),
    CrossBorderEligibility VARCHAR(100),
    GlobalPaymentIncentives VARCHAR(200),
    FOREIGN KEY (CampaignID) REFERENCES CAMPAIGN(CampaignID)
);

CREATE TABLE TOPSELLINGPRODUCT(
    TopSellingID INT AUTO_INCREMENT PRIMARY KEY,
    Period VARCHAR(50),
    TotalSold INT,
    StartDate DATE,
    EndDate DATE,
    RevenueGenerated DECIMAL(10,2)
);

CREATE TABLE PRODUCT (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,  -- <-- Burada AUTO_INCREMENT ekliyoruz
    ProductName VARCHAR(100) NOT NULL,
    ProductDescription VARCHAR(300),
    StockLevel INT,
    ProductImages VARCHAR(300),
    AverageRating DECIMAL(3,2),
    CampaignID INT,
    CategoryID INT,
    TopSellingID INT,
    FOREIGN KEY (CampaignID) REFERENCES CAMPAIGN(CampaignID),
    FOREIGN KEY (CategoryID) REFERENCES CATEGORY(CategoryID),
    FOREIGN KEY (TopSellingID) REFERENCES TOPSELLINGPRODUCT(TopSellingID)
);

CREATE TABLE RETURNS(
    ProductID INT,
    ReturnCode INT,
    ReturnReason VARCHAR(200),
    ReturnDate DATE,
    ReturnStatus VARCHAR(50),
    RefundAmount DECIMAL(10,2),
    PRIMARY KEY (ProductID, ReturnCode),
    FOREIGN KEY (ProductID) 
        REFERENCES PRODUCT(ProductID)
        ON DELETE CASCADE
);
CREATE TABLE ORDERHISTORY(
    UserID INT,
    CreatedDate DATE,
    LastUpdated DATE,
    OrderQuantity INT,
    PRIMARY KEY(UserID, CreatedDate), -- Weak Entity'nin birincil anahtarı
    FOREIGN KEY (UserID) REFERENCES CUSTOMER(UserID)
);

CREATE TABLE ORDERS(
    UserID INT,
    OrderDate DATE,
    OrderStatus VARCHAR(50),
    TotalAmount DECIMAL(10,2),
    HistoryCreatedDate DATE, -- OrderHistory ile ilişki için tarih
    PRIMARY KEY (UserID, OrderDate), -- Siparişlerin birincil anahtarı
    FOREIGN KEY (UserID) REFERENCES CUSTOMER(UserID),
    FOREIGN KEY (UserID, HistoryCreatedDate)
        REFERENCES ORDERHISTORY(UserID, CreatedDate)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE ORDERITEM(
    UserID INT,
    OrderDate DATE,
    OrderItemCode INT,
    ProductID INT,
    PRIMARY KEY (UserID, OrderDate, OrderItemCode),
    FOREIGN KEY (UserID, OrderDate)
        REFERENCES ORDERS(UserID, OrderDate)
        ON DELETE CASCADE  -- sipariş silindiğinde orderitem silinsin
        ON UPDATE CASCADE,
    FOREIGN KEY (ProductID)
        REFERENCES PRODUCT(ProductID)
        ON DELETE CASCADE   -- ürün silinince orderitem da silinsin
);


CREATE TABLE CARRIER(
    CarrierID INT AUTO_INCREMENT PRIMARY KEY,
    CarrierName VARCHAR(100) NOT NULL,
    ContactInfo VARCHAR(100),
    ServiceArea VARCHAR(100),
    AverageDeliveryTime INT
);

CREATE TABLE LOGISTICS(
    UserID INT,
    OrderDate DATE,
    TrackingNumber VARCHAR(50),
    Status VARCHAR(50),
    DeliveryAddress VARCHAR(255),
    ShippingMethod VARCHAR(50),
    CarrierID INT,
    PRIMARY KEY(UserID, OrderDate, TrackingNumber),
    FOREIGN KEY (UserID, OrderDate) REFERENCES ORDERS(UserID, OrderDate)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (CarrierID) REFERENCES CARRIER(CarrierID)
);

CREATE TABLE PAYMENT(
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    PaymentMethod VARCHAR(50),    -- e.g., "DebitCard", "CreditCard", "GiftCard"
    Amount DECIMAL(10,2),
    UserID INT,
    OrderUserID INT,
    OrderDate DATE,
    FOREIGN KEY (UserID) REFERENCES USER(UserID),
    FOREIGN KEY (OrderUserID, OrderDate) REFERENCES ORDERS(UserID, OrderDate)
);

CREATE TABLE DEBITCARD(
    TransactionID INT PRIMARY KEY,
    BankName VARCHAR(100),
    CardNumber VARCHAR(16),
    ExpiryDate DATE,
    FOREIGN KEY (TransactionID) REFERENCES PAYMENT(TransactionID)
);

-- CREDITCARD TABLE (SUBCLASS)
CREATE TABLE CREDITCARD(
    TransactionID INT PRIMARY KEY,
    BankName VARCHAR(100),
    CardNumber VARCHAR(16),
    ExpiryDate DATE,
    CreditLimit DECIMAL(10,2),
    FOREIGN KEY (TransactionID) REFERENCES PAYMENT(TransactionID)
);

-- GIFTCARD TABLE (SUBCLASS)
CREATE TABLE GIFTCARD(
    TransactionID INT PRIMARY KEY,
    GiftCardCode VARCHAR(50),
    Balance DECIMAL(10,2),
    ExpiryDate DATE,
    FOREIGN KEY (TransactionID) REFERENCES PAYMENT(TransactionID)
);

CREATE TABLE CART(
    CartID INT AUTO_INCREMENT PRIMARY KEY,
    TotalAmount DECIMAL(10,2),
    Quantity INT,
    CustomerID INT UNIQUE,       -- 1-1 Relationship
    FOREIGN KEY (CustomerID) REFERENCES USER(UserID)
);

CREATE TABLE CART_PRODUCT(
    CartID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY(CartID, ProductID),
    FOREIGN KEY (CartID) REFERENCES CART(CartID),
    FOREIGN KEY (ProductID)
        REFERENCES PRODUCT(ProductID)
        ON DELETE CASCADE
);


CREATE TABLE REVIEW(
    UserID INT,
    ProductID INT,
    ReviewID INT,
    Rating INT,
    ReviewText VARCHAR(500),
    PRIMARY KEY (UserID, ProductID, ReviewID),
    FOREIGN KEY (UserID) REFERENCES CUSTOMER(UserID),
    FOREIGN KEY (ProductID)
        REFERENCES PRODUCT(ProductID)
        ON DELETE CASCADE
);


CREATE TABLE FAVORITESHOPPINGLIST(
    UserID INT,
    ShoppingListID INT,
    Quantity INT,
    PRIMARY KEY(UserID, ShoppingListID),
    FOREIGN KEY (UserID) REFERENCES CUSTOMER(UserID)
);

CREATE TABLE FAVORITESHOPPINGLIST_PRODUCT(
    UserID INT,
    ShoppingListID INT,
    ProductID INT,
    PRIMARY KEY(UserID, ShoppingListID, ProductID),
    FOREIGN KEY (UserID, ShoppingListID)
        REFERENCES FAVORITESHOPPINGLIST(UserID, ShoppingListID),
    FOREIGN KEY (ProductID)
        REFERENCES PRODUCT(ProductID)
        ON DELETE CASCADE
);

CREATE TABLE WISHLIST(
    UserID INT,
    ListDate DATE,
    Title VARCHAR(100),
    PRIMARY KEY(UserID, ListDate),
    FOREIGN KEY (UserID) REFERENCES CUSTOMER(UserID)
);

CREATE TABLE WISHLIST_PRODUCT(
    UserID INT,
    ListDate DATE,
    ProductID INT,
    PRIMARY KEY(UserID, ListDate, ProductID),
    FOREIGN KEY (UserID, ListDate)
        REFERENCES WISHLIST(UserID, ListDate),
    FOREIGN KEY (ProductID)
        REFERENCES PRODUCT(ProductID)
        ON DELETE CASCADE
);
CREATE TABLE SUBSCRIPTION(
    SubscriptionID INT AUTO_INCREMENT PRIMARY KEY,
    SubType VARCHAR(50),
    StartDate DATE,
    EndDate DATE,
    Status VARCHAR(50),
    UserID INT UNIQUE,
    FOREIGN KEY (UserID) REFERENCES USER(UserID)
);

CREATE TABLE CUSTOMERSERVICE(
    ServiceID INT AUTO_INCREMENT PRIMARY KEY,
    RequestType VARCHAR(100),
    RequestDescription VARCHAR(300),
    RequestDate DATE,
    Status VARCHAR(50),
    UserID INT,
    FOREIGN KEY (UserID) REFERENCES USER(UserID)
);

CREATE TABLE NOTIFICATION(
    NotificationID INT AUTO_INCREMENT PRIMARY KEY,
    NotificationDate DATE,
    MessageText VARCHAR(300),
    ReadStatus BOOLEAN,
    UserID INT,
    FOREIGN KEY (UserID) REFERENCES USER(UserID)
);

CREATE TABLE TAXATION(
    TaxID INT AUTO_INCREMENT PRIMARY KEY,
    Region VARCHAR(50),
    TaxType VARCHAR(50),
    TaxRate DECIMAL(5,2)
);

CREATE TABLE PRODUCT_TAXATION(
    ProductID INT,
    TaxID INT,
    PRIMARY KEY(ProductID, TaxID),
    FOREIGN KEY (ProductID)
        REFERENCES PRODUCT(ProductID)
        ON DELETE CASCADE,
    FOREIGN KEY (TaxID)
        REFERENCES TAXATION(TaxID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE CUSTOMER_SELLER(
    CustomerID INT,
    SellerID INT,
    FollowDate DATE,
    PRIMARY KEY(CustomerID, SellerID),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(UserID),
    FOREIGN KEY (SellerID) REFERENCES SELLER(UserID)
);

CREATE TABLE PRODUCT_SELLER(
    ProductID INT,
    SellerID INT,
    Price DECIMAL(10,2),
    PRIMARY KEY(ProductID, SellerID),
    FOREIGN KEY (ProductID)
        REFERENCES PRODUCT(ProductID)
        ON DELETE CASCADE,
    FOREIGN KEY (SellerID)
        REFERENCES SELLER(UserID)
);