--シールド・オブ・ボンズ
--Shield of Bones
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetHintTiming(0,TIMING_ATTACK)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.fil(c,e)
	return c:IsFaceup() and not c:IsImmuneToEffect(e)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.fil,tp,LOCATION_MZONE,0,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,Duel.GetMatchingGroup(s.fil,tp,LOCATION_MZONE,0,nil,e),0,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.fil,tp,LOCATION_MZONE,0,nil,e)
	if #g>0 then
		local c=e:GetHandler()
		g:ForEach(function(tc)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			tc:RegisterEffect(e3)
			if tc:IsType(TYPE_TRAPMONSTER) then
				local e4=e2:Clone()
				e4:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				tc:RegisterEffect(e4)
			end
		end)
		local cod=e:GetHandler():GetOriginalCode()
		local te1=Effect.CreateEffect(c)
		te1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		te1:SetCode(EVENT_ATTACK_ANNOUNCE)
		te1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			Duel.Hint(HINT_CARD,0,cod)
			Duel.NegateAttack()
		end)
		te1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(te1,tp)
		if Duel.GetAttacker() then
			Duel.BreakEffect()
			Duel.Hint(HINT_CARD,0,cod)
			Duel.NegateAttack()
		end
	end
end