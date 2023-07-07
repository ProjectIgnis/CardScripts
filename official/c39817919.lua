--霊魂鳥－忍鴉
--Shinobird Crow
local s,id=GetID()
function s.initial_effect(c)
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--Cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Increase this card's ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atkcost)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_card_types={TYPE_SPIRIT}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentPhase()~=PHASE_DAMAGE or Duel.IsDamageCalculated() then return false end
	local a,b=Duel.GetBattleMonster(tp)
	return a==e:GetHandler() and b and b:IsControler(1-tp)
end
function s.cfilter(c)
	return c:IsType(TYPE_SPIRIT) and (c:IsAttackAbove(1) or c:IsDefenseAbove(1)) and c:IsDiscardable()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	Duel.SendtoGrave(g,REASON_COST|REASON_DISCARD)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToBattle() or not c:IsRelateToEffect(e) then return end
	local tc=e:GetLabelObject()
	if not tc then return end
	local atk=math.max(tc:GetAttack(),0)
	local def=math.max(tc:GetDefense(),0)
	c:UpdateAttack(atk,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
	c:UpdateDefense(def,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
end