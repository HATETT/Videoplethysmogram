clear all; % Очистка памяти 
close all; % Закрытие всех окон с графиками 
clc; % Очистка окна команд и сообщений 

%Считывание видео, запуск определния лица, запись тествового фрагмента
faceDetector = vision.CascadeObjectDetector();
v = VideoReader('D:\BOMONKA\Practice\Measurements\Ibragem_1_27.04.19.avi')
test = VideoWriter('D:\BOMONKA\Practice\newfile2.avi','Uncompressed AVI');
open(test)
final_val = []; count2 = 300; y_val = [];
for i = 1:count2
    videoFrame = readFrame(v);
    % Возвратим последовательно координату левой верхней точки ширину и высоту прямоугольника
    bbox = step(faceDetector, videoFrame);
    % Выделим самое большое лицо на кадре
    bboxsize = size(bbox);
    if  bboxsize(1)> 1
        edge = 0; squareNum = 0;
        for j = 1:bboxsize(1)
            if edge < bbox(j,3)
            edge = bbox(j,3);
            squareNum = j;
            end
        end
        bbox = bbox(squareNum,:);
    end
    videoFrame = insertShape(videoFrame, "rectangle", bbox);
    writeVideo(test,videoFrame);
    % Вырезаем участок кадра с лицом 
    x_cord = bbox(1); y_cord = bbox(2); side = bbox(3);
    
    %diff_val = []; stept = floor(side/4);
    %for i1 = 1:4
        %for i2 = 1:4
            %point = [x_cord+stept*(i1-1),y_cord+stept*(i2-1)];
            %videoFrame = insertShape(videoFrame, "rectangle", [point,stept,stept]);
            %microFrame = videoFrame(point(2)+1:1:point(2)+stept-1,point(1)+1:1:point(1)+stept-1,1:3);
            %allSum = sum(microFrame,[1 2]);
            %value = allSum(:,:,2)/(allSum(:,:,1)+allSum(:,:,3));
            %diff_val = [diff_val, value];
        %end
    %end
    %final_val = [final_val, sum(diff_val)];
 
    %Рассчет по формуле для целого квадрата лица
    videoFrame = videoFrame(y_cord+1:1:y_cord+side-1,...
        x_cord+1:1:x_cord+side-1,1:3);
    %imshow(videoFrame)
    s1 = sum(videoFrame,[1 2]);
    value = s1(:,:,2)/(s1(:,:,1)+s1(:,:,3));
    y_val = [y_val, value];
end
close(test)

%Определение количесвта ударов сердца для видеоплетизмограммы
video_pks = findpeaks(y_val,'MinPeakDistance',10);
videoBeats = length(video_pks);
crutch2 = 34.1333/1024*count2;
x_axis1 = linspace(0,crutch2,count2);
strVideoBeats = num2str(videoBeats); %Кол-во ударов за промежуток вермени
strVideoPulse = num2str(videoBeats*60/x_axis1(end)); %Пульс


%Считывае Фотоплетизмограммы
inFile = readlines('D:\BOMONKA\Practice\Сигналы\Ibragem_1_27.04.19\Contact.txt');
pogVal = []; time = []; count = 200;
for i = 1:count
    pog = split((inFile(i)),',');
    hlp = split(pog(1),':');
    pogVal = [pogVal,str2num(pog(2))];
    if i == 1 || i==count
        time = [time, (hlp)];
    end
end
crutch = (str2num(time(6))*60000+str2num(time(7))*1000+str2num(time(8))...
    -str2num(time(2))*60000-str2num(time(3))*1000-str2num(time(4)))/1000;
x_axis = linspace(0,crutch,count); title("Detected face");

%Определение количесвта ударов сердца для фотоплетизмограммы
photo_pks = findpeaks(pogVal,'MinPeakDistance',5);
%Определяем пики и отсеиваем неинформатинвые
minBigPick = mean(photo_pks);
meanPick = minBigPick + (max(photo_pks(photo_pks>minBigPick))...
    - min(photo_pks(photo_pks>minBigPick)))/4;
pogVal(pogVal > meanPick) = meanPick;
photo_pks = findpeaks(pogVal,'MinPeakDistance',5);
photoBeats = length(photo_pks(photo_pks > mean(photo_pks)));
strBeats = num2str(photoBeats); %Кол-во ударов за промежуток вермени
strPulse = num2str(photoBeats*60/x_axis(end)); %Пульс

%Формирование графика Видеоплетизмограммы
figure;plot(x_axis1, y_val, 'Color', "blue",'LineWidth',1);
set(get(gcf, 'CurrentAxes'), 'FontSize', 10); % Изменение шрифта 
title({'\rm Видеоплетизмограмма '}); % Заголовок 
xlabel('Время, c'); % Надпись оси абсцисс 
ylabel('Амплитуда, у.е'); % Надпись оси ординат
legend({strcat('Количесвто ударов сердца -',strVideoBeats,...
    ', Пульс в минуту -',strVideoPulse)},'Location','southwest') % Подпись

%Формирование графика Фотоплетизмограммы
figure;plot(x_axis, pogVal, 'Color', "g",'LineWidth',1);
set(get(gcf, 'CurrentAxes'), 'FontSize', 10); % Изменение шрифта 
title({'\rm Фотоплетизмограмма '}); % Заголовок 
xlabel('Время, c'); % Надпись оси абсцисс 
ylabel('Амплитуда, у.е'); % Надпись оси ординат
legend({strcat('Количесвто ударов сердца -',strBeats,...
    ', Пульс в минуту -',strPulse)},'Location','southwest') % Подпись 
