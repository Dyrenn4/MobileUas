# App Flowchart — Retail Inventory

Diagram berikut menggambarkan alur navigasi dan aliran data pada aplikasi.

```mermaid
flowchart TD
  subgraph App
    Entry[App Entry\n`main.dart`]
    Entry --> MainScreen[`MainScreen`]
  end

  subgraph Navigation[TABS]
    MainScreen --> Home[`HomeScreen`]
    MainScreen --> Products[`ProductsScreen`]
    MainScreen --> Reports[`ReportsScreen`]
    MainScreen --> Settings[`SettingsScreen`]
    MainScreen -->|FAB / Add| AddProductModal[`AddProductScreen (modal)`]
  end

  %% Home interactions
  Home -->|Quick action: Add product| AddProductModal
  Home -->|Quick action: Update stock| UpdateStockModal[`UpdateStockScreen (modal)`]
  Home -->|View all products| Products

  %% Products interactions
  Products -->|Edit product (open modal)| AddProductModal

  %% UpdateStock interactions
  UpdateStockModal -->|updateStock()| Inventory[InventoryProvider]

  %% Add / Edit / Delete product
  AddProductModal -->|addProduct() / updateProduct() / deleteProduct()| Inventory

  %% Reports reads history
  Reports -->|reads stockHistory| Inventory

  %% Providers & models
  subgraph Providers
    Inventory
    Settings[SettingsProvider]
  end

  subgraph Models
    ProductModel[`Product model`]
    StockHistoryModel[`StockHistory model`]
  end

  %% Data flows
  Inventory --> ProductModel
  Inventory --> StockHistoryModel
  Settings -->|theme / language / prefs| MainScreen
  Settings -->|theme / language / prefs| Home
  Settings -->|theme / language / prefs| Products
  Settings -->|theme / language / prefs| Reports
  Settings -->|theme / language / prefs| Settings

  %% Screens read providers
  Home -->|reads/writes| Inventory
  Products -->|reads/writes| Inventory
  AddProductModal -->|reads/writes| Inventory
  Reports -->|reads| Inventory
  Settings -->|reads/writes| Settings

  classDef provider fill:#fef3c7,stroke:#f59e0b
  class Inventory,Settings provider

  classDef model fill:#eef2ff,stroke:#6366f1
  class ProductModel,StockHistoryModel model

  %% Legend
  subgraph Legend
    L1[Blue boxes = Screens]
    L2[Yellow boxes = Providers]
    L3[Light blue = Models]
  end
``` 

Notes:
- Modal flows: `AddProductScreen` dan `UpdateStockScreen` dibuka sebagai modal bottom sheet dari `MainScreen` (FAB / quick actions / edit).
- Semua perubahan data (add/update/delete stock) men-trigger method di `InventoryProvider`, yang mengubah `Product` dan menambah `StockHistory`.
- `SettingsProvider` mengatur theme, language, dan preferensi yang dibaca oleh semua screens.

Jika Anda mau, saya bisa:
- Mengekspor diagram ini jadi PNG/SVG dan menaruhnya ke repo.
- Memodifikasi diagram untuk menampilkan lebih banyak detail (mis. method names, contoh sequence).
