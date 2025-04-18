--バーサーキング
--Berserking
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Halve and increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase())
		or (Duel.IsTurnPlayer(1-tp) and Duel.IsBattlePhase() and aux.StatChangeDamageStepCondition())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsRace,RACE_BEAST),tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsRace,RACE_BEAST),tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
	if #tg~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local tc1=tg:Select(tp,1,1,nil):GetFirst()
	if not tc1 then return end
	Duel.HintSelection(tc1,true)
	local tc2=(tg-tc1):GetFirst()
	if tc1:IsImmuneToEffect(e) then return end
	--Halve ATK
	local atk=tc1:GetAttack()/2
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc1:RegisterEffect(e1)
	--Increase ATK
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	tc2:RegisterEffect(e2)
end