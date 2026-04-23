//
//  Observers.swift
//  Grocery Management
//
//  Created by mac on 02/06/2025.
//
protocol DataObserver{
    func NotifyData()
}
class ObservableDataManager<T: Equatable> {
    private var data: T?
    private var observers = [DataObserver]()

    func setData(_ newData: T) {
       
        notifyObservers()
    }

    func getData() -> T? {
        return data
    }

    func addObserver(_ observer: DataObserver) {
        observers.append(observer)
    }

    private func notifyObservers() {
        observers.forEach { $0.NotifyData() }
    }
}
