function [dat,aux] = readabf(ifn, epi, offset, limit)
% READABF - Read ABF files from pClamp 10 into Matlab
%    dat = READABF(ifn) simply reads the data and returns values in mV or nA.
%    [dat,aux] = READABF(ifn) also returns a structure with auxiliary
%    information, which includes:
%       CHANNELNAME: cell array of the names of each channel included in DAT.
%       UNIT: cell array specifying the units (i.e. mV for voltage channels,
%             nA for current channels).
%       DT_S: time (in seconds) between successive samples
%       FS_HZ: sampling frequency (in Hz).
%    AUX also contains a substructure, ABF, which contains lots of hard-to-
%    interpret information straight from the ABF file.
%    [dat,aux] = READABF(ifn,epi,offset,limit) specifies reading only
%    episode #EPI, starting at offset OFFSET, and reading no more than LIMIT
%    samples per channel.
%    This function only works for pClamp 10 and later; for pClamp 9 and
%    ealier, you can use ABFLOAD instead.

if nargin<2
  epi=[];
end
if nargin<3
  offset=0;
end
if nargin<4
  limit=inf;
end

% This is for ABF 2 file format.

fd = fopen(ifn,'rb');
if fd<0
  error(sprintf('readabf: cannot read "%s"',ifn));
end

aux.hdr.uFileSignature = fread(fd,1,'uint32');

if aux.hdr.uFileSignature == hex2dec('20464241')
  error('readabf: file is from pClamp 9 or before; use abfload instead');
end

if aux.hdr.uFileSignature ~= hex2dec('32464241')
  error('readabf: bad file signature');
end

aux.hdr.uFileVersionNumber = fread(fd,1,'uint32');
if aux.hdr.uFileVersionNumber~=hex2dec('02000000')
  error('readabf: bad file version number');
end

aux.hdr.uFileInfoSize = fread(fd,1,'uint32');
aux.hdr.uActualEpisodes = fread(fd,1,'uint32');
aux.hdr.uFileStartDate = fread(fd,1,'uint32');
aux.hdr.uFileStartTimeMS = fread(fd,1,'uint32');
aux.hdr.uStopwatchTime = fread(fd,1,'uint32');;
aux.hdr.nFileType = fread(fd,1,'int16');
aux.hdr.nDataFormat = fread(fd,1,'int16');
aux.hdr.nSimultaneousScan = fread(fd,1,'int16');
aux.hdr.nCRCEnable = fread(fd,1,'int16');
aux.hdr.uFileCRC = fread(fd,1,'uint32');
aux.hdr.FileGUID = fread(fd,4,'uint32');
aux.hdr.uCreatorVersion = fread(fd,1,'uint32');
aux.hdr.uCreatorNameIndex = fread(fd,1,'uint32');
aux.hdr.uModifierVersion = fread(fd,1,'uint32');
aux.hdr.uModifierNameIndex = fread(fd,1,'uint32');
aux.hdr.uProtocolPathIndex = fread(fd,1,'uint32');   
aux.sec.ProtocolSection = abf_readsection(fd);
aux.sec.ADCSection = abf_readsection(fd);
aux.sec.DACSection = abf_readsection(fd);
aux.sec.EpochSection = abf_readsection(fd);
aux.sec.ADCPerDACSection = abf_readsection(fd);
aux.sec.EpochPerDACSection = abf_readsection(fd);
aux.sec.UserListSection = abf_readsection(fd);
aux.sec.StatsRegionSection = abf_readsection(fd);
aux.sec.MathSection = abf_readsection(fd);
aux.sec.StringsSection = abf_readsection(fd);
aux.sec.DataSection = abf_readsection(fd);
aux.sec.TagSection = abf_readsection(fd);
aux.sec.ScopeSection = abf_readsection(fd);
aux.sec.DeltaSection = abf_readsection(fd);
aux.sec.VoiceTagSection = abf_readsection(fd);
aux.sec.SynchArraySection = abf_readsection(fd);
aux.sec.AnnotationSection = abf_readsection(fd);
aux.sec.StatsSection = abf_readsection(fd);
sUnused = fread(fd,148,'char');
if ftell(fd)~=512
  error('readabf: bug in reading header');
