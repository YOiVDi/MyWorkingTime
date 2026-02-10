import SwiftUI

struct DateIconView: View {
    let model: WorkDay
    
    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: -1, y: 1)
                VStack {
                    Text(model.date, format: .dateTime.month())
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                        .opacity(0.8)
                        .font(.system(size: 12))
                    Text(model.date, format: .dateTime.day())
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .opacity(0.8)
                            .font(.system(size: 12))
                }
            }
            .shadow(color: .black, radius: 0.1)
            .frame(maxWidth: 50, maxHeight: 40)
    }
}

#Preview {
    DateIconView(model: WorkDay.mock)
}
