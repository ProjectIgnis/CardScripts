-- 特報マシン・タフロイド 
-- News Flash Machine Toughroid
local s,id=GetID()
function s.initial_effect(c)
	--excavate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,5) end
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsPlayerCanDiscardDeck(1-tp,5) then return end
	Duel.ConfirmDecktop(1-tp,5)
	local g=Duel.GetDecktopGroup(1-tp,5)
	local sg=g:Filter(s.filter,nil)
	if #sg>0 then
		local atkval=#sg*100
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	Duel.MoveToDeckBottom(5,1-tp)
	Duel.SortDeckbottom(1-tp,1-tp,5)
end