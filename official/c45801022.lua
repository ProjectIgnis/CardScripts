--エレキツネザル
--Wattlemur
local s,id=GetID()
function s.initial_effect(c)
	--bp limit
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and e:GetHandler():IsPreviousControler(tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(0,1)
	e1:SetCondition(s.con)
	e1:SetLabel(Duel.GetTurnCount())
	if Duel.IsTurnPlayer(tp) then
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,1)
	else
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,2)
	end
	Duel.RegisterEffect(e1,tp)
end
function s.con(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end