end
aux.info.protocol = abf_readProtocolInfo(fd,aux.sec.ProtocolSection);
aux.info.adc = abf_readADCInfo(fd,aux.sec.ADCSection);
aux.info.dac = abf_readDACInfo(fd,aux.sec.DACSection);
aux.info.epoch = abf_readEpochInfo(fd,aux.sec.EpochSection);
aux.info.adcperdac = abf_readGenericSection(fd,aux.sec.ADCPerDACSection);
aux.info.epochperdac = abf_readGenericSection(fd,aux.sec.EpochPerDACSection);
aux.info.userlist = abf_readUserListInfo(fd,aux.sec.UserListSection);
aux.info.statsregion = abf_readStatsRegionInfo(fd,aux.sec.StatsRegionSection);
aux.info.math = abf_readMathInfo(fd,aux.sec.MathSection);
aux.info.strings = abf_readStringsSection(fd,aux.sec.StringsSection);
aux.info.tag = abf_readGenericSection(fd,aux.sec.TagSection);
aux.info.scope =  abf_readGenericSection(fd,aux.sec.ScopeSection);
aux.info.delta =  abf_readGenericSection(fd,aux.sec.DeltaSection);
aux.info.voicetag =  abf_readGenericSection(fd,aux.sec.VoiceTagSection);
aux.info.syncharray =  abf_readGenericSection(fd,aux.sec.SynchArraySection);
aux.info.annotation =  abf_readGenericSection(fd,aux.sec.AnnotationSection);
aux.info.stats =  abf_readGenericSection(fd,aux.sec.StatsSection);
dat = abf_readData(fd,aux, epi, offset, limit);
fclose(fd);

hdr = aux.hdr;
info = aux.info;

clear aux
aux.abf = info;
aux.abf.hdr = hdr;

for k=1:length(aux.abf.adc)
  aux.channelname{k} = aux.abf.strings{aux.abf.adc(k).lADCChannelNameIndex};
  aux.unit{k} = aux.abf.strings{aux.abf.adc(k).lADCUnitsIndex};
end
aux.dt_s = aux.abf.protocol.fADCSequenceInterval/1e6;
aux.fs_hz = 1/aux.dt_s;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = abf_readsection(fd)
s.uBlockIndex = fread(fd,1,'uint32');
s.uBytes = fread(fd,1,'uint32');
s.llNumEntries = fread(fd,1,'int64');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = abf_readProtocolInfo(fd,s);
if s.uBlockIndex==0
  p=[];
  return
