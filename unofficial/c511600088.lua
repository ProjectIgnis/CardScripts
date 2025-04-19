--ＤＤＤ昇進
--D/D/D Advance
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function s.cfilter(c,g,e,tp)
	if not c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) or not c:IsAbleToExtraAsCost() then return false end
	local exg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,c,e,tp)
	g:Merge(exg)
	return #exg>0
end
function s.spfilter(c,sc,e,tp)
	return s.chkfilter(sc,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.chkfilter(sc,c)
	local tpe=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ
	return c:IsRace(sc:GetRace()) and c:IsAttribute(sc:GetAttribute()) and c:GetType()&tpe==sc:GetType()&tpe
end
function s.rescon1(g)
	return function(sg,e,tp,mg)
				local ct=#sg
				return aux.SelectUnselectGroup(g,e,tp,ct,ct,s.rescon2(sg),0)
			end
end
function s.rescon2(g)
	return function(sg,e,tp,mg)
				local gtable={}
				g:ForEach(function(tc)
					table.insert(gtable,tc)
				end)
				return sg:IsExists(s.chk,1,nil,tp,sg,Group.CreateGroup(),table.unpack(gtable))
			end
end
function s.chk(c,tp,sg,g,sc,...)
	local tpe=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ
	if not s.chkfilter(sc,c) or Duel.GetLocationCountFromEx(tp,tp,nil,tpe)<#sg then return false end
	if not ... then return true end
	g:AddCard(c)
	local res=sg:IsExists(s.chk,1,g,tp,sg,g,...)
	g:RemoveCard(c)
	return res
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Group.CreateGroup()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil,sg,e,tp)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return aux.SelectUnselectGroup(g,e,tp,nil,nil,s.rescon1(sg),0)
	end
	local cg=aux.SelectUnselectGroup(g,e,tp,nil,nil,s.rescon1(sg),1,tp,HINTMSG_TODECK,s.rescon1(sg))
	cg:KeepAlive()
	Duel.SendtoDeck(cg,nil,0,REASON_COST)
	Duel.SetTargetCard(cg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,#cg,tp,LOCATION_EXTRA)
end
function s.filter(c,sc)
	return c:IsRace(sc:GetRace()) and c:IsAttribute(sc:GetAttribute())
		and c:IsType(sc:GetType()&(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local cg=Duel.GetTargetCards(e)
	local ct=#cg
	local sg=Group.CreateGroup()
	cg:ForEach(function(tc)
		sg:Merge(Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,tc,e,tp,cg))
	end)
	if not aux.SelectUnselectGroup(sg,e,tp,ct,ct,s.rescon2(cg),0) then return end
	local spg=aux.SelectUnselectGroup(sg,e,tp,ct,ct,s.rescon2(cg),1,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
end