import SwiftUI
import RiveRuntime

struct MinimalRiveView: View {
    // The shared Rive instance.
    let riveModel: RiveViewModel = RiveViewModel(
        fileName: "bottom_navigation",
        stateMachineName: "State Machine 2------------------",
        artboardName: "State machine 2"
    )
    
    // State variable to hold the active input name.
    @State private var activeInput: String = "None"
    
    // Ordered list of inputs (for reference only).
    private let inputsOrder = ["Minis 1", "Dine out", "Instamart1", "Food1", "Swiggy1"]
    
    // A timer to simulate polling for the current active input.
    // In a full integration, you'd use an event or callback from Rive instead.
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 16) {
            // Display the Rive view.
            riveModel.view()
                .frame(width: 200, height: 200)
                .padding()
                // Removed onTapGesture that was cycling through inputs.
            
            // Display text based on the active input.
            Group {
                switch activeInput {
                case "Minis 1":
                    Text("Minis 1")
                case "Dine out":
                    Text("Dine out")
                case "Instamart1":
                    Text("Ins")
                case "Food1":
                    Text("Food")
                case "Swiggy1":
                    Text("Swiggy")
                default:
                    Text("No state")
                }
            }
            .font(.largeTitle)
            .padding()
        }
        .onReceive(timer) { _ in
            // Poll for the current active input.
            // Replace the simulated code below with your actual integration to read
            // the active input from your Rive model.
            //
            // For example, if RiveRuntime provided a method like:
            //    let current = riveModel.currentActiveInput()
            // then update:
            //    self.activeInput = current
            //
            // For demonstration, we leave this block empty so that once an input is triggered
            // by the Rive file's own interaction logic, it stays as is.
        }
    }
}

#if DEBUG
struct MinimalRiveView_Previews: PreviewProvider {
    static var previews: some View {
        MinimalRiveView()
    }
}
#endif
