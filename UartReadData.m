%% Importing Data

data = importdata('Serial Saved Output.txt');
ls='';

for m=1:length(data)-1
    space=strfind(data(m),'   ');
    if length(space{1})~= 2
        continue
    else
        for b=space{1}(1)+3:space{1}(2)-1
                a=data{m}(b);
                ls(end+1)=a;
        end
        ls(end+1)=' ';
    end
end

%% Extracting Gyroscope data
Gyrox=[];
Gyroy=[];
Gyroz=[];
k = strfind(ls,'aa 55');
t=0;
missing_messages=0;
check_sum_error=0;
check2=[];
    
for p=1:length(k)-1
    l_control='';
    l_control(end+1)=ls(k(p)+15);
    l_control(end+1)=ls(k(p)+16);
    l_control(end+1)=ls(k(p)+12);
    l_control(end+1)=ls(k(p)+13);
    w=1;
    check='';
    checksum=[];
    for r=6:293
        number=k(p)+r;
        if mod(w,3)==0
            checksum(end+1)=double(typecast(uint16( hex2dec(check) ), 'uint16'));
            check='';
            w=w+1;
        else
            check(end+1)=ls(number);
            w=w+1;
        end
    end
    A=sum(checksum);
    
        checksumvalue='';
        checksumvalue(end+1)=ls(k(p+1)-3);
        checksumvalue(end+1)=ls(k(p+1)-2);
        checksumvalue(end+1)=ls(k(p+1)-6);
        checksumvalue(end+1)=ls(k(p+1)-5);
        checksumdecvalue=double(typecast(uint16( hex2dec(checksumvalue) ), 'int16'));
    
    if hex2dec(l_control)~= length(checksum)+2
        missing_messages=missing_messages+1;
        continue
    elseif checksumdecvalue ~=A
        check_sum_error=check_sum_error+1;
        %check2(end+1)=p;
        continue
    else
        num1=k(p)+36;
        hexStrx='';
        hexStrx(end+1)=ls(num1+3);
        hexStrx(end+1)=ls(num1+4);
        hexStrx(end+1)=ls(num1);
        hexStrx(end+1)=ls(num1+1);
        decvalue=double(typecast(uint16( hex2dec(hexStrx) ), 'int16'));
        KG=detect_KG(hex2dec(hexStrx));
        Gyrox(end+1)=decvalue/KG;
        hexStry='';
        hexStry(end+1)=ls(num1+9);
        hexStry(end+1)=ls(num1+10);
        hexStry(end+1)=ls(num1+6);
        hexStry(end+1)=ls(num1+7);
        decvalue=double(typecast(uint16( hex2dec(hexStry) ), 'int16'));
        KG=detect_KG(hex2dec(hexStry));
        Gyroy(end+1)=decvalue/KG;
        hexStrz='';
        hexStrz(end+1)=ls(num1+15);
        hexStrz(end+1)=ls(num1+16);
        hexStrz(end+1)=ls(num1+12);
        hexStrz(end+1)=ls(num1+13);
        decvalue=double(typecast(uint16( hex2dec(hexStrz) ), 'int16'));
        KG=detect_KG(hex2dec(hexStrz));
        Gyroz(end+1)=decvalue/KG;
        t=t+1;
    
    end
end


%% Ploting Data
time= 1:t;
time=time/50;
figure; 
plot(time,Gyrox)
hold on
plot(time,Gyroy)
plot(time,Gyroz)
legend('X','Y','Z')
xlabel('Time(s)')
ylabel('Angular Velocity (deg/s)')
hold  off


T = table(Gyrox.', Gyroy.',Gyroz.', 'VariableNames', { 'GYRO_X', 'GYRO_Y','GYRO_Z'} );
%writetable(T,'tabledata.txt');
%% Used Functions

function KG=detect_KG(x)
        if x/50<450
            KG=50;
        elseif x/10>2000
            KG=10;
        else
            KG=20;
        end
end

