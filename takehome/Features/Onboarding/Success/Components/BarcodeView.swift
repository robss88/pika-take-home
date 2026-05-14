import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

struct BarcodeView: View {
    let payload: String
    var aspectRatio: CGFloat = 4

    var body: some View {
        if let image = Self.generateBarcode(from: payload) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .aspectRatio(aspectRatio, contentMode: .fit)
        } else {
            Rectangle()
                .fill(Color.semiInk.opacity(0.2))
                .aspectRatio(aspectRatio, contentMode: .fit)
        }
    }

    private static func generateBarcode(from payload: String) -> UIImage? {
        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = Data(payload.utf8)
        filter.quietSpace = 4
        guard let ciImage = filter.outputImage else { return nil }
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: 4, y: 4))
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
