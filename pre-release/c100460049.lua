--ゴーストリック・スパンキー
--Ghostrick Spunkie
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be Normal Summoned, unless you control a "Ghostrick" monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_SUMMON)
	e0:SetCondition(function(e)
		return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_GHOSTRICK),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
	end)
	c:RegisterEffect(e0)
	--When your opponent activates a monster effect on the field (Quick Effect): You can Special Summon this card from your hand in face-down Defense Position, and if you do, place 1 "Ghostrick" Field Spell or "Ghostrick" Continuous Trap from your hand or Deck face-up on your field, then if your opponent has 5 or more cards in their GY, you can Special Summon 1 monster from your hand in face-down Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Once per turn: You can change this card to face-down Defense Position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GHOSTRICK}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Chain.IsTriggeringLocation(ev,LOCATION_MZONE)
end
function s.plfilter(c,tp,szone_chk)
	return c:IsSetCard(SET_GHOSTRICK) and (c:IsFieldSpell() or (c:IsContinuousTrap() and szone_chk)) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp,Duel.GetLocationCount(tp,LOCATION_SZONE)>0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
		Duel.ConfirmCards(1-tp,c)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local place_card=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp,Duel.GetLocationCount(tp,LOCATION_SZONE)>0):GetFirst()
		if not place_card then return end
		local place_location=place_card:IsFieldSpell() and LOCATION_FZONE or LOCATION_SZONE
		if Duel.MoveToField(place_card,tp,tp,place_location,POS_FACEUP,true)
			and Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=5 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and not c:HasFlagEffect(id) end
	c:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD_PHASE_END&~RESET_TURN_SET),0,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,tp,POS_FACEDOWN_DEFENSE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end