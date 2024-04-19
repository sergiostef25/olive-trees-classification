%% Lettura coordinate
oliveTreesTable = createOliveTreesTable(readtable('new_data/ulivi_in_CROP1_RGB.xlsx'), readtable('new_data/ulivi_in_CROP2_RGB.xlsx'));

% encoding delle tipologie di ultivo (da stringa a numero)
[cultEncoded, cultNameAndCount] = grp2idx(oliveTreesTable.cult);
oliveTreesTable.cult = cultEncoded;

[oliveTreesTable, cultNameAndCount] = removeLowCountTrees(oliveTreesTable, cultNameAndCount);

clear cultEncoded
%% Hypercubes
waves=[386,400.3,405.1,409.9,414.6,419.4,424.1,430.1,436,440.8,445.6,450.3,455.1,482.4,509.7,514.5,519.2,525.2,531.1,535.8,543,550.1,559.6,569.1,620,671,675.7,680.5,685.2,690,694.7,699.4,705.4,711.3,716,720.8,725.5,730.2,735,739.7,744.5,749.2,755.1,761,781.2,801.3,930.5]';

crop1=hypercube('new_data/CROP1_47.tif',waves);
[rgbImg1, bands1] = colorize(crop1,'Method','rgb','ContrastStretching',true);

crop2=hypercube('new_data/CROP2_47.tif',waves);
[rgbImg2, bands2] = colorize(crop2,'Method','rgb','ContrastStretching',true);

seg_crop1 = ~logical(imread("new_data/Seg_CROP1.tif"));
seg_crop2 = ~logical(imread("new_data/Seg_CROP2.tif"));

%% Georaster

[A1,R1] = readgeoraster('new_data/CROP1_47.tif','Bands',bands1);
[m1, n1, ~] = size(A1);
proj1 = R1.ProjectedCRS;
[x1,y1] = projfwd(proj1,polignanoTable.expolat,polignanoTable.expolon);
A1=uint8(A1*500);
A1(repmat(seg_crop1, [1 1 3])) = 0;
    
figure
subplot(1,2,1)
mapshow(A1,R1)
hold on
for i=1:length(x1)
    mapshow(x1(i),y1(i),DisplayType="point",Marker="o",MarkerFaceColor="g",MarkerEdgeColor="none");
end
title("Polignano")
hold off
[A2,R2] = readgeoraster('new_data/CROP2_47.tif','Bands',bands2);
[m2, n2, ~] = size(A2);
proj2 = R2.ProjectedCRS;
[x2,y2] = projfwd(proj2,monopoliTable.expolat,monopoliTable.expolon);
A2=uint8(A2*500);
A2(repmat(seg_crop2, [1 1 3])) = 0;
subplot(1,2,2)
mapshow(A2,R2)
hold on
for i=1:length(x2)
    mapshow(x2(i),y2(i),DisplayType="point",Marker="o",MarkerFaceColor="g",MarkerEdgeColor="none");
end
title("Monopoli")
hold off
%% Da cartesiane a pixel
[newX1, newY1] = worldToIntrinsic(R1,x1,y1);
newX1 = round(newX1);
newY1 = round(newY1);
[newX2, newY2] = worldToIntrinsic(R2,x2,y2);
newX2 = round(newX2);
newY2 = round(newY2);

grayA1 = im2gray(A1);
raggio = 10;


[I, J] = ndgrid(1:m1, 1:n1);

mask1 = false(m1, n1);
% label di conteggio albero
treeLabel1 = zeros(m1,n1);
% label del tipo di coltura
cultLabel1 = zeros(m1,n1);

treeNum = 1;

for i = 1:length(newX1)
    % distanza euclidea
    distanza = sqrt((I - newY1(i)).^2 + (J - newX1(i)).^2);
    cultLabel1(distanza <= raggio) = oliveTreesTable{i,"cult"};
    treeLabel1(distanza <= raggio) = treeNum;
    treeNum = treeNum + 1;
    mask1 = mask1 | (distanza <= raggio);
end

mask1 = ~mask1;

% qui con l'ausilio dell'mmagine in scala di grigi
% trasformiamo i 'cerchi' che individuano gli alberi
% dello step precedente, nella forma delle loro chiome

for i=1:m1
    for j=1:n1
        if grayA1(i,j) == 0
            mask1(i,j) = 1;
            cultLabel1(i,j)=0;
            treeLabel1(i,j)=0;
        end
    end
end

newA1 = A1;
newA1(repmat(mask1, [1 1 3])) = 255;

