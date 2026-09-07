--マイクロノヴァ・フュージョン
--Micronova Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	Fusion.RegisterSummonEff(c,s.fusfilter,s.matfilter)
end
function s.fusfilter(c)
	return c:ListsCodeAsMaterial(160024006)
end
function s.matfilter(c)
	return c:IsLocation(LOCATION_HAND|LOCATION_MZONE) and c:GetOriginalRace()==RACE_GALAXY and c:IsAbleToGrave()
end