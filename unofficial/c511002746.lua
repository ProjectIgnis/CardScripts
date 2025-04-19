--高等紋章術 (Anime)
--Advanced Heraldry Art (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon using "Heraldic Beast" monsters in your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_HERALDIC_BEAST}
function s.xyzfilter(c,mg)
	return c:IsXyzSummonable(nil,mg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_HERALDIC_BEAST)
	if chk==0 then return #mg>0 and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,mg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local mg=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,SET_HERALDIC_BEAST)
	local xyzg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,mg)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,nil,mg)
	end
end