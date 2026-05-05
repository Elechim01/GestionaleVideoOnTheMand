import SwiftUI
import ElechimCore
import Services

/// A macOS sheet that shows detailed information about a `Film`.
struct FilmInfoSheet: View {
    // MARK: - Dependencies
    @EnvironmentObject private var homeViewModel: HomeViewModel
    let film: Film
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {
            // MARK: Title
            Text(film.nome)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
            
            // MARK: Card with details
            VStack(alignment: .leading, spacing: 12) {
                infoRow(title: "film.info.url",
                        value: film.url)
                infoRow(title: "film.info.thumbnail",
                        value: film.thumbnail)
                infoRow(title: "film.info.thumnail.name",
                        value: film.thumbnailName)
                infoRow(title: "film.info.size",
                        value: Utils.formatStorage( film.size))
                infoRow(
                    title: "film.info.date",
                    value: Utils.stringToDate(date: film.data ?? .now)
                )
            }
            .padding()
            .background(.ultraThinMaterial)               // Frosted‑glass effect
            .cornerRadius(12)
            .shadow(radius: 4, x: 0, y: 2)                // Subtle shadow
            
            Spacer()
            
            // MARK: Close button
            
            SimpleButton(color: .green.opacity(0.4), action: {
                homeViewModel.selectedFilmForInfo = nil
            }, label:  {
                Text("system.text.close")
                    .font(.body.bold())
                    .frame(maxWidth: .infinity)
            })
            Spacer()
            
            
        }
        .padding(.horizontal, 24)
        .frame(minWidth: 350, minHeight: 400)
        .background(Color("Blue").opacity(0.4).ignoresSafeArea())      // Main background colour
    }
    
    // MARK: - Helper for label + value rows
    @ViewBuilder
    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)                     // Allow wrapping
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview
#Preview {
    FilmInfoSheet(film: Mock.mockFilm[0])
        .environmentObject(PreviewDependecyInjection.shared.makeHomeViewModel())
}
