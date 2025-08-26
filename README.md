# General Store App

A comprehensive Flutter application for a General Store with separate interfaces for customers, workers, and administrators. Built with modern design principles and responsive layouts for both mobile and web platforms.

## 🌟 Features

### ✅ Customer Features (Fully Implemented)
- **Onboarding**: 3-slide introduction to the app with smooth navigation
- **5-Tab Dashboard**: Home, Categories, Cart, Orders, Profile
- **Product Browsing**: Grid/list view with advanced search and filters
- **Product Details**: Image gallery with swipe navigation, descriptions, and features
- **Shopping Cart**: Full cart management with quantity controls and checkout
- **Checkout**: Payment options (Online/Cash on Pickup) with form validation
- **Order Tracking**: Real-time status updates with timeline visualization
- **Notifications**: Badge system and notification center
- **Profile Management**: Complete user profile with settings and preferences

### ✅ Worker Features (Fully Implemented)
- **4-Tab Dashboard**: Overview, Orders, Inventory, Profile
- **Live Orders**: Real-time order feed with status management
- **Order Management**: Complete order lifecycle from received to pickup
- **Inventory Management**: Stock level monitoring and updates
- **Performance Metrics**: Quick stats and productivity insights
- **Profile & Settings**: Worker-specific configuration options

### ✅ Admin Features (Fully Implemented)
- **5-Tab Dashboard**: Analytics, Inventory, Users, Reports, Settings
- **Advanced Analytics**: Interactive charts with FL Chart integration
- **Inventory Management**: Full CRUD operations with search and filtering
- **User Management**: Complete customer and worker account management
- **Excel Import/Export**: File picker integration for bulk operations
- **Real-time Metrics**: Sales trends, performance KPIs, and business insights
- **System Settings**: Comprehensive admin configuration options

## 🎨 Design System

### Color Palette
- **Primary Green**: #28A745
- **Secondary Yellow**: #FFC107
- **Background White**: #FFFFFF
- **Supporting Colors**: Success, Warning, Error, Info variants

### Typography
- **Font Family**: Poppins
- **Hierarchical Text**: H1, H2, H3, Body, Caption styles
- **Responsive Design**: Mobile-first approach

### UI Components
- **Custom Buttons**: Primary, Secondary, Floating Action Buttons
- **Cards**: Product Cards, Order Cards, Analytics Cards
- **Forms**: Consistent input styling and validation
- **Navigation**: Bottom navigation and app bars

## 📱 Screens Overview

### Authentication & Onboarding
- Splash/Onboarding (3 slides)
- Login with role selection
- Signup with validation

### Customer App (5 main sections) ✅ COMPLETE
1. **Home Dashboard**: Featured products grid, horizontal category scroll, search with filters
2. **Categories Tab**: Large grid view of all product categories with navigation
3. **Cart Tab**: Full shopping cart with item management and checkout integration
4. **Orders Tab**: Complete order history with status tracking and details
5. **Profile Tab**: User information, settings, addresses, payment methods, help & support

### Worker App (4 main sections) ✅ COMPLETE
1. **Dashboard**: Performance stats, recent orders, quick actions, real-time updates
2. **Live Orders**: Real-time order feed with status updates and management
3. **Inventory Tab**: Stock monitoring, low stock alerts, inventory updates
4. **Profile Tab**: Worker information, performance metrics, settings

### Admin Web App (5 main sections) ✅ COMPLETE
1. **Analytics Dashboard**: Interactive FL charts, sales trends, KPIs, revenue tracking
2. **Inventory Management**: Full CRUD with DataTable, search, filtering, Excel import/export
3. **User Management**: Customer and worker management with detailed profiles
4. **Analytics Tab**: Advanced charts, business insights, performance metrics
5. **Settings Tab**: System configuration, notifications, store settings

## 🛠️ Technical Stack

### Framework & Language
- **Flutter**: Cross-platform mobile and web development
- **Dart**: Programming language

### State Management
- **Riverpod**: Modern state management solution

### Navigation
- **GoRouter**: Declarative routing with deep linking support

### UI & Animations
- **Material 3**: Modern Material Design
- **Custom Animations**: Smooth transitions and micro-interactions

### Charts & Data Visualization
- **FL Chart**: Interactive line charts and analytics (actively used in admin dashboard)
- **Timeline Tile**: Order tracking visualization with status progression

