--Ｐ・Ｍ アナザードッキング
--Plasmatic Model Another Docking
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name change
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(160021057)
	c:RegisterEffect(e0)
	--Ritual Summon
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup,stage2=s.stage2})
	c:RegisterEffect(e1)
end
s.listed_names={160022034}
function s.ritualfil(c)
	return c:IsCode(160022034)
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