# 🧺 Grocery Bucket List & Invoice Management App (iOS)

## 📱 Overview

This repository contains a **sample iOS application** for Grocery Bucket List and Smart Invoice Management.

The app helps users:
- Create and manage grocery/shopping bucket lists
- Scan receipts using AI and generate structured invoices
- Compare invoices for price tracking
- Search across buckets and invoices
- Manage profile and settings

> ⚠️ This is a **sample codebase** for architecture and structure demonstration only.

---

## ✨ Features

### 🧺 Bucket Lists
- Create shopping lists
- Add / edit / delete items
- Organized bucket-based structure

### 🧾 Invoice System
- AI-based receipt scanning
- Extract item name, quantity, price
- Store structured invoices

### ⚖️ Invoice Comparison
- Compare multiple invoices
- Track price differences
- Analyze spending patterns

### 🔎 Global Search
- Search across buckets and invoices
- Fast and unified search system

### ⚙️ Settings
- Profile management
- Notification settings
- Invite friends
- Terms & Conditions
- Logout

---

## 🏗 Architecture & Project Structure

The project follows a **modular MVC-based architecture** with clear separation of concerns.

### 📂 Folder Structure

The codebase is organized as follows:
├── API Manager
│   ├── End points
│   ├── Models
│   └── Services
├── Constants
├── Controllers
│   ├── Authentications
│   ├── Buckets
│   │   ├── BucketManager
│   │   └── cells
│   ├── Dashboard
│   │   └── cells
│   ├── Invoices
│   │   └── cells
│   ├── Notifications
│   └── Settings
│       ├── Notifications
│       └── cells
├── Helper
│   └── AppManager
├── Storyboards
│   └── Base.lproj
└── fonts


---

## 📂 Folder Responsibilities

### 🌐 API Manager
Handles all networking and backend communication:
- API endpoints
- Request/Response models
- Service layer (API calls & parsing)

---

### 🎮 Controllers

Responsible for UI and feature logic:

- **Authentications**
  - Login, Register, Forgot Password

- **Buckets**
  - Bucket creation and management
  - Item cells and UI handling

- **Dashboard**
  - Main home screen
  - Dashboard UI cells

- **Invoices**
  - Receipt scanning flow
  - Invoice listing and cells

- **Notifications**
  - Notification handling logic

- **Settings**
  - Profile settings
  - Notification settings
  - UI cells for settings

---

### 🧠 Helper
- AppManager for global state handling
- Utility functions and shared logic

---

### 📱 Storyboards
- Base storyboard setup
- UI navigation structure

---

### 🔤 Fonts
- Custom font resources

---

## 🧠 Architecture Principles

- Modular structure
- Separation of concerns
- Reusable components
- Scalable architecture
- Clean MVC implementation

---

## 🚀 Purpose of This Project

This project demonstrates:
- Real-world iOS project structure
- Clean and scalable architecture
- Feature-based modular design
- API + UI separation
- Production-level coding practices (sample)

---

## ⚠️ Note

This is a **sample project only**, used for:
- Architecture reference
- Code structure demonstration
- Portfolio and client showcase

Not production-ready.

---

## 👨‍💻 Summary

A Grocery Bucket List & Invoice Management iOS app featuring:
- AI receipt scanning
- Bucket list management
- Invoice comparison system
- Global search functionality
- Clean modular architecture design

--
