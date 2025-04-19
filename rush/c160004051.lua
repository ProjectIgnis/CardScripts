-- トライアングル・リボーン
-- Triangle Reborn
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.cfilter(c,tp)
	return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_GRAVE,0,2,c,c:GetRace())
end
function s.cfilter2(c,race)
	return c:IsAbleToDeck() and c:IsRace(race)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return
		 Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
end
function s.spfilter(c,e,sp)
	return c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
function s.tdfilter(c,tp)
	return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_TODECK)
	if sg and #sg==3 then
		if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
			--effect
			if Duel.GetMatchingGroupCount(Card.IsAttackPos,tp,LOCATION_MZONE,0,nil)<1 then
				if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
				and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
					if #g>0 then
						Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			end
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetRace)==1
end