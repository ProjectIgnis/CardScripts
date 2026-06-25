--時空穿つ遡光
--Annihilating Retrolight
--scripted by Naim
local s,id=GetID()
local STATUS_SUMMONED_THIS_TURN=STATUS_SUMMON_TURN|STATUS_FLIP_SUMMON_TURN|STATUS_SPSUMMON_TURN
function s.initial_effect(c)
	--When your opponent activates the effect of a monster on the field that was not Summoned this turn: Negate the activation, then you can banish (face-down) all face-up monsters your opponent controls that were not Summoned this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--If this Set card in its owner's control is destroyed by an opponent's card effect: You can Set 1 Trap from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local trig_location,trig_status=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_STATUS)
	return rp==1-tp and re:IsMonsterEffect() and (trig_location&LOCATION_MZONE)>0 and (trig_status&STATUS_SUMMONED_THIS_TURN)==0
		and Duel.IsChainNegatable(ev)
end
function s.notsummonturnfilter(c,tp)
	return c:IsFaceup() and not c:IsStatus(STATUS_SUMMONED_THIS_TURN) and c:IsAbleToRemove(c,tp,POS_FACEDOWN)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	local g=Duel.GetMatchingGroup(s.notsummonturnfilter,tp,0,LOCATION_MZONE,nil,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local g=Duel.GetMatchingGroup(s.notsummonturnfilter,tp,0,LOCATION_MZONE,nil,tp)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
	end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
		and rp==1-tp and c:IsReason(REASON_EFFECT)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsTrap,Card.IsSSetable),tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsTrap,Card.IsSSetable),tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end