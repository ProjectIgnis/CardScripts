--連慄砲固定式
--Simultaneous Equation Cannons
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.rmfilter(c,tp)
	return (c:IsType(TYPE_FUSION) or (c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(function(_c) return _c:IsType(TYPE_XYZ) and _c:IsRank(c:GetRank()) end,tp,LOCATION_EXTRA,0,1,c)))
		and c:IsAbleToRemove()
end
function s.rmrescon(ct)
	return  function(sg,e,tp,mg)
				if not (#sg==3 and sg:IsExists(Card.IsType,2,nil,TYPE_XYZ)
					and sg:IsExists(Card.IsType,1,nil,TYPE_FUSION)
					and sg:Filter(Card.IsType,nil,TYPE_XYZ):GetClassCount(Card.GetRank)==1) then return false end
				local lvsum=sg:GetSum(Card.GetLevel)
				local rnksum=sg:GetSum(Card.GetRank)
				return lvsum+rnksum==ct
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD|LOCATION_HAND,LOCATION_ONFIELD|LOCATION_HAND)
		local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_EXTRA,0,nil,tp)
		return aux.SelectUnselectGroup(g,e,tp,3,3,s.rmrescon(ct),0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,2,tp,LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.texfilter(c)
	return c:IsType(TYPE_FUSION|TYPE_XYZ) and c:IsFaceup() and c:IsAbleToExtra()
end
function s.texrescon(sg,e,tp,mg)
	if not (#sg==2 and sg:IsExists(Card.IsType,1,nil,TYPE_XYZ)
		and sg:IsExists(Card.IsType,1,nil,TYPE_FUSION)) then return false end
	local lvsum=sg:GetSum(Card.GetLevel)
	local rnksum=sg:GetSum(Card.GetRank)
	return Duel.IsExistingMatchingCard(s.lvrnkmatchfilter,tp,0,LOCATION_MZONE,1,nil,lvsum+rnksum)
end
function s.lvrnkmatchfilter(c,lvrnk)
	return c:IsFaceup() and (c:IsLevel(lvrnk) or c:IsRank(lvrnk))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD|LOCATION_HAND,LOCATION_ONFIELD|LOCATION_HAND)
	local exrmg=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_EXTRA,0,nil,tp)
	if #exrmg<3 then return end
	local rg=aux.SelectUnselectGroup(exrmg,e,tp,3,3,s.rmrescon(ct),1,tp,HINTMSG_REMOVE)
	if not (#rg==3 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==3) then return end
	local opp_rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if #opp_rg==0 then return end
	local rmtexg=Duel.GetMatchingGroup(s.texfilter,tp,LOCATION_REMOVED,0,nil)
	if not (#rmtexg>=2 and aux.SelectUnselectGroup(rmtexg,e,tp,2,2,s.texrescon,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
	local texg=aux.SelectUnselectGroup(rmtexg,e,tp,2,2,s.texrescon,1,tp,HINTMSG_TODECK)
	if #texg~=2 then return end
	Duel.HintSelection(texg,true)
	Duel.BreakEffect()
	if Duel.SendtoDeck(texg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==2 then 
		Duel.BreakEffect()
		Duel.Remove(opp_rg,POS_FACEUP,REASON_EFFECT)
	end
end