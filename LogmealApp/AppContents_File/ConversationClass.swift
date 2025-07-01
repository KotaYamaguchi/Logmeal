import Foundation

class Conversation: ObservableObject{
    @Published var dogs:[String] = []
    @Published var cats:[String] = []
    @Published var rabbits:[String] = []
}
