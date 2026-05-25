--悪魔鏡の儀式
--Beastly Mirror Ritual
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup})
	c:RegisterEffect(e1)
end
s.listed_names={31890399}
function s.ritualfil(c)
	return c:IsCode(31890399)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE|LOCATION_HAND)
end