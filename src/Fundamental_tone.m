clear all
clc

way = "";                                                                  %Путь до записи
freq = 100;                                                                 %Частота записи датчика
freq_h = 0.01;                                                              %Определение шага по частоте
freq_strip = [0.5 1.5];                                                        %Полоса частот, в которой ищется собственный тон
probability = 0.95;                                                         %Доверительная вероятность


sig = signal_read(way);                                                     %Считывание сигнала
if sig == -1
    error('Ошибка считывания файла');
end

%sig=sig(105001:195001);
figure()
plot(sig)
%sig = signal_read(way);                                                     %Считывание записи
%if sig == -1                                                                %Проверка на коректность считывания
%    error('Файл записи не найден');
%end

Len_sig = length(sig);                                                      %Определение длины записи
Len_piece_sig = 1/freq_h*freq;                                              %Определение необходимой длины записи для обеспечения шага по частоте
quantity = fix(Len_sig/Len_piece_sig);                                      %Определение количества интервалов разбиения
Freq_max = zeros(1,quantity);                                               %Вектор "собственных" частот на каждом участке
Decrement = zeros(1,quantity);
Freq = 0:freq_h:freq/2;                                                     %Вектор частот
%bound_search=[100 300];
%bound_search = [find(Freq == freq_strip(1))...
%                find(Freq == freq_strip(2))];                               %Нумера элементов массива, в пределах которых проводится поиск

bound_search = [fix(freq_strip(1)/freq_h+1) ...
                fix(freq_strip(2)/freq_h+1)]

for sig_part=1:quantity
    sig_i=sig(Len_piece_sig*(sig_part-1)+1:Len_piece_sig*sig_part);         %Вырезание части записи
    A_sig_i = Amplitude_Spector(sig_i);                                     %Спектор мощности вырезанной части
    %Max_amplit = max(A_sig_i(bound_search(1):bound_s earch(2)));             %Поиск наибольшей амплитуды в заданных пределах
    %Num_mas_max = find(A_sig_i == Max_amplit);                              %Определение нумкра массива с максимальной частотой
    %Freq_max(sig_part) = Freq(Num_mas_max);                                 %Определение частоты с наибольшей амплитудой
    Freq_max(sig_part) = (bound_search(1)-1)*freq_h;
    MAX = A_sig_i(bound_search(1)-1);
    for index = bound_search(1):bound_search(2)-1
        if A_sig_i(index) >= MAX
            Freq_max(sig_part) = (index)*freq_h;
            MAX = A_sig_i(index);
        end
    end
    %{
    figure()
        plot(A_sig_i);
        hold on
        plot([ceil(Freq_max(sig_part)/freq_h) ceil(Freq_max(sig_part)/freq_h)], [0 A_sig_i(ceil(Freq_max(sig_part)/freq_h))])
        xlim(bound_search)
    %}
    %Decrement(sig_part) = Decrement_Damp(A_sig_i, Freq, Num_mas_max);       %Расчет декремента затухания
    Decrement(sig_part) = Decrement_Damp(A_sig_i, Freq, ceil(Freq_max(sig_part)/freq_h));
end
E_freq = mean(Freq_max);                                                    %Среднее значение
S_freq = sqrt(sum((Freq_max-E_freq).^2)/(quantity*(quantity-1)));           %Среднеквадратичное отклонение
E_decrement = mean(Decrement);
S_decrement = sqrt(sum((Decrement-E_decrement).^2)/(quantity*(quantity-1)));
Error_c = error_coef(probability, quantity);

fprintf('Собственная частота колебаний конструкции при\n');
fprintf('ее поиске в частотной полосе [%4.2f, %4.2f]\n', freq_strip(1), freq_strip(2));
fprintf('и доверительной вероятности p=%3.2f равна:\n', probability);
fprintf('%6.4f ± %6.4f Гц\n', E_freq, Error_c*S_freq);
fprintf('Декремент основного тона равен:\n');
fprintf('%6.4f ± %6.4f\n', E_decrement, Error_c*S_decrement);
