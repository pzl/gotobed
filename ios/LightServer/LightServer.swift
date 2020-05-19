//
//  LightServer.swift
//  LightServer
//
//  Created by Dan on 10/5/19.
//  Copyright © 2019 Dan Panzarella. All rights reserved.
//

import Foundation
import UIKit

public struct TrafficState: Codable {
    public var red: Bool
    public var yellow: Bool
    public var green: Bool
    public var lamp: Bool
    
    public init(_ r: Bool, _ y: Bool, _ g: Bool, _ l: Bool) {
        red = r
        yellow = y
        green = g
        lamp = l
    }
}

public struct TimedAction: Codable {
    public var id: String?
    public var state: TrafficState
    public var time: Int64
    
    public init(withState s: TrafficState, at t: Int64) {
        state = s
        time = t
    }
    
    public init(withID i:String, withState s:TrafficState, at t: Int64) {
        id = i
        state = s
        time = t
    }
}

public func LSPing(_ host: String, _ done: @escaping (Bool) -> Void) {
    if let url = URL(string: "\(host)/ping") {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("error pinging server")
                done(false)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("not HTTP response at ping")
                done(false)
                return
            }
            guard response.statusCode == 200 else {
                print("bad ping status code: \(response.statusCode)")
                done(false)
                return
            }
            done(true)
        }
    } else {
        done(false)
    }
}

public func LSGetState(_ host: String, _ done: @escaping (TrafficState?) -> Void) {
    if let url = URL(string: "\(host)/state") {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("initial error: \(error!.localizedDescription)")
                done(nil)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("not HTTP response")
                done(nil)
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                print("bad status code: \(response.statusCode)")
                done(nil)
                return
            }
            guard let data = data else {
                print("nil data response")
                done(nil)
                return
            }
            if let state = try? JSONDecoder().decode(TrafficState.self, from: data) {
                done(state)
            } else {
                done(nil)
            }
        }.resume()
    }
}

public func LSSetState(host: String, withState state: TrafficState, _ done: @escaping (TrafficState?) -> Void) {
    guard let json = try? JSONEncoder().encode(state) else {
        print("error encoding JSON")
        done(nil)
        return
    }
    
    if let url = URL(string: "\(host)/state") {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = json
        URLSession.shared.dataTask(with: req) { data, response, error in
            guard error == nil else {
                print("initial error: \(error!.localizedDescription)")
                done(nil)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("not HTTP response")
                done(nil)
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                print("bad status code: \(response.statusCode)")
                done(nil)
                return
            }
            guard let data = data else {
                print("got nil response after sending")
                done(nil)
                return
            }
            guard let state = try? JSONDecoder().decode(TrafficState.self, from: data) else {
                print("unable to decode response")
                done(nil)
                return
            }
            done(state)
        }.resume()
    }
}

public func LSGetSchedule(_ host: String, _ done: @escaping ([TimedAction]?) -> Void) {
    if let url = URL(string: "\(host)/schedule") {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                print("schedule fetch error: \(error!.localizedDescription)")
                done(nil)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("not HTTP response")
                done(nil)
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                print("bad status code: \(response.statusCode)")
                done(nil)
                return
            }
            guard let data = data else {
                print("nil data response")
                done(nil)
                return
            }
            guard let schedule: [TimedAction] = try? JSONDecoder().decode([TimedAction].self, from: data) else {
                print("unable to decode response")
                if let d = String(data: data, encoding: .utf8) {
                    print(d)
                }
                done(nil)
                return
            }
            done(schedule)
        }.resume()
    }
}

public func LSDeleteSchedule(_ host: String, id: String, _ done: @escaping([TimedAction]?) -> Void) {
    if let url = URL(string: "\(host)/schedule/\(id)") {
        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: req) { data, response, error in
            guard error == nil else {
                print("initial error: \(error!.localizedDescription)")
                done(nil)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("not HTTP response")
                done(nil)
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                print("bad status code: \(response.statusCode)")
                done(nil)
                return
            }
            guard let data = data else {
                print("got nil response after sending")
                done(nil)
                return
            }
            guard let sched = try? JSONDecoder().decode([TimedAction].self, from: data) else {
                print("unable to decode response")
                done(nil)
                return
            }
            done(sched)
        }.resume()
    }
}

public func LSCreateScheduled(_ host: String, _ timer: TimedAction, _ done: @escaping ([TimedAction]?) -> Void) {
    guard let json = try? JSONEncoder().encode(timer) else {
        print("error encoding JSON")
        done(nil)
        return
    }
    
    if let url = URL(string: "\(host)/schedule") {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = json
        URLSession.shared.dataTask(with: req) { data, response, error in
            guard error == nil else {
                print("initial error: \(error!.localizedDescription)")
                done(nil)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("not HTTP response")
                done(nil)
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                print("bad status code: \(response.statusCode)")
                done(nil)
                return
            }
            guard let data = data else {
                print("got nil response after sending")
                done(nil)
                return
            }
            guard let resp = try? JSONDecoder().decode([TimedAction].self, from: data) else {
                print("unable to decode response")
                done(nil)
                return
            }
            done(resp)
        }.resume()
    }
}

public func LSUpdateScheduled(_ host: String, _ timer: TimedAction, _ done: @escaping ([TimedAction]?) -> Void) {
    guard let json = try? JSONEncoder().encode(timer) else {
        print("error encoding JSON")
        done(nil)
        return
    }
    guard timer.id != nil else {
        print("timer missing ID")
        done(nil)
        return
    }
    
    if let url = URL(string: "\(host)/schedule/\(timer.id!)") {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody = json
        URLSession.shared.dataTask(with: req) { data, response, error in
            guard error == nil else {
                print("initial error: \(error!.localizedDescription)")
                done(nil)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                print("not HTTP response")
                done(nil)
                return
            }
            guard response.statusCode >= 200 && response.statusCode < 300 else {
                print("bad status code: \(response.statusCode)")
                done(nil)
                return
            }
            guard let data = data else {
                print("got nil response after sending")
                done(nil)
                return
            }
            guard let resp = try? JSONDecoder().decode([TimedAction].self, from: data) else {
                print("unable to decode response")
                done(nil)
                return
            }
            done(resp)
        }.resume()
    }
}

public class Light: UIView {
    let onColor: UIColor
    let offColor: UIColor
    public var on: Bool = false {
        didSet {
            backgroundColor = on ? onColor : offColor
            if on {
                layer.shadowOffset = .zero
                layer.shadowColor = onColor.cgColor
                layer.shadowRadius = 20
                layer.shadowOpacity = 1
                layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
                alpha = 1
            } else {
                layer.shadowOpacity = 0
                alpha = 0.25
            }
        }
    }
    
    required init?(coder: NSCoder) {
        onColor = .black
        offColor = .black
        super.init(coder: coder)
    }
    
    public init(onColor: UIColor, offColor: UIColor) {
        self.onColor = onColor
        self.offColor = offColor
        super.init(frame: .zero)
        backgroundColor = offColor
        translatesAutoresizingMaskIntoConstraints = false
    }
}

public class CircleLight: Light {
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = CGFloat(self.bounds.size.width / 2.0)
    }
}
