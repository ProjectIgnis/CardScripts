--バトル・イーター
--Battle Eater
local s,id=GetID()
function s.initial_effect(c)
	--If you would take battle damage less than or equal to this card's ATK, you can send this card to the Graveyard to negate the attack and end the Battle Phase. Then, take damage equal to this card's ATK.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18964575,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(function(e,tp) return Duel.GetBattleDamage(tp)<=e:GetHandler():GetAttack() end)
	e1:SetCost(Cost.SelfToGrave)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,e:GetHandler():GetAttack())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateAttack() then
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
		Duel.BreakEffect()
		Duel.Damage(tp,e:GetHandler():GetAttack(),REASON_EFFECT)
	end
end
