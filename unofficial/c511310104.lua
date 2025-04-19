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
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.actcon)
	e2:SetTarget(s.acttg)
	e2:SetOperation(s.actop)
	c:RegisterEffect(e2)
	--Activate between Infinity
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCondition(s.infcon)
	e3:SetTarget(s.inftg)
	e3:SetOperation(s.infop)
	c:RegisterEffect(e3)
end
s.listed_names={511310100,511310105}
s.darkfilter=aux.FaceupFilter(Card.IsCode,511310100)
s.inffilter=aux.FaceupFilter(Card.IsCode,511310105)
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.darkfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and not Duel.IsExistingMatchingCard(s.inffilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.actfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_SZONE,0,1,nil)
	and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,0)
end
function s.getflag(g,tp)
	local flag = 0
	for c in aux.Next(g) do
		flag = flag|((1<<c:GetSequence())<<(8+(16*c:GetControler())))
	end
	if tp~=0 then
		flag=((flag<<16)&0xffff)|((flag>>16)&0xffff)
	end
	return ~flag
end
function s.SelectCardByZone(g,tp,hint)
	if hint then Duel.Hint(HINT_SELECTMSG,tp,hint) end
	local sel=Duel.SelectFieldZone(tp,1,LOCATION_SZONE,0,s.getflag(g,tp))>>8
	local seq=math.log(sel,2)
	local c=Duel.GetFieldCard(tp,LOCATION_SZONE,seq)
	return c
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ag=Duel.GetMatchingGroup(s.actfilter,tp,LOCATION_SZONE,0,nil)
	if #ag==0 then return end
	--workaround to not reveal card names
	local ac=s.SelectCardByZone(ag,tp,HINTMSG_RESOLVEEFFECT)
	if ac then
		--Force activation
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_CHAIN_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(ac)
		e1:SetOperation(s.faop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.faop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or tc:IsFaceup() or not tc:IsLocation(LOCATION_SZONE) then return end
	local te=tc:GetActivateEffect()
	local tep=tc:GetControler()
	if te and te:GetCode()==EVENT_FREE_CHAIN and te:IsActivatable(tep)
		and (not tc:IsSpell() or tc:IsType(TYPE_QUICKPLAY)) then
		Duel.Activate(te)
	end
	e:Reset()
end
function s.infcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.darkfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.inffilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.infacfilter(c,left,right)
	local seq=c:GetSequence()
	return c:IsFacedown() and left<seq and seq<right and c:CheckActivateEffect(false,false,false)
end
function s.inftg(e,tp,eg,ep,ev,re,rs,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:GetFlagEffect(id)~=0 then return false end
		local ig=Duel.GetMatchingGroup(s.inffilter,tp,LOCATION_SZONE,0,nil)
		--find furthest "Infinity" for maximum number of potential activated cards
		local left=c:GetSequence()
		local ic=ig:GetMaxGroup(function(oc,seq)return math.abs(oc:GetSequence()-seq)end,left):GetFirst()
		if not ic then return false end
		local right=ic:GetSequence()
		if left>right then left,right=right,left end
		return Duel.IsExistingMatchingCard(s.infacfilter,tp,LOCATION_SZONE,0,1,nil,left,right)
	end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,0)
end
function s.acinffilter(c,left,tp)
	local right=c:GetSequence()
	if left>right then left,right=right,left end
	return c:IsFaceup() and c:IsCode(511310105) and Duel.IsExistingMatchingCard(s.infacfilter,tp,LOCATION_SZONE,0,1,nil,left,right)
end
function s.infop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local left=c:GetSequence()
	local ig=Duel.GetMatchingGroup(s.acinffilter,tp,LOCATION_SZONE,0,nil,left,tp)
	local ic
	if #ig==1 then
		ic=ig:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		ic=ig:Select(tp,1,1,nil):GetFirst()
	end
	if not ic then return end
	local right=ic:GetSequence()
	if left>right then left,right=right,left end
	local ag=Duel.GetMatchingGroup(s.infacfilter,tp,LOCATION_SZONE,0,nil,left,right)
	if #ag>0 then
		Duel.ChangePosition(ag,POS_FACEUP)
		for ac in aux.Next(ag) do
			Duel.RaiseSingleEvent(ac,EVENT_CUSTOM+id,e,0,tp,tp,0)
		end
	end
end