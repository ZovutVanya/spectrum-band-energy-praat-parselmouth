from os import scandir
from time import time
import parselmouth

path = input("Path to the directory with .sbl files:\n")
start_time = time()

# инициализируем переменную y, которую будем использовать для того,
# чтобы правильно указывать номера объектов Spectrogram и Spectrum
# на каждой итерации цикла
y: int = 0

for file in scandir(path):
    filename = file.name

    if filename.endswith(".sbl"):
        # сохраняем звуковой файл в переменную sound
        sound = parselmouth.praat.call(
            "Read Sound from raw 16-bit Little Endian file", f"{path}/{filename}"
        )
    else:
        continue

    fileNum = filename[3:7]

    # меняем частоту дискретизации с 16000 на 22050
    sound.override_sampling_frequency(22050)

    # сохраняем спектрограмму в переменную spectrogram
    spectrogram = sound.to_spectrogram(0.025, 5000, 0.002, 20, "HAMMING")

    # указываем номер спектрограммы в списке
    id_spectrogram = 3 + y

    # время окончания
    end = sound.get_end_time()

    # frm - начальное время
    frm: float = 0.0

    # step - с таким шагом будем двигаться по спектрограмме
    step: float = 0.01

    # step_id - переменная для нахождения номера Spectrum на каждой итерации цикла
    step_id: int = 0

    with open(f"{path}/BandsOfEnergy{fileNum}.tsv", "w", encoding="utf-8") as tsv:
        # походимся циклом по спектрограмме
        while frm < end:
            # сохраняем мгновенный спектр в переменную spectrum
            spectrum = spectrogram.to_spectrum_slice(frm)

            # записываем в файл время frm
            tsv.write(f"{frm}\t")

            frm += step

            # инициализируем переменную x,
            # которую будем использовать для обозначения границ полосы энергии
            x: int = 0

            # проходимся циклом по мгновенному спектру
            while x < 3000:
                band = spectrum.get_band_energy(x, x + 100)
                tsv.write(f"{band}\t")
                x += 100

            # после каждой итерации добавляем 1 к y
            # (поскольку каждый раз добавляется объект Spectrum)
            y += 1

            # после каждой итерации переходим в файле на новую строку
            tsv.write("\n")

    # после обработки спектрограммы одного файла, добавляем 2 к y
    # (чтобы получить номер Spectrogram на следующей итерации)
    y += 2

print("~~~ %s seconds ~~~" % (time() - start_time))
