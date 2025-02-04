import SwiftUI
import MessageUI

struct NotesList: View {
    let notes: [LoveNote]
    let viewModel: LoveJournalViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Love Note History")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "FF5A5F"))
                .padding(.top, 16)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(notes) { note in
                        NavigationLink(destination: DetailedNoteView(note: note)) {
                            NoteCard(note: note) {
                                if let index = notes.firstIndex(where: { $0.id == note.id }) {
                                    viewModel.deleteNote(at: IndexSet([index]))
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color(hex: "F5F5F5"))
    }
}
