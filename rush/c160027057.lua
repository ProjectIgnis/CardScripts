--千年原人の復活
--Revival of Sennen Genjin
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup})
	c:RegisterEffect(e1)
end
s.listed_names={76232340} --"Sengenjin"
function s.ritualfil(c)
	return c:IsCode(76232340)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE|LOCATION_HAND)
end