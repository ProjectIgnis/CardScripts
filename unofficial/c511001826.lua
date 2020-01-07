--Memories of Courage
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(s.desop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_BATTLED)
		ge2:SetOperation(s.desop2)
		Duel.RegisterEffect(ge2,0)
	end)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:GetOverlayCount()==0 
		and c:GetFlagEffect(511001825+tp)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) 
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,0x48) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ct=Duel.GetMatchingGroupCount(Card.IsSetCard,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,0x48)
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(ct*500)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:GetFlagEffect(511001823+tp)==0 then
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_EXTRA_ATTACK)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e3:SetValue(1)
			tc:RegisterEffect(e3)
		end
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.GetAttackTarget()
	if not dc then return end
	if ev<=0 then return end
	local bc=dc:GetBattleTarget()
	if not bc:IsSetCard(0x48) or not bc:IsType(TYPE_XYZ) or not dc:IsSetCard(0x48) or not dc:IsType(TYPE_XYZ) 
		or bc:GetOverlayCount()>0 or dc:GetOverlayCount()>0 then return end
	if ep==tp then
		if dc:IsControler(1-tp) and bc:IsStatus(STATUS_BATTLE_DESTROYED) 
			and not dc:IsStatus(STATUS_BATTLE_DESTROYED) then
			dc:RegisterFlagEffect(511001823+1-tp,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		end
		if bc:IsControler(1-tp) and dc:IsStatus(STATUS_BATTLE_DESTROYED) 
			and not bc:IsStatus(STATUS_BATTLE_DESTROYED) then
			bc:RegisterFlagEffect(511001823+1-tp,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		end
	end
	if ep==1-tp then
		if dc:IsControler(tp) and bc:IsStatus(STATUS_BATTLE_DESTROYED) 
			and not dc:IsStatus(STATUS_BATTLE_DESTROYED) then
			dc:RegisterFlagEffect(511001823+tp,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		end
		if bc:IsControler(tp) and dc:IsStatus(STATUS_BATTLE_DESTROYED) 
			and not bc:IsStatus(STATUS_BATTLE_DESTROYED) then
			bc:RegisterFlagEffect(511001823+tp,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		end
	end
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.GetAttackTarget()
	if not dc then return end
	local bc=dc:GetBattleTarget()
	if not bc:IsSetCard(0x48) or not bc:IsType(TYPE_XYZ) or not dc:IsSetCard(0x48) or not dc:IsType(TYPE_XYZ) 
		or bc:GetOverlayCount()>0 or dc:GetOverlayCount()>0 then return end
	if dc:IsControler(1-tp) then dc,bc=bc,dc end
	if dc:IsControler(tp) then
		dc:RegisterFlagEffect(511001825+tp,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
	if bc:IsControler(1-tp) then
		bc:RegisterFlagEffect(511001825+1-tp,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
end