grayA2 = im2gray(A2);

[I, J] = ndgrid(1:m2, 1:n2);

mask2 = false(m2, n2);
treeLabel2 = zeros(m2,n2);
cultLabel2 = zeros(m2,n2);

for i = 1:length(newX2)
    % distanza euclidea
    distanza = sqrt((I - newY2(i)).^2 + (J - newX2(i)).^2);
    cultLabel2(distanza <= raggio) = oliveTreesTable{i+height(polignanoTable),"cult"};
    treeLabel2(distanza <= raggio) = treeNum;
    treeNum = treeNum + 1;
    mask2 = mask2 | (distanza <= raggio);
end

mask2 = ~mask2;

for i=1:m2
    for j=1:n2
        if grayA2(i,j) == 0
            mask2(i,j) = 1;
            cultLabel2(i,j)=0;
            treeLabel2(i,j)=0;
        end
    end
end
newA2 = A2;
newA2(repmat(mask2, [1 1 3])) = 255;

figure
subplot(1,2,1)
imshow(newA1)
title('Polignano')
subplot(1,2,2)
imshow(newA2)
title('Monopoli')



[row1, col1] = find(cultLabel1 == 1);
[row2, col2] = find(cultLabel1 == 2);
[row3, col3] = find(cultLabel1 == 3);
[row4, col4] = find(cultLabel1 == 4);
[row5, col5] = find(cultLabel1 == 5);
[row6, col6] = find(cultLabel1 == 6);
[row7, col7] = find(cultLabel1 == 7);
[row8, col8] = find(cultLabel1 == 8);
[row9, col9] = find(cultLabel1 == 9);
[row10, col10] = find(cultLabel1 == 10);
[row11, col11] = find(cultLabel1 == 11);
figure
subplot(1,2,1)
imshow(rgbImg1)
hold on
c1 = plot(col1, row1, '.', 'MarkerSize', 7,'Color', '#D95319','DisplayName','Altro');
c2 = plot(col2, row2, '.', 'MarkerSize', 7,'Color', '#008000','DisplayName','Leccino');
c3 = plot(col3, row3, '.', 'MarkerSize', 7,'Color', '#0072BD','DisplayName','Nociara');
c4 = plot(col4, row4, '.', 'MarkerSize', 7,'Color', '#0000FF','DisplayName','Ogliarola barese');
c5 = plot(col5, row5, '.', 'MarkerSize', 7, 'Color', '#800080','DisplayName','Oliastro');
c6 = plot(col6, row6, '.', 'MarkerSize', 7,'Color', '#EDB120','DisplayName','Coratina');
c7 = plot(col7, row7, '.', 'MarkerSize', 7,'Color', '#7E2F8E','DisplayName','Cornale');
c8 = plot(col8, row8, '.', 'MarkerSize', 7,'Color', '#77AC30','DisplayName','Frantoio');
c9 = plot(col9, row9, '.', 'MarkerSize', 7,'Color', '#4DBEEE','DisplayName','Mele');
c10 = plot(col10, row10, '.', 'MarkerSize', 7,'Color', '#A2142F','DisplayName','Ogliarola salentina');
c11 = plot(col11, row11, '.', 'MarkerSize', 7,'Color', '#FF0000','DisplayName','Oliva rossa');
title("Polignano")
hold off
legend([c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11])
clear c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11

