--抹殺の指名者
--Crossout Designator
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Declare 1 card name; banish 1 of that declared card from your Main Deck, and if you do, negate its effects, as well as the activated effects and effects on the field of cards with the same original name, until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_DECK,0,1,nil) end
	local ids=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_DECK,0,nil):GetClass(Card.GetCode)
	local announce_filter=DF.IsCode(ids)
	Duel.AnnounceCard(tp,announce_filter)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	--if the opponent tries to overwrite the announced name,
	--they should be able to announce any Main Deck card's name,
	--since they don't know what cards are in the player's Deck
	e:GetChainData().announce_filter=function(_,p) return p==tp and announce_filter or DF.IsMainDeckCard() end
end
function s.rmfilter(c,ac)
	return c:IsCode(ac) and c:IsAbleToRemove()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil,cd.announced_card):GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
		local c=e:GetHandler()
		local code=tc:GetOriginalCodeRule()
		--Negate its effects, as well as the activated effects and effects on the field of cards with the same original name, until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
		e1:SetTarget(function(e,c) return c:IsOriginalCodeRule(code) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:GetHandler():IsOriginalCodeRule(code) end)
		e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		Duel.RegisterEffect(e3,tp)
	end
end
