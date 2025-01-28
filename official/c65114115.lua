--七星天流抜刀術－「破軍」
--Seven Star Sky Style Battojutsu - "Hagun"
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Equip 1 Level 7 monster with the same Type, but a different name, to 1 face-up monster you control, from your hand or Deck as an Equip Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(function() return not (Duel.IsPhase(PHASE_DAMAGE) and Duel.IsDamageCalculated()) end)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	--Add this card to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqpfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp,c:GetRace(),c:GetCode())
end
function s.eqpfilter(c,tp,rac,code)
	return c:IsLevel(7) and c:IsRace(rac) and not c:IsCode(code) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_SZONE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local ec=Duel.SelectMatchingCard(tp,s.eqpfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp,tc:GetRace(),tc:GetCode()):GetFirst()
	if ec and Duel.Equip(tp,ec,tc) then
		--The equipped monster gains 700 ATK
		local e1=Effect.CreateEffect(ec)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		ec:RegisterEffect(e1)
		--Equip limit
		local e2=Effect.CreateEffect(ec)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetValue(function(e,c) return c==tc end)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		ec:RegisterEffect(e2)
		--Return that Equip Card to the hand during the End Phase
		aux.DelayedOperation(ec,PHASE_END,id,e,tp,function() Duel.SendtoHand(ec,nil,REASON_EFFECT) end,nil,0,1,aux.Stringid(id,2))
	end
end
function s.thconfilter(c,tp)
	return c:IsPreviousControler(1-tp) and (c:GetPreviousLevelOnField()>=8 or c:GetPreviousRankOnField()>=8)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thconfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end