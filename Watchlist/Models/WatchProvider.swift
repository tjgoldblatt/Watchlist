//
//  WatchProvider.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/11/23.
//

import Foundation

// MARK: - Watch Provider

struct WatchProvider: Codable {
    let id: Int?
    let results: Results?
}

// MARK: - Results

struct Results: Codable {
    let ad, ag, al, ar, at,
        au, ba, be, bg, bo, br, ca, ch, ci, cl, co, cr,
        cv, cz, de, dk, `do`, ec, ee, es, fi, fj, fr, gb,
        gh, gr, gt, hk, hn, hr, hu, id, ie, `is`, it, jm,
        jp, lt, lv, md, mk, mt, mu, mx, my, mz, ne, nl, no,
        nz, pa, pe, ph, pl, pt, py, ro, rs, ru, se, sg, si,
        sk, sn, sv, th, tt, tw, tz, ug, us, uy, ve, za, zm: Country?

    enum CodingKeys: String, CodingKey, CaseIterable {
        case ad = "AD"
        case ag = "AG"
        case al = "AL"
        case ar = "AR"
        case at = "AT"
        case au = "AU"
        case ba = "BA"
        case be = "BE"
        case bg = "BG"
        case bo = "BO"
        case br = "BR"
        case ca = "CA"
        case ch = "CH"
        case ci = "CI"
        case cl = "CL"
        case co = "CO"
        case cr = "CR"
        case cv = "CV"
        case cz = "CZ"
        case de = "DE"
        case dk = "DK"
        case `do` = "DO"
        case ec = "EC"
        case ee = "EE"
        case es = "ES"
        case fi = "FI"
        case fj = "FJ"
        case fr = "FR"
        case gb = "GB"
        case gh = "GH"
        case gr = "GR"
        case gt = "GT"
        case hk = "HK"
        case hn = "HN"
        case hr = "HR"
        case hu = "HU"
        case id = "ID"
        case ie = "IE"
        case `is` = "IS"
        case it = "IT"
        case jm = "JM"
        case jp = "JP"
        case lt = "LT"
        case lv = "LV"
        case md = "MD"
        case mk = "MK"
        case mt = "MT"
        case mu = "MU"
        case mx = "MX"
        case my = "MY"
        case mz = "MZ"
        case ne = "NE"
        case nl = "NL"
        case no = "NO"
        case nz = "NZ"
        case pa = "PA"
        case pe = "PE"
        case ph = "PH"
        case pl = "PL"
        case pt = "PT"
        case py = "PY"
        case ro = "RO"
        case rs = "RS"
        case ru = "RU"
        case se = "SE"
        case sg = "SG"
        case si = "SI"
        case sk = "SK"
        case sn = "SN"
        case sv = "SV"
        case th = "TH"
        case tt = "TT"
        case tw = "TW"
        case tz = "TZ"
        case ug = "UG"
        case us = "US"
        case uy = "UY"
        case ve = "VE"
        case za = "ZA"
        case zm = "ZM"
    }
}

struct Country: Codable, Hashable {
    let link: String?
    let buy, rent, ads, flatrate, free: [Provider]?
}

struct Provider: Codable, Hashable {
    let logoPath: String?
    let providerID: Int?
    let providerName: String?
    let displayPriority: Int?

    enum CodingKeys: String, CodingKey {
        case logoPath = "logo_path"
        case providerID = "provider_id"
        case providerName = "provider_name"
        case displayPriority = "display_priority"
    }
}

extension Encodable {
    subscript(key: String) -> Any? {
        return dictionary[key]
    }

    var dictionary: [String: Any] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
}

extension Decodable {
    init(from: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: from, options: .prettyPrinted)
        let decoder = JSONDecoder()
        self = try decoder.decode(Self.self, from: data)
    }
}
