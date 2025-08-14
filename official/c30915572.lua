--星見獣ガリス
--Gallis the Star Beast
local s,id=GetID()
function s.initial_effect(c)
	--Send the top card of your Deck to the GY, also, after that, if it was a monster in the Deck, inflict damage to your opponent equal to that monster's Level x 200, also Special Summon this card, otherwise destroy this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,c,1,tp,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local top_c=Duel.GetOperatedGroup():GetFirst()
	if not top_c then return end
	local c=e:GetHandler()
	if top_c:IsMonster() then
		Duel.BreakEffect()
		Duel.Damage(1-tp,top_c:GetOriginalLevel()*200,REASON_EFFECT)
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif c:IsRelateToEffect(e) then
		Duel.Destroy(c,REASON_EFFECT)
	end
end