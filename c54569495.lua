--海晶乙女クラウンテイル
--Marincess Crown Tail
--scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--reduce damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(s.damcon)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
s.listed_series={0x12b}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return a and d
end
function s.cfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetCondition(s.dcon)
		e1:SetOperation(s.dop)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.dcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	Duel.HalfBattleDamage(ep)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()~=tp
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	--avoid damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_AVAILABLE_BD+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.damfilter(c)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x12b)
end
function s.damval(e,re,val,r,rp,rc)
	local ct=Duel.GetMatchingGroup(s.damfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil):GetSum(Card.GetLink)*1000
	if val<=ct then return 0 else return val end
end
