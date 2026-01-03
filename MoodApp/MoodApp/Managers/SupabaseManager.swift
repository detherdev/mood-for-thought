import Foundation
import Combine
import Supabase
import Auth

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    @Published var session: Session?
    @Published var currentUser: User?
    @Published var isInitialized = false
    
    private init() {
        // These will be used in the actual Xcode project via Config/Plist or Env
        let url = URL(string: "https://pnnreudfvpomqvysvldh.supabase.co")!
        let key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBubnJldWRmdnBvbXF2eXN2bGRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjczNzI2NDEsImV4cCI6MjA4Mjk0ODY0MX0.jz3ojlqDSiSFAeE52wRyrufRAxd_MXAOjPzrF_2MbiQ"
        
        // Opt-in to new session behavior to avoid deprecation warnings
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            options: SupabaseClientOptions(
                auth: .init(
                    emitLocalSessionAsInitialSession: true
                )
            )
        )
        
        Task {
            await checkSession()
            
            // Listen for auth changes
            for await (_, session) in client.auth.authStateChanges {
                await MainActor.run {
                    self.session = session
                    self.currentUser = session?.user
                }
            }
        }
    }
    
    func checkSession() async {
        do {
            let session = try await client.auth.session
            await MainActor.run {
                self.session = session
                self.currentUser = session.user
                self.isInitialized = true
            }
        } catch {
            await MainActor.run {
                self.isInitialized = true
            }
            print("No active session: \(error)")
        }
    }
    
    // MARK: - Auth
    func signOut() async {
        try? await client.auth.signOut()
        await MainActor.run {
            self.session = nil
            self.currentUser = nil
        }
    }
    
    // MARK: - Database
    func fetchMoods() async throws -> [Mood] {
        guard let userId = currentUser?.id else { return [] }
        
        return try await client
            .from("moods")
            .select()
            .eq("user_id", value: userId)
            .order("date", ascending: false)
            .execute()
            .value
    }
    
    func saveMood(date: String, mood: MoodType, note: String?) async throws {
        guard let userId = currentUser?.id else { return }
        
        // Check if a mood already exists for this date
        let existing = try await fetchMoodForDate(date: date)
        
        if let existingMood = existing {
            // Update existing mood
            struct MoodUpdate: Encodable {
                let mood: MoodType
                let note: String?
                let updated_at: Date
            }
            
            let update = MoodUpdate(
                mood: mood,
                note: note,
                updated_at: Date()
            )
            
            try await client
                .from("moods")
                .update(update)
                .eq("user_id", value: userId)
                .eq("date", value: date)
                .execute()
        } else {
            // Insert new mood
            let entry = Mood(
                userId: userId,
                date: date,
                mood: mood,
                note: note,
                updatedAt: Date()
            )
            
            try await client
                .from("moods")
                .insert(entry)
                .execute()
        }
    }
    
    func fetchMoodForDate(date: String) async throws -> Mood? {
        guard let userId = currentUser?.id else { return nil }
        
        let moods: [Mood] = try await client
            .from("moods")
            .select()
            .eq("user_id", value: userId)
            .eq("date", value: date)
            .execute()
            .value
        
        return moods.first
    }
    
    func deleteMood(date: String) async throws {
        guard let userId = currentUser?.id else { return }
        
        try await client
            .from("moods")
            .delete()
            .eq("user_id", value: userId)
            .eq("date", value: date)
            .execute()
    }
}

