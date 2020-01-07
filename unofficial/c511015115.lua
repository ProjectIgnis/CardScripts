--Commander Covington (Manga)
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(s.regop2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(id+1)
	e3:SetLabelObject(e2)
	e3:SetTarget(s.destg2)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(id+1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTarget(s.destg)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
end
s.listed_names={58054262}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>1 and Duel.GetLocationCountFromEx(tp,tp,g)>0 end
	g:KeepAlive()
	e:SetLabelObject(g)
	local tc=Duel.GetFirstMatchingCard(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp)
	Duel.Overlay(tc,g)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x36)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	local g=e:GetLabelObject()
	g:KeepAlive()
	Duel.SetTargetCard(g)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_NEGATED)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	e1:SetLabelObject(e)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_CHAIN_DISABLED)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(id)
	e3:SetOperation(s.resetop)
	e3:SetLabelObject(g)
	e3:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e3,tp)
	e:SetLabelObject(nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(re:GetHandler(),id,e,REASON_EFFECT,tp,tp,0)
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	Duel.SendtoGrave(g,REASON_RULE)
end
function s.filter(c,e,tp)
	return c:IsCode(58054262) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local og=Duel.GetTargetCards(e)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then Duel.SendtoGrave(g,REASON_RULE) return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.Overlay(tc,og)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
		c:SetCardTarget(tc)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	else
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetCardTarget()
	Duel.RaiseSingleEvent(e:GetHandler(),id+1,e,REASON_EFFECT,tp,tp,0)
	if g and #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetCardTarget():FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsDisabled() and e:GetHandler():GetFlagEffect(id)>0 then
		Duel.RaiseEvent(e:GetHandler(),id+1,e,REASON_EFFECT,tp,tp,0)
		e:GetHandler():ResetFlagEffect(id)
	end
end
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()
	if chk==0 then return g and g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)>0 end
	local sg=g:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	e:GetLabelObject():SetLabelObject(nil)
	local spg=Group.CreateGroup()
	local tc=sg:GetFirst()
	while tc do
		local og=tc:GetOverlayGroup()
		if #og>0 then spg:Merge(og) end
		tc=sg:GetNext()
	end
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetCardTarget()
	if chk==0 then return #g and g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)>0 end
	local sg=g:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	local spg=Group.CreateGroup()
	local tc=sg:GetFirst()
	while tc do
		local og=tc:GetOverlayGroup()
		if #og>0 then spg:Merge(og) end
		tc=sg:GetNext()
	end
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		local spg=Group.CreateGroup()
		local tc=tg:GetFirst()
		while tc do
			local og=tc:GetOverlayGroup()
			if #og>0 then spg:Merge(og) end
			tc=tg:GetNext()
		end
		if Duel.Destroy(tg,REASON_EFFECT)>0 then
			Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
