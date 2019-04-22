--Subverted Reyortsed
function c210001106.initial_effect(c)
	--cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e1)
	--damage effect
	local e2=Effect.CreateEffect(c)
	e2:SetCountLimit(1,210001108)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c210001106.dmcondition)
	e2:SetCost(c210001106.dmcost)
	e2:SetTarget(c210001106.dmtarget)
	e2:SetOperation(c210001106.dmoperation)
	c:RegisterEffect(e2)
	--target to special sumon
	local e3=Effect.CreateEffect(c)
	e3:SetCountLimit(1,210001109)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(c210001106.sdcondition)
	e3:SetCost(c210001106.sdcost)
	e3:SetTarget(c210001106.sdtarget)
	e3:SetOperation(c210001106.sdoperation)
	c:RegisterEffect(e3)
	--global effect
	if not c210001106.gchk then
		c210001106.gchk=true
		c210001106.rth=false
		--count when a subverted is returned to hand
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(c210001106.chk1)
		Duel.RegisterEffect(ge1,0)
		--reset
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c210001106.chk2)
		Duel.RegisterEffect(ge2,0)
	end
end
function c210001106.chkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsCode(210001106)
end
function c210001106.chk1(e,tp,eg,ep,ev,re,r,rp)
	if eg and eg:IsExists(c210001106.chkfilter,1,nil) then
		c210001106.rth=true
	end
end
function c210001106.chk2(e,tp,eg,ep,ev,re,r,rp)
	c210001106.rth=false
end
function c210001106.dmcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and c210001106.rth
end
function c210001106.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function c210001106.dmtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1200)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
function c210001106.dmoperation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function c210001106.sdcondition(e,tp,eg,ep,ev,re,r,rp)
	local phase=Duel.GetCurrentPhase()
	local turn_player=Duel.GetTurnPlayer()
	return (turn_player==tp and (phase==PHASE_MAIN1 or phase==PHASE_MAIN2)) or (turn_player==1-tp and phase>=PHASE_BATTLE_START and phase<=PHASE_BATTLE)
end
function c210001106.sdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_DISCARD+REASON_COST)
end
function c210001106.sfilter(c,e,tp)
	return c:IsSetCard(0xfed) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210001106.dfilter(c,e)
	return c:IsDestructable(e)
end
function c210001106.sdtarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c210001106.sfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and Duel.IsExistingTarget(c210001106.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,e) end
	local sg=Duel.GetMatchingGroup(c210001106.sfilter,tp,LOCATION_HAND,0,nil,e,tp)
	Duel.SelectTarget(tp,c210001106.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,0,0)
end
function c210001106.sdoperation(e,tp,eg,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sg=Duel.SelectMatchingCard(tp,c210001106.sfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if sg:GetCount()>0 and Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 and tc and tc:IsRelateToEffect(e) then
		local sc=sg:GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetCondition(c210001106.retcon)
		e1:SetOperation(c210001106.retop)
		sc:RegisterEffect(e1)
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function c210001106.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c210001106.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SendtoHand(c,nil,REASON_EFFECT)
end
