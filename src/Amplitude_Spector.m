function Amplitude = Amplitude_Spector(sig)
    flag=0;
    sig = sig - mean(sig);
    Len_sig = length(sig);                                                  %Определение длины поданного сигнала 
    if flag == 0
        F_sig = fft(sig);
    elseif flag == 1
        Win = hann(Len_sig);                                                %Окно Ханна (Хеннинга)
        sig_with_win = sig.*Win;
        F_sig = fft(sig_with_win);                                          %Преобразование Фурье поданного сигнала
    end                           
    A_sig = abs(F_sig/Len_sig);                                             %Нахождение амплитуды по модулю преобразования Фурье
    Amplitude = A_sig(1:round(Len_sig/2)+1);
    Amplitude(2:end) = 2*Amplitude(2:end);
end