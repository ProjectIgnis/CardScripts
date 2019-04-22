--Subverted Noellag
function c210001105.initial_effect(c)
	--cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e1)
	--if it is returned to you hand
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,210001105)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetCondition(c210001105.thcondition)
	e2:SetTarget(c210001105.thtarget)
	e2:SetOperation(c210001105.thoperation)
	c:RegisterEffect(e2)
	--damage effect
	local e2=Effect.CreateEffect(c)
	e2:SetCountLimit(1,210001106)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c210001105.dmcondition)
	e2:SetCost(c210001105.dmcost)
	e2:SetTarget(c210001105.dmtarget)
	e2:SetOperation(c210001105.dmoperation)
	c:RegisterEffect(e2)
	--when normla summoned
	local e3=Effect.CreateEffect(c)
	e3:SetCountLimit(1,210001107)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetTarget(c210001105.rthtarget)
	e3:SetOperation(c210001105.rthoperation)
	c:RegisterEffect(e3)
	--global effect
	if not c210001105.gchk then
		c210001105.gchk=true
		c210001105.rth=false
		--count when a subverted is returned to hand
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(c210001105.chk1)
		Duel.RegisterEffect(ge1,0)
		--reset
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c210001105.chk2)
		Duel.RegisterEffect(ge2,0)
	end
end
function c210001105.chkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsCode(210001105)
end
function c210001105.chk1(e,tp,eg,ep,ev,re,r,rp)
	if eg and eg:IsExists(c210001105.chkfilter,1,nil) then
		c210001105.rth=true
	end
end
function c210001105.chk2(e,tp,eg,ep,ev,re,r,rp)
	c210001105.rth=false
end
function c210001105.thcondition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD)
end
function c210001105.thfilter(c)
	return c:IsSetCard(0xfed) and c:IsAbleToHand()
end
function c210001105.thtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210001105.thfilter,tp,LOCATION_DECK,0,1,nil) end
	local thg=Duel.GetMatchingGroup(c210001105.thfilter,tp,LOCATION_DECK,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,thg,1,0,0)
end
function c210001105.thoperation(e,tp,eg,ep,ev,re,r,rp)
	local thg=Duel.SelectMatchingCard(tp,c210001105.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if thg:GetCount()>0 then
		Duel.SendtoHand(thg,nil,REASON_EFFECT)
	end
end
function c210001105.dmcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and c210001105.rth
end
function c210001105.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function c210001105.dmtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function c210001105.dmoperation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function c210001105.rthtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c~=chkc and c210001105.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210001105.thfilter,tp,LOCATION_MZONE,0,1,c) end
	Duel.SelectTarget(tp,c210001105.thfilter,tp,LOCATION_MZONE,0,1,1,c)
end
function c210001105.rthoperation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