### Additional Packages
- **Cached Network Image**: Efficient image loading and caching
- **File Picker**: Excel file import functionality (implemented in admin)
- **Badges**: Notification and status badges (cart, notifications)
- **Shimmer**: Loading states and skeleton screens
- **Flutter Staggered Grid View**: Advanced grid layouts
- **HTTP**: API ready integration
- **Shared Preferences**: Local data persistence

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Chrome (for web development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd general_store_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For mobile (Android/iOS)
   flutter run
   
   # For web
   flutter run -d chrome
   ```

### Demo Credentials
For testing purposes, use these demo accounts:

**Customer Account:**
- Email: customer@demo.com
- Password: password123

**Worker Account:**
- Email: worker@demo.com
- Password: password123

**Admin Account:**
- Email: admin@demo.com
- Password: password123

## 📁 Project Structure

```
lib/
├── core/
│   ├── models/           # Data models (User, Product, Order, etc.)
│   ├── theme/           # App theme and styling
│   ├── widgets/         # Reusable UI components
│   └── routing/         # App navigation configuration
├── features/
│   ├── auth/            # Authentication screens
│   ├── onboarding/      # App introduction
│   ├── customer/        # Customer-specific features
│   ├── worker/          # Worker-specific features
│   └── admin/           # Admin-specific features
└── main.dart           # App entry point
```

## 🎯 Key Features Implementation

### ✅ Responsive Design (Implemented)
- Mobile-first approach with adaptive layouts
- Cross-platform compatibility (iOS, Android, Web)
- Touch-optimized interactions and gestures
- Consistent UI across different screen sizes

### ✅ Real-time Updates (Simulated)
- Live order feed with auto-refresh for workers
- Automatic status updates with visual indicators
- Badge notifications system throughout the app
- Real-time inventory tracking and alerts

### ✅ Data Management (Complete)
- Riverpod state management integration
- Mock data simulation for demonstration
- Optimistic UI updates for better UX
- Comprehensive error handling

### ✅ User Experience Features
- Smooth navigation with GoRouter
- Interactive charts and data visualization
- Search and filtering capabilities
- Form validation and user feedback
- Loading states and progress indicators

## 🔧 Configuration

## 🛠️ Current Implementation Status

### ✅ Fully Functional Features
- **Authentication System**: Complete login/signup with role-based access
- **Customer Experience**: All 5 tabs fully implemented with navigation
- **Worker Interface**: Complete dashboard with all 4 functional tabs
- **Admin Panel**: Comprehensive management with all 5 tabs operational
- **Data Flow**: Full CRUD operations for products, orders, and users
- **UI Components**: All custom widgets and cards implemented
- **Navigation**: Complete routing system with deep linking support

### 📊 Demo Data & Simulation
- Uses comprehensive mock data for realistic demonstration
- All payment processing is simulated (ready for payment gateway integration)
- File upload features include full UI and validation (ready for cloud storage)
- Real-time features use timers (ready for WebSocket integration)
- All charts and analytics use real data structures

## 🔧 Configuration

### Environment Setup
The app uses different configurations for development and production:

- **Development**: Local data simulation
- **Production**: API integration ready

### Theme Customization
Modify `lib/core/theme/app_theme.dart` to customize:
- Colors and branding
- Typography scales
- Component styling
- Dark mode support (ready for implementation)

## 📊 Analytics & Insights

The admin dashboard provides comprehensive analytics:
- Sales trends and forecasting
- Product performance metrics
- Customer behavior insights
- Inventory optimization suggestions

## 🔐 Security Features

- Role-based access control
- Input validation and sanitization
- Secure authentication flow
- Data privacy compliance ready

## 🌐 Multi-platform Support

### Mobile (iOS & Android)
- Native performance with Flutter
- Platform-specific adaptations
- Offline capability ready

### Web
- Responsive web design
- Desktop-optimized layouts
- Progressive Web App ready

## 🚧 Future Enhancements

### Ready for API Integration
- [ ] Backend API integration (HTTP package already included)
- [ ] Real-time WebSocket connections
- [ ] Push notifications integration
- [ ] User authentication with JWT tokens

### Enhanced Features
- [ ] Offline mode with local storage (SharedPreferences ready)
- [ ] Advanced reporting and analytics exports
- [ ] Multi-language support (i18n ready)
- [ ] Dark mode implementation (theme system ready)
- [ ] Barcode scanning for inventory management
- [ ] GPS integration for delivery tracking
- [ ] Social media integration and sharing
- [ ] Advanced search with AI suggestions
- [ ] Loyalty program and rewards system
- [ ] Advanced image handling and optimization

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- **Lily** - *Initial work and design*

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Community contributors and package maintainers

---

**Note**: This is a demonstration application showcasing modern Flutter development practices and UI/UX design principles for a real-world business application.