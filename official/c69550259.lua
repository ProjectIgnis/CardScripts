--SRブロックンロール
--Speedroid Block-n-Roll
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcon)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
end
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local sync=e:GetHandler():GetReasonCard()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x2016,TYPES_TOKEN,0,0,sync:GetLevel(),RACE_MACHINE,ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sync=c:GetReasonCard()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0x2016,TYPES_TOKEN,0,0,sync:GetLevel(),RACE_MACHINE,ATTRIBUTE_WIND) then
		local tk=Duel.CreateToken(tp,id+1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(sync:GetLevel())
		tk:RegisterEffect(e1)
		Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP)
	end
end