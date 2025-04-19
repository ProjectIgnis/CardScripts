--星因士 カペラ
--Satellarknight Capella
local s,id=GetID()
function s.initial_effect(c)
	--Treat "tellarknight" monsters as Level 5 for Xyz Summons
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_TELLAR)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={SET_TELLARKNIGHT}
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_XYZ_LEVEL)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.xyztg)
	e1:SetValue(s.xyzlv)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SATELLARKNIGHT_CAPELLA)
	e2:SetLabelObject(e1)
	e2:SetValue(0x30003) --0x1 >, 0x2 =, 0x4 <, value == last digit(s)
	Duel.RegisterEffect(e2,tp)
end
function s.xyztg(e,c)
	return c:IsLevelBelow(4) and c:IsSetCard(SET_TELLARKNIGHT)
end
function s.xyzlv(e,c,rc)
	return 0x50000+c:GetLevel()
end
