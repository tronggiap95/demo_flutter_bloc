//
//  HeartBeatAlgorithm.swift
//  OctoBeat-clinic-ios
//
//  Created by Manh Tran on 24/06/20.
//  Copyright © 2020 itr.vn. All rights reserved.
//

import Foundation

class HeartBeatAlgorithm {
    
    private static func lfilter(x: [Double], a: [Double], b: [Double], zi: [Double]) -> [Double]? {
        if(a.count != b.count) {
            return nil
        }
        
        var y = [Double](repeating: 0, count: x.count)
        let N = a.count
        var d = [Double](repeating: 0, count: N)
        
        if (copyArray(source: zi, sourcePos: 0, des: &d, desPos: 0, count: zi.count)) {
            for n in 0..<x.count {
                y[n] = b[0] * x[n] + d[0]
                for f in 1..<N {
                    if d.count > f {
                        d[f - 1] = b[f] * x[n] - a[f] * y[n] + d[f]
                    } else {
                        d[f-1] = b[f] * x[n] - a[f] * y[n]
                    }
                }
            }
            return y
        }
        return nil
    }
    
    private static func copyArray(source: [Double], sourcePos: Int, des: inout [Double], desPos: Int, count: Int) -> Bool {
        if (des.count < desPos + count || source.count < sourcePos + count) {
            return false
        }
        
        var j = sourcePos
        for i in desPos..<(desPos + count) {
            des[i] = source[j]
            j += 1
        }
        
        return true
    }
    
    
    private static func filtFilt(data: [Double], a_0: [Double], b_0: [Double]) -> [Double]? {
        let prepareFilterList = prepare_for_lfilter(a: a_0, b: b_0)
        var a = prepareFilterList[0]
        let b = prepareFilterList[1]
        
        let zi = lfilter_z(a: &a, b: b)
        
        let additionalLength = a.count * 3
        let endOfData = additionalLength + data.count
        var x = [Double](repeating: 0, count: data.count + additionalLength * 2)
        if(!copyArray(source: data, sourcePos: 0, des: &x, desPos: additionalLength, count: data.count))  {
            return nil
        }
        for i in 0..<additionalLength {
            x[additionalLength - i - 1] = (x[additionalLength] * 2) - x[additionalLength + i + 1]
            x[endOfData + i] = (x[endOfData - 1] * 2) - x[endOfData - i - 2]
        }
        
        //Calculate the initial values for the given sequence
        var zi_ = [Double](repeating: 0, count: zi.count)
        for i in 0..<zi.count {
            zi_[i] = zi[i] * x[0]
        }
        
        if let y = lfilter(x: x, a: a, b: b, zi: zi_) {
            var y_flipped = [Double](repeating: 0, count: y.count)
            for i in 0..<y_flipped.count {
                y_flipped[i] = y[y.count - i - 1]
            }
            for i in 0..<zi.count {
                zi_[i] = zi[i] * y_flipped[0]
            }
            if let y = self.lfilter(x: y_flipped, a: a, b: b, zi: zi_) {
                var y_flipped = [Double](repeating: 0, count: data.count)
                
                //reverse it again and return
                for i in 0..<y_flipped.count {
                    y_flipped[i] = y[endOfData - i - 1]
                }
                return y_flipped
            }
        }
        
        return nil
    }
    
    private static func createRange(start: Int, count: Int) -> [Int]? {
        if (start + count - 1) > Int.max {
            return nil
        }
        
        if count >= 0 {
            var result = [Int](repeating: 0, count: count)
            for i in start..<(start + count) {
                result[i] = i
            }
            return result
        }
        
        return nil
    }
    
    private static func prepare_for_lfilter(a: [Double], b: [Double]) -> Array<[Double]> {
        let n = max(a.count, b.count)
        var a_temp = [Double](repeating: 0, count: n)
        var b_temp = [Double](repeating: 0, count: n)
        
        if a.count < n {
            for i in 0..<n {
                if i < a.count {
                    a_temp[i] = a[i]
                } else {
                    a_temp[i] = 0.0
                }
                b_temp[i] = b[i]
            }
        } else if b.count < n {
            for i in 0..<n {
                if i < b.count {
                    b_temp[i] = b[i]
                } else {
                    b_temp[i] = 0.0
                }
                a_temp[i] = a[i]
            }
        }
        
        var temp: Double
        if 0.0 != a[0] {
            temp =  a[0]
        } else {
            temp = 1.0
        }
        
        for i in 0..<n {
            a_temp[i] /= temp
            b_temp[i] /= temp
        }
        
        return [a_temp, b_temp]
    }
    
