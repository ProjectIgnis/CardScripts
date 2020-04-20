--虚無
--Zero
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
	--Activate 1 Set Trap
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.actcon)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
	--Activate between Infinity
	local e3=e2:Clone()
	e3:SetCondition(s.infcon)
	e3:SetTarget(s.inftg)
	e3:SetOperation(s.infop)
	c:RegisterEffect(e3)
end
s.listed_names={100000590,100000595}
s.darkfilter=aux.FilterFaceupFunction(Card.IsCode,100000590)
s.inffilter=aux.FilterFaceupFunction(Card.IsCode,100000595)
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.darkfilter,tp,LOCATION_ONFIELD,0,1,nil) 
		and not Duel.IsExistingMatchingCard(s.inffilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.actfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_SZONE,0,1,nil) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ac=Duel.SelectMatchingCard(s.actfilter,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
	if ac then
		--Force activation
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_ADJUST)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.facon)
		e1:SetOperation(s.faop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.facon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end
function s.faop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or tc:IsFaceup() or not tc:IsLocation(LOCATION_SZONE) then return end
	local te=tc:GetActivateEffect()
	local tep=tc:GetControler()
	if te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep)
		and (not tc:IsType(TYPE_SPELL) or tc:IsType(TYPE_QUICKPLAY)) then
		Duel.Activate(te)
	else
	e:Reset()
end
function s.infcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.darkfilter,tp,LOCATION_ONFIELD,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.inffilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.infacfilter(c,left,right)
	local seq=c:GetSequence()
	return c:IsFacedown() and left<seq and seq<right and c:CheckActivateEffect()
end
function s.inftg(e,tp,eg,ep,ev,re,rs,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local ig=Duel.GetMatchingGroup(s.inffilter,tp,LOCATION_SZONE,0,nil)
		--find furthest "Infinity" for maximum number of potential activated cards
		local left=c:GetSequence()
		local ic=ig:GetMaxGroup(function(oc,seq)return math.abs(oc:GetSequence()-seq)end,left)
		if not ic then return false end
		local right=ic:GetSequence()
		if left>right then left,right=right,left end
		return Duel.IsExistingMatchingCard(s.infacfilter,tp,LOCATION_SZONE,0,1,nil,left,right)
	end
end
function s.acinffilter(c,left,tp)
	local right=c:GetSequence()
	if left>right then left,right=right,left end
	return c:IsFaceup() and c:IsCode(100000595) and Duel.IsExistingMatchingCard(s.infacfilter,tp,LOCATION_SZONE,0,1,nil,left,right)
end
function s.infop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local left=c:GetSequence()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local ic=Duel.SelectMatchingCard(tp,s.acinffilter,tp,LOCATION_SZONE,0,1,nil,left,tp):GetFirst()
	if not ic then return end
	local right=ic:GetSequence()
	if left>right then left,right=right,left end
	local ag=Duel.GetMatchingGroup(s.infacfilter,tp,LOCATION_SZONE,0,nil,left,right)
	if #ag==0 then return end
	ag:KeepAlive()
	--Force activation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EVENT_ADJUST)
	e1:SetCountLimit(1)
	e1:SetLabelObject(ag)
	e1:SetCondition(s.facon2)
	e1:SetOperation(s.faop2)
	Duel.RegisterEffect(e1,tp)
end
function s.facon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentChain()==0
end
function s.faop2(e,tp,eg,ep,ev,re,r,rp)
	local ag=e:GetLabelObject()
	while #ag>0 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVEEFFECT)
		local tg=ag:Select(tp,1,1,nil)
		ag:Sub(tg)
		local tc=tg:GetFirst()
		if tc and tc:IsFacedown() and tc:IsLocation(LOCATION_SZONE) then 
			local te=tc:GetActivateEffect()
			local tep=tc:GetControler()
			if te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep)
				and (not tc:IsType(TYPE_SPELL) or tc:IsType(TYPE_QUICKPLAY)) then
				tc:RegisterFlagEffect(100000594,RESET_PHASE+PHASE_END,0,0)
				Duel.Activate(ae)
			end
		end
	end
	ag:DeleteGroup()
	e:Reset()
end