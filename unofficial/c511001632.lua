--オーバーレイ・リジェネレート
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct1=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)
	local ct2=Duel.GetMatchingGroupCount(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return ct1+ct2>0 and Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)>=ct1 
		and Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=ct2 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)
	if ct1<#g1 
		or ct2<#g2 then return end
	if #g1>0 then
		local og=Group.CreateGroup()
		for i=1,#g1 do
			local tc=Duel.GetFieldCard(tp,LOCATION_GRAVE,ct1-i)
			og:AddCard(tc)
		end
		while #og>0 and #g1>0 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local sgo=og:Select(tp,1,1,nil)
			og:Sub(sgo)
			local sg=g1:Select(tp,1,1,nil)
			g1:Sub(sg)
			Duel.Overlay(sg:GetFirst(),sgo)
		end
	end
	if #g2>0 then
		local og=Group.CreateGroup()
		for i=1,#g2 do
			local tc=Duel.GetFieldCard(1-tp,LOCATION_GRAVE,ct2-i)
			og:AddCard(tc)
		end
		while #og>0 and #g2>0 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local sgo=og:Select(1-tp,1,1,nil)
			og:Sub(sgo)
			local sg=g2:Select(1-tp,1,1,nil)
			g2:Sub(sg)
			Duel.Overlay(sg:GetFirst(),sgo)
		end
	end
end
