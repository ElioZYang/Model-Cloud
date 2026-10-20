function thermalBoundary=mc_pmsm_c_boundary(T,P,WA,FAR,D,EFFH,temp_Fe,temp_Cu,free_temperature_mask,mode,TPR_ref,WCOR_ref)
thermalBoundary=struct('T',T,'P',P,'WA',WA,'FAR',FAR,'D',D,'EFFH',EFFH,...
    'T_Fe',temp_Fe+273,'T_Cu',temp_Cu+273,'mode',string(mode),...
    'free_temperature_mask',logical(free_temperature_mask(:)),'TPR_ref',TPR_ref,'WCOR_ref',WCOR_ref);
if numel(thermalBoundary.free_temperature_mask)~=2||any(~isfinite([temp_Fe,temp_Cu]))
    error('PMSM:InvalidBoundary','Two finite temperatures and two boundary flags are required.');
end
end
