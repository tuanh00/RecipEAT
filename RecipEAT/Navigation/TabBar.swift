import SwiftUI
import RiveRuntime

struct TabBar: View {
    @State private var selectedTab: Int = 0

    let riveViewModel = RiveViewModel(
        fileName: "bottom_navigation",
        stateMachineName: "State Machine 2------------------",
        artboardName: "State machine 2"
    )

    var body: some View {
        VStack(spacing: 0) {
            // Screen based on selectedTab
            Group {
                switch selectedTab {
                case 0: HomeScreen()
                case 1: SavedListScreen()
                case 2: CreateNewRecipeScreen(selectedTab: .constant(0))
                case 3: MealPlannerScreen(selectedTab: .constant(0))
                case 4: ProfileScreen()
                default: HomeScreen()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Rive Tab Bar at Bottom
            ZStack {
                riveViewModel.view()
                    .frame(height: 80)

                HStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { index in
                        Button {
                            // Only switch SwiftUI screen — let Rive animate on its own
                            selectedTab = index
                        } label: {
                            Color.clear 
                        }
                        .frame(width: UIScreen.main.bounds.width / 5, height: 80)
                    }
                }
            }
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar()
    }
}
