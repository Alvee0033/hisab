# 💰 Hisab - Expense Tracker

A beautiful, modern expense tracker application built with Flutter. Hisab helps you manage your finances with an intuitive interface and powerful features.

## ✨ Features

- **📊 Smart Dashboard**: Real-time balance overview with income/expense breakdown
- **📈 Weekly Analytics**: Visualize your spending patterns with interactive charts
- **🏷️ Smart Categorization**: Track expenses by multiple categories with color-coded indicators
- **🌍 Multi-Language Support**: English and Bengali localization
- **🎨 Beautiful Themes**: Light and Dark mode with seamless switching
- **💾 Offline First**: All data stored locally using Hive - no internet required
- **📝 Transaction Management**: Add, view, filter, and delete transactions easily
- **⏰ Billing Cycle Control**: Set custom billing cycles for monthly budget management
- **💸 Auto Salary**: Automatically add recurring salary entries
- **🔐 Clean Architecture**: MVVM pattern with Provider for maintainable code

## 🎯 Key Screens

- **Dashboard**: Overview of balance, weekly spending, and recent transactions
- **Transactions**: Browse all transactions with filtering by week/month/all time
- **Reports**: Detailed expense breakdown by category
- **Settings**: Customize app preferences, billing cycle, and auto salary

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Android SDK or iOS SDK (depending on your platform)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/hisab.git
   cd hisab
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Code** (Hive Adapters & Localization):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   *Note: Run this whenever you modify models annotated with @HiveType.*

4. **Run the App**:
   ```bash
   flutter run
   ```

5. **Build Release APK**:
   ```bash
   flutter build apk --release
   ```

## 📁 Project Structure

```
lib/
├── models/              # Data models (Transaction, Category, User)
├── viewmodels/          # State management (Providers)
├── views/               # UI Screens and Widgets
│   ├── dashboard_screen.dart
│   ├── transactions_screen.dart
│   ├── reports_screen.dart
│   ├── settings_screen.dart
│   └── widgets/
├── services/            # Data services (Hive)
├── utils/               # Constants, Theme, Colors
├── l10n/                # Localization (.arb files)
└── main.dart            # App entry point
```

## 🛠️ Technologies Used

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Local Database**: Hive
- **Charts**: FL Chart
- **Localization**: Flutter Localization
- **UI Components**: Material Design
- **Icons**: Material Icons + Google Fonts

## 📦 Key Dependencies

```yaml
provider: ^6.0.5          # State management
hive: ^2.2.3              # Local database
hive_flutter: ^1.1.0      # Flutter integration
fl_chart: ^0.63.0         # Charts and graphs
google_fonts: ^5.1.0      # Typography
intl: ^0.19.0             # Internationalization
uuid: ^3.0.7              # Unique IDs
```

## 🎨 UI/UX Highlights

- **Color-Coded Transactions**: Income in green, expenses in red for quick visual identification
- **Interactive Charts**: Smooth animations and gradient visualizations
- **Responsive Design**: Works seamlessly on phones and tablets
- **Dark Mode Support**: Eye-friendly dark theme option
- **Bilingual Interface**: Seamless English/Bengali switching

## 💡 Usage Tips

1. **First-Time Setup**: Complete the setup wizard to configure your billing cycle and auto-salary
2. **Billing Cycles**: Customize your monthly reset date for accurate budget tracking
3. **Filtering**: Use the filter dropdown to view transactions by week, month, or all time
4. **Categories**: Organize expenses into predefined categories for better insights
5. **Backup**: Consider exporting your data regularly for safety

## 🔄 Billing Cycle Feature

Set a custom start date for your monthly billing cycle (e.g., 15th to 14th). The app calculates all totals based on this custom period rather than the calendar month, perfect for salary-based budgeting.

## 🐛 Known Issues & Limitations

- Currently Android-focused; iOS requires additional setup
- No cloud sync (all data is local)
- No recurring transactions (except auto-salary)

## 🚀 Future Enhancements

- Cloud synchronization
- Budget goals and alerts
- Receipt image capture
- PDF expense reports
- Multi-currency support
- Investment tracking

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Contributing

We welcome contributions! Please feel free to submit a Pull Request.

## 📧 Support

For issues, feature requests, or questions, please open an issue on GitHub.

## 🙏 Acknowledgments

- Built with Flutter and love ❤️
- Icons and design inspired by modern financial apps

---

**Made with ❤️ by Alvee Khan**

