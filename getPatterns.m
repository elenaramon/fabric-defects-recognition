% Cerca i pattern migliori su cui effettuare la cross-correlazione
% Partendo da un pattern "sicuramente corretto", posizionato in alto a
% sinistra, la funzione effettua una convoluzione dalla quale determinano
% quali zone sono quasi sicuramente prive di errore.
function [pattern1, pattern2, pattern3, pattern4, patternWidth] = getPatterns(image, startPatternX, startPatternY, patternWidth, threshold, patternStartWidth)
    [imageSizeY, imageSizeX] = size(image);
    numberOfImageCells = imageSizeY * imageSizeX;
    startPattern = image(startPatternX : (startPatternX + patternStartWidth), startPatternY : (startPatternY + patternStartWidth));
    
    % conv2(image, pattern);
    convolvedImage = real(ifft2(fft2(image) .* fft2(startPattern, imageSizeY, imageSizeX)));
    imageWithThreshold = applyThreshold(convolvedImage, threshold);
    
    % Se il numero di celle nere (ovvero celle dove � stato riconosciuto un
    % errore) � maggiore dell'85% delle celle totali, il pattern base viene
    % ridimensionato finch� non si raggiunge un valore di celle nere
    % ideale.
    [yPositionOfOneValue, xPositionOfOneValue] = find(imageWithThreshold == 1);
    dimensione = size(yPositionOfOneValue);
    storeThreshold = threshold;
    while(dimensione(1) > (numberOfImageCells * 0.85) && patternStartWidth > 4) 
        patternStartWidth = floor(patternStartWidth * 0.8);
        patternWidth = patternWidth * 1.05;
        threshold = threshold - 0.87;
        startPattern = image(startPatternX : (startPatternX + patternStartWidth), startPatternY : (startPatternY + patternStartWidth));
        convolvedImage = real(ifft2(fft2(image) .* fft2(startPattern, imageSizeY, imageSizeX)));
        imageWithThreshold = applyThreshold(convolvedImage, threshold);
    
        [yPositionOfOneValue, xPositionOfOneValue] = find(imageWithThreshold == 1);
        dimensione = size(yPositionOfOneValue);
    end
    
    % Se i parametri di default sono corretti (quindi non siamo mai entrati
    % nel ciclo while sopra), imposto i valori di default per la ricerca
    % dei pattern.
    if(storeThreshold == threshold)
        threshold = 85;
        convolvedImage = real(ifft2(fft2(image) .* fft2(startPattern, imageSizeY, imageSizeX)));
        imageWithThreshold = applyThreshold(convolvedImage, threshold);
    
        [yPositionOfOneValue, xPositionOfOneValue] = find(imageWithThreshold == 1);
    end
    
    patternWidth = floor(patternWidth);
    positionOfXElements = find(xPositionOfOneValue < (imageSizeX - patternWidth));
    positionOfYElements = find(yPositionOfOneValue < (imageSizeY - patternWidth));
    
    % Cerco la dimensione minima dei due array cos� da evitare eccezioni di
    % overflow
    minPositionElement = min(size(positionOfXElements), size(positionOfYElements));
    
    yPositionOfOneValueWithPatternWidth = yPositionOfOneValue + patternWidth;
    xPositionOfOneValueWithPatternWidth = xPositionOfOneValue + patternWidth;
    halfNumberOfXElements = floor(minPositionElement(1) / 2);
    quarterNumberOfXElements = floor(halfNumberOfXElements / 2);    
    while(yPositionOfOneValue(halfNumberOfXElements) >= (imageSizeY - patternWidth) || xPositionOfOneValue(halfNumberOfXElements) >= (imageSizeX - patternWidth) || yPositionOfOneValueWithPatternWidth(quarterNumberOfXElements) >= (imageSizeY - patternWidth) || xPositionOfOneValueWithPatternWidth(quarterNumberOfXElements) >= (imageSizeX - patternWidth))
        halfNumberOfXElements = floor(halfNumberOfXElements / 2);
        quarterNumberOfXElements = floor(halfNumberOfXElements / 2);
    end
    
    pattern1 = image(yPositionOfOneValue(1) : yPositionOfOneValueWithPatternWidth(1), xPositionOfOneValue(1) : xPositionOfOneValueWithPatternWidth(1));
    pattern2 = image(yPositionOfOneValue(halfNumberOfXElements) : yPositionOfOneValueWithPatternWidth(halfNumberOfXElements), xPositionOfOneValue(halfNumberOfXElements) : xPositionOfOneValueWithPatternWidth(halfNumberOfXElements));
    pattern3 = image(imageSizeY - patternWidth : imageSizeY, imageSizeX - patternWidth : imageSizeX);
    pattern4 = image(yPositionOfOneValue(quarterNumberOfXElements) : yPositionOfOneValueWithPatternWidth(quarterNumberOfXElements), xPositionOfOneValue(quarterNumberOfXElements) : xPositionOfOneValueWithPatternWidth(quarterNumberOfXElements));
    
    % Plot
    %{
    figure; title 'TDF';
    subplot(221); imshow(image); title 'Immagine con pattern di partenza';
    rectangle('position',[startPatternX, startPatternY, patternWidth, patternWidth], 'EdgeColor',[1 0 0]);
    subplot(222); imshow(convolvedImage, []); title 'Immagine post convoluzione';
    subplot(223); imshow(imageWithThreshold, []); title 'Immagine dopo threshold';
    subplot(224); imshow(image); title 'Immagine con pattern finali';
    rectangle('position', [yPositionOfOneValue(1), xPositionOfOneValue(1), patternWidth, patternWidth], 'EdgeColor',[1 0 0]);
    rectangle('position',[yPositionOfOneValue(halfNumberOfXElements), xPositionOfOneValue(halfNumberOfXElements), patternWidth, patternWidth], 'EdgeColor',[1 0 0]);
    rectangle('position', [imageSizeY - patternWidth, imageSizeX - patternWidth, patternWidth, patternWidth], 'EdgeColor', [1 0 0]);
    rectangle('position',[yPositionOfOneValue(quarterNumberOfXElements), xPositionOfOneValue(quarterNumberOfXElements), patternWidth, patternWidth], 'EdgeColor',[1 0 0]);
    %}
end