    private static func lfilter_z(a: inout [Double], b: [Double]) -> [Double] {
        var IminusA = [[Double]]()
        for _ in 0..<(a.count - 1) {
            IminusA.append([Double](repeating: 0, count: a.count - 1))
        }
        for i in 0..<(a.count - 1) {
            IminusA[i][i]  = 1.0
        }
        
        if a[0] == 0.0 {
            a[0] = 1.0
        }
        
        var linalg = [[Double]]()
        for _ in 0..<(a.count - 1) {
            linalg.append([Double](repeating: 0, count: a.count - 1))
        }
        
        for j in 0..<(a.count - 1) {
            for i in 0..<(a.count - 1) {
                if j == 0 {
                    linalg[i][j] = -a[i+1]/a[0]
                } else {
                    linalg[j-1][j] = 1.0
                }
                IminusA[i][j] -= linalg[i][j]
            }
        }
        
        var B = [Double](repeating: 0, count: a.count - 1)
        for i in 1..<a.count {
            if i < b.count {
                B[i - 1] = b[i] - a[i] * b[0]
            } else {
                B[i - 1] = -(a[i] * b[0])
            }
        }
        
        var zi = [Double](repeating: 0, count: a.count - 1)
        var Iminus_sum = 0.0
        for i in 0..<(a.count - 1) {
            Iminus_sum += IminusA[i][0]
        }
        
        zi[0] = B.reduce(0, +) / Iminus_sum
        var asum = 1.0
        var csum = 0.0
        for i in 0..<(a.count - 1) {
            asum += a[i]
            if b.count > i {
                csum += b[i] - a[i] * b[0]
                zi[i] = asum * zi[0] - csum
            } else {
                zi[i] = Double.nan
            }
        }
        return zi
    }
    
    private static func signal_ricker(point: Double, a: Double) -> [Double]? {
        
        //point: Number of points in vector. Will be centered around 0
        //a: Width parameter of the wavelet
        
        let A = 2 / (sqrt(3.0 * a) * pow(Double.pi, 0.25))
        let wsq = pow(a, 2.0)
        var vec = [Double]()
        var xsq = [Double]()
        var mod = [Double]()
        var gauss = [Double]()
        var total = [Double]()
        if  let arrange_point = createRange(start: 0, count: Int(point)) {
            for index in 0..<arrange_point.count {
                vec.append(Double(arrange_point[index]) - ((point - 1.0) / 2.0))
                xsq.append(pow(vec[vec.count - 1], 2.0))
                mod.append(1 - (xsq[xsq.count - 1] / wsq))
                gauss.append(exp(-xsq[xsq.count - 1] / (2 * wsq)))
                total.append(A * mod[mod.count - 1] * gauss[gauss.count - 1])
            }
            
            return total
        }
        
        return nil
    }
    
