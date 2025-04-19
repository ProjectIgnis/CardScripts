--コンタクト (Anime)
--Contact (Anime)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_ADJUST)
	e2:SetLabelObject(e1)
	e2:SetOperation(function(e) e:GetLabelObject():SetLabelObject(Duel.CreateToken(0,0)) e:Reset() end)
	Duel.RegisterEffect(e2,0)
end
s.listed_series={0x1e}
function s.spfilter(c,e,tp,id)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_CHRYSALIS),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then 
		if not (#g>0 and g:FilterCount(Card.IsAbleToGrave,nil)==#g) then return false end
		local tok=e:GetLabelObject()
		local tg=Group.CreateGroup()
		for c in aux.Next(g) do
			if not c.listed_names then end
			for _,v in ipairs(c.listed_names) do
				tok:Recreate(v)
				if tok:IsMonster() then
					local tempg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp,v)
					if #tempg==0 then return false end
					tg:Merge(tempg)
				end
			end
		end
		return Duel.GetMZoneCount(tp,g)>=tg:GetClassCount(Card.GetCode)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_CHRYSALIS),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local sg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		if #sg==0 then return end
		local tok=e:GetLabelObject()
		local tg=Group.CreateGroup()
		for c in aux.Next(sg) do
			if not c.listed_names then end
			for _,v in ipairs(c.listed_names) do
				tok:Recreate(v)
				if tok:IsMonster() then
					local tempg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp,v)
					if #tempg==0 then return end
					tg:Merge(tempg)
				end
			end
		end
		local ct=tg:GetClassCount(Card.GetCode)
		if Duel.GetMZoneCount(tp,g)>=ct then
			local spg=aux.SelectUnselectGroup(tg,e,tp,ct,ct,nil,1,tp,HINTMSG_SPSUMMON)
			Duel.SpecialSummon(spg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return #sg==#sg:GetClassCount(Card.GetCode)
end