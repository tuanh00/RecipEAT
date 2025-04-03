import SwiftUI
import Firebase

struct PersonalRecipeScreen: View {
    @EnvironmentObject var userService: UserFirebaseService
    @StateObject var recipeService = RecipeService()
    @State private var allRecipes: [Recipe] = []
    @Binding var selectedTab: Int
    @State private var selectedList: RecipeListType = .saved
    
    enum RecipeListType {
        case saved
        case liked
    }
    
    var filteredRecipes: [Recipe] {
        guard let user = userService.currentUser else { return [] }
        switch selectedList {
        case .saved:
            return recipeService.filterRecipesBySavedList(allRecipes: allRecipes, savedIds: user.savedRecipes)
        case .liked:
            return recipeService.filterRecipesByLikedList(allRecipes: allRecipes, likedIds: user.likedRecipes)
        }
    }
    
    private var isPreview: Bool
    
    init(selectedTab: Binding<Int>, previewRecipes: [Recipe] = []) {
        self._selectedTab = selectedTab
        self._allRecipes = State(initialValue: previewRecipes)
        self.isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    var body: some View {
        VStack {
            // Toggle Tabs UI
            HStack(spacing: 12) {
                Button(action: {
                    selectedList = .saved
                }) {
                    Text("Saved List")
                        .fontWeight(selectedList == .saved ? .bold : .regular)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedList == .saved ? Color.gray.opacity(0.2) : Color.clear)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    selectedList = .liked
                }) {
                    Text("Liked List")
                        .fontWeight(selectedList == .liked ? .bold : .regular)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedList == .liked ? Color.gray.opacity(0.2) : Color.clear)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            // Render Recipes
            if filteredRecipes.isEmpty {
                VStack {
                    Spacer(minLength: 0)
                    Text(selectedList == .saved ? "Let's save some recipes 🎉" : "No liked recipes yet 🙁")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                RecipeScreen(recipes: filteredRecipes)
            }
        }
        .navigationTitle("My Recipes")
        .onAppear {
            if !isPreview {
                recipeService.fetchAllRecipes { fetched in
                    self.allRecipes = fetched
                }
            }
        }
    }
}

let sampleRecipesForPreview: [Recipe] = {
    var recipes = [
        Recipe(
            imageUrl: "https://images.unsplash.com/photo-1586040140378-b5634cb4c8fc?w=1400",
            title: "Tiramisu",
            description: "Classic Italian dessert",
            ingredients: [Ingredients(name: "Mascarpone", quantity: "250", unit: "g")],
            instructions: ["Prepare layers", "Chill in fridge"],
            userId: "user123",
            category: "Dessert",
            review: [],
            servings: 4,
            createdAt: Date(),
            isPublished: true,
            likeCount: 10,
            saveCount: 5
        ),
        Recipe(
            imageUrl: "https://images.unsplash.com/photo-1626844131082-256783844137?w=1400",
            title: "Tomato Spaghetti",
            description: "Simple and tasty pasta",
            ingredients: [Ingredients(name: "Spaghetti", quantity: "1", unit: "pack")],
            instructions: ["Boil pasta", "Make sauce"],
            userId: "user123",
            category: "Dinner",
            review: [],
            servings: 2,
            createdAt: Date(),
            isPublished: true,
            likeCount: 10,
            saveCount: 5
        )
    ]
    recipes[0].id = "tiramisuID"
    recipes[1].id = "spaghettiID"
    return recipes
}()

let mockUserServiceForPreview: UserFirebaseService = {
    let service = UserFirebaseService()
    service.currentUser = User(
        id: "user123",
        email: "sample@example.com",
        displayName: "Test User",
        imageUrl: "",
        password: "",
        createdAt: Date(),
        savedRecipes: ["tiramisuID", "spaghettiID"],
        likedRecipes: []
    )
    return service
}()

#Preview {
    PersonalRecipeScreen(selectedTab: .constant(1), previewRecipes: sampleRecipesForPreview)
        .environmentObject(mockUserServiceForPreview)
}
