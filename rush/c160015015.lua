--スターズハンド・カメラレディ
--Star's Hand Camera Lady
local s,id=GetID()
function s.initial_effect(c)
	--mill 2 then destroy 1 spell/trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160002025}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN|STATUS_SUMMON_TURN)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(160002025)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	if Duel.DiscardDeck(tp,2,REASON_EFFECT)==0 then return end
	if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,1,nil)
			Duel.HintSelection(dg,true)
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
	end
end