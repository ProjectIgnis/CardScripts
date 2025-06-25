--いとをかしはかまき
--Grace Hakama Fitting Ceremony
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup})
	c:RegisterEffect(e1)
end
s.listed_names={160215014,160215015}
function s.ritualfil(c)
	return c:IsCode(160215014,160215015)
end
function s.forcedgroup(c,e,tp)
	return c:IsRace(RACE_AQUA) and c:IsAttribute(ATTRIBUTE_LIGHT) and (c:IsLocation(LOCATION_MZONE) or c:IsType(TYPE_NORMAL))
end