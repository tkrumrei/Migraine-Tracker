import SwiftUI

struct TipItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let category: String
}

struct TipsAndTricksView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: String = "All"
    
    let categories = ["All", "Prevention", "Relief", "Lifestyle", "Tracking"]
    
    let tips = [
        TipItem(title: "Stay Hydrated", 
                description: "Drink at least 8 glasses of water daily. Dehydration is a common migraine trigger.", 
                icon: "drop.fill", 
                color: .blue, 
                category: "Prevention"),
        
        TipItem(title: "Regular Sleep Schedule", 
                description: "Go to bed and wake up at the same time every day, even on weekends.", 
                icon: "moon.zzz.fill", 
                color: .indigo, 
                category: "Prevention"),
        
        TipItem(title: "Cold Compress", 
                description: "Apply a cold compress to your forehead or neck for 15-20 minutes during a migraine.", 
                icon: "snowflake", 
                color: .cyan, 
                category: "Relief"),
        
        TipItem(title: "Dark, Quiet Room", 
                description: "Rest in a dark, quiet room when experiencing a migraine to reduce sensory triggers.", 
                icon: "moon.fill", 
                color: .purple, 
                category: "Relief"),
        
        TipItem(title: "Regular Meals", 
                description: "Don't skip meals. Low blood sugar can trigger migraines. Eat balanced meals every 3-4 hours.", 
                icon: "fork.knife", 
                color: .orange, 
                category: "Prevention"),
        
        TipItem(title: "Limit Screen Time", 
                description: "Take regular breaks from screens and use blue light filters, especially in the evening.", 
                icon: "display", 
                color: .green, 
                category: "Prevention"),
        
        TipItem(title: "Gentle Massage", 
                description: "Massage your temples, neck, and shoulders to help relieve tension and pain.", 
                icon: "hand.point.up.left.fill", 
                color: .pink, 
                category: "Relief"),
        
        TipItem(title: "Stress Management", 
                description: "Practice relaxation techniques like deep breathing, meditation, or yoga daily.", 
                icon: "heart.fill", 
                color: .red, 
                category: "Lifestyle"),
        
        TipItem(title: "Track Your Triggers", 
                description: "Keep a detailed migraine diary to identify patterns and personal triggers.", 
                icon: "chart.line.uptrend.xyaxis", 
                color: .teal, 
                category: "Tracking"),
        
        TipItem(title: "Regular Exercise", 
                description: "Gentle, regular exercise like walking or swimming can help prevent migraines.", 
                icon: "figure.walk", 
                color: .mint, 
                category: "Lifestyle"),
        
        TipItem(title: "Weather Awareness", 
                description: "Track weather patterns. Changes in barometric pressure can trigger migraines.", 
                icon: "cloud.sun.fill", 
                color: .yellow, 
                category: "Tracking"),
        
        TipItem(title: "Aromatherapy", 
                description: "Peppermint or lavender essential oils may help reduce migraine intensity.", 
                icon: "leaf.fill", 
                color: .green, 
                category: "Relief")
    ]
    
    var filteredTips: [TipItem] {
        if selectedCategory == "All" {
            return tips
        } else {
            return tips.filter { $0.category == selectedCategory }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    selectedCategory = category
                                }
                            }) {
                                Text(category)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedCategory == category ?
                                        Color.cyan : Color(.systemGray5)
                                    )
                                    .foregroundColor(
                                        selectedCategory == category ?
                                        .white : .primary
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Tips Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(filteredTips) { tip in
                            TipCard(tip: tip)
                        }
                    }
                    .padding(.horizontal)
                    .animation(.easeInOut, value: filteredTips.count)
                }
            }
            .padding(.bottom, 70)
            .navigationTitle("Tips & Tricks")
        }
    }
}

struct TipCard: View {
    let tip: TipItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: tip.icon)
                    .font(.title2)
                    .foregroundColor(tip.color)
                    .frame(width: 30)
                
                Spacer()
                
                Text(tip.category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tip.color.opacity(0.1))
                    .foregroundColor(tip.color)
                    .cornerRadius(8)
            }
            
            Text(tip.title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineLimit(isExpanded ? nil : 3)
            
            if tip.description.count > 80 {
                Button(action: {
                    withAnimation(.easeInOut) {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "Show less" : "Read more")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(tip.color)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct TipsAndTricksView_Previews: PreviewProvider {
    static var previews: some View {
        TipsAndTricksView()
    }
}