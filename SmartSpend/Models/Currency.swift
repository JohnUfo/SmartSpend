import Foundation

enum Currency: String, CaseIterable, Codable {
    // Major Currencies
    case usd = "USD"  // US Dollar
    case eur = "EUR"  // Euro
    case gbp = "GBP"  // British Pound
    case jpy = "JPY"  // Japanese Yen
    case cny = "CNY"  // Chinese Yuan
    case aud = "AUD"  // Australian Dollar
    case cad = "CAD"  // Canadian Dollar
    case chf = "CHF"  // Swiss Franc
    case inr = "INR"  // Indian Rupee
    case brl = "BRL"  // Brazilian Real
    
    // Asian Currencies
    case uzs = "UZS"  // Uzbekistani Som
    case krw = "KRW"  // South Korean Won
    case sgd = "SGD"  // Singapore Dollar
    case hkd = "HKD"  // Hong Kong Dollar
    case twd = "TWD"  // Taiwan Dollar
    case thb = "THB"  // Thai Baht
    case myr = "MYR"  // Malaysian Ringgit
    case idr = "IDR"  // Indonesian Rupiah
    case php = "PHP"  // Philippine Peso
    case vnd = "VND"  // Vietnamese Dong
    
    // Middle Eastern Currencies
    case aed = "AED"  // UAE Dirham
    case sar = "SAR"  // Saudi Riyal
    case ils = "ILS"  // Israeli Shekel
    case try_ = "TRY"  // Turkish Lira
    case egp = "EGP"  // Egyptian Pound
    case irr = "IRR"  // Iranian Rial
    
    // European Currencies
    case rub = "RUB"  // Russian Ruble
    case pln = "PLN"  // Polish Zloty
    case sek = "SEK"  // Swedish Krona
    case nok = "NOK"  // Norwegian Krone
    case dkk = "DKK"  // Danish Krone
    case czk = "CZK"  // Czech Koruna
    case huf = "HUF"  // Hungarian Forint
    case ron = "RON"  // Romanian Leu
    case bgn = "BGN"  // Bulgarian Lev
    
    // African Currencies
    case zar = "ZAR"  // South African Rand
    case ngn = "NGN"  // Nigerian Naira
    case kes = "KES"  // Kenyan Shilling
    case etb = "ETB"  // Ethiopian Birr
    case ghs = "GHS"  // Ghanaian Cedi
    
    // Latin American Currencies
    case mxn = "MXN"  // Mexican Peso
    case ars = "ARS"  // Argentine Peso
    case clp = "CLP"  // Chilean Peso
    case cop = "COP"  // Colombian Peso
    case pen = "PEN"  // Peruvian Sol
    
    // Other Currencies
    case nzd = "NZD"  // New Zealand Dollar
    
    var symbol: String {
        return rawValue
    }
    
    var locale: Locale {
        switch self {
        case .usd: return Locale(identifier: "en_US")
        case .eur: return Locale(identifier: "de_DE")
        case .gbp: return Locale(identifier: "en_GB")
        case .jpy: return Locale(identifier: "ja_JP")
        case .cny: return Locale(identifier: "zh_CN")
        case .aud: return Locale(identifier: "en_AU")
        case .cad: return Locale(identifier: "en_CA")
        case .chf: return Locale(identifier: "de_CH")
        case .inr: return Locale(identifier: "en_IN")
        case .brl: return Locale(identifier: "pt_BR")
        case .uzs: return Locale(identifier: "uz_UZ")
        case .krw: return Locale(identifier: "ko_KR")
        case .sgd: return Locale(identifier: "en_SG")
        case .hkd: return Locale(identifier: "zh_HK")
        case .twd: return Locale(identifier: "zh_TW")
        case .thb: return Locale(identifier: "th_TH")
        case .myr: return Locale(identifier: "ms_MY")
        case .idr: return Locale(identifier: "id_ID")
        case .php: return Locale(identifier: "en_PH")
        case .vnd: return Locale(identifier: "vi_VN")
        case .aed: return Locale(identifier: "ar_AE")
        case .sar: return Locale(identifier: "ar_SA")
        case .ils: return Locale(identifier: "he_IL")
        case .try_: return Locale(identifier: "tr_TR")
        case .egp: return Locale(identifier: "ar_EG")
        case .irr: return Locale(identifier: "fa_IR")
        case .rub: return Locale(identifier: "ru_RU")
        case .pln: return Locale(identifier: "pl_PL")
        case .sek: return Locale(identifier: "sv_SE")
        case .nok: return Locale(identifier: "nb_NO")
        case .dkk: return Locale(identifier: "da_DK")
        case .czk: return Locale(identifier: "cs_CZ")
        case .huf: return Locale(identifier: "hu_HU")
        case .ron: return Locale(identifier: "ro_RO")
        case .bgn: return Locale(identifier: "bg_BG")
        case .zar: return Locale(identifier: "en_ZA")
        case .ngn: return Locale(identifier: "en_NG")
        case .kes: return Locale(identifier: "en_KE")
        case .etb: return Locale(identifier: "am_ET")
        case .ghs: return Locale(identifier: "en_GH")
        case .mxn: return Locale(identifier: "es_MX")
        case .ars: return Locale(identifier: "es_AR")
        case .clp: return Locale(identifier: "es_CL")
        case .cop: return Locale(identifier: "es_CO")
        case .pen: return Locale(identifier: "es_PE")
        case .nzd: return Locale(identifier: "en_NZ")
        }
    }
    
