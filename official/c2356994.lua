--偉大天狗
--Great Long Nose
local s,id=GetID()
function s.initial_effect(c)
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--Cannot be Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Opponent skips their next Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(function(_,tp,_,ep) return ep==1-tp end)
	e2:SetOperation(s.skipop)
	c:RegisterEffect(e2)
end
function s.skipop(e,tp,eg,ep,ev,re,r,rp)
	--Skip next Battle Phase
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(0,1)
	if Duel.IsTurnPlayer(1-tp) then
		local turn=Duel.GetTurnCount()
		e1:SetCondition(function() return Duel.GetTurnCount()~=turn end)
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)
end