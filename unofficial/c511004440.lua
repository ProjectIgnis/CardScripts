--Cubic Mandala (movie)
local s,id=GetID()
function s.initial_effect(c)
	local g=nil
	if not s.g then
		g=Group.CreateGroup()
		s.g=g
	else
		g=s.g
	end  
	g:KeepAlive()
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetLabelObject(g)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROY)
		ge1:SetOperation(s.gchk)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			g:Clear()
		end)
	end)
end
s.g=nil
function s.gchk(e,tp,eg,ev,ep,re,r,rp)
	local c=eg:GetFirst()
	local g=e:GetLabelObject()
	while c do
		if c:GetCounter(0x1038)~=0 then g:AddCard(c) end
		c=eg:GetNext()
	end
end
function s.sfilter(c,e,tp,g)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false) and (not g or g:IsContains(c))
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	local g=e:GetLabelObject()
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,0x30,0x30,nil,e,tp,g)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>=#g and #sg>0
		and #g==#sg and not (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #sg>1) end
	Duel.SetTargetCard(sg)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local og=e:GetLabelObject()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if #g>ft or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and #g>1) then return end
	if not #g==g:FilterCount(s.sfilter,nil,e,tp) or not #g==g:FilterCount(Card.IsRelateToEffect,nil,e) then return end
	local tc=g:GetFirst()
	local sg=Group.CreateGroup()
	while tc do
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_SPECIAL,tp,1-tp,true,false,POS_FACEUP) then
			--atk 0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			--disable
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetRange(LOCATION_MZONE)
			e2:SetTargetRange(0x16,0)
			e2:SetTarget(s.disable)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetCondition(s.disablecon)
			e2:SetLabel(1-tp)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			sg:AddCard(tc)
		end
		tc=g:GetNext()
	end
	Duel.SpecialSummonComplete()
	sg:KeepAlive()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetLabelObject(sg)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	if #g~=#sg then return end
	tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1038,1)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetCondition(s.lim)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE)
		tc:RegisterEffect(e2)
		c:SetCardTarget(tc)
		tc=g:GetNext()
	end
end
function s.disable(e,c)
	return c:IsType(TYPE_MONSTER)
end
function s.disablecon(e)
	return e:GetHandler():IsControler(e:GetLabel())
end
function s.lim(e)
	return e:GetHandler():GetCounter(0x1038)>0
end
function s.dfilter(c,sg)
	return sg:IsContains(c)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCardTargetCount()==0 then return false end
	local sg=e:GetLabelObject()
	local lg=sg:Filter(s.dfilter,nil,eg)
	sg:Sub(lg)
	return #sg==0
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end