    var name: String {
        switch self {
        case .usd: return "US Dollar"
        case .eur: return "Euro"
        case .gbp: return "British Pound"
        case .jpy: return "Japanese Yen"
        case .cny: return "Chinese Yuan"
        case .aud: return "Australian Dollar"
        case .cad: return "Canadian Dollar"
        case .chf: return "Swiss Franc"
        case .inr: return "Indian Rupee"
        case .brl: return "Brazilian Real"
        case .uzs: return "Uzbekistani Som"
        case .krw: return "South Korean Won"
        case .sgd: return "Singapore Dollar"
        case .hkd: return "Hong Kong Dollar"
        case .twd: return "Taiwan Dollar"
        case .thb: return "Thai Baht"
        case .myr: return "Malaysian Ringgit"
        case .idr: return "Indonesian Rupiah"
        case .php: return "Philippine Peso"
        case .vnd: return "Vietnamese Dong"
        case .aed: return "UAE Dirham"
        case .sar: return "Saudi Riyal"
        case .ils: return "Israeli Shekel"
        case .try_: return "Turkish Lira"
        case .egp: return "Egyptian Pound"
        case .irr: return "Iranian Rial"
        case .rub: return "Russian Ruble"
        case .pln: return "Polish Zloty"
        case .sek: return "Swedish Krona"
        case .nok: return "Norwegian Krone"
        case .dkk: return "Danish Krone"
        case .czk: return "Czech Koruna"
        case .huf: return "Hungarian Forint"
        case .ron: return "Romanian Leu"
        case .bgn: return "Bulgarian Lev"
        case .zar: return "South African Rand"
        case .ngn: return "Nigerian Naira"
        case .kes: return "Kenyan Shilling"
        case .etb: return "Ethiopian Birr"
        case .ghs: return "Ghanaian Cedi"
        case .mxn: return "Mexican Peso"
        case .ars: return "Argentine Peso"
        case .clp: return "Chilean Peso"
        case .cop: return "Colombian Peso"
        case .pen: return "Peruvian Sol"
        case .nzd: return "New Zealand Dollar"
        }
    }
    
    var flag: String {
        switch self {
        case .usd: return "🇺🇸"
        case .eur: return "🇪🇺"
        case .gbp: return "🇬🇧"
        case .jpy: return "🇯🇵"
        case .cny: return "🇨🇳"
        case .aud: return "🇦🇺"
        case .cad: return "🇨🇦"
        case .chf: return "🇨🇭"
        case .inr: return "🇮🇳"
        case .brl: return "🇧🇷"
        case .uzs: return "🇺🇿"
        case .krw: return "🇰🇷"
        case .sgd: return "🇸🇬"
        case .hkd: return "🇭🇰"
        case .twd: return "🇹🇼"
        case .thb: return "🇹🇭"
        case .myr: return "🇲🇾"
        case .idr: return "🇮🇩"
        case .php: return "🇵🇭"
        case .vnd: return "🇻🇳"
        case .aed: return "🇦🇪"
        case .sar: return "🇸🇦"
        case .ils: return "🇮🇱"
        case .try_: return "🇹🇷"
        case .egp: return "🇪🇬"
        case .irr: return "🇮🇷"
        case .rub: return "🇷🇺"
        case .pln: return "🇵🇱"
        case .sek: return "🇸🇪"
        case .nok: return "🇳🇴"
        case .dkk: return "🇩🇰"
        case .czk: return "🇨🇿"
        case .huf: return "🇭🇺"
        case .ron: return "🇷🇴"
        case .bgn: return "🇧🇬"
        case .zar: return "🇿🇦"
        case .ngn: return "🇳🇬"
        case .kes: return "🇰🇪"
        case .etb: return "🇪🇹"
        case .ghs: return "🇬🇭"
        case .mxn: return "🇲🇽"
        case .ars: return "🇦🇷"
        case .clp: return "🇨🇱"
        case .cop: return "🇨🇴"
        case .pen: return "🇵🇪"
        case .nzd: return "🇳🇿"
        }
    }
}

