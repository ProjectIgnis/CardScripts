--Construct Element
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x3008}
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtra() and c:IsSetCard(0x3008)
end
function s.spfilter(c,e,tp,lv)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x3008) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local ct=Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)
	if ct>0 then
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and ct>1 then return end
		local gate=Duel.GetMetatable(CARD_SUMMON_GATE)
		local ect=gate and Duel.IsPlayerAffectedByEffect(tp,CARD_SUMMON_GATE) and gate[tp]
		if ect~=nil and ct>ect then return end
		local spg=Group.CreateGroup()
		local tc=sg:GetFirst()
		while tc do
			local sumg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
			sumg:Sub(spg)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local gc=sumg:FilterSelect(tp,Card.IsLevel,1,1,nil,tc:GetPreviousLevelOnField()):GetFirst()
			if gc then
				spg:AddCard(gc)
			end
			tc=sg:GetNext()
		end
		if #spg>0 and Duel.GetLocationCountFromEx(tp)>=#spg then
			Duel.SpecialSummon(spg,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		end
	end
end
