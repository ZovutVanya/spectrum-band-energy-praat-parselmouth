# указываем директорию, откуда будем брать sbl-файлы
list = Create Strings as file list: "list", "YOUR/PATH"

selectObject: list
numFiles = Get number of strings

# инициализируем переменную y, которую будем использовать для того,
# чтобы правильно указывать номера объектов Spectrogram и Spectrum
# на каждой итерации цикла
y = 0

# проходимся циклом по файлам cta0001 - cta0010
for fileNum from 1 to numFiles
	selectObject: list
	fileName$ = Get string: fileNum
	
	# сохраняем звуковой файл в переменную sound
	sound = Read Sound from raw 16-bit Little Endian file: fileName$
	# меняем частоту дискретизации с 16000 на 22050
	Override sampling frequency: 22050
	
	# сохраняем спектрограмму в переменную spectrogram
	spectrogram = To Spectrogram: 0.025, 5000, 0.002, 20, "Hamming (raised sine-squared)"
	
	# указываем номер спектрограммы в списке
	id_spectrogram = 3 + y
	
	selectObject: id_spectrogram
	end = Get end time
	# frm - начальное время
	frm = 0.0
	# step - с таким шагом будем двигаться по спектрограмме
	step = 0.01
	# step_id - переменная для нахождения номера Spectrum на каждой итерации цикла
	step_id = 0
	
	# проходимся циклом по спектрограмме
	while frm < end

		selectObject: id_spectrogram
		
		# сохраняем мгновенный спектр в переменную spectrum
		spectrum = To Spectrum (slice): frm

		# указываем название файла, в который записываем bands of energy
		name_of_file$ = "bands_of_energy_" + string$( fileNum ) + ".tsv"

		# записываем в файл время frm
		appendFile: name_of_file$, 'frm', tab$
		
		frm = frm + step
		id_spectrum = id_spectrogram + 1 + step_id
		step_id = step_id + 1

		selectObject: id_spectrum
		# инициализируем переменную x, которую будем использовать для обозначения границ полосы энергии
		x = 0
		
		# проходимся циклом по мгновенному спектру
		while x < 3000
			band = Get band energy... x  x+100
			appendFile: name_of_file$, 'band', tab$
			x = x + 100
		
		endwhile
		# после каждой итерации добавляем 1 к y
		# (поскольку каждый раз добавляется объект Spectrum)
		y = y + 1
		# после каждой итерации удаляем объект Spectrum 
		removeObject: spectrum
		# после каждой итерации переходим в файле на новую строку 
		appendFile: name_of_file$, newline$
	endwhile
	# после обработки спектрограммы одного файла, добавляем 2 к y
	# (чтобы получить номер Spectrogram на следующей итерации)  
	y = y + 2
	# после каждой итерации удаляем звуковой файл и спектрограмму
 	removeObject: sound
	removeObject: spectrogram
endfor
