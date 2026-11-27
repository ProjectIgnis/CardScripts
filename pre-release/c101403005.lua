--アマゾネスの鎖使い－死に際の鎖舞い－
--Amazoness Chain Master - Brink of Death Chain Dance
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If this card is sent to the GY and you have another "Amazoness" monster in your GY: You can pay 1000 LP; your opponent can choose 1 Level 10 monster in their Deck or Extra Deck, and if they do, you can Special Summon it to your field, ignoring its Summoning conditions, but neither player can activate its effects this turn. If they do not, you discard 1 random card from their hand. You can only use this effect of "Amazoness Chain Master - Brink of Death Chain Dance" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.PayLP(1000))
	e1:SetTarget(s.sphandestg)
	e1:SetOperation(s.sphandesop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_AMAZONESS}
function s.amazonessfilter(c)
	return c:IsSetCard(SET_AMAZONESS) and c:IsMonster()
end
function s.sphandestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.amazonessfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		and (Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0
		or Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0
		or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK|LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,0,1,1-tp,1)
end
function s.sphandesop(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	if Duel.IsExistingMatchingCard(Card.IsLevel,opp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,10)
		and (Duel.GetFieldGroupCount(opp,LOCATION_HAND,0)==0 or Duel.SelectYesNo(opp,aux.Stringid(id,1))) then
		Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_CONFIRM)
		local sc=Duel.SelectMatchingCard(opp,Card.IsLevel,opp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,10):GetFirst()
		if not sc then return end
		Duel.ConfirmCards(tp,sc)
		local shuffle_chk=true
		if sc:IsCanBeSpecialSummoned(e,0,tp,true,false) and ((sc:IsLocation(LOCATION_DECK) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) or Duel.GetLocationCountFromEx(tp,tp,nil,sc)>0)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			if Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
				shuffle_chk=false
				--Neither player can activate its effects this turn
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(3302)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				sc:RegisterEffect(e1)
			end
			Duel.SpecialSummonComplete()
		end
		if shuffle_chk then
			if sc:IsLocation(LOCATION_DECK) then
				Duel.ShuffleDeck(opp)
			elseif sc:IsLocation(LOCATION_EXTRA) then
				Duel.ShuffleExtra(opp)
			end
		end
	else
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		if #g==0 then return end
		local sg=g:RandomSelect(opp,1)
		Duel.SendtoGrave(sg,REASON_DISCARD|REASON_EFFECT)
	end
end