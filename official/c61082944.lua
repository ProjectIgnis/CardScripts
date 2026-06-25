--霊力回復薬
--Spiritual Power Recovery Potion
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Banish any number of Spellcaster monsters and/or Spells from your GY; all monsters you currently control gain 200 ATK for each card banished this way, and if they do, you gain 400 LP for each card banished this way
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--During your Main Phase: You can banish this card from your GY; Special Summon any number of Spellcaster monsters with different Attributes from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_POSSESSED}
function s.atkcostfilter(c)
	return (c:IsRace(RACE_SPELLCASTER) or c:IsSpell()) and c:IsAbleToRemoveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkcostfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local max_count=Duel.GetMatchingGroupCount(s.atkcostfilter,tp,LOCATION_GRAVE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.atkcostfilter,tp,LOCATION_GRAVE,0,1,max_count,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(#g)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	local banish_count=e:GetLabel()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,tp,200*banish_count)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,400*banish_count)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local prev_atk=0
	local c=e:GetHandler()
	local banish_count=e:GetLabel()
	local atk=200*banish_count
	local atk_change_chk=false
	for atkc in g:Iter() do
		prev_atk=atkc:GetAttack()
		--All monsters you currently control gain 200 ATK for each card banished this way
		atkc:UpdateAttack(atk,RESET_EVENT|RESETS_STANDARD,c)
		if not atk_change_chk and atkc:GetAttack()>prev_atk then
			atk_change_chk=true
		end
	end
	if not atk_change_chk then return end
	Duel.Recover(tp,400*banish_count,REASON_EFFECT)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if #g==0 then return end
	local max_attribute_count=g:GetClassCount(Card.GetAttribute)
	ft=math.min(ft,max_attribute_count)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=aux.SelectUnselectGroup(g,e,tp,1,max_attribute_count,aux.dpcheck(Card.GetAttribute),1,tp,HINTMSG_SPSUMMON)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end