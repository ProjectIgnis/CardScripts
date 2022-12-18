--Consumed By Darkness
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,s.flipcon,s.flipop,1)
end
function s.flipcon(e)
	local tp=e:GetHandlerPlayer()
	return aux.CanActivateSkill(tp)
end
function s.flipop(e,tp,ep,eg,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
	if Duel.IsDuelType(DUEL_1_FIELD) then
		if fc then Duel.Destroy(fc,REASON_RULE) end
		fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc and Duel.Destroy(fc,REASON_RULE)==0 then Duel.SendtoGrave(c,REASON_RULE) end
	else
		fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc and Duel.SendtoGrave(fc,REASON_RULE)==0 then Duel.SendtoGrave(c,REASON_RULE) end
	end
	Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true,0)
	Duel.Hint(HINT_SKILL_REMOVE,tp,c:GetOriginalCode())
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Change Attribute to DARK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetTarget(s.tg)
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	--Negate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.discon)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--Prevent damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.damcon)
	e4:SetCost(s.damcost)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
	--id chk
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(id)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,1)
	e5:SetValue(s.val)
	c:RegisterEffect(e5)
end
s.listed_series={SET_CRYSTAL_BEAST,SET_ULTIMATE_CRYSTAL}
function s.tg(e,c)
	if not c:IsSetCard(SET_CRYSTAL_BEAST) then return false end
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		local eff
		if c:IsLocation(LOCATION_MZONE) then
			eff={Duel.GetPlayerEffect(c:GetControler(),EFFECT_NECRO_VALLEY)}
		else
			eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		end
		c:ResetFlagEffect(1)
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return true
end
function s.val(e,c,re,chk)
	if chk==0 then return c:IsSetCard(SET_CRYSTAL_BEAST) end
	return ATTRIBUTE_DARK
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return at and a:IsSetCard(SET_ULTIMATE_CRYSTAL)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetAttackTarget()
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e2)
	Duel.AdjustInstantly(tc)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return Duel.GetBattleDamage(tp)>0
		and ((a:IsControler(tp) and a:IsSetCard(SET_CRYSTAL_BEAST)) or (at and at:IsControler(tp) and at:IsSetCard(SET_CRYSTAL_BEAST)))
end
function s.dfilter(c)
	return c:IsSetCard(SET_CRYSTAL_BEAST) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end