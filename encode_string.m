function data = encode_string(str)
    numArray = uint8(str);
    if (length(numArray) * 8 > 83)
        throw(MException('encode_string:stringTooLong', 'The input string is too long to encode'));
    end
    
    byteArray = de2bi(numArray, 8, 'left-msb');
    if (size(byteArray,1) == 1)
        data = [byteArray, zeros(1, 83 - numel(byteArray))];
    else
        data = [reshape(byteArray.',1,[]), zeros(1, 83 - numel(byteArray))];
    end  
end

