function sig = signal_read(way)
    
    way_char=char(way);                                                     %Перевод строки пути в символьный вектор
    sig_type = way_char(end-2:end);                                         %Выделение последних трёх символов - расширение открываемого файла
    if sig_type == 'zsg'                                                    %Файл сигнала от ZET7156, порезанный програмкой Rezak
        sig_id = fopen(way, 'rb');                                          %Идентификатор файла при открытии
        if sig_id == -1                                                     %Проверка корректности открытия 
            sig = -1;
        else
            sig = fread(sig_id, 'float32');                                 %Считывание сигнала
            fclose(sig_id);                                                 %Закрытие файла
        end
    elseif sig_type == 'wav'                                                %Файл сигнала от АДМВ-06
        [sig, ~] = audioread(char(way));                                    %Считывание сигнала
    else
        sig = -1;
    end
end