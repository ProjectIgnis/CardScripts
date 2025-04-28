--Ｐ・Ｍ プレイ
--Plasmatic Model Play
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup,stage2=s.stage2})
	c:RegisterEffect(e1)
end
s.listed_names={160021047,160021048}
function s.ritualfil(c)
	return c:IsCode(160021047,160021048)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_THUNDER) and c:IsFaceup()
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	--Prevent non-Thunders from attacking
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ftarget)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.ftarget(e,c)
	return not c:IsRace(RACE_THUNDER)
end