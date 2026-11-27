--戦士の献身
--Warrior's Devotion
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 Warrior monster from your hand or Deck to the GY, then target 1 face-up monster your opponent controls; it loses ATK equal to the sent monster's ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(aux.StatChangeDamageStepCondition)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_DAMAGE_STEP|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--If a Warrior monster(s) you control would be destroyed by battle or card effect, you can banish this card from your GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetValue(function(e,c)
		return s.repfilter(c,e:GetHandlerPlayer())
	end)
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
	end)
	c:RegisterEffect(e2)
end
function s.atkcostfilter(c)
	return c:IsRace(RACE_WARRIOR) and not c:IsAttack(0) and c:IsAbleToGraveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkcostfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.atkcostfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil):GetFirst()
	Duel.SendtoGrave(sc,REASON_COST)
	e:GetChainData().cost_card_atk=sc:GetAttack()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then
		local cost_chk=e:GetLabel()==-100
		e:SetLabel(0)
		return cost_chk and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	local cost_card_atk=e:GetChainData().cost_card_atk
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,-cost_card_atk)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local cost_card_atk=e:GetChainData().cost_card_atk
		--It loses ATK equal to the sent monster's ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-cost_card_atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.repfilter(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end