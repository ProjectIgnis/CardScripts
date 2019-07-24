--Instant Cooking
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp,sum)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetLevel()<=sum and c:IsSetCard(0x1512)
end
function s.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,0,LOCATION_MZONE,nil)
	local sum=g:GetSum(Card.GetLevel)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp,sum) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,0,LOCATION_MZONE,nil)
	local sum=g:GetSum(Card.GetLevel)
	local spg=Group.CreateGroup()
	local sp=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp,sum)
	while ft>0 and #sp>0 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=sp:Select(tp,1,1,nil)
		spg:Merge(sg)
		sp:Sub(sg)
		sum=sum-sg:GetFirst():GetLevel()
		sp=sp:Filter(s.filter,nil,e,tp,sum)
		ft=ft-1
	end
	if #spg>0 then
		Duel.SpecialSummon(spg,0,tp,tp,false,false,POS_FACEUP)
	end
end
