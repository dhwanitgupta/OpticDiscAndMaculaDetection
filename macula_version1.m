% Code to detect OD and macula
clear  all
close all
warning('off', 'all');
kernel = uint8(zeros(15,15));
kernel(8,8) = 1;
%to extract the files from base directory
directory_path = '../../';
direc = dir(directory_path);
output_directory = 'results/';

n_resize = 576;
m_resize = 768;

%some utility filters
hf = fspecial('average',81);
him = fspecial('gaussian',11);

% variables
total_od_deviation = 0;
total_mac_deviation = 0;
true_od =0;
false_od = 0;
true_mac = 0;
false_mac =0;
OD = zeros(130,2);
MAC = zeros(130,2);

tic


for i = 1:size(direc,1)
    
    flag = 0;
    image = strcat(directory_path,'/',direc(i).name);
    
    [ppm,t] = size(findstr(image, '.ppm'));
    [png,t] = size(findstr(image, '.png'));
    [tif,t] = size(findstr(image,'.tif'));
    [jpg,t] = size(findstr(image,'.jpg'));
    if png == 0 && tif == 0 && jpg == 0 && ppm == 0
        flag = 1;
    end
    if flag == 0
        'Processing on image ' 
            direc(i).name
        % PRE PROCESSING
        
        
        % Image resizing
        
        rim = imread(image);
	  [initial_x,initial_y,temp] = size(rim);
        t1 = imresize(rim(:,:,1),[n_resize m_resize]);
        t2 = imresize(rim(:,:,2),[n_resize m_resize]);
        t3 = imresize(rim(:,:,3),[n_resize m_resize]);
        rim = uint8(zeros(n_resize , m_resize , 3));
        rim(:,:,1) = t1;
        rim(:,:,2) = t2;
        rim(:,:,3) = t3;
        ves_im = rim;
        
        s = size(rim);
        cg = rgb2gray(rim);
        cg  = uint8(conv2(cg,kernel));
        [sizex,sizey] = size(cg);
        
        rim(:,:,2) = histeq(rim(:,:,2));
        cg = rgb2gray(rim);
        
        temp = cg;
        
        %Thresholding to get the bright regions
        
        m = max(max(cg));
        ind1 = find(cg < 30);
        cg(ind1) = m - 50;
        ind = find(cg > m - 20);
        cg(ind) = 0;
        [n,m] = size(cg);
        newim =  logical(zeros(n,m));
        newim(ind) = 1;
        
        newim = imfilter(newim,him);
        
        %Ignoring the small bright regions
        [labelbw,num] = bwlabel(newim);
        
        for j = 1:num
            ind = find(labelbw == j);
            [countwhite,q] = size(ind);
            if countwhite < 30
                newim(ind) = 0;
            end
        end
        
        [n1,m1]  = size(newim);
        
        maxx =0;
        mx = 41 ;
        my = 41;
        maxcomp = -1;
        distmin = 10000000;
        
        % Vessel detection
        gplane = ves_im(:,:,1)*0.3 + ves_im(:,:,2)*0.6 + ves_im(:,:,3)*0.1 ;
        
        %Trying to get exact vessel map , aim to get major vessels
        vessmac = myVessel(ves_im);
        
        [row,col] = find(newim == 1);
        
        %Finding approx mid line
        midline = ReturnLine(gplane);
        f = zeros(576,768);
        
        % Detecting OD using three parameters
        % correlation value , distance from midlin and vessel density
        for x = 1:size(row,1)
            
            if row(x) > 60 & row(x) + 60< n1 & col(x) > 60 & col(x) + 60 < m1
                temp_gplane = adapthisteq(gplane(row(x)-45:row(x)+45-1,col(x)-45:col(x)+45-1));
                
                val1 = get_maxresponse(temp_gplane,45); % to get the correlation value of OD and circular template
                
                res = val1 + 0.1*sum(sum(vessmac(row(x)-45:row(x)+45,col(x)-45:col(x)+45))) - 0.0002*abs(midline -x );
                f(row(x),col(x)) = res;
                
                %check for max res
                if res > maxcomp
                    maxcomp = res;
                    mx = row(x);
                    my = col(x);
                    
                end
            end
        end
        im = ves_im;
        im(mx-5:mx+5,my-5:my+5,:) = 0;
        
        %OD co-ordinates x = mx and y = my
        
        
        % Detecting  Macula
        
        
        cg1 = imcomplement(temp);
        
        m = uint8(zeros(15,15));
       % rough vessel map to ignore the regions where vessel present
       % due to the fact that macula having zero vesseldensity
       [vessimage,vess_temp] = vesdetect_v1(gplane);
        vess_index = find(vessimage==1);
        cg1(vess_index) = 0;
      
        m = max(max(cg1));
        
        cg1 = adapthisteq(cg1);
        
        check = uint8(ones(40,40));
        check1 = uint8(ones(60,60));
        maxz = -100;
        
