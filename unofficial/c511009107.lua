--Performage Bubble Gardna
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,0,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(s.indescon)
	e1:SetTarget(s.indestg)
	e1:SetOperation(s.indesop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.indescon2)
	c:RegisterEffect(e2)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetDescription(aux.Stringid(511001711,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_DAMAGE_CAL)
	e3:SetRange(LOCATION_PZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_series={0xc6}
function s.scfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc6)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	if (phase~=PHASE_DAMAGE and phase~=PHASE_DAMAGE_CAL) or Duel.IsDamageCalculated() then return false end
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return ((a:IsControler(tp) and a:IsRelateToBattle()) or (d and d:IsControler(tp) and d:IsRelateToBattle())) 
		and Duel.IsExistingMatchingCard(s.scfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp,chk)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.rdop)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,Duel.GetBattleDamage(tp)/2)
	Duel.ChangeBattleDamage(1-tp,Duel.GetBattleDamage(1-tp)/2)
end
function s.indescon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=tc:GetBattleTarget()
	if tc:IsControler(1-tp) then
		tc=Duel.GetAttackTarget()
		bc=Duel.GetAttacker()
	end
	if not tc or not bc or tc:IsControler(1-tp) or not tc:IsSetCard(0xc6) then return false end
	if tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) then
		local tcind={tc:GetCardEffect(EFFECT_INDESTRUCTABLE_BATTLE)}
		for _,te in ipairs(tcind) do
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
function s.cfilter(c,e,tp)
	return c:IsOnField() and c:IsType(TYPE_MONSTER) and c:IsControler(tp) and (not e or c:IsRelateToEffect(e)) 
		and c:IsSetCard(0xc6)
end
function s.indescon2(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if tg==nil then return false end
	local g=tg:Filter(s.cfilter,nil,nil,tp)
	g:KeepAlive()
	e:SetLabelObject(g)
	return ex and tc+#g-#tg>0
end
function s.indestg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return g end
	Duel.SetTargetCard(g)
end
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.cfilter,nil,e,tp)
	g:ForEach(function(tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		if e:GetCode()==EVENT_PRE_DAMAGE_CALCULATE then
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		else
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetValue(function(e,te) return re==te end)
			e1:SetReset(RESET_CHAIN)
		end
		tc:RegisterEffect(e1)
	end)
end
