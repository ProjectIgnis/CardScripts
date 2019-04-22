--サイバース・プライド
--Cyberse Pride
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a:IsControler(tp) then a=Duel.GetAttackTarget() d=Duel.GetAttacker() end
	if chkc then return chkc==a end
	if chk==0 then return a and d and a:IsRace(RACE_CYBERSE) end
	Duel.SetTargetCard(a)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local oc=tc:GetBattleTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
		if tc:IsRelateToBattle() and oc and oc:IsFaceup() and oc:IsRelateToBattle() then
			local atk=oc:GetAttack()-tc:GetAttack()
			if atk>0 and Duel.CheckLPCost(tp,atk) then
				Duel.PayLPCost(tp,atk)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetValue(atk)
				tc:RegisterEffect(e2)
			end
		end
	end
end
