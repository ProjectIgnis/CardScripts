--JP name
--GMX Applied Experiment #55
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Excavate the top cards of your Deck until you have excavated a "GMX" monster and a Dinosaur monster, lose 400 LP for each excavated card, then you can Fusion Summon 1 "GMX" Fusion Monster from your Extra Deck, using any excavated monsters as material, also shuffle the rest into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_GMX}
function s.gmxfilter(c,tp)
	return c:IsSetCard(SET_GMX) and c:IsMonster() and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_DECK,0,1,c,RACE_DINOSAUR)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gmxfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local deck_count=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if deck_count==0 then return end
	local gmx_g=Duel.GetMatchingGroup(s.gmxfilter,tp,LOCATION_DECK,0,nil,tp)
	local dino_g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_DECK,0,nil,RACE_DINOSAUR)
	if #gmx_g==0 or #dino_g==0 then
		Duel.ConfirmDecktop(tp,deck_count)
		Duel.SetLP(tp,Duel.GetLP(tp)-deck_count*400)
	else
		local gmx_c=gmx_g:GetMaxGroup(Card.GetSequence):GetFirst()
		local dino_c=dino_g:GetMaxGroup(Card.GetSequence):GetFirst()
		local excav_count=deck_count-math.min(gmx_c:GetSequence(),dino_c:GetSequence())
		Duel.ConfirmDecktop(tp,excav_count)
		Duel.SetLP(tp,Duel.GetLP(tp)-excav_count*400)
		local excav_monsters=Duel.GetDecktopGroup(tp,excav_count):Match(Card.IsMonster,nil)
		local fusion_params={
				fusfilter=function(c) return c:IsSetCard(SET_GMX) end,
				matfilter=aux.FALSE,
				extrafil=function(e,tp,mg) return excav_monsters end
			}
		if Fusion.SummonEffTG(fusion_params)(e,tp,eg,ep,ev,re,r,rp,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Fusion.SummonEffOP(fusion_params)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
	Duel.ShuffleDeck(tp)
end