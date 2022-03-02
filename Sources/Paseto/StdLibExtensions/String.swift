extension String {
    func split(with separator: Character) -> [String] {
        return self.split(
            separator: separator, omittingEmptySubsequences: false
        ).map(String.init)
    }
}
