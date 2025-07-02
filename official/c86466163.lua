--星因士 カペラ
--Satellarknight Capella
local s,id=GetID()
function s.initial_effect(c)
	--Apply a "You can treat Level 4 or lower "tellarknight" monsters you control as Level 5 when Xyz Summoning using 3 or more monsters as Xyz Materials" effect
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetOperation(s.effop)
	c:RegisterEffect(e1a)
	local e1ab=e1a:Clone()
	e1ab:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1ab)
	local e1ac=e1a:Clone()
	e1ac:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1ac)
end
s.listed_series={SET_TELLARKNIGHT}
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	--For the rest of this turn, you can treat Level 4 or lower "tellarknight" monsters you control as Level 5 when Xyz Summoning using 3 or more monsters as Xyz Materials
	local e1a=Effect.CreateEffect(e:GetHandler())
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1a:SetCode(EFFECT_XYZ_LEVEL)
	e1a:SetTargetRange(LOCATION_MZONE,0)
	e1a:SetTarget(function(e,c) return c:IsLevelBelow(4) and c:IsSetCard(SET_TELLARKNIGHT) end)
	e1a:SetValue(function(e,c,rc) return 0x50000+c:GetLevel() end)
	e1a:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1a,tp)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_SATELLARKNIGHT_CAPELLA)
	e1b:SetLabelObject(e1a)
	e1b:SetValue(0x30003) --0x1 >, 0x2 =, 0x4 <, value == last digit(s)
	Duel.RegisterEffect(e1b,tp)
end