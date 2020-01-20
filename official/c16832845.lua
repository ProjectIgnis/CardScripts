--ファイナル・ギアス
--FInal Geas
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_TOGRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)	
	aux.GlobalCheck(s,function()
		s[0]=false
		s[1]=false
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=false
			s[1]=false
		end)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		if tc:GetOriginalLevel()>=7 and tc:IsPreviousLocation(LOCATION_MZONE) then
			s[tc:GetPreviousControler()]=true
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return s[0] and s[1]
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if g:FilterCount(Card.IsControler,nil,1-tp)==0 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,LOCATION_GRAVE)
	elseif g:FilterCount(Card.IsControler,nil,tp)==0 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,1-tp,LOCATION_GRAVE)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,PLAYER_ALL,LOCATION_GRAVE)
	end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLocation(LOCATION_REMOVED) and c:HasLevel()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(s.spfilter,nil,e,tp)
		if #og>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			local sg=og:GetMaxGroup(Card.GetLevel)
			if #sg>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				sg=sg:Select(tp,1,1,nil)
			end
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
