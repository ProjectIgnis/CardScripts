--野獣の激怒
--Rage of the Beasts
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,2,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #dg>0 end
end
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsType(TYPE_FIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local dg=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,nil)
	if #dg==0 then return end
	local sg=dg:Select(tp,1,1,nil)
	Duel.HintSelection(sg)
	if Duel.Destroy(sg,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local tg=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
		Duel.ShuffleDeck(tp)
	end
end