import xml.etree.ElementTree as ET
from datetime import datetime, timedelta
from typing import List

import numpy as np
from scipy.fft import rfft, rfftfreq
import config
from config import signals_path


class ZetlabSignal:
    def __init__(
        self,
        zetlab_data_path: str,
        axis_name: str,
        hours_deep: int,
        low_freq: float,
        high_freq: float,
        to_time: datetime = datetime.now(),
    ):
        self.zetlab_data_path = zetlab_data_path
        self.axis_name = axis_name
        self.to_time = to_time
        self.hours_deep = hours_deep
        self.low_freq = low_freq
        self.high_freq = high_freq
        self.period_quantity = 20
        self.probability = 0.95
        self.xml_read = False
        self.xml_filename = "sig0000.xml"
        self.signal_data_files = self.__collect_data_files()
        self.frequency: int

    def __parse_xml_000(self, path: str) -> str:
        tree = ET.parse(path + self.xml_filename)
        for signal in tree.getroot():
            if self.axis_name in signal.get("name"):
                if self.xml_read is not True:
                    self.frequency = int(signal.get("frequency"))
                data_file = path + signal.get("data_file")[-11:]
                return data_file

    def __collect_data_files(self) -> List[str] | None:
        result = []
        try:
            for hour in range(self.hours_deep):
                current_signals_path = self.zetlab_data_path + datetime.strftime(
                    self.to_time - timedelta(hours=hour), "%Y/%m/%d/%H/"
                )
                result.append(self.__parse_xml_000(path=current_signals_path))
            return result

        except FileNotFoundError as xml_error:
            raise FileNotFoundError("XML file not found") from xml_error

    def read_data(self):
        result = []
        if self.signal_data_files:
            for data_file in self.signal_data_files:
                data = np.fromfile(data_file, dtype=np.float32)
                result.extend(data)
            return result
        return 0

    def __get_fft_data(self, data):
        return 2.0 / len(data) * np.abs(rfft(data)[1 : len(data) // 2])

    def __get_fft_freq(self, data):
        freq_list = rfftfreq(len(data), 1 / self.frequency)
        return freq_list[1 : len(data) // 2]

    def __get_masked_fft_data(self, fft_array, freq_array):
        mask = (self.low_freq < freq_array) & (freq_array < self.high_freq)

        return fft_array[mask], freq_array[mask]

    def __find_max_fft_datas(self, data):
        fft_freq = self.__get_fft_freq(data)
        fft_data = self.__get_fft_data(data)
        m_fft_data, m_fft_freq = self.__get_masked_fft_data(fft_data, fft_freq)

        return m_fft_freq[np.argmax(m_fft_data)]

    def __get_base_freqs_list(self):
        result = []
        all_data = self.read_data()
        for period_data in np.array_split(all_data, self.period_quantity):
            result.append(self.__find_max_fft_datas(period_data))

        return result

    def get_base_freq_with_error(self):
        max_freq = self.__get_base_freqs_list()
        mean_frequency = np.mean(max_freq)
        std_freq = np.std(max_freq)
        try:
            coefs_table = np.genfromtxt(
                "error_coefs",
                delimiter=",",
                dtype="int,float",
                usecols=(0, 2),
            )
            error_coefficients = coefs_table[self.period_quantity][1]
            std_error = error_coefficients * std_freq
        except FileNotFoundError:
            std_error = -1
            print("Error coefs file not found")

        return mean_frequency, std_error


if __name__ == "__main__":
    axis_list = []
    current_signals_path = config.signals_path + datetime.strftime(
        datetime.now() - timedelta(hours=1), "%Y/%m/%d/%H/"
    )
    tree = ET.parse(current_signals_path + "sig0000.xml")
    for signal in tree.getroot():
        if "Izhora" in signal.get("name"):
            axis = signal.get("name")
            axis_list.append(axis)

    for axis in axis_list:
        print(axis)
        try:
            signal = ZetlabSignal(
                zetlab_data_path=signals_path,
                axis_name=axis,
                hours_deep=3,
                low_freq=0.5,
                high_freq=1.5,
            )
            print(signal.get_base_freq_with_error())

        except FileNotFoundError as e:
            print(e.args)
