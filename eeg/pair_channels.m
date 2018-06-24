function locations = pair_channels(expected_chanlocs)
locations = [];
centN = 1;
latN = 1;
for ch1 = 1:numel(expected_chanlocs)
    if(expected_chanlocs(ch1).radius == 0 || expected_chanlocs(ch1).theta == 0 || expected_chanlocs(ch1).theta == 180)
        locations.center(centN) = ch1;
        centN = centN + 1;
    else
        for ch2 = ch1+1:numel(expected_chanlocs)
            radiusCrit = abs(expected_chanlocs(ch1).radius - expected_chanlocs(ch2).radius)<1e-3;
            thetaCrit = abs(expected_chanlocs(ch1).theta + expected_chanlocs(ch2).theta)<1e-3;
            if(radiusCrit && thetaCrit)
                % Match found
                if(expected_chanlocs(ch1).theta < expected_chanlocs(ch2).theta)
                    locations.left(latN) = ch1;
                    locations.right(latN) = ch2;
                else
                    locations.left(latN) = ch2;
                    locations.right(latN) = ch1;
                end
                latN = latN + 1;
            end
        end
    end
end
