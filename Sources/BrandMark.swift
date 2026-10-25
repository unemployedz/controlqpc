import SwiftUI
import UIKit

/// Monochrome Files-inspired mark. The PNG is embedded as Base64 so the app
/// does not need a remote image or a separate runtime download.
struct BrandMark: View {
    private static let encodedPNG = """
    iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAYAAABccqhmAAAC5UlEQVR42u3cS67CMBBE0XTk/W+5mHuSICEipc7ZQUz70vA+kyQHUOl0BCAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAAPWg0POTOvfK4kJhgBaLv4+/MJAQJQdPGFAN8BuPyeHQFwAZwBAmDwnQU+AgB1AfCO50ywAQBtAfBO52ywAQACAAgAIACAAAACAOyWI3g3Pwr8TttfVNoAYAtmUzQFAIpDIABQHAIBgJshEAAQAQEAERAAEAEBAAQAbAEC8G/+Fz7YAMAWIABAVQD8sQvmzwYACAAgAIAAAAIACAAgAIAAAAIAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgAIACAAgAAAAgACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAgAIACAAAACAAIACAAgAIAAAAIACAAgAIAAAALwvCReRcyfDQCoDIAtAHNnAwBaA2ALwLzZAIDWANgCMGflG4AIYL7KPwKIAOaq/DsAEcA8XVsNL9rMmGBc/LYACAEuvgAIAS6+APh+AHZ+EQgEABAAQAAAAQAEABAAQAAAAQAEABAAQAAAAQAEABAAQAAAAQAEABAAQAAAAQAEABAAQAAAAQAEABAAQAAAAQAEABAAQAAAAQAEABAAQAAAAQABcAQgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAAIACAAgAIAAAL/wAXQ2VCGwdD2TAAAAAElFTkSuQmCC
    """

    var body: some View {
        Group {
            if let data = Data(base64Encoded: Self.encodedPNG),
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
            } else {
                ZStack {
                    Color.white
                    Image(systemName: "folder.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .foregroundStyle(Color.black)
                }
            }
        }
        .accessibilityLabel("Monochrome folder logo")
    }
}
