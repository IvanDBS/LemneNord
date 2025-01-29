# LemneNord Bot

A Telegram bot built with Ruby for managing orders and interactions with LemneNord services.

## Description

LemneNord Bot is a Telegram bot that helps manage orders, user interactions, and administrative tasks. The bot is built using Ruby and includes features for both users and administrators.

## Features

- User management system
- Shopping cart functionality
- Admin panel with specialized controls
- Order processing and tracking
- Message handling system
- Callback query processing

## Tech Stack

- Ruby
- Telegram Bot API
- SQLite/PostgreSQL (database)
- Rake (task automation)

## Project Structure

## Features

### User Features
- 🌐 Language selection (Russian/Romanian)
- 🛒 Multi-step order creation with product selection
- 📋 Order history tracking
- 📍 Saved addresses and phone numbers
- 💰 Price calculation and order confirmation
- 🔔 Order status notifications

### Admin Features
- 📊 Real-time statistics dashboard
- ⏳ Order management (approve/reject/ignore)
- 📢 Broadcast messages to users
- 📅 Scheduled daily statistics
- 🚨 Health monitoring and alerts
- 🔄 Automated database backups

## Admin Commands

- 📊 Статистика - System statistics
- ⏳ Ожидающие - Pending orders
- ✅ Принятые - Approved orders
- ❌ Отклоненные - Rejected orders
- 📢 Рассылка - Broadcast message
- 📢 Сообщение в канал - Post to channel

## Sequence Diagrams

### Order Flow
```mermaid
sequenceDiagram
    participant Customer
    participant Bot
    participant OrderHandler
    participant Database
    participant Admin

    Customer->>Bot: Start order (/start)
    Bot->>Customer: Show language selection
    Customer->>Bot: Select language
    Bot->>Customer: Display main menu
    Customer->>Bot: Select "New Order"
    Bot->>Customer: Show product categories
    
    rect rgb(200, 220, 250)
        Note right of Customer: Product Selection Process
        Customer->>Bot: Select category
        Bot->>Database: Fetch products
        Database-->>Bot: Return products
        Bot->>Customer: Display products
        Customer->>Bot: Add product to cart
        Bot->>Database: Update cart
    end

    rect rgb(220, 250, 200)
        Note right of Customer: Checkout Process
        Customer->>Bot: Proceed to checkout
        Bot->>Customer: Request contact info
        Customer->>Bot: Provide contact
        Bot->>Customer: Request address
        Customer->>Bot: Provide address
        Bot->>Customer: Confirm order details
    end

    Customer->>Bot: Confirm order
    Bot->>Database: Save order
    Bot->>Admin: Notify new order
    Bot->>Customer: Order confirmation
    
    rect rgb(250, 220, 200)
        Note right of Admin: Admin Processing
        Admin->>Bot: Review order
        Admin->>Bot: Approve/Reject order
        Bot->>Database: Update order status
        Bot->>Customer: Send status notification
    end
```

### Admin Dashboard Flow
```mermaid
sequenceDiagram
    participant Admin
    participant Bot
    participant StatsService
    participant Database

    Admin->>Bot: Request statistics
    Bot->>StatsService: Fetch statistics
    StatsService->>Database: Query orders
    Database-->>StatsService: Return data
    StatsService->>Bot: Process statistics
    Bot->>Admin: Display dashboard

    rect rgb(200, 220, 250)
        Note right of Admin: Daily Operations
        Admin->>Bot: View pending orders
        Bot->>Database: Fetch pending orders
        Database-->>Bot: Return orders
        Bot->>Admin: Display orders list
    end

    rect rgb(220, 250, 200)
        Note right of Admin: Broadcast Message
        Admin->>Bot: Initialize broadcast
        Bot->>Database: Fetch active users
        Database-->>Bot: Return users list
        Admin->>Bot: Send broadcast message
        Bot->>Database: Log broadcast
        Bot->>Database: Send to users
    end
```

These sequence diagrams illustrate:
1. **Order Flow**: Complete customer journey from order initiation to completion
2. **Admin Dashboard**: Administrative operations including statistics and broadcast messaging

## Tech Stack
- **Language**: Ruby
- **Framework**: ActiveRecord (ORM)
- **Database**: SQLite (development), PostgreSQL (production)
- **Telegram Integration**: `telegram-bot-ruby` gem
- **Scheduling**: Rufus-scheduler
- **Caching**: Rails.cache (in-memory)
- **Logging**: Custom logger with rotation

