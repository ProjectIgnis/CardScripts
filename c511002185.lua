--Crown of Command
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--lose atk and def
	local e2=Effect.CreateEffect(c)	
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetHandler():GetEquipTarget()
	local bc=eq:GetBattleTarget()
	if not bc or not bc:IsRelateToBattle() then return end
	Duel.Hint(HINT_CARD,0,id)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-500)
	bc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	bc:RegisterEffect(e2)
end
