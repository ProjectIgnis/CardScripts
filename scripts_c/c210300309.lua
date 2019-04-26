--Youkai Rogue, Kabuki
function c210300309.initial_effect(c)
	aux.EnableDualAttribute(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210300309,0))
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCondition(function(e) return aux.bdocon(e) and aux.IsDualState(e) end)
	e1:SetOperation(c210300309.spop)
	c:RegisterEffect(e1)
	--on release
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c210300309.checkop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c210300309.rcon)
	e3:SetTarget(c210300309.rtg)
	e3:SetOperation(c210300309.rop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function c210300309.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(0,1)
	e1:SetTarget(c210300309.sumlimitr)
	e1:SetLabel(tc:GetRace())
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	end
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetTarget(c210300309.sumlimita)
	e2:SetLabel(tc:GetAttribute())
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetTarget(c210300309.sumlimitc)
	e3:SetLabel(tc:GetCode())
	Duel.RegisterEffect(e3,tp)
end
function c210300309.sumlimitr(e,c)
	return c:IsRace(race)
end
function c210300309.sumlimita(e,c)
	return c:IsAttribute(att)
end
function c210300309.sumlimitc(e,c)
	return c:IsCode(code)
end
function c210300309.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsDisabled() and c:IsDualState() and c:IsReason(REASON_RELEASE) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
function c210300309.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
function c210300309.spfilter(c)
	return c:GetCode()>210300300 and c:GetCode()<210300400 and not c:IsCode(210300309) and c:IsAbleToHand()
end
function c210300309.rtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(c210300309.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c210300309.rop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c210300309.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
