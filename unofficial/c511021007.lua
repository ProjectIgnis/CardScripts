
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=tc:GetBattleTarget()
	if not tc or not bc then return false end
	local tcindes=false
	local bcindes=false
	if tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
		local tcind={tc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
		for i=1,#tcind do
			local te=tcind[i]
			local f=te:GetValue()
			if type(f)=='function' then
				if f(te,bc) then tcindes=true end
			else tcindes=true end
		end
	end
	if bc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
		local tcind={bc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
		for i=1,#tcind do
			local te=tcind[i]
			local f=te:GetValue()
			if type(f)=='function' then
				if f(te,tc) then bcindes=true end
			else bcindes=true end
		end
	end
	local g=Group.CreateGroup()
	if bc~=Duel.GetAttackTarget() or bc:IsAttackPos() then
		if bc:IsPosition(POS_FACEUP_DEFENSE) and bc==Duel.GetAttacker() then
			if bc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then
				if bc:IsHasEffect(75372290) then
					if tc:IsAttackPos() then
						if bc:GetAttack()>0 and bc:GetAttack()>=tc:GetAttack() then
							g:AddCard(tc)
						end
					else
						if bc:GetAttack()>tc:GetDefense() then
							g:AddCard(tc)
						end
					end
				else
					if tc:IsAttackPos() then
						if bc:GetDefense()>0 and bc:GetDefense()>=tc:GetAttack() then
							g:AddCard(tc)
						end
					else
						if bc:GetDefense()>tc:GetDefense() then
							g:AddCard(tc)
						end
					end
				end
			end
		else
			if tc:IsAttackPos() then
				if bc:GetAttack()>0 and bc:GetAttack()>=tc:GetAttack() then
					g:AddCard(tc)
				end
			else
				if bc:GetAttack()>tc:GetDefense() then
					g:AddCard(tc)
				end
			end
		end
	end
	if tc~=Duel.GetAttackTarget() or tc:IsAttackPos() then
		if tc:IsPosition(POS_FACEUP_DEFENSE) and tc==Duel.GetAttacker() then
			if tc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then
				if tc:IsHasEffect(75372290) then
					if bc:IsAttackPos() then
						if tc:GetAttack()>0 and tc:GetAttack()>=bc:GetAttack() then
							g:AddCard(bc)
						end
					else
						if tc:GetAttack()>bc:GetDefense() then
							g:AddCard(bc)
						end
					end
				else
					if bc:IsAttackPos() then
						if tc:GetDefense()>0 and tc:GetDefense()>=bc:GetAttack() then
							g:AddCard(bc)
						end
					else
						if tc:GetDefense()>bc:GetDefense() then
							g:AddCard(bc)
						end
					end
				end
			end
		else
			if bc:IsAttackPos() then
				if tc:GetAttack()>0 and tc:GetAttack()>=bc:GetAttack() then
					g:AddCard(bc)
				end
			else
				if tc:GetAttack()>bc:GetDefense() then
					g:AddCard(bc)
				end
			end
		end
	end
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	else return false end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return #g>0 end
	e:SetLabelObject(nil)
	Duel.SetTargetCard(g)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g<=0 then return end
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
