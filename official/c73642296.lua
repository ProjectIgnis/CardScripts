--屋敷わらし
--Ghost Belle & Haunted Mansion
local s,id=GetID()
function s.initial_effect(c)
	--Negate the activation of a card or effect that includes adding a card(s) to the hand, Deck, and/or Extra Deck, Special Summoning a Monster Card, or banishing a card(s), from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.negtg)
	e1:SetOperation(function(e,tp,eg,ep,ev) Duel.NegateActivation(ev) end)
	c:RegisterEffect(e1)
end
function s.check(ev,category)
	local ex1,g1,gc1,dp1,loc1=Duel.GetOperationInfo(ev,category)
	local ex2,g2,gc2,dp2,loc2=Duel.GetPossibleOperationInfo(ev,category)
	if not (ex1 or ex2) then return false end
	local g=Group.CreateGroup()
	if g1 then g:Merge(g1) end
	if g2 then g:Merge(g2) end
	return (((loc1 or 0)|(loc2 or 0))&LOCATION_GRAVE)>0 or (#g>0 and g:IsExists(function(c) return c:IsLocation(LOCATION_GRAVE) and (category~=CATEGORY_SPECIAL_SUMMON or c:IsMonster()) end,1,nil))
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
	if (s.check(ev,CATEGORY_SPECIAL_SUMMON)
		or s.check(ev,CATEGORY_REMOVE)
		or s.check(ev,CATEGORY_TOHAND)
		or s.check(ev,CATEGORY_TODECK)
		or s.check(ev,CATEGORY_TOEXTRA)) then return true end
	return false
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
end