end
fseek(fd,s.uBlockIndex*512,'bof');
for k=1:s.llNumEntries
  p(k).nOperationMode = fread(fd,1,'int16');
  p(k).fADCSequenceInterval = fread(fd,1,'float');
  p(k).bEnableFileCompression = fread(fd,1,'char');
  sUnused1 = fread(fd,3,'char');
  p(k).uFileCompressionRatio = fread(fd,1,'uint32');
  p(k).fSynchTimeUnit = fread(fd,1,'float');
  p(k).fSecondsPerRun = fread(fd,1,'float');
  p(k).lNumSamplesPerEpisode = fread(fd,1,'int32');
  p(k).lPreTriggerSamples = fread(fd,1,'int32');
  p(k).lEpisodesPerRun = fread(fd,1,'int32');
  p(k).lRunsPerTrial = fread(fd,1,'int32');
  p(k).lNumberOfTrials = fread(fd,1,'int32');
  p(k).nAveragingMode = fread(fd,1,'int16');
  p(k).nUndoRunCount = fread(fd,1,'int16');
  p(k).nFirstEpisodeInRun = fread(fd,1,'int16');
  p(k).fTriggerThreshold = fread(fd,1,'float');
  p(k).nTriggerSource = fread(fd,1,'int16');
  p(k).nTriggerAction = fread(fd,1,'int16');
  p(k).nTriggerPolarity = fread(fd,1,'int16');
  p(k).fScopeOutputInterval = fread(fd,1,'float');
  p(k).fEpisodeStartToStart = fread(fd,1,'float');
  p(k).fRunStartToStart = fread(fd,1,'float');
  p(k).lAverageCount = fread(fd,1,'int32');
  p(k).fTrialStartToStart = fread(fd,1,'float');
  p(k).nAutoTriggerStrategy = fread(fd,1,'int16');
  p(k).fFirstRunDelayS = fread(fd,1,'float');
  p(k).nChannelStatsStrategy = fread(fd,1,'int16');
  p(k).lSamplesPerTrace = fread(fd,1,'int32');
  p(k).lStartDisplayNum = fread(fd,1,'int32');
  p(k).lFinishDisplayNum = fread(fd,1,'int32');
  p(k).nShowPNRawData = fread(fd,1,'int16');
  p(k).fStatisticsPeriod = fread(fd,1,'float');
  p(k).lStatisticsMeasurements = fread(fd,1,'int32');
  p(k).nStatisticsSaveStrategy = fread(fd,1,'int16');
  p(k).fADCRange = fread(fd,1,'float');
  p(k).fDACRange = fread(fd,1,'float');
  p(k).lADCResolution = fread(fd,1,'int32');
  p(k).lDACResolution = fread(fd,1,'int32');
  p(k).nExperimentType = fread(fd,1,'int16');
  p(k).nManualInfoStrategy = fread(fd,1,'int16');
  p(k).nCommentsEnable = fread(fd,1,'int16');
  p(k).lFileCommentIndex = fread(fd,1,'int32');
  p(k).nAutoAnalyseEnable = fread(fd,1,'int16');
  p(k).nSignalType = fread(fd,1,'int16');
  p(k).nDigitalEnable = fread(fd,1,'int16');
  p(k).nActiveDACChannel = fread(fd,1,'int16');
  p(k).nDigitalHolding = fread(fd,1,'int16');
  p(k).nDigitalInterEpisode = fread(fd,1,'int16');
  p(k).nDigitalDACChannel = fread(fd,1,'int16');
  p(k).nDigitalTrainActiveLogic = fread(fd,1,'int16');
  p(k).nStatsEnable = fread(fd,1,'int16');
  p(k).nStatisticsClearStrategy = fread(fd,1,'int16');
  p(k).nLevelHysteresis = fread(fd,1,'int16');
  p(k).lTimeHysteresis = fread(fd,1,'int32');
  p(k).nAllowExternalTags = fread(fd,1,'int16');
  p(k).nAverageAlgorithm = fread(fd,1,'int16');
  p(k).fAverageWeighting = fread(fd,1,'float');
  p(k).nUndoPromptStrategy = fread(fd,1,'int16');
  p(k).nTrialTriggerSource = fread(fd,1,'int16');
  p(k).nStatisticsDisplayStrategy = fread(fd,1,'int16');
  p(k).nExternalTagType = fread(fd,1,'int16');
  p(k).nScopeTriggerOut = fread(fd,1,'int16');
  p(k).nLTPType = fread(fd,1,'int16');
  p(k).nAlternateDACOutputState = fread(fd,1,'int16');
  p(k).nAlternateDigitalOutputState = fread(fd,1,'int16');
  p(k).fCellID = fread(fd,3,'float');
  p(k).nDigitizerADCs = fread(fd,1,'int16');
  p(k).nDigitizerDACs = fread(fd,1,'int16');
  p(k).nDigitizerTotalDigitalOuts = fread(fd,1,'int16');
  p(k).nDigitizerSynchDigitalOuts = fread(fd,1,'int16');
  p(k).nDigitizerType = fread(fd,1,'int16');
  sUnused = fread(fd,304,'char');
end
n = ftell(fd) - s.uBlockIndex*512;
if n~=s.llNumEntries * s.uBytes
  error('readabf: bug in readProtocolInfo');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = abf_readMathInfo(fd,s);
if s.uBlockIndex==0
  p=[];
  return
end
fseek(fd,s.uBlockIndex*512,'bof');
for k=1:s.llNumEntries
  p(k).nMathEnable = fread(fd,1,'int16');
  p(k).nMathExpression = fread(fd,1,'int16');
  p(k).uMathOperatorIndex = fread(fd,1,'uint32');
  p(k).uMathUnitsIndex = fread(fd,1,'uint32');
  p(k).fMathUpperLimit = fread(fd,1,'float');
  p(k).fMathLowerLimit = fread(fd,1,'float');
  p(k).nMathADCNum = fread(fd,2,'int16');
  sUnused = fread(fd,16,'char');
  p(k).fMathK = fread(fd,6,'float');
  sUnused2 = fread(fd,64,'char');
end
n = ftell(fd) - s.uBlockIndex*512;
if n~=s.llNumEntries * s.uBytes
  error('readabf: bug in readMathInfo');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = abf_readADCInfo(fd,s);
if s.uBlockIndex==0
  p=[];
  return
