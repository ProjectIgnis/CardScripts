--カオス－黒魔術の儀式
--Black Magic Ritual
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil})
	c:RegisterEffect(e1)
end
s.listed_names={30208479}
function s.ritualfil(c)
	return c:IsCode(30208479)
end