    private static func Butterworth_bandpass(data: [Double]) -> [Double]? {
        var filt_data = [Double](repeating: 0, count: data.count)
        let Nzeros = 6
        let Npoles = 6
        
        let GAIN = 6.380888203e+02
        
        var xv = [Double](repeating: 0.0, count: Nzeros + 1)
        var yv = [Double](repeating: 0.0, count: Npoles + 1)
        
        for i in 0..<data.count {
            xv[0] = xv[1]
            xv[1] = xv[2]
            xv[2] = xv[3]
            xv[3] = xv[4]
            xv[4] = xv[5]
            xv[5] = xv[6]
            xv[6] = data[i] / GAIN
            yv[0] = yv[1]
            yv[1] = yv[2]
            yv[2] = yv[3]
            yv[3] = yv[4]
            yv[4] = yv[5]
            yv[5] = yv[6]
            
            yv[6] = (xv[6] - xv[0]) + (3.0 * (xv[2] - xv[4]))
            yv[6] += (-0.6041096995 * yv[0]) + (3.8344265750 * yv[1])
            yv[6] += (-10.2563232650 * yv[2]) + (14.7947956750 * yv[3])
            yv[6] += (-12.1370614820 * yv[4]) + (5.3681892278 * yv[5])
            
            filt_data[i] = yv[6]
        }
        
        xv = [Double](repeating: 0.0, count: Nzeros + 1)
        yv = [Double](repeating: 0.0, count: Npoles + 1)
        
        var back_filt_data = [Double](repeating: 0.0, count: data.count)
        for i in stride(from: filt_data.count - 1, to: -1, by: -1) {
            xv[0] = xv[1]
            xv[1] = xv[2]
            xv[2] = xv[3]
            xv[3] = xv[4]
            xv[4] = xv[5]
            xv[5] = xv[6]
            xv[6] = filt_data[i] / GAIN
            yv[0] = yv[1]
            yv[1] = yv[2]
            yv[2] = yv[3]
            yv[3] = yv[4]
            yv[4] = yv[5]
            yv[5] = yv[6]
            yv[6] = (xv[6] - xv[0]) + 3.0 * (xv[2] - xv[4])
            yv[6] += (-0.6041096995 * yv[0]) + (3.8344265750 * yv[1])
            yv[6] += (-10.2563232650 * yv[2]) + (14.7947956750 * yv[3])
            yv[6] += (-12.1370614820 * yv[4]) + (5.3681892278 * yv[5])
            back_filt_data[i] = yv[6]
        }
        
        return back_filt_data
    }
    
    private static func return_real_value(ecgData: [Float], mitGain: Double) -> [Double] {
        var ecg_output = [Double]()
        
        for i in 0..<ecgData.count {
            if Double(ecgData[i]) / mitGain != Double.nan {
                ecg_output.append(Double(ecgData[i]) / mitGain)
            } else {
                ecg_output.append(Double.greatestFiniteMagnitude)
            }
        }
        
        return ecg_output
    }
    
    private static func find_peaks(sig: [Double], threshold: Double, distance: Double) -> [Int] {
        var peaks = [Int]()
        var i = 0
        let radius: Int = Int(distance)
        
        while i < (radius + 1) {
            if sig[i] == getRange(arr: sig, index: 0, count: i + radius)?.max() {
                peaks.append(i)
                i += radius
            } else {
                i += 1
            }
        }
        
        while  i < sig.count {
            if sig[i] == getRange(arr: sig, index: i - radius, count: min(radius * 2, sig.count - (i - radius)))?.max() {
                peaks.append(i)
                i += radius
            } else {
                i += 1
            }
        }
        
        return peaks
    }
    
    private static func list_from_list(ecg: [Double],  locs: [Int]) -> [Double] {
        var new_list = [Double]()
        for i in 0..<locs.count {
            new_list.append(ecg[locs[i]])
        }
        
        return new_list
    }
    
    private static func remove_high_sample(ecg: inout [Double]) -> [Double] {
        let Average = ecg.average()
        for i in 0..<ecg.count {
            if abs(ecg[i]) > abs(Average * 2) {
                ecg[i] = Average * 2
            }
        }
        
        return ecg
    }
    
    struct MaxLocate {
        var y_i: Double = 0.0
        var i_l: [Double] = []
        var x_i: Double  = 0.0
    }
    
    private static func find_max_locate(ecg_array: [Double]) -> MaxLocate {
        var y_i: Double
        var i_l: [Double]
        var x_i: Double
        
        if !ecg_array.isEmpty {
            y_i = ecg_array.max()!
            i_l = ecg_array.filter{
                $0 == y_i
            }
            x_i = i_l[0]
        } else {
            y_i = 0.0
            i_l = ecg_array
            x_i = 0.0
        }
        
        return MaxLocate(y_i: y_i, i_l: i_l, x_i: x_i)
    }
    
    private static func diff_int(array: [Int]) -> [Int] {
        var newArr = [Int]()
        
        for i in 0..<(array.count - 1) {
            newArr.append(array[i + 1] - array[i])
        }
        
        return newArr
    }
    
    private static func pow_list(ecg: inout [Double]) -> [Double] {
        for i in 0..<ecg.count {
            ecg[i] = pow(ecg[i], 2.0)
        }
        return ecg
    }
    
