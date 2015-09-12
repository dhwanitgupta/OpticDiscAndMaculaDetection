function RGB = draw_circle(sz ,rad);

%this function draws a circle 

clear RGB
RGB(1:sz,1:sz)=0;
[x y]= find(RGB==0);
xc=ceil((sz+1)/2);
yc=ceil((sz+1)/2);
r=rad.^2;
d=find(((x-xc).^2+(y-yc).^2) <= r);
for i=1:size(d,1) 
    RGB(x(d(i)),y(d(i)))=255;
    
end
end