end
fseek(fd,s.uBlockIndex*512,'bof');
for k=1:s.llNumEntries
  p(k).nADCNum = fread(fd,1,'int16');
  p(k).nTelegraphEnable = fread(fd,1,'int16');
  p(k).nTelegraphInstrument = fread(fd,1,'int16');
  p(k).fTelegraphAdditGain = fread(fd,1,'float');
  p(k).fTelegraphFilter = fread(fd,1,'float');
  p(k).fTelegraphMembraneCap = fread(fd,1,'float');
  p(k).nTelegraphMode = fread(fd,1,'int16');
  p(k).fTelegraphAccessResistance = fread(fd,1,'float');
  p(k).nADCPtoLChannelMap = fread(fd,1,'int16');
  p(k).nADCSamplingSeq = fread(fd,1,'int16');
  p(k).fADCProgrammableGain = fread(fd,1,'float');
  p(k).fADCDisplayAmplification = fread(fd,1,'float');
  p(k).fADCDisplayOffset = fread(fd,1,'float');
  p(k).fInstrumentScaleFactor = fread(fd,1,'float');
  p(k).fInstrumentOffset = fread(fd,1,'float');
  p(k).fSignalGain = fread(fd,1,'float');
  p(k).fSignalOffset = fread(fd,1,'float');
  p(k).fSignalLowpassFilter = fread(fd,1,'float');
  p(k).fSignalHighpassFilter = fread(fd,1,'float');
  p(k).nLowpassFilterType = fread(fd,1,'char');
  p(k).nHighpassFilterType = fread(fd,1,'char');
  p(k).fPostProcessLowpassFilter = fread(fd,1,'float');
  p(k).nPostProcessLowpassFilterType = fread(fd,1,'char');
  p(k).bEnabledDuringPN = fread(fd,1,'char');
  p(k).nStatsChannelPolarity = fread(fd,1,'int16');
  p(k).lADCChannelNameIndex = fread(fd,1,'int32');
  p(k).lADCUnitsIndex = fread(fd,1,'int32');
  sUnused = fread(fd,46,'char');
end
n = ftell(fd) - s.uBlockIndex*512;
if n~=s.llNumEntries * s.uBytes
  error('readabf: bug in readADCInfo');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = abf_readDACInfo(fd,s);
if s.uBlockIndex==0
  p=[];
  return
end
fseek(fd,s.uBlockIndex*512,'bof');
for k=1:s.llNumEntries
  p(k).nDACNum = fread(fd,1,'int16');
  p(k).nTelegraphDACScaleFactorEnable = fread(fd,1,'int16');
  p(k).fInstrumentHoldingLevel = fread(fd,1,'float');
  p(k).fDACScaleFactor = fread(fd,1,'float');
  p(k).fDACHoldingLevel = fread(fd,1,'float');
  p(k).fDACCalibrationFactor = fread(fd,1,'float');
  p(k).fDACCalibrationOffset = fread(fd,1,'float');
  p(k).lDACChannelNameIndex = fread(fd,1,'int32');
  p(k).lDACChannelUnitsIndex = fread(fd,1,'int32');
  p(k).lDACFilePtr = fread(fd,1,'int32');
  p(k).lDACFileNumEpisodes = fread(fd,1,'int32');
  p(k).nWaveformEnable = fread(fd,1,'int16');
  p(k).nWaveformSource = fread(fd,1,'int16');
  p(k).nInterEpisodeLevel = fread(fd,1,'int16');
  p(k).fDACFileScale = fread(fd,1,'float');
  p(k).fDACFileOffset = fread(fd,1,'float');
  p(k).lDACFileEpisodeNum = fread(fd,1,'int32');
  p(k).nDACFileADCNum = fread(fd,1,'int16');
  p(k).nConditEnable = fread(fd,1,'int16');
  p(k).lConditNumPulses = fread(fd,1,'int32');
  p(k).fBaselineDuration = fread(fd,1,'float');
  p(k).fBaselineLevel = fread(fd,1,'float');
  p(k).fStepDuration = fread(fd,1,'float');
  p(k).fStepLevel = fread(fd,1,'float');
  p(k).fPostTrainPeriod = fread(fd,1,'float');
  p(k).fPostTrainLevel = fread(fd,1,'float');
  p(k).nMembTestEnable = fread(fd,1,'int16');
  p(k).nLeakSubtractType = fread(fd,1,'int16');
  p(k).nPNPolarity = fread(fd,1,'int16');
  p(k).fPNHoldingLevel = fread(fd,1,'float');
  p(k).nPNNumADCChannels = fread(fd,1,'int16');
  p(k).nPNPosition = fread(fd,1,'int16');
  p(k).nPNNumPulses = fread(fd,1,'int16');
  p(k).fPNSettlingTime = fread(fd,1,'float');
  p(k).fPNInterpulse = fread(fd,1,'float');
  p(k).nLTPUsageOfDAC = fread(fd,1,'int16');
  p(k).nLTPPresynapticPulses = fread(fd,1,'int16');
  p(k).lDACFilePathIndex = fread(fd,1,'int32');
  p(k).fMembTestPreSettlingTimeMS = fread(fd,1,'float');
  p(k).fMembTestPostSettlingTimeMS = fread(fd,1,'float');
  p(k).nLeakSubtractADCIndex = fread(fd,1,'int16');
  sUnused = fread(fd,124,'char');
