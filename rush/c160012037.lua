-- スターキャット・デストロイニャー
-- Star Cat Destronya
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160012016,160012005)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end 
s.listed_names={160012016}
function s.tdfilter(c,tp)
	return c:IsMonster() and c:IsDefense(200) and c:IsAbleToDeckOrExtraAsCost()
end
function s.spfilter(c,e,tp)
	return c:IsDefense(200) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp,c)
end
function s.spfilter2(c,e,tp,tc)
	local g=Group.CreateGroup()
	local lvl=tc:GetLevel()
	g:AddCard(c)
	g:AddCard(tc)
	return c:IsDefense(200) and c:IsLevel(lvl) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,2,g,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spfilter3(c,e,tp)
	return c:IsDefense(200) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.lvfilter1(c,g)
	return g:IsExists(s.afilter2,1,c,c:GetLevel())
end
function s.afilter2(c,lvl)
	return c:IsLevel(lvl)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	local td=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,2,tp,HINTMSG_SELECT)
	Duel.HintSelection(td,true)
	if Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
		--group used to check if the summoned monsters are normal
		local tg=Group.CreateGroup()
			
		--summon
		local sg=Duel.GetMatchingGroup(s.spfilter3,tp,LOCATION_GRAVE,0,nil,e,tp)
		local dg=sg:Filter(s.lvfilter1,nil,sg)
		if #dg>=1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc1=dg:Select(tp,1,1,nil):GetFirst()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tc2=dg:FilterSelect(tp,s.afilter2,1,1,tc1,tc1:GetLevel()):GetFirst()
			tg:AddCard(tc1)
			tg:AddCard(tc2)
			Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
			Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
			Duel.SpecialSummonComplete()		
		end
		--normal check
		for tc in tg:Iter() do
			if tc:IsType(TYPE_NORMAL) and tc:IsFaceup() then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(2200)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end	
	end
end
function s.rescon(sg,e,tp,mg)
	local gg=(g-sg)
	return Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_GRAVE,0,1,sg,e,tp) and gg:GetClassCount(Card.GetLevel)~=#gg
end