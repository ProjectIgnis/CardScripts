--ＥＭゴムゴムートン (Anime)
--Performapal Gumgumouton (Anime)
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34149830,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.reptg)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_series={0x99}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=tc:GetBattleTarget()
	if not tc or not bc then return false end
	local bd=Group.CreateGroup()
	if tc:IsPosition(POS_FACEUP_DEFENSE) then
		if not tc:IsHasEffect(EFFECT_DEFENSE_ATTACK) then return false end
		if tc:IsHasEffect(75372290) then
			bd:Merge(bc:IsAttackPos() and tc:GetAttack()>0 and (tc:GetAttack()>bc:GetAttack() and Group.FromCards(bc)
				or bc:GetAttack()>tc:GetAttack() and Group.FromCards(tc) or Group.FromCards(bc,tc))
				or tc:GetAttack()>bc:GetDefense() and Group.FromCards(bc) or bd)
		else
			bd:Merge(bc:IsAttackPos() and tc:GetDefense()>0 and tc:GetDefense()>=bc:GetAttack() and Group.FromCards(bc)
			or tc:GetDefense()>bc:GetDefense() and Group.FromCards(bc) or bd)
		end
	else
		bd:Merge(bc:IsAttackPos() and tc:GetAttack()>0 and (tc:GetAttack()>bc:GetAttack() and Group.FromCards(bc)
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
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x99)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	Duel.SetTargetCard(e:GetLabelObject())
end
function s.cfilter(c,e)
	return c:IsOnField() and c:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e) and c:IsRelateToBattle()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.cfilter,nil,e)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE) 
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,nil) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,1,nil)
		e:SetLabelObject(g:GetFirst())
		return true
	else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if Duel.SendtoHand(tc,nil,REASON_EFFECT+REASON_REPLACE)>0 then
		Duel.BreakEffect()
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end