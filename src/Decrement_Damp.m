function Decrement = Decrement_Damp(Sig, Freq, Num_mas_max)
    
    Sig_len = length(Sig);
    Amplit_max = Sig(Num_mas_max);                                          %Максимальное значение амплитуды
   
    for i=Num_mas_max:Sig_len
        if Sig(i) < Amplit_max*0.707 %Amplit_max/2
            Freq_right = (Amplit_max/2*(Freq(i-1)-Freq(i))+Freq(i)*Sig(i-1)-Freq(i-1)*Sig(i))/(Sig(i-1)-Sig(i));
            break;
        elseif Sig(i) == Amplit_max*0.707 %Amplit_max/2
            Freq_right = Freq(i);
            break;
        end
    end
    for i=Num_mas_max:-1:1
        if Sig(i) < Amplit_max*0.707 %Amplit_max/2
            Freq_left = (Amplit_max/2*(Freq(i+1)-Freq(i))+Freq(i)*Sig(i+1)-Freq(i+1)*Sig(i))/(Sig(i+1)-Sig(i));
            break;
        elseif Sig(i) == Amplit_max*0.707 %Amplit_max/2
            Freq_left = Freq(i);
            break;
        end
    end
    Decrement = pi*(Freq_right-Freq_left)/Freq(Num_mas_max);
end