[row1, col1] = find(cultLabel2 == 1);
[row2, col2] = find(cultLabel2 == 2);
[row3, col3] = find(cultLabel2 == 3);
[row4, col4] = find(cultLabel2 == 4);
[row5, col5] = find(cultLabel2 == 5);
[row6, col6] = find(cultLabel2 == 6);
[row7, col7] = find(cultLabel2 == 7);
[row8, col8] = find(cultLabel2 == 8);
[row9, col9] = find(cultLabel2 == 9);
[row10, col10] = find(cultLabel2 == 10);
[row11, col11] = find(cultLabel2 == 11);
subplot(1,2,2)
imshow(rgbImg2)
hold on
c1 = plot(col1, row1, '.', 'MarkerSize', 7,'Color', '#D95319','DisplayName','Altro');
c2 = plot(col2, row2, '.', 'MarkerSize', 7,'Color', '#008000','DisplayName','Leccino');
c3 = plot(col3, row3, '.', 'MarkerSize', 7,'Color', '#0072BD','DisplayName','Nociara');
c4 = plot(col4, row4, '.', 'MarkerSize', 7,'Color', '#0000FF','DisplayName','Ogliarola barese');
c5 = plot(col5, row5, '.', 'MarkerSize', 7, 'Color', '#800080','DisplayName','Oliastro');
c6 = plot(col6, row6, '.', 'MarkerSize', 7,'Color', '#EDB120','DisplayName','Coratina');
c7 = plot(col7, row7, '.', 'MarkerSize', 7,'Color', '#7E2F8E','DisplayName','Cornale');
c8 = plot(col8, row8, '.', 'MarkerSize', 7,'Color', '#77AC30','DisplayName','Frantoio');
c9 = plot(col9, row9, '.', 'MarkerSize', 7,'Color', '#4DBEEE','DisplayName','Mele');
c10 = plot(col10, row10, '.', 'MarkerSize', 7,'Color', '#A2142F','DisplayName','Ogliarola salentina');
c11 = plot(col11, row11, '.', 'MarkerSize', 7,'Color', '#FF0000','DisplayName','Oliva rossa');
title("Monopoli")
hold off
legend([c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11])
clear c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 col1 col2 col3 col4 col5 col6 col7 col8 col9 col10 col11
clear row1 row2 row3 row4 row5 row6 row7 row8 row9 row10 row11
%% Maschera HSV per eliminare il terreno dall'immagine segmentata 
newRgbImg1 = rgbImg1;
newRgbImg1(repmat(mask1, [1 1 3])) = 255;
hsvImg = rgb2hsv(newRgbImg1);
% tonalità
hue = hsvImg(:,:,1);
% per visualizzare al meglio l'istogramma delle tonalità
% i pixel di valore 0 (nero) non vengono visualizzati

X = hue(hue ~= 0);
% figure
% imhist(X)

% Soglie impostata vedendo l'istogramma
terrainMask1 =  hsvImg(:,:,1) <= 0.18 | hsvImg(:,:,1) >= 0.45;
newRgbImgNoOut1 = newRgbImg1;
newRgbImgNoOut1(repmat(terrainMask1, [1 1 3])) = 255;


figure
subplot(2,3,1)
imshow(newRgbImg1)
title('Polignano with terrain')
subplot(2,3,2)
imshow(newRgbImgNoOut1)
title('Polignano without terrain')
subplot(2,3,3)
imshowpair(newRgbImg1,newRgbImgNoOut1)
title('Polignano differences')

newRgbImg2 = rgbImg2;
newRgbImg2(repmat(mask2, [1 1 3])) = 255;
hsvImg = rgb2hsv(newRgbImg2);
% tonalità
hue = hsvImg(:,:,1);
% per visualizzare al meglio l'istogramma delle tonalità
% i pixel di valore 0 (nero) non vengono visualizzati

X = hue(hue ~= 0);
% figure
% imhist(X)

% Soglie impostata vedendo l'istogramma
terrainMask2 =  hsvImg(:,:,1) <= 0.18 | hsvImg(:,:,1) >= 0.45;
newRgbImgNoOut2 = newRgbImg2;
newRgbImgNoOut2(repmat(terrainMask2, [1 1 3])) = 255;


subplot(2,3,4)
imshow(newRgbImg2)
title('Monopoli with terrain')
subplot(2,3,5)
imshow(newRgbImgNoOut2)
title('Monopoli without terrain')
subplot(2,3,6)
imshowpair(newRgbImg2,newRgbImgNoOut2)
title('Monopoli differences')


cultLabel1(terrainMask1) = 0;
treeLabel1(terrainMask1) = 0;

mask1 = mask1 | terrainMask1;
newA1(repmat(mask1, [1 1 3])) = 255;


cultLabel2(terrainMask2) = 0;
treeLabel2(terrainMask2) = 0;

mask2 = mask2 | terrainMask2;
newA2(repmat(mask2, [1 1 3])) = 255;

%% CalcoloVI
ndviImg1 = computeVIs(crop1, 'ndvi');
evi2Img1 = computeVIs(crop1 , 'evi2');
cireImg1 = computeVIs(crop1, 'cire');
gndviImg1 = computeVIs(crop1, 'gndvi');
grviImg1 = computeVIs(crop1, 'grvi');
psriImg1 = computeVIs(crop1, 'psri');
renImg1 = computeVIs(crop1, 'ren');
saviImg1 = computeVIs(crop1, 'savi');

