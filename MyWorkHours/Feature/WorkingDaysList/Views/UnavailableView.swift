import SwiftUI

struct UnavailableView: View {
    @ObservedObject var viewModel: WorkDaysScreen.ViewModel
    private(set) var emptyViewMessage: LocalizedStringKey = "Your working list is empty. To add a working day, use the button below."
    
    
    
    var body: some View {
        VStack {
            ContentUnavailableView {
                Label("Your list is empty", systemImage: "scribble.variable")
            } description: {
                Text(emptyViewMessage)
            } actions: {
                Button {
                    viewModel.createNewDaySheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 40))
                }
            }
        }
        .sheet(isPresented: $viewModel.createNewDaySheet) {
            CreateNewDayView(viewModel: viewModel)
        }
        .onAppear {
            
        }
    }
    
    init(viewModel: WorkDaysScreen.ViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }
}
