import Foundation
import Vision
import UIKit

struct OCRResult {
    let merchantName: String?
    let amount: Double?
    let date: Date?
}

class ReceiptOCRService {
    static let shared = ReceiptOCRService()
    
    func recognizeText(from image: UIImage, completion: @escaping (OCRResult) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(OCRResult(merchantName: nil, amount: nil, date: nil))
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(OCRResult(merchantName: nil, amount: nil, date: nil))
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            self?.processRecognizedStrings(recognizedStrings, completion: completion)
        }
        
        request.recognitionLevel = .accurate
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("❌ OCR Error: \(error)")
                completion(OCRResult(merchantName: nil, amount: nil, date: nil))
            }
        }
    }
    
    private func processRecognizedStrings(_ strings: [String], completion: @escaping (OCRResult) -> Void) {
        var amount: Double?
        var detectedDate: Date?
        
        // Keywords for Total (Uzbek, English, Russian)
        let totalKeywords = ["jami", "total", "itogo", "summa", "narxi", "to`lov", "amount"]
        let dateKeywords = ["yil", "date", "sana"]
        
        // Pattern for numbers including possible separators
        let amountPattern = #"\d[\d\s,'.]*[.,]\d{2}"#
        let amountRegex = try? NSRegularExpression(pattern: amountPattern)
        
        // Pattern for dates: DD.MM.YYYY or YYYY-MM-DD or DD/MM/YYYY
        let datePattern = #"\d{2}[./-]\d{2}[./-]\d{4}"#
        let dateRegex = try? NSRegularExpression(pattern: datePattern)
        
        var candidates: [Double] = []
        var priorityCandidate: Double?
        
        for (index, string) in strings.enumerated() {
            let lowerString = string.lowercased()
            
            // Check for Date first
            if let dateMatch = dateRegex?.firstMatch(in: string, range: NSRange(location: 0, length: (string as NSString).length)) {
                let dateStr = (string as NSString).substring(with: dateMatch.range)
                if let parsedDate = parseDate(dateStr) {
                    detectedDate = parsedDate
                }
                continue // Skip amount processing for date lines
            }
            
            // Ignore lines that contain high-confidence date words when looking for amounts
            if dateKeywords.contains(where: { lowerString.contains($0) }) { continue }
            
            let nsString = string as NSString
            let matches = amountRegex?.matches(in: string, range: NSRange(location: 0, length: nsString.length)) ?? []
            
            for match in matches {
                let amountStr = nsString.substring(with: match.range)
                if let val = parseAmount(amountStr) {
                    let hasKeyword = totalKeywords.contains(where: { lowerString.contains($0) })
                    let prevHasKeyword = index > 0 && totalKeywords.contains(where: { strings[index-1].lowercased().contains($0) })
                    
                    if hasKeyword || prevHasKeyword {
                        if priorityCandidate == nil || val > priorityCandidate! {
                            priorityCandidate = val
                        }
                    }
                    candidates.append(val)
                }
            }
        }
        
        amount = priorityCandidate ?? candidates.max()
        
        completion(OCRResult(merchantName: nil, amount: amount, date: detectedDate))
    }
    
    private func parseDate(_ text: String) -> Date? {
        let formats = ["dd.MM.yyyy", "dd/MM/yyyy", "yyyy-MM-dd", "dd-MM-yyyy"]
        let formatter = DateFormatter()
        
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: text) {
                return date
            }
        }
        return nil
    }
    
    private func parseAmount(_ text: String) -> Double? {
        // Remove all noise: spaces, quotes, etc.
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        cleaned = cleaned.replacingOccurrences(of: "'", with: "")
        cleaned = cleaned.replacingOccurrences(of: " ", with: "")
        
        // Handle standard formats: 1,245,000.00 (with multiple separators)
        // If there are both , and ., the last one is the decimal
        let hasComma = cleaned.contains(",")
        let hasDot = cleaned.contains(".")
        
        if hasComma && hasDot {
            // Assume 1,245,000.00 format (US/Uzbek standard for banking)
            cleaned = cleaned.replacingOccurrences(of: ",", with: "")
            return Double(cleaned)
        } else if hasComma {
            // Could be 1.245,00 or 1,245,000
            let parts = cleaned.components(separatedBy: ",")
            if parts.last?.count == 2 {
                // Likely a decimal: 1245,00
                let main = parts.dropLast().joined()
                return Double(main + "." + parts.last!)
            } else {
                // Likely a thousand separator: 1,245,000
                return Double(parts.joined())
            }
        } else if hasDot {
            // Could be 1,245.00 or 1.245.000
            let parts = cleaned.components(separatedBy: ".")
            if parts.last?.count == 2 {
                // Likely a decimal: 1245.00
                let main = parts.dropLast().joined()
                return Double(main + "." + parts.last!)
            } else {
                // Likely a thousand separator: 1.245.000
                return Double(parts.joined())
            }
        }
        
        return Double(cleaned)
    }
}
