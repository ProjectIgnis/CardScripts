--Scripted by Eerie Code
--Abyss Actor - Pretty Heroine
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--Reduce ATK (P)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMING_BATTLE_END)
	e2:SetCondition(s.pacon)
	e2:SetTarget(s.patg)
	e2:SetOperation(s.paop)
	c:RegisterEffect(e2)
	--Reduce ATK (M)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(TIMING_BATTLE_END,TIMING_BATTLE_END)
	e3:SetCondition(s.macon)
	e3:SetTarget(s.matg)
	e3:SetOperation(s.maop)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		s[0]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(s.desop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
		ge2:SetOperation(s.clear)
		Duel.RegisterEffect(ge2,0)
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_BATTLE_DAMAGE)
		ge3:SetOperation(s.damop)
		Duel.RegisterEffect(ge3,0)
	end)
end
s.listed_series={0x10ec}
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.GetAttackTarget()
	if not dc then return end
	local bc=dc:GetBattleTarget()
	if ep==tp then
		if bc:IsControler(tp) and bc:IsSetCard(0x10ec) and bc:IsStatus(STATUS_BATTLE_DESTROYED) 
			and not dc:IsStatus(STATUS_BATTLE_DESTROYED) then
			dc:RegisterFlagEffect(id+tp,RESET_EVENT+RESETS_STANDARD,0,1,ev)
		end
		if dc:IsControler(tp) and dc:IsSetCard(0x10ec) and dc:IsStatus(STATUS_BATTLE_DESTROYED) 
			and not bc:IsStatus(STATUS_BATTLE_DESTROYED) then
			bc:RegisterFlagEffect(id+tp,RESET_EVENT+RESETS_STANDARD,0,1,ev)
		end
	end
	if ep==1-tp then
		if bc:IsControler(1-tp) and bc:IsSetCard(0x10ec) and bc:IsStatus(STATUS_BATTLE_DESTROYED) 
			and not dc:IsStatus(STATUS_BATTLE_DESTROYED) then
			dc:RegisterFlagEffect(id+1-tp,RESET_EVENT+RESETS_STANDARD,0,1,ev)
		end
		if dc:IsControler(1-tp) and dc:IsSetCard(0x10ec) and dc:IsStatus(STATUS_BATTLE_DESTROYED) 
			and not bc:IsStatus(STATUS_BATTLE_DESTROYED) then
			bc:RegisterFlagEffect(id+1-tp,RESET_EVENT+RESETS_STANDARD,0,1,ev)
		end
	end
end
function s.clear(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	s[0]=s[0]+ev
end
function s.pacon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()~=tp and ph>=0x08 and ph<=0x20 
		and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()) 
end
function s.pafil(c)
	return c:IsFaceup() and c:GetFlagEffect(id)>0 and c:GetAttack()>0
end
function s.patg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.pafil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.pafil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.pafil,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.paop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-tc:GetFlagEffectLabel(id+tp))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.macon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=0x08 and ph<=0x20 and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()) 
		and s[0]>0
end
function s.mafil(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.matg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.mafil(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.mafil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.mafil,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g:GetFirst(),1,0,0)
end
function s.maop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(tc:GetBaseAttack()-s[0])
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
