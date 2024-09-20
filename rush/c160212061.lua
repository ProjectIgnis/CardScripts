--伝説の種火
--Legendary Sparkseed
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top 2 cards from the Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_POSITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,2,tp,0)
end
function s.filter(c)
	return c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLegend()
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsNotMaximumModeSide()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardDeck(tp,2,REASON_EFFECT)==0 then return end
	local dg=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,nil)
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=dg:Select(tp,1,2,nil)
		Duel.HintSelection(sg)
		sg=sg:AddMaximumCheck()
		Duel.Destroy(sg,REASON_EFFECT)
	end
end