    private static func getBeatMarkersArr(samplingRate: Int, gain: Double, ecgData: [Float]) -> [Int]? {
        var ecg_m: [Double]
        var ecg_h: [Double]
        var ecg_d: [Double]
        
        let new_ecg = return_real_value(ecgData: ecgData, mitGain: gain)
        let ecg_h_ = Butterworth_bandpass(data: new_ecg)
        if ecg_h_ == nil {
            return nil
        }
        ecg_h = ecg_h_!
        let a = [Double](repeating: 1.0, count: 1)
        let wavelet_filter = signal_ricker(point: 0.1 * Double(samplingRate), a: 4.0)
        if wavelet_filter == nil {
            return nil
        }
        let ecg_d_ = filtFilt(data: ecg_h, a_0: a, b_0: wavelet_filter!)
        if ecg_d_ == nil {
            return nil
        }
        ecg_d = ecg_d_!
        ecg_m = pow_list(ecg: &(ecg_d))
        
        let locs = find_peaks(sig: ecg_m, threshold: 0.00000000001, distance: Double(samplingRate) * 0.22)
        var pks = list_from_list(ecg: ecg_m, locs: locs)
        pks = remove_high_sample(ecg: &pks)
        
        var qrs_c = [Double]()
        var qrs_i = [Int]()
        var qrs_i_raw = [Int]()
        var qrs_amp_raw = [Double]()
        var noise_c = [Double]()
        var noise_i = [Int]()
        
        var x = 0
        var x1: [Int]
        var skip = 0
        var ser_back = 0
        var y_i = 0.0
        var x_i = 0.0
        let thr_sig_range = getRange(arr: ecg_m, index: 0, count: 2 * samplingRate)
        if thr_sig_range == nil {
            return nil
        }
        var THR_SIG = thr_sig_range!.max()! * 1/3
        let thr_noise_range = getRange(arr: ecg_m, index: 0, count: 2 * samplingRate)
        if thr_noise_range == nil {
            return nil
        }
        var THR_NOISE = thr_noise_range!.average() * 1/2
        var SIG_LEV = THR_SIG
        var NOISE_LEV = THR_NOISE
        let thr_sig1_range = getRange(arr: ecg_h, index: 0, count: 2 * samplingRate)
        if thr_sig1_range == nil {
            return nil
        }
        var THR_SIG1 = thr_sig1_range!.max()! * 1/3
        let thr_noise1_range = getRange(arr: ecg_h, index: 0, count: 2 * samplingRate)
        if thr_noise1_range == nil {
             return nil
        }
        var THR_NOISE1 = thr_noise1_range!.average() * 1/2
        var SIG_LEV1 = THR_SIG1
        var NOISE_LEV1 = THR_NOISE1
        var m_selected_RR = 0.0
        var meanRR = 0.0
        
        for peak_index in 0..<pks.count {
            var ecg_array: [Double]?
            ser_back = 0
            if locs[peak_index] - Int(round(0.150 * Double(samplingRate))) >= 1 &&
                locs[peak_index] <= ecg_h.count - 1 {
                ecg_array = getRange(arr: ecg_h, index: locs[peak_index] - Int(round(0.150 * Double(samplingRate))) , count: Int(round(0.150 * Double(samplingRate))) )
                if ecg_array == nil {
                    return nil
                }
                let result = find_max_locate(ecg_array: ecg_array!)
                y_i = result.y_i
                x_i = result.x_i
            } else {
                if peak_index == 0 {
                    ecg_array = getRange(arr:ecg_h, index: 0, count: locs[peak_index])
                    ser_back = 1
                } else if locs[peak_index] >= ecg_h.count {
                    ecg_array = getRange(arr: ecg_h, index: locs[peak_index] - Int(round(0.150 * Double(samplingRate))), count: ecg_h.count - (locs[peak_index] - Int(round(0.150 * Double(samplingRate)))))
                }
                if ecg_array != nil {
                    let result = find_max_locate(ecg_array: ecg_array!)
                    y_i = result.y_i
                    x_i = result.x_i
                } else {
                    y_i = 0.0
                    x_i = 0.0
                }
                
            }
            
            if(qrs_c != nil) {
                x = qrs_c.count
            } else {
                x = 0
            }
            
            if x >= 9 {
                let x_range = getRange(arr: qrs_i, index: x - 9, count: 9)
                if x_range == nil {
                    return nil
                }
                x1 = x_range!
                let diffRR = diff_int(array: x1)
                meanRR = diffRR.average()
                
                let comp = Double((qrs_i[qrs_i.count - 1] - qrs_i[qrs_i.count - 2]))
                if comp <= 0.92 * meanRR || comp >= 1.16 * meanRR {
                    THR_SIG *= 0.5
                    THR_SIG1 *= 0.5
                } else {
                    m_selected_RR = meanRR
                }
            }
            
            var test_m = -3000.0
            
            if m_selected_RR != 0.0 {
                test_m = m_selected_RR
            } else if meanRR != 0.0 && m_selected_RR == 0.0 {
                test_m = meanRR
            } else {
                test_m = 0.0
            }
            
            if test_m != 0.0 {
                if locs[peak_index] - qrs_i[qrs_i.count - 1] >= Int(round(1.66 * test_m)) {
                    let obj_range = getRange(arr: ecg_m, index: qrs_i[qrs_i.count - 1] + Int(round(0.2 * Double(samplingRate))), count: max(locs[peak_index] - Int(round(0.2 * Double(samplingRate))) - (qrs_i[qrs_i.count -   1] + Int(round(0.2 * Double(samplingRate)))), 0))
                    if obj_range == nil {
                        return nil
                    }
                    let obj = find_max_locate(ecg_array: obj_range!)
                    let pks_temp = obj.y_i
                    var locs_temp = obj.x_i
                    locs_temp = Double(qrs_i[qrs_i.count - 1]) + round(0.2 * Double(samplingRate)) + locs_temp - 1.0
                    if pks_temp > 1.75 * THR_NOISE {
                        qrs_c.append(pks_temp)
                        qrs_i.append(Int(locs_temp))
                    }
                    
                    var y_i_t: Double
                    var x_i_t: Double
                    
                    if Int(locs_temp) <= ecg_h.count {
                        let result_range = getRange(arr: ecg_h, index: Int(locs_temp) - Int(round(0.150 * Double(samplingRate))), count: Int(round(0.150 * Double(samplingRate))))
                        if result_range == nil {
                            return nil
                        }
                        let result = find_max_locate(ecg_array: result_range!)
                        y_i_t = result.y_i
                        x_i_t = result.x_i
                    } else {
                        let result_range = getRange(arr: ecg_h, index: Int(locs_temp) - Int(round(0.150 * Double(samplingRate))), count: Int(round(0.150 * Double(samplingRate))))
                        if result_range == nil {
                            return nil
                        }
                        let result = find_max_locate(ecg_array: result_range!)
                        y_i_t = result.y_i
                        x_i_t = result.x_i
                    }
                    
                    if(y_i_t > THR_NOISE) {
                        qrs_i_raw.append(Int(locs_temp) - Int(round(0.150 * Double(samplingRate))) + Int(x_i_t - 1.0))
                        qrs_amp_raw.append(y_i_t)
                        SIG_LEV1 = 0.25 * y_i_t + 0.75 * SIG_LEV1
                    }
                    
                    SIG_LEV = 0.25 * pks_temp + 0.75 * SIG_LEV
                
                }
            }
            if pks[peak_index] >= THR_SIG {
                skip = 0
                if qrs_c.count >= 3 {
                    if locs[peak_index] - qrs_i[qrs_i.count - 1] <= Int(round(0.3600 * Double(samplingRate))) {
                        let slope1_array = diff_double(array: getRange(arr: ecg_m, index: locs[peak_index] - Int(round(0.075 * Double(samplingRate))), count: Int(round(0.075 * Double(samplingRate))))!)
                        let slope1 = slope1_array.average()
                        let slope2_array_range = getRange(arr: ecg_m, index: qrs_i[qrs_i.count - 1] - Int(round(0.075 * Double(samplingRate))), count: Int(round(0.075 * Double(samplingRate))))
                        if slope2_array_range == nil {
                            return nil
                        }
                        let slope2_array = diff_double(array: slope2_array_range!)
                        let slope2 = slope2_array.average()
                        if abs(slope1) <= abs(0.5 * slope2) {
                            noise_c.append(pks[peak_index])
                            noise_i.append(locs[peak_index])
                            skip = 1
                            NOISE_LEV1 = 0.125 * y_i + 0.875 * NOISE_LEV1
                            NOISE_LEV = 0.125 * pks[peak_index] + 0.875 * NOISE_LEV
                        } else {
                            skip = 0
                        }
                    }
                }
                
                if skip == 0 {
                    qrs_c.append(pks[peak_index])
                    qrs_i.append(locs[peak_index])
                    if y_i >= THR_SIG1 {
                        if ser_back == 1 {
                            qrs_i_raw.append(Int(x_i))
                        } else {
                            qrs_i_raw.append(Int(round(Double(locs[peak_index]) - 0.150 * Double(samplingRate) + Double(x_i - 1))))
                        }
                    }
                    qrs_amp_raw.append(y_i)
                    SIG_LEV1 = 0.125 * y_i + 0.875 * SIG_LEV1
                }
                
                SIG_LEV = 0.125 * pks[peak_index] + 0.875 * SIG_LEV
            } else if THR_NOISE <= pks[peak_index] && pks[peak_index] < THR_SIG {
                NOISE_LEV1 = 0.125 * y_i + 0.875 * SIG_LEV1
                NOISE_LEV = 0.125 * pks[peak_index] + 0.875 * NOISE_LEV
            } else if pks[peak_index] < THR_NOISE {
                noise_c.append(pks[peak_index])
                noise_i.append(locs[peak_index])
                NOISE_LEV1 = 0.125 * y_i + 0.875 * NOISE_LEV1
                NOISE_LEV = 0.125 * pks[peak_index] + 0.875 + NOISE_LEV
            }
            
            if NOISE_LEV != 0.0 || SIG_LEV != 0.0 {
                THR_SIG = NOISE_LEV + 0.25 * abs(SIG_LEV - NOISE_LEV)
                THR_NOISE = 0.5 * THR_SIG
            }
            
            if NOISE_LEV1 != 0 || SIG_LEV1 != 0.0 {
                THR_SIG1 = NOISE_LEV1 + 0.25 * abs(SIG_LEV1 - THR_NOISE1)
                THR_NOISE1 = 0.5 * THR_SIG1
            }
            
        }
        
        return qrs_i
        
    }

