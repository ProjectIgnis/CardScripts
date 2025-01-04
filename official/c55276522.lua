--登竜華転生門
--Ryu-Ge War Zone
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Take 3 monsters from your Deck (1 Dinosaur, 1 Sea Serpent, and 1 Wyrm)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special Summon 3 "Ryu-Ge" monsters with different Types, 1 each from your Deck, GY, and banishment
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,92487128),tp,LOCATION_EXTRA,0,1,nil) end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={92487128} --"Sosei Ryu-Ge Mistva"
s.listed_series={SET_RYU_GE}
function s.thfilter(c)
	return c:IsRace(RACE_DINOSAUR|RACE_SEASERPENT|RACE_WYRM) and (c:IsAbleToHand() or c:IsAbleToRemove() or c:IsAbleToGrave())
end
function s.thcheck(sg,e,tp,mg)
	return sg:CheckDifferentProperty(Card.GetRace) and sg:FilterCount(Card.IsAbleToHand,nil)>=1
		and sg:FilterCount(Card.IsAbleToRemove,nil)>=1 and sg:FilterCount(Card.IsAbleToGrave,nil)>=1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,3,3,s.thcheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #sg>=3 then
		local g=aux.SelectUnselectGroup(sg,e,tp,3,3,s.thcheck,1,tp,aux.Stringid(id,2))
		if #g==3 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local hg=g:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
			if #hg>0 and Duel.SendtoHand(hg,nil,REASON_EFFECT)>0 then
				Duel.ConfirmCards(1-tp,hg)
				g=g-hg
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local rg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
				if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
					g=g-rg
					Duel.SendtoGrave(g,REASON_EFFECT)
				end
			end
		end
	end
	--You cannot Special Summon for the rest of this turn, except Dragon, Dinosaur, Sea Serpent, and Wyrm monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsRace(RACE_DRAGON|RACE_DINOSAUR|RACE_SEASERPENT|RACE_WYRM) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_RYU_GE) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcheck(sg,e,tp)
	return sg:CheckDifferentProperty(Card.GetLocation) and sg:CheckDifferentProperty(Card.GetRace)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and aux.SelectUnselectGroup(g,e,tp,3,3,s.spcheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
	if #g<3 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	if #sg==3 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end