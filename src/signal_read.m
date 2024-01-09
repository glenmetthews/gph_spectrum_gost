function sig = signal_read(way)
    
    way_char=char(way);                                                     %������� ������ ���� � ���������� ������
    sig_type = way_char(end-2:end);                                         %��������� ��������� ��� �������� - ���������� ������������ �����
    if sig_type == 'zsg'                                                    %���� ������� �� ZET7156, ���������� ���������� Rezak
        sig_id = fopen(way, 'rb');                                          %������������� ����� ��� ��������
        if sig_id == -1                                                     %�������� ������������ �������� 
            sig = -1;
        else
            sig = fread(sig_id, 'float32');                                 %���������� �������
            fclose(sig_id);                                                 %�������� �����
        end
    elseif sig_type == 'wav'                                                %���� ������� �� ����-06
        [sig, ~] = audioread(char(way));                                    %���������� �������
    else
        sig = -1;
    end
end