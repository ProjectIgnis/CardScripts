--覚醒の三幻魔
--Sacred Beast Awakening
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--gain LP (extra handling from Ghost Sister & Spooky Dogwood 儚無みずき)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.reccon1)
	e2:SetOperation(s.recop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4,tp)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(s.reccon2)
	e5:SetOperation(s.recop2)
	c:RegisterEffect(e5,tp)
	e4:SetLabelObject(e5)
	--Negate effect
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(s.discon)
	e6:SetOperation(s.disop)
	c:RegisterEffect(e6)
	--Banish
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(0,0xff)
	e7:SetValue(LOCATION_REMOVED)
	e7:SetCondition(s.rmcon)
	e7:SetTarget(s.rmtg)
	c:RegisterEffect(e7)
	--Return to hand
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetCategory(CATEGORY_TOHAND)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCountLimit(1)
	e8:SetCost(s.thcon)
	e8:SetTarget(s.thtg)
	e8:SetOperation(s.thop)
	c:RegisterEffect(e8)
end
s.listed_names={69890967,6007213,32491822}
function s.sbfilter(c)
	return c:IsFaceup() and c:IsCode(69890967,6007213,32491822)
end
function s.sbcount(tp)
	return Duel.GetMatchingGroup(s.sbfilter,tp,LOCATION_ONFIELD,0,nil):GetClassCount(Card.GetCode)
end
function s.filter(c,sp)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:GetSummonPlayer()==sp
	else
		return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetSummonPlayer()==sp
	end
end
function s.reccon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp) and s.sbcount(tp)>0
		and (not re or (not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS)))
end
function s.sum(c)
	if c:IsLocation(LOCATION_MZONE) then
		return c:GetAttack()
	else
		return c:GetPreviousAttackOnField()
	end
end
function s.recop1(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter,nil,1-tp)
	if #g>0 then
		local sum=g:GetSum(s.sum)
		Duel.Hint(HINT_CARD,0,id)
		if Duel.Recover(tp,sum,REASON_EFFECT)~=0 then 
			Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp) and s.sbcount(tp)>0
		and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.filter,nil,1-tp)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	e:GetLabelObject():SetLabel(g:GetSum(s.sum)+e:GetLabelObject():GetLabel())
end
function s.reccon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0 
end
function s.recop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.ResetFlagEffect(tp,id)
	local rec=e:GetLabel()
	e:SetLabel(0)
	Duel.Hint(HINT_CARD,0,id)
	if Duel.Recover(tp,rec,REASON_EFFECT)~=0 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and rp==1-tp and s.sbcount(tp)>1
	and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return s.sbcount(e:GetHandlerPlayer())>2
end
function s.rmtg(e,c)
	return c:IsType(TYPE_MONSTER) and c:GetOwner()~=e:GetHandlerPlayer() and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsLevel,10),tp,LOCATION_MZONE,0,1,nil)
end
function s.thfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) 
		and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
