--列王詩篇
--The Psalms of Kings
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Negate an opponent's activated monster effect on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--If you have no monsters in your GY, you can activate this card from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(function(e) return not Duel.IsExistingMatchingCard(Card.IsMonster,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil) end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DOMINUS}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local trig_p,trig_typ,trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_TYPE,CHAININFO_TRIGGERING_LOCATION)
	return trig_p==1-tp and trig_typ&TYPE_MONSTER>0 and trig_loc&LOCATION_MZONE>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local act_from_hand_chk=(e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND)) and 1 or 0
	e:SetLabel(act_from_hand_chk)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsSetCard(SET_DOMINUS) and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(Card.IsTrap,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetLabel()==1 then
		--You cannot activate monster effects in the hand, GY, or banishment until the end of the next turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(function(e,re) return re:IsMonsterEffect() and re:GetHandler():IsLocation(LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED) end)
		e1:SetReset(RESET_PHASE|PHASE_END,2)
		Duel.RegisterEffect(e1,tp)
	end
end