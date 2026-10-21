--千年原人の儀式
--Ritual of Sennen Genjin
--scripted by Cybercatman
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Revival of Sennin Genjin" in the Graveyard
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(160027057)
	c:RegisterEffect(e0)
	--Ritual Summon "Sengenjin" or "The Unstoppable Sennen Genjin" by sending face-up EARTH monsters from your field whose total Levels equal 8 or more to the Graveyard
	local e1=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=s.ritualfil,matfilter=s.forcedgroup,stage2=s.stage2})
	c:RegisterEffect(e1)
end
s.listed_names={76232340,160027047,160027057} --"Sengenjin", "The Unstoppable Sengenjin", "Revival of Sennen Genjin"
function s.ritualfil(c)
	return c:IsCode(76232340,160027047)
end
function s.forcedgroup(c,e,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsFaceup()
end
function s.stage2(mg,e,tp,eg,ep,ev,re,r,rp,tc)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.ftarget)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.ftarget(e,c)
	return not c:IsAttribute(ATTRIBUTE_EARTH)
end