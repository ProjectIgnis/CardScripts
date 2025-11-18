--地雷蜘蛛
--Jirai Gumo (GOAT)
--Tossing a coin is a cost to attack, not an effect
local s,id=GetID()
function s.initial_effect(c)
	--Toss a coin and halve the player's LP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_COST)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsAttackCostPaid()~=2 and e:GetHandler():IsLocation(LOCATION_MZONE) then
		Duel.AttackCostPaid()
		if not Duel.CallCoin(tp) then
			Duel.SetLP(tp,Duel.GetLP(tp)//2)
		end
	end
end
