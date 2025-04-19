-- 特報マシン・タフロイド
--Printing Presser
local s,id=GetID()
function s.initial_effect(c)
	--excavate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,5) end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	if not Duel.IsPlayerCanDiscardDeck(1-tp,5) or Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--effect
	local c=e:GetHandler()
	Duel.ConfirmDecktop(1-tp,5)
	local g=Duel.GetDecktopGroup(1-tp,5)
	local sg=g:Filter(Card.IsMonster,nil)
	if #sg>0 then
		local atkval=#sg*100
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atkval)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
	Duel.MoveToDeckBottom(5,1-tp)
	Duel.SortDeckbottom(1-tp,1-tp,5)
end