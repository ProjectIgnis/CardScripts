--サイバー・ダイナソー
local s,id=GetID()
function s.initial_effect(c)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dircon)
	c:RegisterEffect(e1)
	--attack cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_COST)
	e2:SetCost(s.atcost)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
end
function s.dircon(e)
	local tp=e:GetHandlerPlayer()
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) 
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==1 
		and not Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil)
end
function s.atcost(e,c,tp)
	local g,da=e:GetHandler():GetAttackableTarget()
	return e:GetHandler():GetEffectCount(EFFECT_DIRECT_ATTACK)>1 or #g>0 or Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) 
		or Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g,da=c:GetAttackableTarget()
	if Duel.IsAttackCostPaid()~=2 and c:IsLocation(LOCATION_MZONE) then
		if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0 or not da then
			Duel.AttackCostPaid()
			return
		end
		if not Duel.CheckReleaseGroup(tp,nil,1,c) then
			if c:GetEffectCount(EFFECT_DIRECT_ATTACK)==1 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
				c:RegisterEffect(e1)
			end
			Duel.AttackCostPaid()
			return
		end
		if c:GetEffectCount(EFFECT_DIRECT_ATTACK)>1 then
			if Duel.CheckReleaseGroup(tp,nil,1,c) and Duel.SelectYesNo(tp,500) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				local tc=Duel.GetReleaseGroup(tp):Filter(aux.TRUE,c):SelectUnselect(Group.CreateGroup(),tp,Duel.IsAttackCostPaid()==0, Duel.IsAttackCostPaid()==0)
				if tc then
					Duel.Release(tc,REASON_COST)
					Duel.AttackCostPaid()
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
					e1:SetValue(1)
					e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
					c:RegisterEffect(e1)
				else
					Duel.AttackCostPaid(2)
				end
			else
				Duel.AttackCostPaid()
			end
		else
			if #g==0 or Duel.SelectYesNo(tp,500) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
				local tc=Duel.GetReleaseGroup(tp):Filter(aux.TRUE,c):SelectUnselect(Group.CreateGroup(),tp,Duel.IsAttackCostPaid()==0, Duel.IsAttackCostPaid()==0)
				if tc then
					Duel.Release(tc,REASON_COST)
					Duel.AttackCostPaid()
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
					e1:SetValue(1)
					e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
					c:RegisterEffect(e1)
				else
					Duel.AttackCostPaid(2)
				end
			else
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
				e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
				c:RegisterEffect(e1)
				Duel.AttackCostPaid()
			end
		end
	end
end
