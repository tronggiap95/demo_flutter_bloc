////
////  CoreDataHelper.swift
////  OctoBeat-clinic-ios
////
////  Created by Manh Tran on 16/06/20.
////  Copyright © 2020 itr.vn. All rights reserved.
////
//
//import Foundation
//import UIKit
//import CoreData
//
//class CoreDataHelper {
//    public static let shared = CoreDataHelper()
//    func getManagedContext() -> NSManagedObjectContext {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.persistentContainer.viewContext
//    }
//    
//    func fetchDevices() -> [DeviceDisplay]{
//        let fetchRequest: NSFetchRequest<Device> =
//        Device.fetchRequest()
//        do {
//            let devices = try getManagedContext().fetch(fetchRequest)
//            var deviceDisplays: [DeviceDisplay] = []
//            devices.forEach{
//                device in
//                //                print("fetchDevices \(device.studyStatus)")
//                CoreManager.sharedInstance.shouldHideDevice(studyStatus: device.studyStatus) { shouldHide in
//                    if shouldHide {
//                        self.deleteAllDevices()
//                    } else {
//                        deviceDisplays.append(DeviceDisplay(deviceName: device.name!, deviceId: device.id))
//                    }
//                }
//            }
//            return deviceDisplays
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//            return []
//        }
//    }
//    
//    func saveDevice(dv: DeviceDisplay) {
//        DispatchQueue.main.async {
//            if let device = self.fetchSpecificDeviceByID(deviceID: dv.deviceName) {
//                device.name = dv.deviceName
//                device.id = dv.deviceId
//                device.studyStatus = dv.deviceStatus?.studyStatus ?? ""
//                device.facilityName = dv.facility?.name ?? device.facilityName
//                device.facilityId = dv.facility?.facilityID ?? device.facilityId
//            } else {
//                let managedContext = self.getManagedContext()
//                let entity = NSEntityDescription.entity(forEntityName: "Device", in: managedContext)!
//                let device = Device(entity: entity, insertInto: managedContext)
//                device.name = dv.deviceName
//                device.id = dv.deviceId
//                device.facilityName = dv.facility?.name
//                device.facilityId = dv.facility?.facilityID
//                do {
//                    try managedContext.save()
//                } catch let error as NSError {
//                    print("Could not save. \(error), \(error.userInfo)")
//                }
//            }
//        }
//    }
//    
//    func saveAllDevices(devices: [DeviceDisplay]) {
//        deleteAllDevices()
//        for item in devices {
//            saveDevice(dv: item)
//        }
//    }
//    
//    func updateDevice(deviceDisplay: DeviceDisplay){
//        if let id = deviceDisplay.deviceName, let device = self.fetchSpecificDeviceByID(deviceID: id) {
//            device.studyStatus = deviceDisplay.deviceStatus?.studyStatus
//            device.id = deviceDisplay.deviceId
//            device.facilityName = deviceDisplay.facility?.name ?? device.facilityName
//            device.facilityId = deviceDisplay.facility?.facilityID ?? device.facilityId
//            do {
//                try self.getManagedContext().save()
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
//        }
//    }
//    
//    func deleteDevice(uuid: UUID) {
//        DispatchQueue.main.async {
//            let managedContext = self.getManagedContext()
//            if let device = self.fetchSpecificDevice(uuid: uuid) {
//                managedContext.delete(device)
//                do {
//                    try managedContext.save()
//                } catch let error as NSError {
//                    print("Could not save. \(error), \(error.userInfo)")
//                }
//            }
//        }
//    }
//    
//    func deleteAllDevices() {
//        DispatchQueue.main.async {
//            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
//            let request = NSBatchDeleteRequest(fetchRequest: fetch)
//            do {
//                _ = try self.getManagedContext().execute(request)}
//            catch let error as NSError {
//                print("Could not delete all. \(error), \(error.userInfo)")
//            }
//        }
//    }
//    
//    func fetchSpecificDeviceByID(deviceID: String) -> Device? {
//        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "name == %@", deviceID)
//        //3
//        do {
//            let devices = try getManagedContext().fetch(fetchRequest)
//            if(devices.count > 0) {
//                return devices[0]
//            } else {
//                return nil
//            }
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//            return nil
//        }
//    }
//    
//    func fetchSpecificDevice(uuid: UUID) -> Device? {
//        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
//        //3
//        do {
//            let devices = try getManagedContext().fetch(fetchRequest)
//            if(devices.count > 0) {
//                return devices[0]
//            } else {
//                return nil
//            }
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//            return nil
//        }
//    }
//    
//    func saveFacility(name: String, id: String) {
//        DispatchQueue.main.async {
//            let managedContext = self.getManagedContext()
//            let entity = NSEntityDescription.entity(forEntityName: "Facility", in: managedContext)!
//            let facility = Facility(entity: entity, insertInto: managedContext)
//            facility.name = name
//            facility.id = id
//            do {
//                try managedContext.save()
//            } catch let error as NSError {
//                print("Could not save. \(error), \(error.userInfo)")
//            }
//        }
//    }
//    
//    func saveFacilities(facilities: [DisplayFacility]) {
//        deleteAllFacilities()
//        for item in facilities {
//            self.saveFacility(name: item.name, id: item.facilityID)
//        }
//    }
//    
//    func fetchFacilities() -> [DisplayFacility]{
//        let fetchRequest: NSFetchRequest<Facility> =
//        Facility.fetchRequest()
//        do {
//            let facilities = try getManagedContext().fetch(fetchRequest)
//            var facilityDisplays: [DisplayFacility] = []
//            facilities.forEach{
//                facility in
//                facilityDisplays.append(DisplayFacility(facilityID: facility.id ?? "", name: facility.name ?? "", status: "Active"))
//            }
//            return facilityDisplays
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//            return []
//        }
//    }
//    
//    func deleteAllFacilities() {
//        DispatchQueue.main.async {
//            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Facility")
//            let request = NSBatchDeleteRequest(fetchRequest: fetch)
//            do {
//                _ = try self.getManagedContext().execute(request)}
//            catch let error as NSError {
//                print("Could not delete all. \(error), \(error.userInfo)")
//            }
//        }
//    }
//}
