# RecipEAT 

RecipEAT is a mobile application designed for food enthusiasts to share, discover, and organize recipes. This social recipe sharing platform allows users to create profiles, upload recipes, save favorites, plan meals, and generate recipe lists and their details - all while connecting with a community of fellow food lovers.

## Features

### Core Functionality
- **User Authentication**: Secure sign-up/login with email/password or Google Gmail
- **Recipe Management**:
  - Create, edit, and publish recipes with an image
  - Auto sort recipes
  - Save recipes
  - Like favorite recipes
- **Meal Planning**:
  - Create weekly/daily meal plans
  - Add/Remove recipes to specific dates and meal categories
  - Search existing recipes to add to meal plan
  - Add notes
- **Profile**:
  - Update username and password (except for Gmail)
  - Upload/change profile photo

### Technical Highlights
- Modern SwiftUI interface with custom components
- Firebase backend integration:
  - Firestore for data storage
  - Firebase Authentication
  - Firebase Storage for images
- State management with ObservableObject pattern
- Rive animations for engaging UI elements

## Project Structure
RecipEAT/
├── AppServices/
│ ├── Application.swift
│ ├── MealPlanService.swift
│ ├── RecipeService.swift
│ ├── UserFirebaseService.swift
├── Assets.xcassets/
├── Fonts/
├── Models/
│ ├── MealPlanModel.swift
│ ├── RecipeModel.swift
│ ├── ReviewModel.swift
│ ├── UserModel.swift
├── Preview Content/
├── RiveAssets/
├── Styles/
├── Views/
│ ├── Auth/
│ │ ├── AuthenticationView.swift
│ │ ├── InitialView.swift
│ │ ├── SignInView.swift
│ │ ├── SignupView.swift
│ ├── Home/
│ │ ├── HomeScreen.swift
│ ├── MealPlan/
│ │ ├── AddMealScreen.swift
│ │ ├── MealPlannerScreen.swift
│ ├── Profile/
│ │ ├── ChangeNameScreen.swift
│ │ ├── ChangePasswordScreen.swift
│ │ ├── ProfileScreen.swift
│ ├── Recipe/
│ │ ├── CreateNewRecipeScreen.swift
│ │ ├── PersonalRecipeScreen.swift
│ │ ├── RecipeCard.swift
│ │ ├── RecipeDetails.swift
│ │ ├── RecipeScreen.swift
│ ├── OnboardingView.swift
├── ContentView.swift
├── GoogleService-Info.plist
├── Info.plist
├── RecipEATApp.swift
├── RecipEAT.xcodeproj/
├── .gitignore
├── README.md


## Getting Started

### Prerequisites
- **Xcode 16.2+**
- **iOS 18.2+**
- **Firebase account** ([Create one here](https://console.firebase.google.com/))
- **Swift Package Manager** (Built into Xcode)
- **GoogleService-Info.plist** configuration file from Firebase

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/tuanh00/RecipEAT

2. **Navigate to the project directory**:
    cd RecipEAT

3. **Add Firebase dependencies**

4. Open RecipEAT.xcworkspace in Xcode

5. Add your Firebase configuration files (GoogleService-Info.plist)

6. Build and run the project


## Dependencies

- FirebaseAuth
- FirebaseCore
- FirebaseFirestore
- FirebaseStorage
- GoogleSignIn
- GoogleSignInSwift
- RiveRuntime

## Acknowledgments

- [Firebase Documentation](https://firebase.google.com/docs/ios/setup)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Rive Animations](https://rive.app/)
- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)

## Contributors

- Huynh Tu Anh Chau
- Hazel Clarisse Connolly
- Queen Sarah Anumu Bih