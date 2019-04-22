--Subverted Reirrac
function c210001107.initial_effect(c)
	--cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCountLimit(1,210001110)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetCondition(c210001107.sprcondition)
	e2:SetOperation(c210001107.sproperation)
	c:RegisterEffect(e2)
	--damage+reveal
	local e3=Effect.CreateEffect(c)
	e3:SetCountLimit(1,210001111)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCondition(c210001107.dmcondition)
	e3:SetCost(c210001107.dmcost)
	e3:SetTarget(c210001107.dmtarget)
	e3:SetOperation(c210001107.dmoperation)
	c:RegisterEffect(e3)
	--destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetCountLimit(1)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c210001107.destg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--global effect
	if not c210001107.gchk then
		c210001107.gchk=true
		c210001107.rth=false
		--count when a subverted is returned to hand
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_HAND)
		ge1:SetOperation(c210001107.chk1)
		Duel.RegisterEffect(ge1,0)
		--reset
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(c210001107.chk2)
		Duel.RegisterEffect(ge2,0)
	end
end
function c210001107.chkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsCode(210001107)
end
function c210001107.chk1(e,tp,eg,ep,ev,re,r,rp)
	if eg and eg:IsExists(c210001107.chkfilter,1,nil) then
		c210001107.rth=true
	end
end
function c210001107.chk2(e,tp,eg,ep,ev,re,r,rp)
	c210001107.rth=false
end
function c210001107.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xfed) and c:IsAbleToHandAsCost() and not c:IsCode(210001107)
end
function c210001107.sprcondition(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local mg=Duel.GetMatchingGroup(c210001107.sprfilter,tp,LOCATION_MZONE,0,nil)
	return ft>-1 and aux.SelectUnselectGroup(mg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function c210001107.sproperation(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local mg=Duel.GetMatchingGroup(c210001107.sprfilter,tp,LOCATION_MZONE,0,nil)
	local g=aux.SelectUnselectGroup(mg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RTOHAND)
	Duel.SendtoHand(g,nil,REASON_COST)
end
function c210001107.dmcondition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and c210001107.rth
end
function c210001107.dmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function c210001107.dmtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
function c210001107.dmoperation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function c210001107.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=eg:GetFirst()
	if chk==0 then return eg:GetCount()==1 and dc:IsFaceup() and dc:IsLocation(LOCATION_MZONE) 
		and dc:IsSetCard(0xfed) and not dc:IsReason(REASON_REPLACE) and dc:IsReason(REASON_BATTLE+REASON_EFFECT) 
		and dc:IsAbleToHand() end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		Duel.SendtoHand(dc,nil,REASON_EFFECT)
		return true
	else return false end
end
