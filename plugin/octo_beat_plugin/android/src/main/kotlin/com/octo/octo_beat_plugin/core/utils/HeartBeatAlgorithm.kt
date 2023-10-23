package com.octo.octo_beat_plugin.core.utils

import java.util.*
import kotlin.collections.ArrayList
import kotlin.math.*

class HeartBeatAlgorithm {

    companion object {

        @Throws(ArrayIndexOutOfBoundsException::class)
        fun lfilter(x: DoubleArray, a: DoubleArray, b: DoubleArray, zi: DoubleArray): DoubleArray? {
            if (a.size !== b.size) {
                throw ArrayIndexOutOfBoundsException()
            }

            val y = DoubleArray(x.size)
            val N = a.size
            val d = DoubleArray(N)
            // zi.CopyTo(d, 0);
            copyArray(zi, 0, d, 0, zi.size);

            for (n in 0 until x.size) {
                y[n] = b[0] * x[n] + d[0];
                for (f in 1 until N) {
                    if (d.size > f) {
                        d[f - 1] = b[f] * x[n] - a[f] * y[n] + d[f];
                    } else {
                        d[f - 1] = b[f] * x[n] - a[f] * y[n]
                    }
                }
            }
            return y;
        };

        fun FiltFilt(data: DoubleArray, a_0: DoubleArray, b_0: DoubleArray): DoubleArray {
            val prepareFilterList = Prepare_for_lfilter(a_0, b_0);
            val a = prepareFilterList.get(0)
            val b = prepareFilterList.get(1)

            val zi = lfilter_zi(a, b);
            // Pad the data with 3 times the filter length on both sides by rotating the data by 180°
            val additionalLength = a.size * 3
            val endOfData = additionalLength + data.size
            val x = DoubleArray(data.size + additionalLength * 2);
            copyArray(data, 0, x, additionalLength, data.size);
            for (i in 0 until additionalLength) {
                x[additionalLength - i - 1] = (x[additionalLength] * 2) - x[additionalLength + i + 1];
                x[endOfData + i] = (x[endOfData - 1] * 2) - x[endOfData - i - 2];
            }
            // Calculate the initial values for the given sequence
            val zi_ = DoubleArray(zi.size)
            for (i in 0 until zi.size) {
                zi_[i] = zi[i] * x[0];
            }

            var y = lfilter(x, a, b, zi_)
            var y_flipped = DoubleArray(y?.size!!)
            // reverse the data and filter again
            for (i in 0 until y_flipped.size) {
                y_flipped[i] = y[y.size - i - 1]
            }
            for (i in 0 until zi.size) {
                zi_[i] = zi[i] * y_flipped[0]
            }
            y = lfilter(y_flipped, a, b, zi_)
            y_flipped = DoubleArray(data.size)

            // rereverse it again and return
            for (i in 0 until y_flipped.size) {
                y_flipped[i] = y!![endOfData - i - 1]
            }

            return y_flipped
        }

        @Throws(ArrayIndexOutOfBoundsException::class)
        private fun copyArray(source: DoubleArray, sourcePos: Int, des: DoubleArray, desPos: Int, count: Int) {
            if (des.size < desPos + count || source.size < sourcePos + count) {
                throw ArrayIndexOutOfBoundsException()
            }

            var j = sourcePos
            for (i in desPos until (desPos + count)) {
                des[i] = source[j]
                j += 1
            }
        }

        @Throws(ArithmeticException::class)
        fun createRange(start: Int, count: Int): IntArray? {
            if (start + count - 1 > Int.MAX_VALUE) {
                throw ArithmeticException()
                return null
            }

            if (count >= 0) {
                var result = IntArray(count)
                for (i in start until start + count) {
                    result[i] = i
                }

                return result
            }

            return null
        }

        fun Prepare_for_lfilter(a: DoubleArray, b: DoubleArray): List<DoubleArray> {
            val n = max(a.size, b.size)
            val a_temp = DoubleArray(n)
            val b_temp = DoubleArray(n)

            if (a.size < n) {
                for (i in 0 until n) {
                    if (i < a.size) {
                        a_temp[i] = a[i];
                    } else {
                        a_temp[i] = 0.0
                    }
                    b_temp[i] = b[i];
                }
            } else if (b.size < n) {
                for (i in 0 until n) {
                    if (i < b.size) {
                        b_temp[i] = b[i];
                    } else {
                        b_temp[i] = 0.0
                    }
                    a_temp[i] = a[i];
                }
            }

            val temp: Double = if (0.0 !== a[0]) {
                a[0]; } else {
                1.0; }

            for (i in 0 until n) {
                a_temp[i] /= temp;
                b_temp[i] /= temp;
            }

            // eslint-disable-next-line no-param-reassign
            // a = a_temp;
            // eslint-disable-next-line no-param-reassign
            // b = b_temp;

            return listOf(a_temp, b_temp)
        }

        fun lfilter_zi(a: DoubleArray, b: DoubleArray): DoubleArray {
            // Prepare_for_lfilter(ref a, ref b);
            // const IminusA = [Array(a.length - 1).fill(0), Array(a.length - 1).fill(0)];
            val IminusA = arrayListOf<DoubleArray>()
            for (i in 0 until (a.size - 1)) {
                IminusA.add(DoubleArray(a.size - 1))
            }
            for (i in 0 until a.size - 1) {
                IminusA[i][i] = 1.0;
            }
            if (a[0] === 0.0) {
                a[0] = 1.0; }

            // const linalg = [Array(a.length - 1), Array(a.length - 1)];
            val linalg = arrayListOf<DoubleArray>()
            for (i in 0 until (a.size - 1)) {
                linalg.add(DoubleArray(a.size - 1))
            }

            for (j in 0 until (a.size - 1)) {
                for (i in 0 until (a.size - 1)) {
                    if (j === 0) {
                        linalg[i][j] = -a[i + 1] / a[0];
                    } else {
                        linalg[j - 1][j] = 1.0;
                    }
                    IminusA[i][j] -= linalg[i][j];
                }
            }
            val B = DoubleArray(a.size - 1);
            for (i in 1 until a.size) {
                if (i < b.size) {
                    B[i - 1] = b[i] - a[i] * b[0];
                } else {
                    B[i - 1] = -(a[i] * b[0]);
                }
            }
            val zi = DoubleArray(a.size - 1)
            var Iminus_sum = 0.0
            for (i in 0 until (a.size - 1)) {
                Iminus_sum += IminusA[i][0];
            }
            zi[0] = B.sum() / Iminus_sum
            var asum = 1.0
            var csum = 0.0
            for (i in 0 until (a.size - 1)) {
                asum += a[i]

                if (b.size > i) {
                    csum += b[i] - a[i] * b[0];
                    zi[i] = asum * zi[0] - csum;
                } else {
                    zi[i] = Double.NaN
                }
            }
            return zi
        }

        fun Signal_ricker(point: Double, a: Double): DoubleArray {
            // point: Number of points in `vector`. Will be centered around 0.
            // a: Width parameter of the wavelet
            val A = 2 / (sqrt(3.0 * a) * Math.pow(Math.PI, 0.25));
            val wsq = Math.pow(a, 2.0);
            val arrange_point = createRange(0, point.toInt())
            val vec: ArrayList<Double> = ArrayList()
            val xsq: ArrayList<Double> = ArrayList()
            val mod: ArrayList<Double> = ArrayList()
            val gauss: ArrayList<Double> = ArrayList()
            val total: ArrayList<Double> = ArrayList()

            for (index in 0 until arrange_point!!.size) {
                vec.add(arrange_point!![index] - ((point - 1.0) / 2))
                xsq.add(Math.pow(vec[vec.size - 1], 2.0))
                mod.add(1 - (xsq[xsq.size - 1] / wsq))
                gauss.add(exp(-xsq[xsq.size - 1] / (2 * wsq)))
                total.add(A * mod[mod.size - 1] * gauss[gauss.size - 1])
            }

            return total.toDoubleArray()
        };

        fun Butterworth_bandpass(data: DoubleArray): DoubleArray? {
            val filt_data = DoubleArray(data.size)
            val Nzeros = 6
            val Npoles = 6
//             val GAIN = 9.263328319;
            val GAIN = 6.380888203e+02;
            // double GAIN = 2.697665960e+03;
            var xv = DoubleArray(Nzeros + 1)
            var yv = DoubleArray(Npoles + 1)
            // Array.Clear(xv, 0, xv.Length);
            // Array.Clear(yv, 0, yv.Length);

            xv.fill(0.0)
            yv.fill(0.0)
            for (i in 0 until data.size) {
                xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4]; xv[4] = xv[5]; xv[5] = xv[6];
                xv[6] = data[i] / GAIN;
                yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4]; yv[4] = yv[5]; yv[5] = yv[6];

                yv[6] = (xv[6] - xv[0]) + (3 * (xv[2] - xv[4]))
                yv[6] += (-0.6041096995 * yv[0]) + (3.8344265750 * yv[1])
                yv[6] += (-10.2563232650 * yv[2]) + (14.7947956750 * yv[3])
                yv[6] += (-12.1370614820 * yv[4]) + (5.3681892278 * yv[5]);

                filt_data[i] = yv[6]
            }

