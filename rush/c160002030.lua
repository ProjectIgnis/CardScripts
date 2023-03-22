--邪影ダーク・ルーカー
--Wicked Shadow Dark Lurker
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 Spell/Trap and deal 1000 damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_SZONE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,1000)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)>0 then
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.HintSelection(g,true)
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			local c=e:GetHandler()
			if Duel.Damage(1-tp,1000,REASON_EFFECT)==1000 and c:IsFaceup() and c:IsRelateToEffect(e) then
				Duel.BreakEffect()
				Duel.SendtoHand(c,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,c)
			end
		end
	end
end