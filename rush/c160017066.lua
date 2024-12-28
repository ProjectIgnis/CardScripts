--夢中の誘い
--Invitation to a Delirious Dream
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.confilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.confilter,1,nil,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.ctrlfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and not c:IsType(TYPE_MAXIMUM) and c:IsControlerCanBeChanged(true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
function s.tdfilter(c,tp)
	return c:IsLocation(LOCATION_DECK) and c:IsOwner(tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local td=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_MZONE,0,1,1,nil)
	td=td:AddMaximumCheck()
	local td2=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_HAND,0,1,1,nil)
	td:Merge(td2)
	if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)<1 then return end
	local td=Duel.GetOperatedGroup():Filter(s.tdfilter,nil,tp)
	if #td>1 then
		Duel.SortDeckbottom(tp,tp,#td)
	end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=Duel.SelectMatchingCard(tp,s.ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc)
	if Duel.GetControl(tc,tp) then
		--Cannot attack
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3206)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		--Cannot activate its effects
		local e2=e1:Clone()
		e2:SetDescription(3302)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		tc:RegisterEffect(e2)
	end
end
