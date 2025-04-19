--ハイブリッドライブ・バックフュージョン
--Hybridrive Back Fusion
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change Position and Fusion Summon
	local params={nil,s.mfilter,s.fextra,Fusion.ShuffleMaterial}
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation(Fusion.SummonEffTG(table.unpack(params)),Fusion.SummonEffOP(table.unpack(params))))
	c:RegisterEffect(e1)
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsAbleToDeck()
end
function s.fcheck(tp,sg,fc)
	local mg1=sg:Filter(Card.IsRace,nil,RACE_MACHINE)
	local mg2=sg:Filter(Card.IsRace,nil,RACE_DRAGON)
	return #sg==2 and #mg1==1 and #mg2==1
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil),s.fcheck
end
function s.cfilter(c)
	return c:IsMonster() and c:IsRace(RACE_DRAGON|RACE_MACHINE) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,4,nil) end
end
function s.filter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_GRAVE,1,nil,e,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_GRAVE)
end
function s.operation(fustg,fusop)
	return function(e,tp,eg,ep,ev,re,r,rp)
		--Requirement
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,4,4,nil)
		Duel.HintSelection(g)
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)<=0 then return end
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=Duel.SelectMatchingCard(1-tp,s.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,1-tp)
		if #sg>0 and Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)>0
			and fustg(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			fusop(e,tp,eg,ep,ev,re,r,rp)
			--Prevent non-Fusion from attacking
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_OATH)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetTarget(s.ftarget)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.ftarget(e,c)
	return not c:IsType(TYPE_FUSION)
end