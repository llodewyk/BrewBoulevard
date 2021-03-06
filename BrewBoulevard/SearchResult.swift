import Foundation

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
  return lhs.name.localizedStandardCompare(rhs.name) == NSComparisonResult.OrderedAscending
}

private let displayNamesForKind = [
  "album": NSLocalizedString("Album", comment: "Localized kind: Album"),
  "audiobook": NSLocalizedString("Audio Book", comment: "Localized kind: Audio Book"),
  "book": NSLocalizedString("Book", comment: "Localized kind: Book"),
  "ebook": NSLocalizedString("E-Book", comment: "Localized kind: E-Book"),
  "feature-movie": NSLocalizedString("Movie", comment: "Localized kind: Feature Movie"),
  "music-video": NSLocalizedString("Music Video", comment: "Localized kind: Music Video"),
  "podcast": NSLocalizedString("Podcast", comment: "Localized kind: Podcast"),
  "software": NSLocalizedString("App", comment: "Localized kind: Software"),
  "song": NSLocalizedString("Song", comment: "Localized kind: Song"),
  "tv-episode": NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode"),
]

class SearchResult {
  var id = ""
  var name = ""
  var address = ""
  var smallIcon = ""
  var largeIcon = ""
  var website = ""
  var latitude = 0.0
  var longitude = 0.0
  var description = ""
  var phone = ""
  var hours = ""
  var city = ""
}