%         % improved vessel map as compare to vessimage 
%         vessimage1 = vesdetect1(image); 
        % angle_v1 return all the local minimas 
        % ( see funtion for more details )
 
        [data] = angle_v1(imread(image),vessmac,mx,my);
        
        % extrema is used to get all the local minimas from data
        [zmax,imax,zmin,imin]= extrema(data);
        imin = imin-31;
        data1 = zeros(1,1000);
        count = 1;
        s = size(rim);
        nx = 100; ny=100;
        
        % using angle , vessel density and brightness to detect macula
        for x = s(1)/4:3*s(1)/4
            
            for y = s(2)/4:3*s(2)/4
                tanVal = (mx-x)/(my-y);
                myAngle = atan(tanVal)*180/pi;
                
                
                if abs((x-mx)^2 + (y-my)^2) < 290^2 & abs((x-mx)^2 + (y-my)^2) > 200^2 & min(abs(imin - myAngle)) < 5 
                                              
                    ver = sum(sum(uint8(cg1(x-4:x+5, y-4:y+5))));
                    ver1 = sum(sum(uint8(cg1(x-9:x+10, y-9:y+10))));
                   
                    vesscount = sum(sum(vess_temp(x-20:x+20,y-20:y+20)));
                    mycompare = sum(sum(ver)) -  2.8*vesscount;
                    if maxz < mycompare
                        maxz=mycompare;
                        nx = x;
                        ny=y;
                        last = tanVal;
                    end
                    
                end
            end
        end
        im(nx-5:nx+5,ny-5:ny+5,:) = 255;
        % nx and ny are the x,y co-ordinates of macula respectively 
        
        
        % Evaluation using ground truth
        
        x_factor = double(initial_x)/double(n_resize);
	    y_factor = double(initial_y) /double(m_resize);
        actual_odx = double(GT_OD(i,2)/x_factor);
        actual_ody = double(GT_OD(i,1)/y_factor);
        deviation_od = sqrt(double((mx - actual_odx) * ( mx - actual_odx ) + (my -actual_ody ) * (my - actual_ody)));
        
        actual_macx = double(GT_MAC(i,2)/x_factor);
        actual_macy = double(GT_MAC(i,1)/y_factor);
        deviation_mac = sqrt(double((nx - actual_macx) * ( nx - actual_macx ) + (ny -actual_macy ) * (ny - actual_macy)));
        
        total_od_deviation = total_od_deviation + deviation_od;
        if deviation_od > 45
            false_od = false_od + 1;
        else
            true_od = true_od + 1;
        end
        
        total_mac_deviation = total_mac_deviation + deviation_mac;
        if deviation_mac > 45
            flase_mac = false_mac + 1;
        else
            true_mac = true_mac + 1;
        end
        OD(i,1) = mx;
        OD(i,2) = my;
        MAC(i,1) = nx;
        MAC(i,2) = ny;
       
        'Writing output ' 
        imwrite(im,strcat(output_directory,direc(i).name));
      
    end
    save('total_mac_deviation.mat','total_mac_deviation');
    save('total_od_deviation.mat','total_od_deviation');
    save('accuracy_od.mat','true_od');
    save('accuracy_mac.mat','true_mac');
    true_od/i
    true_mac/i
    toc
end
