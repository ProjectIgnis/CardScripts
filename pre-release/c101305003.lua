--エルフの聖賢者
--Mystical Celtic Sage
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can activate this effect; you can only Special Summon from the Extra Deck once for the rest of this turn, also reveal your entire hand, and if there is a card that mentions "Ritual of Light and Darkness" in it, you can draw 3 cards, then discard 2 cards
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetTarget(s.drtg)
	e1a:SetOperation(s.drop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--You can Tribute this card; Special Summon 1 Ritual Monster that mentions "Ritual of Light and Darkness" from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfTribute)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_RITUAL_OF_LIGHT_AND_DARKNESS}
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
	--You can only Special Summon from the Extra Deck once for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.sprestrictioncon)
	e1:SetOperation(s.sprestrictionop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) then return end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	if g:IsExists(Card.ListsCode,1,nil,CARD_RITUAL_OF_LIGHT_AND_DARKNESS) and Duel.IsPlayerCanDraw(tp,3)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) and Duel.Draw(tp,3,REASON_EFFECT)==3 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,2,2,REASON_EFFECT|REASON_DISCARD)
	end
end
function s.sprestrictionconfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.sprestrictioncon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.sprestrictionconfilter,1,nil,tp)
end
function s.sprestrictionop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--You can only Special Summon from the Extra Deck once for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--"Clock Lizard" check
	aux.addTempLizardCheck(c,tp)
end
function s.spfilter(c,e,tp)
	return c:IsRitualMonster() and c:ListsCode(CARD_RITUAL_OF_LIGHT_AND_DARKNESS) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEUP)
	end
end