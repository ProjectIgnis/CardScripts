--リボ・ダメージ   
--Reverse Damage
--Original script by Shad3
--Rescripted by Larry126
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
	--Destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.GetBattleDamage(tp)>0 or Duel.GetBattleDamage(1-tp)>0) then return false end
	local tc=Duel.GetAttacker()
	local bc=tc:GetBattleTarget()
	if not tc or not bc then return false end
	local bd=Group.CreateGroup()
	if tc:IsPosition(POS_FACEUP_DEFENSE) then
		if not tc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then return false end
		if tc:IsHasEffect(75372290) then
			bd:Merge(bc:IsAttackPos() and (tc:GetAttack()>0 or bc:GetAttack()>0)
				and (tc:GetAttack()>bc:GetAttack() and Group.FromCards(bc)
				or bc:GetAttack()>tc:GetAttack() and Group.FromCards(tc) or Group.FromCards(bc,tc))
				or tc:GetAttack()>bc:GetDefense() and Group.FromCards(bc) or bd)
		else
			bd:Merge(bc:IsAttackPos() and (tc:GetDefense()>0 or bc:GetDefense()>0)
				and tc:GetDefense()>=bc:GetAttack() and Group.FromCards(bc)
				or tc:GetDefense()>bc:GetDefense() and Group.FromCards(bc) or bd)
		end
	else
		bd:Merge(bc:IsAttackPos() and (tc:GetAttack()>0 or bc:GetAttack()>0)
			and (tc:GetAttack()>bc:GetAttack() and Group.FromCards(bc)
			or bc:GetAttack()>tc:GetAttack() and Group.FromCards(tc) or Group.FromCards(bc,tc))
			or tc:GetAttack()>bc:GetDefense() and Group.FromCards(bc) or bd)
	end
	local dg=Group.CreateGroup()
	for dc in aux.Next(bd) do
		if dc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
			local bdind={dc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
			for i=1,#bdind do
				local te=bdind[i]
				local f=te:GetValue()
				if type(f)=='function' then
					if not f(te,dc) then dg:AddCard(dc) end
				end
			end
		else dg:AddCard(dc) end
	end
	dg:KeepAlive()
	e:SetLabelObject(dg)
	return #dg>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(e:GetLabelObject())
end
function s.filter(c,tp)
	return c:IsOnField() and c:IsMonster() and c:IsRelateToBattle()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetTargetCards(e):Filter(s.filter,nil,tp):GetFirst()
	if not tc then return end
	local c=e:GetHandler()
	c:SetCardTarget(tc)
	--Ngeate battle destruction
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetLabel(tc:GetFieldID())
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repval)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
	--Halve battle damage from this battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	e2:SetValue(HALF_DAMAGE)
	Duel.RegisterEffect(e2,tp)
	local p=Duel.GetBattleDamage(tp)>0 and tp or 1-tp
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,Duel.GetBattleDamage(p)/2)
end
function s.repfilter(c,fid)
	return c:IsLocation(LOCATION_ONFIELD) and c:IsMonster()
		and c:IsReason(REASON_BATTLE) and c:IsRelateToBattle() and c:GetFieldID()==fid
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(s.repfilter,1,nil,e:GetLabel())
	end
	return true
end
function s.repval(e,c)
	return s.repfilter(c,e:GetLabel())
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local dam=e:GetHandler():GetFlagEffectLabel(id)
	if dam then
		Duel.Damage(tp,dam,REASON_EFFECT)
	end
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end