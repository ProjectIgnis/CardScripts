--Radiance of the FOrbidden Spell
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--disable your field
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.dscon1)
	e2:SetOperation(s.dsop1)
	c:RegisterEffect(e2)
	-- disable opponent field
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.dscon2)
	e3:SetOperation(s.dsop2)
	c:RegisterEffect(e3)
	--atk & def
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	--damage
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(46128076,0))
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(s.damtg)
	e5:SetOperation(s.damop)
	c:RegisterEffect(e5)
end
--disable your zone
function s.dscon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.dsop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	--disable field
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.disop1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e:GetHandler():RegisterEffect(e1)
	local ct=e:GetHandler():GetFlagEffectLabel(95100886)
	if ct==nil then
		e:GetHandler():RegisterFlagEffect(95100886,RESET_EVENT+RESETS_STANDARD,0,0,1)
	else
		ct=ct+1
		e:GetHandler():SetFlagEffectLabel(95100886,ct)
	end
end
function s.disop1(e,tp)
	local dis1=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	return dis1
end
--disable opponent zone
function s.dscon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.dsop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	--disable field
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.disop2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e:GetHandler():RegisterEffect(e1)
	local ct=e:GetHandler():GetFlagEffectLabel(95100886)
	if ct==nil then
		e:GetHandler():RegisterFlagEffect(95100886,RESET_EVENT+RESETS_STANDARD,0,0,1)
	else
		ct=ct+1
		e:GetHandler():SetFlagEffectLabel(95100886,ct)
	end
end
function s.disop2(e,tp)
	local dis1=Duel.SelectDisableField(1-tp,1,LOCATION_MZONE,0,0)
	local seq=0
	if dis1==1 then seq=0 end
	if dis1==2 then seq=1 end
	if dis1==4 then seq=2 end
	if dis1==8 then seq=3 end
	if dis1==16 then seq=4 end
	return (0x1<<16+seq)
end
--atk up
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if bc:IsControler(1-tp) then bc=tc end
	e:SetLabelObject(bc)
	return bc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local c=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c==0 then return end
	local tc=e:GetLabelObject()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.disop3)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	e:GetHandler():RegisterEffect(e1)
	if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(c*800)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_DAMAGE_STEP_END)
		e3:SetOperation(s.desop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		e3:SetCountLimit(1)
		tc:RegisterEffect(e3,true)
	end
end
function s.disop3(e,tp)
	local c=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if c==0 then return end
	local dis1=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
	local ct=e:GetHandler():GetFlagEffectLabel(95100886)
	if ct==nil then
		e:GetHandler():RegisterFlagEffect(95100886,RESET_EVENT+RESETS_STANDARD,0,0,1)
	else
		ct=ct+1
		e:GetHandler():SetFlagEffectLabel(95100886,ct)
	end
	if c>1 then
		local dis2=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,dis1)	
		local ct=e:GetHandler():GetFlagEffectLabel(95100886)
		if ct==nil then
			e:GetHandler():RegisterFlagEffect(95100886,RESET_EVENT+RESETS_STANDARD,0,0,1)
		else
			ct=ct+1
			e:GetHandler():SetFlagEffectLabel(95100886,ct)
		end
		dis1=(dis1|dis2)
		if c>2 then
			local dis3=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,dis1)
			local ct=e:GetHandler():GetFlagEffectLabel(95100886)
			if ct==nil then
				e:GetHandler():RegisterFlagEffect(95100886,RESET_EVENT+RESETS_STANDARD,0,0,1)
			else
				ct=ct+1
				e:GetHandler():SetFlagEffectLabel(95100886,ct)
			end
			dis1=(dis1|dis3)
			if c>3 then
				local dis4=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,dis1)
				local ct=e:GetHandler():GetFlagEffectLabel(95100886)
				if ct==nil then
					e:GetHandler():RegisterFlagEffect(95100886,RESET_EVENT+RESETS_STANDARD,0,0,1)
				else
					ct=ct+1
					e:GetHandler():SetFlagEffectLabel(95100886,ct)
				end
				dis1=(dis1|dis4)
				if c>4 then
					local dis5=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,dis1)
					local ct=e:GetHandler():GetFlagEffectLabel(95100886)
					if ct==nil then
						e:GetHandler():RegisterFlagEffect(95100886,RESET_EVENT+RESETS_STANDARD,0,0,1)
					else
						ct=ct+1
						e:GetHandler():SetFlagEffectLabel(95100886,ct)
					end
					dis1=(dis1|dis5)
				end
			end
		end
	end
	return dis1
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT) then
		local g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEUP_ATTACK)
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
--damage
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetHandler():GetFlagEffectLabel(95100886)
	-- Duel.SetTargetPlayer(1-tp)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,ct*500)
	-- Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=e:GetHandler():GetFlagEffectLabel(95100886)
	-- Duel.Damage(p,ct*300,REASON_EFFECT)
	Duel.Damage(tp,ct*500,REASON_EFFECT)
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end


