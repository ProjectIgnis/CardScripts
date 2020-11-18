--まよい猫
--Lost Cat
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	Duel.SetChainLimit(s.chlimit)
end
function s.chlimit(e,ep,tp)
	return not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	local tc=Duel.GetOperatedGroup():GetFirst()
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)>0 then
		if e:GetLabel()==0 and tc:IsType(TYPE_MONSTER) then 
			--Effect
			Duel.NegateAttack()
			Duel.Damage(1-tp,300,REASON_EFFECT)
		elseif e:GetLabel()==1 and tc:IsType(TYPE_SPELL) then
			--Effect
			Duel.NegateAttack()
			Duel.Damage(1-tp,300,REASON_EFFECT)
		elseif e:GetLabel()==2 and tc:IsType(TYPE_TRAP) then
			--Effect
			Duel.NegateAttack()
			Duel.Damage(1-tp,300,REASON_EFFECT)
		end
	end
end