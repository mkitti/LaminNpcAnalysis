function pThis = splitPerChannelParams(pAll,iChan)
%SPLITPERCHANNELPARAMS splits per-channel parameters to create single-channel parameter structure
%
% pThisChan = splitPerChannelParams(pAllChan,iChan)
%
% Set up parameter structure for detection on single specified channel,
% given input structure containing variable-format parameters for all
% channels. (designed to accepts output of e.g. prepPerChannelParams.m)
%

%Hunter Elliott
%6/2014


pThis = pAll;
for l = 1:numel(pAll.PerChannelParams)
    if isfield(pAll,pAll.PerChannelParams{l})%Check, some params may use defaults
        if iscell(pAll.(pAll.PerChannelParams{l}))
            pThis.(pAll.PerChannelParams{l}) = pAll.(pAll.PerChannelParams{l}){iChan};
        else
            pThis.(pAll.PerChannelParams{l}) = pAll.(pAll.PerChannelParams{l})(:,iChan);
            if all(isnan(pAll.(pAll.PerChannelParams{l})(:,iChan)))
                pThis.(pAll.PerChannelParams{l}) = [];
            end
        end        
    end
end