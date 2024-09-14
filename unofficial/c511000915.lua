--トゥーン・マスク (Anime)
--Toon Mask (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Toon version from your hand or Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--[Toon]=original
s.list={
[53183600]=CARD_BLUEEYES_W_DRAGON,
[38369349]=2964201,
[31733941]=CARD_REDEYES_B_DRAGON,
[7171149]=83104731,
[28112535]=81480460,
[28711704]=5405694,
[61190918]=78193831,
[79875176]=11384280,
[83629030]=CARD_CYBER_DRAGON,
[21296502]=CARD_DARK_MAGICIAN,
[90960358]=CARD_DARK_MAGICIAN_GIRL,
[42386471]=69140098,
[15270885]=78658564,
[64116319]=CARD_HARPIE_LADY,
[16392422]=10189126,
[65458948]=65570596,
[91842653]=CARD_SUMMONED_SKULL
}
function s.cfilter(c,tp)
	return c:IsType(TYPE_TOON) and Duel.GetMZoneCount(tp,c)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,nil,tp)
	Duel.Release(g,REASON_COST)
end
function s.toonfilter(c,code,e,tp)
	return (c.toonVersion==code or s.list[c:GetCode()]==code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tp~=ep and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return Duel.IsExistingMatchingCard(s.toonfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tc:GetCode(),e,tp) end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.toonfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tc:GetCode(),e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
