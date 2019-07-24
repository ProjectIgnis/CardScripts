--黒魔術のカーテン (Anime)
--Dark Magic Curtain (Anime)
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	local p=tp
	if Duel.IsExistingMatchingCard(s.spfilter,1-tp,LOCATION_DECK,0,1,nil,e,1-tp) 
		and Duel.SelectYesNo(1-tp,aux.Stringid(102380,0)) then
		Duel.PayLPCost(1-tp,math.floor(Duel.GetLP(1-tp)/2))
		p=tp+1
	end
	e:SetLabel(p)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) 
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(1-tp) end
	local p=e:GetLabel()
	if p~=tp then
		p=PLAYER_ALL
	end
	Duel.SetTargetPlayer(p)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,p==PLAYER_ALL and 2 or 1,p,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if p==PLAYER_ALL and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(1-tp,s.spfilter,1-tp,LOCATION_DECK,0,1,1,nil,e,1-tp)
		if #g>0 then
			Duel.SpecialSummonStep(g:GetFirst(),0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
	Duel.SpecialSummonComplete()
end