end
n = ftell(fd) - s.uBlockIndex*512;
if n~=s.llNumEntries * s.uBytes
  error('readabf: bug in readDACInfo');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = abf_readEpochInfoPerDAC(fd,s);
if s.uBlockIndex==0
  p=[];
  return
end
fseek(fd,s.uBlockIndex*512,'bof');
for k=1:s.llNumEntries
  p(k).nEpochNum = fread(fd,1,'int16');
  p(k).nDACNum = fread(fd,1,'int16');
  p(k).nEpochType = fread(fd,1,'int16');
  p(k).fEpochInitLevel = fread(fd,1,'float');
  p(k).fEpochLevelInc = fread(fd,1,'float');
  p(k).lEpochInitDuration = fread(fd,1,'int32');
  p(k).lEpochDurationInc = fread(fd,1,'int32');
  p(k).lEpochPulsePeriod = fread(fd,1,'int32');
  p(k).lEpochPulseWidth = fread(fd,1,'int32');
  sUnused = fread(fd,18,'char');
end
n = ftell(fd) - s.uBlockIndex*512;
if n~=s.llNumEntries * s.uBytes
  error('readabf: bug in readEpochInfoPerDAC');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = abf_readEpochInfo(fd,s);
if s.uBlockIndex==0
  p=[];
  return
end
fseek(fd,s.uBlockIndex*512,'bof');
for k=1:s.llNumEntries
  p(k).nEpochNum = fread(fd,1,'int16');
  p(k).nDigitalValue = fread(fd,1,'int16');
  p(k).nDigitalTrainValue = fread(fd,1,'int16');
  p(k).nAlternateDigitalValue = fread(fd,1,'int16');
  p(k).nAlternateDigitalTrainValue = fread(fd,1,'int16');
  p(k).bEpochCompression = fread(fd,1,'char');
  sUnused = fread(fd,21,'char');
end
n = ftell(fd) - s.uBlockIndex*512;
if n~=s.llNumEntries * s.uBytes
  error('readabf: bug in readEpochInfo');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = abf_readStatsRegionInfo(fd,s);
if s.uBlockIndex==0
  p=[];
  return
end
fseek(fd,s.uBlockIndex*512,'bof');
for k=1:s.llNumEntries
  p(k).nRegionNum = fread(fd,1,'int16');
  p(k).nADCNum = fread(fd,1,'int16');
  p(k).nStatsActiveChannels = fread(fd,1,'int16');
  p(k).nStatsSearchRegionFlags = fread(fd,1,'int16');
  p(k).nStatsSelectedRegion = fread(fd,1,'int16');
  p(k).nStatsSmoothing = fread(fd,1,'int16');
  p(k).nStatsSmoothingEnable = fread(fd,1,'int16');
  p(k).nStatsBaseline = fread(fd,1,'int16');
  p(k).lStatsBaselineStart = fread(fd,1,'int32');
  p(k).lStatsBaselineEnd = fread(fd,1,'int32');
  p(k).lStatsMeasurements = fread(fd,1,'int32');
  p(k).lStatsStart = fread(fd,1,'int32');
  p(k).lStatsEnd = fread(fd,1,'int32');
  p(k).nRiseBottomPercentile = fread(fd,1,'int16');
  p(k).nRiseTopPercentile = fread(fd,1,'int16');
  p(k).nDecayBottomPercentile = fread(fd,1,'int16');
  p(k).nDecayTopPercentile = fread(fd,1,'int16');
  p(k).nStatsSearchMode = fread(fd,1,'int16');
  p(k).nStatsSearchDAC = fread(fd,1,'int16');
  p(k).nStatsBaselineDAC = fread(fd,1,'int16');
  sUnused = fread(fd,78,'char');
end
n = ftell(fd) - s.uBlockIndex*512;
if n~=s.llNumEntries * s.uBytes
  error('readabf: bug in readStatsRegionInfo');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = abf_readUserListInfo(fd,s);
if s.uBlockIndex==0
  p=[];
  return
