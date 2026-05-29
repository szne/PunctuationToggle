import Foundation

/// 句読点モード（JIMPrefPunctuationTypeKey のビットマスク値）
///   bit0 = 読点 (0=、 1=，)
///   bit1 = 句点 (0=。 1=．)
enum PunctuationMode: Int, CaseIterable, Identifiable {
    case wabun      = 0  // 、。
    case commaWest  = 1  // ，。
    case periodWest = 2  // 、．
    case obun       = 3  // ，．

    var id: Int { rawValue }

    /// メニューバー・設定画面用ラベル
    var displayLabel: String { "\(comma)\(period)" }

    /// 設定画面の補足説明
    var detail: String {
        switch self {
        case .wabun:      return "和文（読点・句点）"
        case .commaWest:  return "読点のみ欧文"
        case .periodWest: return "句点のみ欧文"
        case .obun:       return "欧文（コンマ・ピリオド）"
        }
    }

    var comma:  String { rawValue & 1 == 0 ? "、" : "，" }
    var period: String { rawValue & 2 == 0 ? "。" : "．" }
}
