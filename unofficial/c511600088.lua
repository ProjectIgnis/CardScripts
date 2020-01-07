--ＤＤＤ昇進
--D/D/D Advance
--scripted by Larry126
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
function s.cfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ) and c:IsAbleToExtraAsCost()
end
function s.spfilter(c,e,tp,g)
	return g:IsExists(s.chkfilter,1,nil,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.chkfilter(sc,c)
	local tpe=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ
	return c:IsRace(sc:GetRace()) and c:IsAttribute(sc:GetAttribute()) and c:GetType()&tpe==sc:GetType()&tpe
end
function s.rescon1(g)
	return	function(sg,e,tp,mg)
				local ct=#sg
				return aux.SelectUnselectGroup(g,e,tp,ct,ct,s.rescon2(sg),0)
			end
end
function s.rescon2(g)
	return	function(sg,e,tp,mg)
				local gtable={}
				g:ForEach(function(tc)
					table.insert(gtable,tc)
				end)
				return sg:IsExists(s.chk,1,nil,sg,Group.CreateGroup(),table.unpack(gtable))
			end
end
function s.chk(c,sg,g,sc,...)
	local tpe=TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ
	if not c:IsRace(sc:GetRace()) or not c:IsAttribute(sc:GetAttribute()) or c:GetType()&tpe~=sc:GetType()&tpe then return false end
	local res
	if ... then
		g:AddCard(c)
		res=sg:IsExists(s.chk,1,g,sg,g,...)
		g:RemoveCard(c)
	else
		res=true
	end
	return res
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCountFromEx(tp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,g)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return ft>0 and aux.SelectUnselectGroup(g,e,tp,nil,1,s.rescon1(sg),0)
	end
	local cg=aux.SelectUnselectGroup(g,e,tp,nil,ft,s.rescon1(sg),1,tp,HINTMSG_TODECK,s.rescon1(sg))
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
	local cg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local ct=#cg
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,cg)
	if Duel.GetLocationCountFromEx(tp)<ct or not aux.SelectUnselectGroup(sg,e,tp,ct,ct,s.rescon2(cg),0) then return end
	local spg=aux.SelectUnselectGroup(sg,e,tp,ct,ct,s.rescon2(cg),1,tp,HINTMSG_SPSUMMON)
	Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
end
