--属性反発作用
--Attribute Rejection
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Target 1 face-up monster your opponent controls that was Special Summoned from the Extra Deck; send 1 DARK or Zombie monster from your hand, Deck, or face-up field to the GY, and if you do, the targeted monster loses ATK equal to the sent monster's original ATK, then if the targeted monster is LIGHT, negate its effects. You can only activate 1 "Attribute Rejection" per turn. If this card was activated as Chain Link 3 or higher, your opponent cannot activate cards or effects in response to this card's activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
function s.togyfilter(c)
	return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_ZOMBIE)) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
		and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsSummonLocation(LOCATION_EXTRA) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSummonLocation,LOCATION_EXTRA),tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(s.togyfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSummonLocation,LOCATION_EXTRA),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,g,1,tp,0)
	--If this card was activated as Chain Link 3 or higher, your opponent cannot activate cards or effects in response to this card's activation
	if Duel.GetCurrentChain()>=3 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(function(effect,event_player,triggering_player) return triggering_player==event_player end)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.togyfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE)
		and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		local prev_atk=tc:GetAttack()
		--The targeted monster loses ATK equal to the sent monster's original ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-sc:GetBaseAttack())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		--Then if the targeted monster is LIGHT, negate its effects
		if prev_atk>tc:GetAttack() and tc:IsAttribute(ATTRIBUTE_LIGHT) and tc:IsNegatableMonster() then
			Duel.BreakEffect()
			tc:NegateEffects(c)
		end
	end
end