end
fseek(fd,s.uBlockIndex*512,'bof');
for k=1:s.llNumEntries
  p(k).nListNum = fread(fd,1,'int16');
  p(k).nULEnable = fread(fd,1,'int16');
  p(k).nULParamToVary = fread(fd,1,'int16');
  p(k).nULRepeat = fread(fd,1,'int16');
  p(k).lULParamValueListIndex = fread(fd,1,'int32');
  sUnused = fread(fd,52,'char');
end
n = ftell(fd) - s.uBlockIndex*512;
if n~=s.llNumEntries * s.uBytes
  error('readabf: bug in readUserListInfo');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = abf_readGenericSection(fd,s)
if s.uBlockIndex==0
  p=[];
  return
end
fseek(fd,s.uBlockIndex*512,'bof');
N=s.uBytes;
for k=1:s.llNumEntries
  p(k).asBytes = fread(fd,[N 1],'uint8');
  p(k).asText = repmat('.',[1 N]);
  for n=1:N
    if p(k).asBytes(n)>=32 & p(k).asBytes(n)<127
      p(k).asText(n) = p(k).asBytes(n);
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function p = abf_readStringsSection(fd,s)
if s.uBlockIndex==0
  p=[];
  return
end
fseek(fd,s.uBlockIndex*512,'bof');
%N=s.uBytes;
%for k=1:s.llNumEntries
aux.dwSignature = fread(fd,1,'uint32');
aux.dwVersion = fread(fd,1,'uint32');
aux.uNumStrings = fread(fd,1,'uint32');
aux.uMaxSize = fread(fd,1,'uint32');
aux.lTotalBytes = fread(fd,1,'int32');
uUnused = fread(fd,6,'uint32');
aux.data = fread(fd,aux.lTotalBytes,'uint8');
M = aux.uNumStrings;
p = cell(M,1);
dp=1;
for m=1:M
  p{m} = '';
  while aux.data(dp)>0
    p{m} = [p{m} char(aux.data(dp))];
    dp=dp+1;
  end
  dp=dp+1;
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = abf_readData(fd,aux, epi,offset,limit)
if aux.sec.DataSection.uBlockIndex==0
  d=[];
  return
end

if aux.hdr.uActualEpisodes
  ;
else
  if ~isempty(epi) & epi~=1
    error('readabf: episodes specified for non-episodic file');
  end
  epi=[];
end

C=length(aux.info.adc);
mustScale = 1;

if isempty(epi)
  fseek(fd,aux.sec.DataSection.uBlockIndex*512,'bof');
  fseek(fd,C*aux.sec.DataSection.uBytes*offset,'cof'); % skip to offset
  L=min(aux.sec.DataSection.llNumEntries,limit*C);
  
  switch aux.sec.DataSection.uBytes
    case 1
      d = fread(fd,[L 1],'int8');
    case 2
      d = fread(fd,[L 1],'int16');
    case 4
      d = fread(fd,[L 1],'float32');
      mustScale = 0;
    otherwise
      error(sprintf('readabf: I do not know how to read data stored with %i bytes/sample',s.uBytes));
  end
  d = reshape(d,[C L/C])';
else
  for e=1:length(epi)
    fseek(fd,aux.sec.DataSection.uBlockIndex*512,'bof');
    fseek(fd,(epi(e)-1)*aux.sec.DataSection.uBytes * ...
        aux.info.protocol.lNumSamplesPerEpisode,'cof');
    fseek(fd,C*aux.sec.DataSection.uBytes*offset,'cof'); % skip to offset
    L=min(aux.info.protocol.lNumSamplesPerEpisode,limit*C);
    switch aux.sec.DataSection.uBytes
      case 1
        p = fread(fd,[L 1],'int8');
      case 2
        p = fread(fd,[L 1],'int16');
      case 4
        p = fread(fd,[L 1],'float32');
        mustScale = 0;
      otherwise
        error(sprintf('readabf: I do not know how to read data stored with %i bytes/sample',s.uBytes));
    end
    d(:,:,e) = reshape(p,[C L/C])';
  end
end

if mustScale
  for k=1:C
    d(:,k,:) = d(:,k,:) / ...
        ( aux.info.adc(k).fSignalGain * ...
        aux.info.adc(k).fInstrumentScaleFactor * ...
        aux.info.adc(k).fADCProgrammableGain ) * ...
        aux.info.protocol.fADCRange/aux.info.protocol.lADCResolution + ...
        aux.info.adc(k).fInstrumentOffset - aux.info.adc(k).fSignalOffset;
  end
end
