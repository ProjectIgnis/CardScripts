-- スプライト・スマッシャーズ
-- Splight Smashers
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.actcost)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end
s.listed_series={0x158,0x17b,0x280}
function s.actcostfilter(c,tp,dsp,gg,rg)
	if not ((c:IsSetCard(0x158) or c:IsSetCard(0x17b) or c:IsSetCard(0x280)) and c:IsAbleToRemoveAsCost() 
		and (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c,true))) then return false end
	return (Duel.GetMZoneCount(tp,c)>0 and (dsp or #(gg-c)>0)) or (rg and #(rg-c)>0)
end
function s.spfilter(c,e,tp,set)
	return c:IsSetCard(set) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmfilter(c,tp)
	return c:IsAbleToRemove() and c:IsFaceup() and (c:IsLevel(2) or c:IsRank(2) or c:IsLink(2))
end
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local dsp=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,0x158)
	local gg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,0x17b)
	local rg=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil) or nil
	if chk==0 then return Duel.IsExistingMatchingCard(s.actcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,tp,dsp,gg,rg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local cg=Duel.SelectMatchingCard(tp,s.actcostfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,tp,dsp,gg,rg)
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local op=aux.SelectEffect(tp,
		{ft>0 and dsp,aux.Stringid(id,1)},
		{ft>0 and #(gg-cg)>0,aux.Stringid(id,2)},
		{rg and #(rg-cg)>0,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 or op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,op==1 and LOCATION_DECK or LOCATION_GRAVE)
	elseif op==3 then
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg-cg,2,PLAYER_ALL,LOCATION_ONFIELD)
	else
		e:SetCategory(0)
	end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 or op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Group.CreateGroup()
		if op==1 then
			g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,0x158)
		else
			g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,0x17b)
		end
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==3 then
		local rg1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
		if #rg1<=0 then return end
		local rg2=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_MZONE,0,nil)
		if #rg2<=0 then return end
		local g=aux.SelectUnselectGroup(rg1+rg2,e,tp,2,2,function(sg) return sg:GetClassCount(Card.GetControler)==2 end,1,tp,HINTMSG_REMOVE)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end