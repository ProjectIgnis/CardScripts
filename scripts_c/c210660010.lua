--Wicked Altar
--concept by Gideon
--scripted by Larry126 and Lyris
function c210660010.initial_effect(c)
	--
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(210660010)
	e0:SetValue(SUMMON_TYPE_NORMAL)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c210660010.reg)
	e1:SetCondition(c210660010.accon)
	c:RegisterEffect(e1)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80921533,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c210660010.target)
	e2:SetOperation(c210660010.operation)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1315120,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c210660010.thcon)
	e2:SetCost(c210660010.thcost)
	e2:SetTarget(c210660010.thtg)
	e2:SetOperation(c210660010.thop)
	c:RegisterEffect(e2)
	--disable spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
end
function c210660010.reg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(210660010,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c210660010.accon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c210660010.otfilter(c,tp)
    return c:IsAttackAbove(2000) and (c:IsControler(tp) or c:IsFaceup())
end
function c210660010.filter(c,se)
	if not c:IsSummonableCard() or not c:IsRace(RACE_FIEND) then return false end
    local mg=Duel.GetMatchingGroup(c210660010.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	local ex={c:GetCardEffect(EFFECT_LIMIT_SUMMON_PROC),c:GetCardEffect(EFFECT_LIMIT_SET_PROC)}
	for _,te in ipairs(ex) do
		if type(te:GetCondition())=='function' then return te:GetCondition()(se,c,0) or not Duel.CheckTribute(c,3) or not Duel.CheckTribute(c,1,1,mg) end
	end
	local mi,ma=c:GetTributeRequirement()
	return mi>0 and (c:IsSummonable(false,se) or c:IsMSetable(false,se))
end
function c210660010.get_targets(se,tp)
	local g=Duel.GetMatchingGroup(c210660010.filter,tp,LOCATION_HAND,0,nil,se)
	local minct=5
	local maxct=0
	local tc=g:GetFirst()
	while tc do
		local mi,ma=tc:GetTributeRequirement()
		if mi>0 and mi<minct then minct=mi end
		if ma>maxct then maxct=ma end
		local ex={tc:GetCardEffect(EFFECT_LIMIT_SUMMON_PROC),tc:GetCardEffect(EFFECT_LIMIT_SET_PROC)}
		for _,te in ipairs(ex) do
			if type(te:GetCondition())=='function' then
				local ct=3
				if tc:IsCode(23309606) then ct=1 end
				if ct<minct then minct=ct end
				if ct>maxct then maxct=ct end
			end
		end
		tc=g:GetNext()
	end
	return minct,maxct
end
function c210660010.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
function c210660010.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local se=e:GetLabelObject()
	if chk==0 then
		local mi,ma=c210660010.get_targets(se,tp)
		if mi==5 then return false end
		return Duel.IsExistingMatchingCard(c210660010.cfilter,tp,LOCATION_EXTRA,0,mi,nil)
	end
	local mi,ma=c210660010.get_targets(se,tp)
	local rg=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	if mi==ma then rg=Duel.SelectMatchingCard(tp,c210660010.cfilter,tp,LOCATION_EXTRA,0,mi,mi,nil)
	elseif ma>=3 and Duel.IsExistingMatchingCard(c210660010.cfilter,tp,LOCATION_EXTRA,0,3,nil) then
		rg=Duel.SelectMatchingCard(tp,c210660010.cfilter,tp,LOCATION_EXTRA,0,1,3,nil)
	else rg=Duel.SelectMatchingCard(tp,c210660010.cfilter,tp,LOCATION_EXTRA,0,1,1,nil) end
	local rc=Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
	e:SetLabel(rc)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c210660010.sfilter(c,se,ct)
	if not c:IsSummonableCard() then return false end
    local mg=Duel.GetMatchingGroup(c210660010.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	local ex={c:GetCardEffect(EFFECT_LIMIT_SUMMON_PROC),c:GetCardEffect(EFFECT_LIMIT_SET_PROC)}
	for _,te in ipairs(ex) do
		if type(te:GetCondition())=='function' then return te:GetCondition()(se,c,0) or not Duel.CheckTribute(c,3) or not Duel.CheckTribute(c,1,1,mg) end
	end
	local mi,ma=c:GetTributeRequirement()
	return (mi==ct or ma==ct) and (c:IsSummonable(false,se) or c:IsMSetable(false,se))
end
function c210660010.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ct=e:GetLabel()
	local se=e:GetLabelObject()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c210660010.sfilter,tp,LOCATION_HAND,0,1,1,nil,se,ct)
	local tc=g:GetFirst()
	if tc then
		local s1=tc:IsSummonable(false,se)
		local s2=tc:IsMSetable(false,se)
		local mg=Duel.GetMatchingGroup(c210660010.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
		local ex1,ex2={tc:GetCardEffect(EFFECT_LIMIT_SUMMON_PROC)},{tc:GetCardEffect(EFFECT_LIMIT_SET_PROC)}
		for _,te in ipairs(ex1) do
			if type(te:GetCondition())=='function' then s1=s1 or te:GetCondition()(se,tc,0) or not Duel.CheckTribute(tc,3) or not Duel.CheckTribute(tc,1,1,mg) end
		end
		for _,te in ipairs(ex2) do
			if type(te:GetCondition())=='function' then s2=s2 or te:GetCondition()(se,tc,0) or not Duel.CheckTribute(tc,3) or not Duel.CheckTribute(tc,1,1,mg) end
		end
		if s1 and s2 then
			local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
			if pos==POS_FACEUP_ATTACK or not s2 then
				Duel.Summon(tp,tc,false,se)
			else
				Duel.MSet(tp,tc,false,se)
			end
			if tc:IsLocation(LOCATION_HAND) then
				if tc:IsCode(23309606) then
					local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
					hg:RemoveCard(tc)
					Duel.SendtoGrave(hg,REASON_COST+REASON_DISCARD)
				end
				Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,pos,true)
				local event=EVENT_MSET
				if pos==POS_FACEUP_ATTACK then event=EVENT_SUMMON_SUCCESS end
				Duel.RaiseEvent(tc,event,se,REASON_EFFECT,tp,tp,0)
			end
		end
	end
end
function c210660010.thcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		and e:GetHandler():GetFlagEffect(210660010)==0
end
function c210660010.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function c210660010.thfilter(c)
	return ((c:IsSetCard(0xf66) and c:IsType(TYPE_MONSTER)) or c:IsCode(21208154,57793869,62180201)) and c:IsAbleToHand()
end
function c210660010.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210660010.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c210660010.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c210660010.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffect(e1)
	end
end