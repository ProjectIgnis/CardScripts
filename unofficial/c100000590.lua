--ダークネス
function c100000590.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c100000590.target)
	e1:SetOperation(c100000590.activate)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c100000590.descon)
	e2:SetOperation(c100000590.desop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(100000590,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetOperation(c100000590.setop)
	c:RegisterEffect(e3)
end
function c100000590.filter(c,code)
	return c:IsCode(code) and c:IsSSetable()
end
function c100000590.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDestructable()
end
function c100000590.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c100000590.filter,tp,0x03,0,1,nil,100000591)
		and Duel.IsExistingMatchingCard(c100000590.filter,tp,0x03,0,1,nil,100000592)
		and Duel.IsExistingMatchingCard(c100000590.filter,tp,0x03,0,1,nil,100000593)
		and Duel.IsExistingMatchingCard(c100000590.filter,tp,0x03,0,1,nil,100000594)
		and Duel.IsExistingMatchingCard(c100000590.filter,tp,0x03,0,1,nil,100000595) end
	local g=Duel.GetMatchingGroup(c100000590.desfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	
end
function c100000590.sfilter(c)
	return c:IsSSetable() and (c:IsCode(100000591) or c:IsCode(100000592) or c:IsCode(100000593) or c:IsCode(100000594) or c:IsCode(100000595))
end
function c100000590.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c100000590.desfilter,tp,LOCATION_ONFIELD,0,e:GetHandler())
	Duel.Destroy(g,REASON_EFFECT)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=4 then return end 
	Duel.BreakEffect()
	--darkness
	if Duel.GetMatchingGroupCount(c100000590.filter,tp,0x03,0,nil,100000591)==0 then return end 
	if Duel.GetMatchingGroupCount(c100000590.filter,tp,0x03,0,nil,100000592)==0 then return end 
	if Duel.GetMatchingGroupCount(c100000590.filter,tp,0x03,0,nil,100000593)==0 then return end 
	if Duel.GetMatchingGroupCount(c100000590.filter,tp,0x03,0,nil,100000594)==0 then return end 
	if Duel.GetMatchingGroupCount(c100000590.filter,tp,0x03,0,nil,100000595)==0 then return end 
	local sg=Duel.GetMatchingGroup(c100000590.sfilter,tp,0x03,0,nil)
	local s1=sg:RandomSelect(tp,1):GetFirst()
	Duel.SSet(tp,s1)
	sg:Remove(Card.IsCode,nil,s1:GetCode())
	Duel.BreakEffect()
	local s2=sg:RandomSelect(tp,1):GetFirst()
	Duel.SSet(tp,s2)
	sg:Remove(Card.IsCode,nil,s2:GetCode())
	Duel.BreakEffect()
	local s3=sg:RandomSelect(tp,1):GetFirst()
	Duel.SSet(tp,s3)
	sg:Remove(Card.IsCode,nil,s3:GetCode())
	Duel.BreakEffect()
	local s4=sg:RandomSelect(tp,1):GetFirst()
	Duel.SSet(tp,s4)
	sg:Remove(Card.IsCode,nil,s4:GetCode())
	Duel.BreakEffect()
	local s5=sg:RandomSelect(tp,1):GetFirst()
	Duel.SSet(tp,s5)
end
function c100000590.cfilter(c,tp)
	return c:GetPreviousControler()==tp and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c100000590.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c100000590.cfilter,1,nil,tp) and re:GetHandler()~=e:GetHandler()
end
function c100000590.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c100000590.desfilter,tp,LOCATION_ONFIELD,0,nil)
	Duel.Destroy(g,REASON_EFFECT)
end
function c100000590.setfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
function c100000590.setop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c100000590.setfilter,tp,LOCATION_ONFIELD,0,nil)
	local tc=g:GetFirst()
	while tc do
		Duel.ChangePosition(tc,POS_FACEDOWN)
		Duel.RaiseEvent(tc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		tc=g:GetNext()
	end
end
