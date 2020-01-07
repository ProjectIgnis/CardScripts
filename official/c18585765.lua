--ボルテスター
--Voltester
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.lkfilter(c,oc)
	return c:GetLinkedGroup():IsContains(oc)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.lkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c) end
	local g=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.GetPointedGroup(g)
	local og=Group.CreateGroup()
	for tc in aux.Next(g) do
		local lg=tc:GetLinkedGroup()
		for lc in aux.Next(lg) do
			lc:RegisterFlagEffect(tc:GetFieldID(),RESET_CHAIN,0,0)
			og:AddCard(lc)
		end
	end
	return og
end
function s.idfilter(c,og)
	for tc in aux.Next(og) do
		if c:GetFlagEffect(tc:GetFieldID()) then
			return true
		end
	end
	return false
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.lkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
	if #g>0 then
		local lg=s.GetPointedGroup(g)
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			local og=Duel.GetOperatedGroup()
			g=lg:Filter(s.idfilter,c,og)
			while #g>0 do
				Duel.BreakEffect()
				lg=s.GetPointedGroup(g)
				Duel.Destroy(g,REASON_EFFECT)
				local og=Duel.GetOperatedGroup()
				g=lg:Filter(s.idfilter,c,og)
			end
		end
	end
end
