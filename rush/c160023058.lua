--ライオンの強襲
--War-Lion Assault
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup,stage2=s.stage2})
	c:RegisterEffect(e1)
end
s.listed_names={33951077}
function s.ritualfil(c)
	return c:IsCode(33951077)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_BEAST) and c:IsFaceup()
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
	--Gains ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(2000)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
end