            // Array.Clear(xv, 0, xv.Length);
            // Array.Clear(yv, 0, yv.Length);
            xv.fill(0.0)
            yv.fill(0.0)
            val back_filt_data = DoubleArray(data.size)
            for (i in (filt_data.size - 1) downTo 0) {
                xv[0] = xv[1]; xv[1] = xv[2]; xv[2] = xv[3]; xv[3] = xv[4]; xv[4] = xv[5]; xv[5] = xv[6];
                xv[6] = filt_data[i] / GAIN;
                yv[0] = yv[1]; yv[1] = yv[2]; yv[2] = yv[3]; yv[3] = yv[4]; yv[4] = yv[5]; yv[5] = yv[6];
                yv[6] = (xv[6] - xv[0]) + 3 * (xv[2] - xv[4])
                yv[6] += (-0.6041096995 * yv[0]) + (3.8344265750 * yv[1])
                yv[6] += (-10.2563232650 * yv[2]) + (14.7947956750 * yv[3])
                yv[6] += (-12.1370614820 * yv[4]) + (5.3681892278 * yv[5]);
                back_filt_data[i] = yv[6]
            }

            return back_filt_data
        }

        fun Return_real_value(ecgData: FloatArray, mitGain: Double): DoubleArray {
            var ecg_output = arrayListOf<Double>()

            for (i in 0 until ecgData.size) {
                if (ecgData[i] / mitGain != Double.NaN) {
                    ecg_output.add(ecgData[i] / mitGain)
                } else {
                    ecg_output.add(Double.MAX_VALUE)
                }
            }

            return ecg_output.toDoubleArray()
        };

        fun Pow_list(ecg: DoubleArray): DoubleArray {
            for (i in 0 until ecg.size) {
                ecg[i] = Math.pow(ecg[i], 2.0)
            }

            return ecg
        }

        fun Find_peaks(sig: DoubleArray, threshold: Double, distance: Double): IntArray {
            var peaks = arrayListOf<Int>()
            var i = 0
            val radius = distance.toInt()

            while (i < radius + 1) {
                i += if (sig[i] == sig.getRange(0, i + radius).maxOrNull()) {
                    peaks.add(i)
                    radius
                } else {
                    1
                }
            }

            while (i < sig.size) {
                i += if (sig[i] == (sig.getRange(i - radius, min(radius * 2, sig.size - (i - radius))).maxOrNull())) {
                    peaks.add(i)
                    radius
                } else {
                    1;
                }
            }
//             while (i < sig.size) {
//               if (sig[i] === sig.getRange(i - radius, sig.size - (i - radius)).max()) {
//                 peaks.add(i);
//                 i += radius;
//               } else {
//                 i += 1;
//               }
//             }
            return peaks.toIntArray()
        };

        fun List_from_list(ecg: DoubleArray, locs: IntArray): DoubleArray {
            val new_list = arrayListOf<Double>()
            for (i in 0 until locs.size) {
                new_list.add(ecg[locs[i]]);
            }
            return new_list.toDoubleArray()
        }

        fun Remove_High_Sample(ecg: DoubleArray): DoubleArray {
            val Average = ecg.average()
            for (i in 0 until ecg.size) {
                if (Math.abs(ecg[i]) > Math.abs(Average * 2)) {
                    ecg[i] = Average * 2
                }
            }
            return ecg
        }

        class MaxLocate(var y_i: Double, var i_l: DoubleArray, var x_i: Double) {
            override fun toString(): String {
                return "MaxLocate(y_i=$y_i, i_l=${Arrays.toString(i_l)}, x_i=$x_i)"
            }
        }

        fun Find_max_locate(ecg_array: DoubleArray): MaxLocate {
            val y_i: Double
            var i_l: DoubleArray
            val x_i: Double

            if (ecg_array.isNotEmpty()) {
                y_i = ecg_array.maxOrNull()!!
                i_l = ecg_array.filter {
                    it == y_i
                }.toDoubleArray()
                x_i = i_l[0]
            } else {
                y_i = 0.0
                i_l = ecg_array
                x_i = 0.0
            }

            return MaxLocate(y_i, i_l, x_i)
        }

        fun Diff_int(array: IntArray): IntArray {
            val newArr = arrayListOf<Int>()

            for (i in 0 until (array.size - 1)) {
                newArr.add(array[i + 1] - array[i])
            }

            return newArr.toIntArray()
        }

        fun Diff_double(array: DoubleArray): DoubleArray {
            val newArr = arrayListOf<Double>()

            for (i in 0 until (array.size - 1)) {
                newArr.add(array[i + 1] - array[i])
            }

            return newArr.toDoubleArray()
        }

        fun getBeatMarkersArr(samplingRate: Int, gain: Double, ecgData: FloatArray): List<Int> {
            var ecg_m: DoubleArray?
            var ecg_h: DoubleArray?
            var ecg_d: DoubleArray?
            val ecg_s: DoubleArray?

            val new_ecg = Return_real_value(ecgData, gain)
            ecg_h = Butterworth_bandpass(new_ecg!!)
            val a = doubleArrayOf(1.0)
            val wavelet_filter = Signal_ricker(0.1 * samplingRate, 4.0);
            // ecg_d = FirstDerivative(ecg_h, ecg_h.length);
            ecg_d = FiltFilt(ecg_h!!, a, wavelet_filter);
            // ecg_s = Pow_list(ecg_d);
            ecg_m = Pow_list(ecg_d);

            // let window_len = Math.round(0.150 * samplingRate);
            // if (window_len % 2 === 0) {
            //   window_len += 1;
            // }
            // const s = Prepare_list(ecg_s, window_len);
            // const kernel = Array(parseInt(window_len, 10)).fill(1);
            // ecg_m = Convolve(s, kernel, true);
            // ecg_m = getRange(ecg_m, parseInt(window_len, 10), ecg_m.length - parseInt(window_len, 10));

            val locs = Find_peaks(ecg_m, 0.00000000001, samplingRate * 0.22);
            var pks = List_from_list(ecg_m, locs);
            pks = Remove_High_Sample(pks);

            // remove pick which the value > averageP*2
            // const averageP = getAverage(pks);
            // const arrayRemove = [];
            // for (let i = pks.length - 1; i >= 0; i -= 1) {
            //   if (pks[i] > averageP * 2) {
            //     arrayRemove.push(i);
            //   }
            // }
            // for (let i = 0; i < arrayRemove.length; i += 1) {
            //   pks.splice(arrayRemove[i], 1);
            //   locs.splice(arrayRemove[i], 1);
            // }

            val peak_index = 0
            val qrs_c = arrayListOf<Double>()
            val qrs_i = arrayListOf<Int>()
            val qrs_i_raw = arrayListOf<Int>()
            val qrs_amp_raw = arrayListOf<Double>()
            val noise_c = arrayListOf<Double>()
            val noise_i = arrayListOf<Int>()

            var x = 0
            var x1: IntArray? = null
            var skip = 0;
            var ser_back = 0;
            var y_i = 0.0
            var x_i = 0.0
            var i_l: DoubleArray

            var THR_SIG = ecg_m.getRange(0, 2 * samplingRate).maxOrNull()!! * 1 / 3
            var THR_NOISE = (ecg_m.getRange(0, 2 * samplingRate)).average() * 1 / 2
            var SIG_LEV = THR_SIG
            var NOISE_LEV = THR_NOISE
            var THR_SIG1 = (ecg_h.getRange(0, 2 * samplingRate)).maxOrNull()!! * 1 / 3
            var THR_NOISE1 = ecg_h.getRange(0, 2 * samplingRate).average() * 1 / 2
            var SIG_LEV1 = THR_SIG1
            var NOISE_LEV1 = THR_NOISE1
            var m_selected_RR = 0.0
            var meanRR = 0.0

            for (peak_index in 0 until pks.size) {
                var ecg_array: DoubleArray? = null
                ser_back = 0;
                if ((locs[peak_index] - Math.round(0.150 * samplingRate) >= 1) && (locs[peak_index] <= ecg_h.size - 1)) {
                    // console.log('If 1T');
                    ecg_array = ecg_h.getRange((locs[peak_index] - (0.150 * samplingRate).roundToInt()), (0.150 * samplingRate).roundToInt());
                    val result = Find_max_locate(ecg_array);
                    y_i = result.y_i;
                    i_l = result.i_l;
                    x_i = result.x_i;
                } else {
                    // console.log('If 1F');
                    if (peak_index === 0) {
                        // console.log('If 1F-1');
                        ecg_array = ecg_h.getRange(0, locs[peak_index]);
                        ser_back = 1;
                    } else if (locs[peak_index] >= ecg_h.size) {
                        // console.log('If 1F-2');
                        ecg_array = ecg_h.getRange(locs[peak_index] - (0.150 * samplingRate).roundToInt(), ecg_h.size - (locs[peak_index] - (0.150 * samplingRate).roundToInt()));
                    }
                    if (ecg_array !== null) {
                        // console.log('If 1F-3T');
                        val result = Find_max_locate(ecg_array);
                        y_i = result.y_i;
                        i_l = result.i_l;
                        x_i = result.x_i;
                    } else {
                        // console.log('If 1F-3F');
                        y_i = 0.0;
                        i_l = DoubleArray(0)
                        x_i = 0.0;
                    }
                }
                if (qrs_c !== null) {
                    // console.log('If 2T');
                    x = qrs_c.size;
                } else {
                    // console.log('If 2F');
                    x = 0;
                }
                if (x >= 9) {
                    // console.log('If 3T');
                    x1 = qrs_i.toIntArray().getRange(x - 9, 9)
                    val diffRR = Diff_int(x1);
                    meanRR = diffRR.average()
                    val comp = qrs_i[qrs_i.size - 1] - qrs_i[qrs_i.size - 2]

                    if ((comp <= 0.92 * meanRR) || (comp >= 1.16 * meanRR)) {
                        // console.log('If 3T-1T');
                        THR_SIG *= 0.5;
                        THR_SIG1 *= 0.5;
                    } else {
                        // console.log('If 3T-1F');
                        m_selected_RR = meanRR;
                    }
                }
                var test_m = -3000.0
                if (m_selected_RR !== 0.0) {
                    // console.log('If 4-1');
                    test_m = m_selected_RR
                } else if ((meanRR !== 0.0) && (m_selected_RR == 0.0)) {
                    // console.log('If 4-2');
                    test_m = meanRR;
                } else {
                    // console.log('If 4-3');
                    test_m = 0.0
                }
                if (test_m !== 0.0) {
                    // console.log('If 5T');
                    if (locs[peak_index] - qrs_i[qrs_i.size - 1] >= Math.round(1.66 * test_m)) {
                        // console.log('If 5T-1T');
                        val obj = Find_max_locate(ecg_m.getRange(qrs_i[qrs_i.size - 1] + (0.2 * samplingRate).roundToInt(), Math.max((locs[peak_index] - Math.round(0.2 * samplingRate).toInt() - (qrs_i[qrs_i.size - 1] + Math.round(0.2 * samplingRate))), 0).toInt()));
                        val pks_temp = obj.y_i;
                        val i_3 = obj.i_l;
                        var locs_temp = obj.x_i;
                        locs_temp = qrs_i[qrs_i.size - 1] + Math.round(0.2 * samplingRate) + locs_temp - 1;
                        if (pks_temp > 1.75 * THR_NOISE) {
                            // console.log('If 5T-1T-1T');
                            qrs_c.add(pks_temp);
                            qrs_i.add(locs_temp.toInt());
                        }

                        var y_i_t: Double
                        var x_i_t: Double
                        var i_4 = listOf<Double>()
                        var i_5 = listOf<Double>()

                        if (locs_temp <= ecg_h.size) {
                            // console.log('If 5T-1T-2T');
                            val result = Find_max_locate(ecg_h.getRange((locs_temp - (0.150 * samplingRate).roundToInt()).toInt(), (0.150 * samplingRate).roundToInt()));
                            y_i_t = result.y_i;
                            i_4 = result.i_l.asList();
                            x_i_t = result.x_i;
                        } else {
                            // console.log('If 5T-1T-2F');
                            var result = Find_max_locate(ecg_h.getRange((locs_temp - Math.round(0.150 * samplingRate)).toInt(), (0.150 * samplingRate).roundToInt()));
                            y_i_t = result.y_i;
                            i_5 = result.i_l.asList();
                            x_i_t = result.x_i;
                        }
                        if (y_i_t > THR_NOISE) {
                            // console.log('If 5T-1T-3T');
                            qrs_i_raw.add((locs_temp - (0.150 * samplingRate).roundToInt() + (x_i_t - 1)).toInt());
                            qrs_amp_raw.add(y_i_t);
                            SIG_LEV1 = 0.25 * y_i_t + 0.75 * SIG_LEV1;
                        }
                        SIG_LEV = 0.25 * pks_temp + 0.75 * SIG_LEV;
                    }
                }

                if (pks[peak_index] >= THR_SIG) {
                    // console.log('If 6T');
                    skip = 0;
                    if (qrs_c.size >= 3) {
                        // console.log('If 6T-1T');
                        if (locs[peak_index] - qrs_i[qrs_i.size - 1] <= Math.round(0.3600 * samplingRate)) {
                            // console.log('If 6T-1T-1T');
                            val Slope1_array = Diff_double(ecg_m.getRange((locs[peak_index] - Math.round(0.075 * samplingRate)).toInt(), (0.075 * samplingRate).roundToInt()));
                            val Slope1 = (Slope1_array).average()
                            val Slope2_array = Diff_double(ecg_m.getRange((qrs_i[qrs_i.size - 1] - Math.round(0.075 * samplingRate)).toInt(), (0.075 * samplingRate).roundToInt()));
                            val Slope2 = (Slope2_array).average()
                            if (Math.abs(Slope1) <= Math.abs(0.5 * Slope2)) {
                                // console.log('If 6T-1T-1T-1T');
                                noise_c.add(pks[peak_index])
                                noise_i.add(locs[peak_index])
                                skip = 1;
                                NOISE_LEV1 = 0.125 * y_i + 0.875 * NOISE_LEV1;
                                NOISE_LEV = 0.125 * pks[peak_index] + 0.875 * NOISE_LEV;
                            } else {
                                // console.log('If 6T-1T-1T-1F');
                                skip = 0;
                            }
                        }
                    }

                    if (skip === 0) {
                        // console.log('If 6T-2T');
                        qrs_c.add(pks[peak_index]);
                        qrs_i.add(locs[peak_index]);
                        if (y_i >= THR_SIG1) {
                            // console.log('If 6T-2T-1T');
                            if (ser_back === 1) {
                                // console.log('If 6T-2T-1T-1T');
                                qrs_i_raw.add(x_i.toInt());
                            } else {
                                // console.log('If 6T-2T-1T-1F');
                                qrs_i_raw.add((locs[peak_index] - (0.150 * samplingRate) + (x_i - 1)).roundToInt());
                            }
                        }
                        qrs_amp_raw.add(y_i);
                        SIG_LEV1 = 0.125 * y_i + 0.875 * SIG_LEV1;
                    }

                    SIG_LEV = 0.125 * pks[peak_index] + 0.875 * SIG_LEV;
                } else if ((THR_NOISE <= pks[peak_index]) && (pks[peak_index] < THR_SIG)) {
                    // console.log('If 6T-3');
                    NOISE_LEV1 = 0.125 * y_i + 0.875 * NOISE_LEV1;
                    NOISE_LEV = 0.125 * pks[peak_index] + 0.875 * NOISE_LEV;
                } else if (pks[peak_index] < THR_NOISE) {
                    // console.log('If 6T-4');
                    noise_c.add(pks[peak_index]);
                    noise_i.add(locs[peak_index]);
                    NOISE_LEV1 = 0.125 * y_i + 0.875 * NOISE_LEV1;
                    NOISE_LEV = 0.125 * pks[peak_index] + 0.875 * NOISE_LEV;
                }

                if ((NOISE_LEV !== 0.0) || (SIG_LEV !== 0.0)) {
                    // console.log('If 7T');
                    THR_SIG = NOISE_LEV + 0.25 * (Math.abs(SIG_LEV - NOISE_LEV));
                    THR_NOISE = 0.5 * (THR_SIG);
                }
                if ((NOISE_LEV1 !== 0.0) || (SIG_LEV1 !== 0.0)) {
                    // console.log('If 8T');
                    THR_SIG1 = NOISE_LEV1 + 0.25 * (Math.abs(SIG_LEV1 - THR_NOISE1));
                    THR_NOISE1 = 0.5 * THR_SIG1;
                }
            }
            return qrs_i;
        }

        fun calculateHeartBeat(samplingRate: Int, gain: Double, ecgData: FloatArray): Int {
            val list = getBeatMarkersArr(samplingRate, gain, ecgData)
            return calculatingAVGHeartBeat(samplingRate, list)
        }

        fun calculatingAVGHeartBeat(samplingRate: Int, list: List<Int>): Int {
            val listAvg = ArrayList<Int>()
            for (i in 1 until list.size) {
                val avg = (60 * samplingRate) / (list[i] - list[i - 1])
                listAvg.add(avg)
            }
            var sum: Int = 0
            for (mark in listAvg) {
                sum += mark
            }
            return sum / listAvg.size
        }

        @Throws(ArrayIndexOutOfBoundsException::class)
        fun butterworthFilter(inputData: DoubleArray?, samplingRate: Int, cutOff: Int): DoubleArray? {
            if (inputData != null) {
                return null
            }

            if (cutOff === 0) {
                return inputData
            }

            val dF2 = inputData?.size!! - 1; // The data range is set with dF2
            val Dat2 = DoubleArray(dF2 + 4); // Array with 4 extra points front and back
            val data = DoubleArray(inputData?.size!!); // Ptr., changes passed data
            copyArray(inputData, 0, data, 0, inputData?.size!!)

            copyArray(inputData, 0, Dat2, 2, dF2);
            Dat2[0] = inputData!![0]!!;
            Dat2[1] = Dat2[0];
            Dat2[dF2 + 2] = inputData!![dF2]!!;
            Dat2[dF2 + 3] = Dat2[dF2 + 2];

            val wc = Math.tan(cutOff * Math.PI / samplingRate);
            val k1 = Math.sqrt(2.0) * wc; // Sqrt(2) * wc
            val k2 = wc * wc;
            val a = k2 / (1 + k1 + k2);
            val b = 2 * a;
            val c = a;
            val k3 = b / k2;
            val d = -2 * a + k3;
            val e = 1 - (2 * a) - k3;

            // RECURSIVE TRIGGERS - ENABLE filter is performed (first, last points constant)
            val DatYt = DoubleArray(dF2 + 4);
            DatYt[0] = inputData!![0]!!;
            DatYt[1] = DatYt[0];
            for (s in 2..(dF2 + 2)) {
                DatYt[s] = a * Dat2[s] + b * Dat2[s - 1] + c * Dat2[s - 2]
                +d * DatYt[s - 1] + e * DatYt[s - 2];
            }
            DatYt[dF2 + 2] = DatYt[dF2 + 1];
            DatYt[dF2 + 3] = DatYt[dF2 + 2];

            // FORWARD filter
            val DatZt = DoubleArray(dF2 + 2);
            DatZt[dF2] = DatYt[dF2 + 2];
            DatZt[dF2 + 1] = DatYt[dF2 + 3];
            for (t in -dF2 + 1..0) {
                DatZt[-t] = a * DatYt[-t + 2] + b * DatYt[-t + 3] + c * DatYt[-t + 4]
                +d * DatZt[-t + 1] + e * DatZt[-t + 2];
            }

            copyArray(DatZt, 0, data, 0, dF2);
            return data;
        };
    }

}

private fun IntArray.getRange(index: Int, count: Int): IntArray {
    return copyOfRange(index, index + count)
}

private fun DoubleArray.getRange(index: Int, count: Int): DoubleArray {
    return copyOfRange(index, index + count)
}
