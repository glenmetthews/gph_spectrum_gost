clear all
clc

way = "U:\Zetlab\����� (��������� �����)\Z01_23-10-07_Z.zsg";                  %���� �� ������
freq = 100;                                                                 %������� ������ �������
freq_h = 0.01;                                                              %����������� ���� �� �������
freq_strip = [0.5 1.5];                                                        %������ ������, � ������� ������ ����������� ���
probability = 0.95;                                                         %������������� �����������


sig = signal_read(way);                                                     %���������� �������
if sig == -1
    error('������ ���������� �����');
end

%sig=sig(105001:195001);
figure()
plot(sig)
%sig = signal_read(way);                                                     %���������� ������
%if sig == -1                                                                %�������� �� ����������� ����������
%    error('���� ������ �� ������');
%end

Len_sig = length(sig);                                                      %����������� ����� ������
Len_piece_sig = 1/freq_h*freq;                                              %����������� ����������� ����� ������ ��� ����������� ���� �� �������
quantity = fix(Len_sig/Len_piece_sig);                                      %����������� ���������� ���������� ���������
Freq_max = zeros(1,quantity);                                               %������ "�����������" ������ �� ������ �������
Decrement = zeros(1,quantity);
Freq = 0:freq_h:freq/2;                                                     %������ ������
%bound_search=[100 300];
%bound_search = [find(Freq == freq_strip(1))...
%                find(Freq == freq_strip(2))];                               %������ ��������� �������, � �������� ������� ���������� �����

bound_search = [fix(freq_strip(1)/freq_h+1) ...
                fix(freq_strip(2)/freq_h+1)]

for sig_part=1:quantity
    sig_i=sig(Len_piece_sig*(sig_part-1)+1:Len_piece_sig*sig_part);         %��������� ����� ������
    A_sig_i = Amplitude_Spector(sig_i);                                     %������� �������� ���������� �����
    %Max_amplit = max(A_sig_i(bound_search(1):bound_s earch(2)));             %����� ���������� ��������� � �������� ��������
    %Num_mas_max = find(A_sig_i == Max_amplit);                              %����������� ������ ������� � ������������ ��������
    %Freq_max(sig_part) = Freq(Num_mas_max);                                 %����������� ������� � ���������� ����������
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
    %Decrement(sig_part) = Decrement_Damp(A_sig_i, Freq, Num_mas_max);       %������ ���������� ���������
    Decrement(sig_part) = Decrement_Damp(A_sig_i, Freq, ceil(Freq_max(sig_part)/freq_h));
end
E_freq = mean(Freq_max);                                                    %������� ��������
S_freq = sqrt(sum((Freq_max-E_freq).^2)/(quantity*(quantity-1)));           %������������������ ����������
E_decrement = mean(Decrement);
S_decrement = sqrt(sum((Decrement-E_decrement).^2)/(quantity*(quantity-1)));
Error_c = error_coef(probability, quantity);

fprintf('����������� ������� ��������� ����������� ���\n');
fprintf('�� ������ � ��������� ������ [%4.2f, %4.2f]\n', freq_strip(1), freq_strip(2));
fprintf('� ������������� ����������� p=%3.2f �����:\n', probability);
fprintf('%6.4f � %6.4f ��\n', E_freq, Error_c*S_freq);
fprintf('��������� ��������� ���� �����:\n');
fprintf('%6.4f � %6.4f\n', E_decrement, Error_c*S_decrement);