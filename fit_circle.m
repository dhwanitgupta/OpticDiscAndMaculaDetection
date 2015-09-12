function [ yfit , xfit , Rfit] = fit_circle(gplane,x,y,name,flag)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[m n] = size(gplane);

if x - 80 >  1  & y - 80 > 1 & x+80 < m & y+ 80 < n & flag == 1
%     template = draw_circle(200,90);
%     template(:,35:45) = 0;
%     fsp = fspecial('gaussian',11,15);
%     gplane = imfilter(gplane,fsp);
%     template(:,:) = template(:,:) / sum(sum(template));
%     conv_gplane = uint8(conv2(gplane(x-90:x+90,y-90:y+90),template,'same'));
    shift = 80;
    E = edge(Oriented_Image(gplane(x-80:x+80,y-80:y+80)),'canny');
    %E = edge(gplane(x-90:x+90,y-90:y+90),'canny');
else
    shift = 40;
    E = edge(Oriented_Image(gplane(x-40:x+40,y-40:y+40)),'canny');
end

%figure,imshow(E);
[xs,ys] = find(E == 1);
[xfit,yfit,Rfit] = circfit(xs,ys);
xfit = x + xfit - shift;
yfit = y + yfit - shift;
% h = figure;
% imshow(gplane);
% hold on
% rectangle('position',[yfit-Rfit,xfit-Rfit,Rfit*2,Rfit*2],...
%     'curvature',[1,1],'linestyle','-','edgecolor','r');
% plot(y,x,'g.');
% plot(yfit,xfit,'r.');
% [name,temp] =strtok(name,'.');
%saveas(h,strcat('circlefitting/',name,'.jpg'),'jpeg');
%close all


end