ndviImg2 = computeVIs(crop2, 'ndvi');
evi2Img2 = computeVIs(crop2, 'evi2');
cireImg2 = computeVIs(crop2, 'cire');
gndviImg2 = computeVIs(crop2, 'gndvi');
grviImg2 = computeVIs(crop2, 'grvi');
psriImg2 = computeVIs(crop2, 'psri');
renImg2 = computeVIs(crop2, 'ren');
saviImg2 = computeVIs(crop2, 'savi');

ndviImg1(mask1)=0;
evi2Img1(mask1)=0;
cireImg1(mask1)=0;
gndviImg1(mask1)=0;
grviImg1(mask1)=0;
psriImg1(mask1)=0;
renImg1(mask1)=0;
saviImg1(mask1)=0;

ndviImg2(mask2)=0;
evi2Img2(mask2)=0;
cireImg2(mask2)=0;
gndviImg2(mask2)=0;
grviImg2(mask2)=0;
psriImg2(mask2)=0;
renImg2(mask2)=0;
saviImg2(mask2)=0;
%% Merge immagine
additionNewA1 = zeros(m2-m1,n1,3);
additionNewA1(:) = 255;
mergedRgbImg = cat(2, [newA1; additionNewA1], newA2);
figure
imshow(mergedRgbImg)
title('Polignano and Monopoli merged')

mergedCultLabel = cat(2, [cultLabel1; zeros(m2-m1,n1)], cultLabel2);
mergedTreeLabel = cat(2, [treeLabel1; zeros(m2-m1,n1)], treeLabel2);


ndviImg = cat(2, [ndviImg1; zeros(m2-m1,n1)], ndviImg2);
clear ndviImg1 ndviImg2
evi2Img = cat(2, [evi2Img1; zeros(m2-m1,n1)], evi2Img2);
clear evi2Img1 evi2Img2
cireImg = cat(2, [cireImg1; zeros(m2-m1,n1)], cireImg2);
clear cireImg1 cireImg2
gndviImg = cat(2, [gndviImg1; zeros(m2-m1,n1)], gndviImg2);
clear gndviImg1 gndviImg2
grviImg = cat(2, [grviImg1; zeros(m2-m1,n1)], grviImg2);
clear grviImg1 grviImg2
psriImg = cat(2, [psriImg1; zeros(m2-m1,n1)], psriImg2);
clear psriImg1 psriImg2
renImg = cat(2, [renImg1; zeros(m2-m1,n1)], renImg2);
clear renImg1 renImg2
saviImg = cat(2, [saviImg1; zeros(m2-m1,n1)], saviImg2);
clear saviImg1 saviImg2;

%% Visualizza VI
figure
imagesc(ndviImg);
colorbar
title('NDVI')

figure
imagesc(evi2Img);
colorbar
title('EVI2')

figure
imagesc(cireImg);
colorbar
title('CIRE')

figure
imagesc(gndviImg);
colorbar
title('GNDVI')

figure
imagesc(grviImg);
colorbar
title('GRVI')

figure
imagesc(psriImg, [0, 1]);
colorbar
title('PSRI')

figure
imagesc(renImg);
colorbar
title('REN')

figure
imagesc(saviImg);
colorbar
title('SAVI')
%% Creazione Dataset
notTerrIdx = find(mergedCultLabel);
[rowDataset, colDataset] = ind2sub(size(mergedCultLabel),notTerrIdx);

green = cat(2, [crop1.DataCube(:,:,22); zeros(m2-m1,n1)], crop2.DataCube(:,:,22));
red = cat(2, [crop1.DataCube(:,:,26); zeros(m2-m1,n1)], crop2.DataCube(:,:,26));
redEdge = cat(2, [crop1.DataCube(:,:,37); zeros(m2-m1,n1)], crop2.DataCube(:,:,37));
nir = cat(2, [crop1.DataCube(:,:,46); zeros(m2-m1,n1)], crop2.DataCube(:,:,46));

dataset = table(ndviImg(notTerrIdx),evi2Img(notTerrIdx),cireImg(notTerrIdx),gndviImg(notTerrIdx),grviImg(notTerrIdx),psriImg(notTerrIdx),renImg(notTerrIdx),saviImg(notTerrIdx), ...
    green(notTerrIdx), red(notTerrIdx), redEdge(notTerrIdx), nir(notTerrIdx), rowDataset, colDataset, mergedTreeLabel(notTerrIdx),zeros(size(notTerrIdx)),...
    'VariableNames',{'ndvi','evi2','cire','gndvi','grvi','psri','ren','savi', 'green','red','rededge','nir','row','col','treenum','place'});
%% Creazione Training e Test set
% length(find(mergedCultLabel == 11))
aa = cultName;

