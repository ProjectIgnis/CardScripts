--マテリアクトル・エクサガルド
--Materiactor Exagard
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 3 monsters
	Xyz.AddProcedure(c,nil,3,2,nil,nil,Xyz.InfiniteMats)
	--Special Summon 1 "Materiactor" monster from your Deck, OR add 1 "Materiactor" Spell/Trap from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.Detach(1,1,nil))
	e1:SetTarget(s.deckspthtg)
	e1:SetOperation(s.deckspthop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Add up to 2 cards attached to this card to your hand, including at least 1 "Materiactor" card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	e2:SetTarget(s.xyzthtg)
	e2:SetOperation(s.xyzthop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MATERIACTOR}
function s.deckspthfilter(c,e,tp,mmz_chk)
	return c:IsSetCard(SET_MATERIACTOR) and ((c:IsMonster() and mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
		or (c:IsSpellTrap() and c:IsAbleToHand()))
end
function s.deckspthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckspthfilter,tp,LOCATION_DECK,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.deckspthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc=Duel.SelectMatchingCard(tp,s.deckspthfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE)>0):GetFirst()
	if not sc then return end
	if sc:IsMonster() then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	elseif sc:IsSpellTrap() then
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
	end
end
function s.xyzthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local og=c:GetOverlayGroup():Filter(Card.IsAbleToHand,nil)
	if chk==0 then return c:IsType(TYPE_XYZ) and og:IsExists(Card.IsSetCard,1,nil,SET_MATERIACTOR) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,og,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_MATERIACTOR)
end
function s.xyzthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsType(TYPE_XYZ)) then return end
	local og=c:GetOverlayGroup():Filter(Card.IsAbleToHand,nil)
	if #og==0 then return end
	local sg=aux.SelectUnselectGroup(og,e,tp,1,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)
		if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_NORMAL)
			and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local rthg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			if #rthg==0 then return end
			Duel.HintSelection(rthg)
			Duel.BreakEffect()
			Duel.SendtoHand(rthg,nil,REASON_EFFECT)
		end
	end
end
