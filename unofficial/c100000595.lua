--無限
--Infinity
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
s.listed_names={100000590,100000594}
s.darkfilter=aux.FilterFaceupFunction(Card.IsCode,100000590)
s.zerofilter=aux.FilterFaceupFunction(Card.IsCode,100000594)
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.darkfilter,tp,LOCATION_ONFIELD,0,1,nil) 
		and not Duel.IsExistingMatchingCard(s.zerofilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.actfilter(c)
	return c:IsFacedown() and c:GetSequence()<5 and c:CheckActivateEffect()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_SZONE,0,1,nil) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ac=Duel.SelectMatchingCard(s.actfilter,tp,LOCATION_SZONE,0,1,1,nil):GetFirst()
	if ac then
		ae=ac:CheckActivateEffect()
		if ae then
			Duel.Activate(ae)
		end
	end
end
function s.infcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.darkfilter,tp,LOCATION_ONFIELD,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.zerofilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.infacfilter(c,left,right)
	local seq=c:GetSequence()
	return c:IsFacedown() and left<seq and seq<right and c:CheckActivateEffect()
end
function s.inftg(e,tp,eg,ep,ev,re,rs,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local ig=Duel.GetMatchingGroup(s.inffilter,tp,LOCATION_SZONE,0,nil)
		--find furthest "Zero" for maximum number of potential activated cards
		local left=c:GetSequence()
		local ic=ig:GetMaxGroup(function(oc,seq)return math.abs(oc:GetSequence()-seq)end,left)
		if not ic then return false
		local right=ic:GetSequence()
		if left>right then left,right=right,left end
		return Duel.IsExistingMatchingCard(s.infacfilter,tp,LOCATION_SZONE,0,1,nil,left,right)
	end
end
function s.acinffilter(c,left,tp)
	local right=c:GetSequence()
	if left>right then left,right=right,left end
	return c:IsFaceup() and c:IsCode(100000594) and Duel.IsExistingMatchingCard(s.infacfilter,tp,LOCATION_SZONE,0,1,nil,left,right)
end
function s.infop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local left=c:GetSequence()
	local Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local ic=Duel.SelectMatchingCard(tp,s.acinffilter,tp,LOCATION_SZONE,0,1,nil,left,tp):GetFirst()
	if not ic then return end
	local right=ic:GetSequence()
	if left>right then left,right=right,left end
	local ag=Duel.GetMatchingGroup(s.infacfilter,tp,LOCATION_SZONE,0,nil,left,right)
	while #ag>0 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVEEFFECT)
		local tg=ag:Select(tp,1,1,nil)
		ag:Sub(tg)
		local ac=tg:GetFirst()
		local ae=ac:CheckActivateEffect()
		ac:RegisterFlagEffect(100000594,RESET_PHASE+PHASE_END,0,0)
		Duel.Activate(ae)
	end
end