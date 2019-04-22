--Subverted Dalcnori
function c210001103.initial_effect(c)
	--cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,210001103)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCondition(c210001103.spcondition)
	e2:SetTarget(c210001103.sptarget)
	e2:SetOperation(c210001103.spoperation)
	c:RegisterEffect(e2)
	--banish
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetCondition(c210001103.rmcondition)
	e3:SetTarget(c210001103.rmtarget)
	e3:SetOperation(c210001103.rmoperation)
	c:RegisterEffect(e3)
	--damage+reveal
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_HAND)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(c210001103.dmcondition)
	e4:SetCost(c210001103.dmcost)
	e4:SetTarget(c210001103.dmtarget)
	e4:SetOperation(c210001103.dmoperation)
	c:RegisterEffect(e4)
	--global effect
	if not c210001103.gchk then
		c210001103.gchk=true
		c210001103.rth=false
		--count when a subverted is returned to hand
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(c210001103.chk1)
		Duel.RegisterEffect(ge1,0)
		--reset
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c210001103.chk2)
		Duel.RegisterEffect(ge2,0)
	end
end
function c210001103.chkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsCode(210001103)
end
function c210001103.chk1(e,tp,eg,ep,ev,re,r,rp)
	if eg and eg:IsExists(c210001103.chkfilter,1,nil) then
		c210001103.rth=true
	end
end
function c210001103.chk2(e,tp,eg,ep,ev,re,r,rp)
	c210001103.rth=false
end
function c210001103.spconditionfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfed) and c:IsPreviousLocation(LOCATION_ONFIELD) and not c:IsCode(210001103)
end
function c210001103.spcondition(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(c210001103.spconditionfilter,1,nil) --and not eg:IsContains(e:GetHandler())
end
function c210001103.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210001103.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetReset(RESET_EVENT+0x1fe0000)
		e3:SetCondition(c210001103.retcon)
		e3:SetOperation(c210001103.retop)
		c:RegisterEffect(e3)
	end
end
function c210001103.retcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function c210001103.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
function c210001103.rmcondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_GRAVE)
end
function c210001103.rmfilter(c)
	return c:IsAbleToRemove()
end
function c210001103.rmtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c210001103.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210001103.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SelectTarget(tp,c210001103.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function c210001103.rmoperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetLabelObject(tc)
		if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==1-tp then
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN,2)
			e1:SetLabel(Duel.GetTurnCount()+1)
		else
			e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_OPPO_TURN)
			e1:SetLabel(Duel.GetTurnCount())
		end
		e1:SetCountLimit(1)
		e1:SetCondition(c210001103.remretcon)
		e1:SetOperation(c210001103.remretop)
		Duel.RegisterEffect(e1,tp)
	end
end
function c210001103.remretcon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer() and Duel.GetTurnCount()>=e:GetLabel()
end
function c210001103.remretop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function c210001103.dmcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and c210001103.rth
end
function c210001103.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function c210001103.dmtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function c210001103.dmoperation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end