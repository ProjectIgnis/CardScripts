--Brutal Red
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=tc:GetBattleTarget()
	if tc:IsControler(1-tp) then
		tc=Duel.GetAttackTarget()
		bc=Duel.GetAttacker()
	end
	if not tc or not bc or tc:IsControler(1-tp) or not tc:IsRed() then return false end
	if tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
		local tcind={tc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
		for i=1,#tcind do
			local te=tcind[i]
			local f=te:GetValue()
			if type(f)=='function' then
				if f(te,bc) then return false end
			else return false end
		end
	end
	e:SetLabelObject(tc)
	if bc==Duel.GetAttackTarget() and bc:IsDefensePos() then return false end
	if bc:IsPosition(POS_FACEUP_DEFENSE) and bc==Duel.GetAttacker() then
		if not bc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then return false end
		if bc:IsHasEffect(75372290) then
			if tc:IsAttackPos() then
				return bc:GetAttack()>0 and bc:GetAttack()>=tc:GetAttack()
			else
				return bc:GetAttack()>tc:GetDefense()
			end
		else
			if tc:IsAttackPos() then
				return bc:GetDefense()>0 and bc:GetDefense()>=tc:GetAttack()
			else
				return bc:GetDefense()>tc:GetDefense()
			end
		end
	else
		if tc:IsAttackPos() then
			return bc:GetAttack()>0 and bc:GetAttack()>=tc:GetAttack()
		else
			return bc:GetAttack()>tc:GetDefense()
		end
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.cfilter(c,e,tp)
	return c:IsOnField() and c:IsType(TYPE_MONSTER) and c:IsControler(tp) and (not e or c:IsRelateToEffect(e)) 
		and c:IsRed()
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if tg==nil then return false end
	local g=tg:Filter(s.cfilter,nil,nil,tp)
	g:KeepAlive()
	e:SetLabelObject(g)
	return ex and tc+#g-#tg==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return g end
	Duel.SetTargetCard(g)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_UPDATE_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetValue(1000)
		tc:RegisterEffect(e3)
	end
end
