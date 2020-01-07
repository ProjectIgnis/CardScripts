--Toon Mask
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- [Toon]=original 
s.list={
[53183600]=CARD_BLUEEYES_W_DRAGON,
[38369349]=2964201,
[31733941]=CARD_REDEYES_B_DRAGON,
[7171149]=83104731,
[28112535]=81480460,
[61190918]=78193831,
[79875176]=11384280,
[83629030]=CARD_CYBER_DRAGON,
[21296502]=CARD_DARK_MAGICIAN,
[90960358]=CARD_DARK_MAGICIAN_GIRL,
[42386471]=69140098,
[15270885]=78658564,
[16392422]=10189126,
[65458948]=65570596,
[91842653]=CARD_SUMMONED_SKULL
}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsType,1,false,nil,nil,TYPE_TOON) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsType,1,1,false,nil,nil,TYPE_TOON)
	Duel.Release(g,REASON_COST)
end
function s.toonfilter(c,code,e,tp)
	return (c.toonVersion==code or s.list[c:GetCode()]==code ) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and #eg==1 and Duel.GetCurrentChain()==0	
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #eg==1 
		and Duel.IsExistingTarget(s.toonfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tc:GetCode(),e,tp) end
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not tc then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.toonfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tc:GetCode(),e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
