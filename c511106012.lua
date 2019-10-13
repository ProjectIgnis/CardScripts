--分断の壁
--Wall of Disruption (Anime)
--scripted by Hatter

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	return tc:IsControler(1-tp) or (bc and bc:IsControler(1-tp))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.FromCards(Duel.GetAttackTarget(),Duel.GetAttacker())
	if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0 then return end
	local atk=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)*800
	local tc=g:GetFirst()
	while tc do
		if tc:IsControler(1-tp) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end
