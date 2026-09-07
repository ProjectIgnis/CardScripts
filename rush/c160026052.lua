--健康賢明早押しバトル！
--Healthy Mind Speedy Buzzer Battle!
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup})
	c:RegisterEffect(e1)
end
function s.ritualfil(c)
	return c:IsLevel(7) and c:IsRace(RACE_PYRO)
end
function s.forcedgroup(c,e,tp)
	return (c:IsCode(160026019) or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_PYRO) and c:IsLevelAbove(7) and c:IsDefense(1300)
end