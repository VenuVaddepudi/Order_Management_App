# 📦 Order Management System – iOS App

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-13.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-12%2B-blue.svg)](https://developer.apple.com/xcode/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## 📖 Overview

The **Order Management System** is an iOS app that helps users efficiently manage their orders. It allows users to create, view, edit, and delete orders with details such as:

- Order number  
- Due date  
- Customer info  
- Order total  

---

## 🧠 Architecture

Follows the **MVC (Model-View-Controller)** pattern:

- **Models:** Core Data entities (`User`, `Order`)  
- **Views:** Custom UI like `OrderTableViewCell`  
- **Controllers:** Manage UI & business logic  
- **Helpers:** `CoreDataManager`, `UserManager`, `Validator`  

---

## 🧩 Core Components

### 📄 Data Models

**User Entity**
- `username: String`
- `password: String`
- `rememberMe: Bool`
- `orders: [Order]` (relationship)

**Order Entity**
- `orderNumber: String`
- `dueDate: Date`
- `buyerName: String`
- `address: String`
- `phone: String`
- `total: Double`
- `user: User` (relationship)

### 🎮 View Controllers

| View Controller         | Purpose                          |
|-------------------------|----------------------------------|
| `LoginViewController`   | Authenticates users              |
| `RegisterViewController`| User registration & validation   |
| `OrdersViewController`  | Displays, adds, edits, deletes orders |
| `OrderDetailViewController` | Form to add/edit orders     |

### 🧰 Helper Classes

- `UserManager` – Session management  
- `CoreDataManager` – CRUD operations for Core Data  
- `Validator` – Input validation  

### 🖼 Custom Views

- `OrderTableViewCell` – Displays an order card with delete/edit actions  

---

## 🔄 User Flow

### 🔐 Authentication

- App launches and checks login state
- If logged in → Goes to **Orders**
- If not → Goes to **Login**
- Supports "Remember Me" using `UserDefaults`
- Registration creates a new user record

### 📋 Order Management

Users can:
- View a list of orders  
- Add new orders  
- Edit existing orders  
- Delete orders with confirmation  
- All persisted using Core Data  

---

## 🎨 UI Design

### 🧭 Navigation
- `UINavigationController` stack  
- Large titles, back buttons

### 📱 Order List
- Card-style `UITableView`  
- Total order count in header  
- Swipe actions for edit/delete  

### 📝 Order Detail
- Input form with validation  
- Date picker for due date  
- Save and Cancel actions  

---

## 💾 Data Persistence

- **Core Data** for storing users and orders  
- **UserDefaults** for session tracking  
- No external API dependencies  

---

## ⚠️ Error Handling

- All inputs are validated  
- Shows user-friendly error messages  
- Confirmation prompts before deletions  
- Displays success messages after actions  

---

## 🚀 Future Enhancements

- 🔍 Search & filter orders  
- ✅ Order status field  
- 👥 Customer management module  
- 📊 Reporting and charts  
- 🔄 Offline mode sync  
- 🌐 Multi-language support  

---

## 📸 Screenshots

> _(Add your app screenshots here when ready!)_

| Login | Orders | Order Detail |
|------|--------|--------------|
| ![Login](screenshots/login.png) | ![Orders](screenshots/orders.png) | ![Detail](screenshots/detail.png) |

---

## 📚 Technical Specs

- iOS **13.0+**  
- Swift **5+**  
- Xcode **12+**  
- UIKit (Programmatic UI)  
- Core Data  

---



