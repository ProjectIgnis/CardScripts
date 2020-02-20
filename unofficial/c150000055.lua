--Quiz Action - Science for 100
function c150000055.initial_effect(c)
	--Activate/Answer
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c150000055.target)
	e1:SetOperation(c150000055.activate)
	c:RegisterEffect(e1)
end
function c150000055.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=Duel.SelectOption(tp,aux.Stringid(150000055,0),aux.Stringid(150000055,1))
	e:SetLabel(op)
end
function c150000055.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	Duel.Recover(tp,100,REASON_EFFECT)
	elseif e:GetLabel()==1 then
	Duel.Damage(tp,100,REASON_EFFECT)
	end
end