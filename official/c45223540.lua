--沼地の魔道王
--Magical King of the Swamp
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is in your hand: You can reveal 1 Fusion Monster in your Extra Deck and banish 1 material whose name is mentioned on it from your Deck, then Special Summon this card, and its name can be treated as the banished monster's if used as Fusion Material this turn. You can only use this effect of "Magical King of the Swamp" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.revealfilter(c,tp)
	return c:IsFusionMonster() and c.material and Duel.IsExistingMatchingCard(s.banfilter,tp,LOCATION_DECK,0,1,nil,c.material)
end
function s.banfilter(c,codes)
	return c:IsCode(codes) and c:IsAbleToRemove()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local reveal_card=Duel.SelectMatchingCard(tp,s.revealfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if not reveal_card then return end
	Duel.ConfirmCards(1-tp,reveal_card)
	Duel.ShuffleExtra(tp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local banish_card=Duel.SelectMatchingCard(tp,s.banfilter,tp,LOCATION_DECK,0,1,1,nil,reveal_card.material):GetFirst()
	if banish_card and Duel.Remove(banish_card,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
			--Its name can be treated as the banished monster's if used as Fusion Material this turn
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_ADD_CODE)
			e1:SetValue(banish_card:GetOriginalCodeRule())
			e1:SetOperation(function(scard,sumtype,tp) return (sumtype&MATERIAL_FUSION)>0 or (sumtype&SUMMON_TYPE_FUSION)>0 end)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end