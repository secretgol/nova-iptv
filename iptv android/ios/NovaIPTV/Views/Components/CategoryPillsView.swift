import SwiftUI

public struct CategoryPillsView: View {
    let categories: [Category]
    @Binding var selectedCategoryId: String

    public init(categories: [Category], selectedCategoryId: Binding<String>) {
        self.categories = categories
        self._selectedCategoryId = selectedCategoryId
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories) { cat in
                    let isSelected = (cat.id == selectedCategoryId)
                    Button(action: {
                        selectedCategoryId = cat.id
                    }) {
                        HStack(spacing: 6) {
                            Text(cat.name)
                                .font(.system(size: 13, weight: isSelected ? .bold : .medium))

                            Text("\(cat.count)")
                                .font(.system(size: 11, weight: .semibold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .foregroundColor(isSelected ? .black : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.cyan : Color(red: 0.12, green: 0.15, blue: 0.22))
                        )
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
}
