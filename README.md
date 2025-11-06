# Inclass15 – Firebase Inventory Management App  
**Author:** Safia Shaik  


## 📱 Overview
The **Inclass15 Firebase Inventory Management App** is a cross-platform Flutter application that enables users to manage inventory items in real time using **Firebase Firestore** and **Firebase Authentication**.

The app supports **Admin** and **Viewer** roles, provides **role-based access control**, and introduces two major enhancements:
1. **Advanced Search & Filtering**  
2. **Data Insights Dashboard**

This project demonstrates secure authentication, database integration, and interactive data visualization with a clean, responsive UI.


## 🚀 Features Summary

### 🔐 Firebase Authentication
- Login and Sign-Up using **Email/Password**.
- Optional **Admin Secret** for admin account creation.
- User roles are stored in Firestore:
  ```json
  {
    "email": "user@example.com",
    "role": "admin" or "viewer",
    "createdAt": "timestamp"
  }

### 🔑 Admin Account Creation
During sign-up, users can optionally enter an **Admin Secret** to create an admin-level account.  
For testing and grading purposes, the admin secret is:
**ADMIN_SECRET_123**

- If left blank → user is created as a **Viewer** (read-only access).  
- If entered → user is created as an **Admin** (full CRUD access).


### Inventory Management (CRUD)
- Add, edit, delete, and view inventory items.
- Real-time synchronization with Firestore.
- Each item includes:
1. Name
2. Category
3. Quantity
4. Price

### 🔍 Advanced Search & Filtering (✨ Enhancement #1)

- Keyword search bar filters items dynamically as you type.
- Category dropdown allows users to quickly view specific item types.
- Fully reactive filtering with no reloads required.

### 📊 Data Insights Dashboard (✨ Enhancement #2)

- Accessed via the “📊 Dashboard” button in the top-right corner.
- Displays real-time statistics based on Firestore data:
- Total number of items
- Total inventory value
- Number of out-of-stock items
- Uses cards and charts for quick, visual insights.