    private static func diff_double(array: [Double]) -> [Double] {
        var newArr = [Double]()
        
        for i in 0..<(array.count - 1) {
            newArr.append(array[i+1] - array[i])
        }
        
        return newArr
    }
    
   private static func calculatingAVGHeartBeat(samplingRate: Int, list: [Int]) -> Int{
        var listAvg = [Int]()
        for i in 1..<list.count {
            let avg = (60 * samplingRate) / (list[i] - list[i - 1])
            listAvg.append(avg)
        }
        return listAvg.average()
    }
    
    public static func CalculateHeartBeat(samplingRate: Int, gain: Double, ecgData: [Float]) -> Int? {
        if let list = getBeatMarkersArr(samplingRate: samplingRate, gain: gain, ecgData: ecgData) {
            if list.count > 1 {
                return calculatingAVGHeartBeat(samplingRate: samplingRate, list: list)
            } else {
                return nil
            }
        }
        return nil
    }
    
    
}

extension HeartBeatAlgorithm {
    public static  func getRange(arr: [Double], index: Int, count: Int) -> [Double]? {
        return copyOfRange(arr: arr, from: index, to: index +  count)
    }
    
    private static  func getRange(arr: [Int], index: Int, count: Int) -> [Int]? {
        return copyOfRange(arr: arr, from: index, to: index + count)
    }
    private static func copyOfRange<T>(arr: [T], from: Int, to: Int) -> [T]? where T: ExpressibleByIntegerLiteral {
        guard from >= 0 && from <= arr.count && from <= to else { return nil }
        
        var to = to
        var padding = 0
        
        if to > arr.count {
            padding = to - arr.count
            to = arr.count
        }
        
        return Array(arr[from..<to]) + [T](repeating: 0, count: padding)
    }
}
