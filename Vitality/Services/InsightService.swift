//
//  InsightService.swift
//  Vitality
//
//  Created by Aang phurba Sherpa on 9/14/26.
//

import Foundation

/// Fetches a generated plain-language reading for a metric.
///
/// Every failure returns `nil` rather than throwing: the caller always has the
/// hand-written reading from `MetricSample` to fall back on, so a missing
/// network, a slow server, or a decline should be invisible to the user.
actor InsightService {
    static let shared = InsightService()

    /// Where the insight server lives. Points at localhost for development.
    /// Override with the `INSIGHT_BASE_URL` environment variable.
    private let baseURL: URL

    /// Give up well before the user notices. The fallback is already on screen.
    private static let timeout: TimeInterval = 5

    /// Readings already fetched this session, keyed by metric.
    private var cache: [MetricSample: String] = [:]

    private let session: URLSession

    init(baseURL: URL? = nil) {
        if let baseURL {
            self.baseURL = baseURL
        } else if let raw = ProcessInfo.processInfo.environment["INSIGHT_BASE_URL"],
                  let url = URL(string: raw) {
            self.baseURL = url
        } else {
            self.baseURL = URL(string: "http://localhost:8787")!
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = Self.timeout
        configuration.waitsForConnectivity = false
        self.session = URLSession(configuration: configuration)
    }

    /// Returns a generated reading, or `nil` if one could not be produced.
    func reading(
        for metric: MetricSample,
        unit: String,
        aim: TrainingAim,
        units: UnitSystem
    ) async -> String? {
        if let cached = cache[metric] {
            return cached
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("reading"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RequestBody(
            metric: metric.label,
            series: metric.week,
            unit: unit,
            aim: aim.rawValue,
            units: units.rawValue
        )

        guard let encoded = try? JSONEncoder().encode(body) else { return nil }
        request.httpBody = encoded

        do {
            let (data, response) = try await session.data(for: request)

            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return nil
            }

            let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
            let text = decoded.text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }

            cache[metric] = text
            return text
        } catch {
            // Offline, timed out, or malformed — the caller uses its fallback.
            return nil
        }
    }

    // MARK: - Wire Types

    private struct RequestBody: Encodable {
        let metric: String
        let series: [Double]
        let unit: String
        let aim: String
        let units: String
    }

    private struct ResponseBody: Decodable {
        let text: String
    }
}
