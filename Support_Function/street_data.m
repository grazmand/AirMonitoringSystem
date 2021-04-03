function street=street_data ( street, ie )

% long_array = cell(1,size(street.xy,2));
%
% long_max = cell(1,size(street.xy,2));

for ip = 1:size(street.xy,2)
    
    if ip==13
        deb=0;
    end
    
    [ street.data{ie}.acolor{ip} , street.data{ie}.color{ip} ] = motor_color ( street.rgb{ie} , street.xy{ip} );
    
    
    [street.poly{ip}, street.data{ie}.acolor{ip}]= StreetGenerator_mod_2 ( street.coord{ip} , street.data{ie}.acolor{ip} );
    
end

clearvars -except street

end